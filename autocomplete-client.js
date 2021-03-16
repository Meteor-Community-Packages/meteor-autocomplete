import { Mongo } from "meteor/mongo";
import { Match } from "meteor/check";
import { _ } from "meteor/underscore";
import { Meteor } from "meteor/meteor";
import { Blaze } from "meteor/blaze";
import { Tracker } from "meteor/tracker";

const __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

export const AutoCompleteRecords = new Mongo.Collection("autocompleteRecords");

const isServerSearch = function(rule) {
  return (rule.subscription != null) || _.isString(rule.collection);
};

const validateRule = function(rule) {
  if ((rule.subscription != null) && (rule.collection != null)) {
    throw new Error("Rule cannot specify both a server-side subscription and a client/server collection to search simultaneously");
  }
  if (!((rule.subscription != null) || Match.test(rule.collection, Match.OneOf(String, Mongo.Collection)))) {
    throw new Error("Collection to search must be either a Mongo collection or server-side name");
  }
  if (rule.callback != null) {
    return console.warn("autocomplete no longer supports callbacks; use event listeners instead.");
  }
};

const isWholeField = function(rule) {
  return !rule.token;
};

const getRegExp = function(rule) {
  if (!isWholeField(rule)) {
    return new RegExp('(^|\\b|\\s)' + rule.token + '([\\w.]*)$');
  } else {
    return new RegExp('(^)(.*)$');
  }
};

const getFindParams = function(rule, filter, limit) {
  const selector = _.extend({}, rule.filter || {});
  const options = {
    limit: limit
  };
  if (!filter) {
    return [selector, options];
  }
  if (rule.sort && rule.field) {
    let sortspec = {};
    sortspec[rule.field] = 1;
    options.sort = sortspec;
  }
  if (_.isFunction(rule.selector)) {
    _.extend(selector, rule.selector(filter));
  } else {
    selector[rule.field] = {
      $regex: rule.matchAll ? filter : "^" + filter,
      $options: typeof rule.options === 'undefined' ? 'i' : rule.options
    };
  }
  return [selector, options];
};

const getField = function(obj, str) {
  let key, _i, _len;
  const _ref = str.split(".");
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    key = _ref[_i];
    obj = obj[key];
  }
  return obj;
};

export const AutoComplete = function() {
  AutoComplete.KEYS = [40, 38, 13, 27, 9];

  function AutoComplete(settings) {
    this.onItemClick = __bind(this.onItemClick, this);
    let rule, _i, _len;
    this.limit = settings.limit || 5;
    this.position = settings.position || "bottom";
    this.rules = settings.rules;
    const _ref = this.rules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      rule = _ref[_i];
      validateRule(rule);
    }
    this.expressions = (function() {
      let _j, _len1;
      const _ref1 = this.rules;
      const _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        rule = _ref1[_j];
        _results.push(getRegExp(rule));
      }
      return _results;
    }).call(this);
    this.matched = -1;
    this.loaded = true;
    this.ruleDep = new Tracker.Dependency();
    this.filterDep = new Tracker.Dependency();
    this.loadingDep = new Tracker.Dependency();
    this.sub = null;
    this.comp = new Tracker.autorun((function(_this) {
      return function() {
        let filter, _ref1, _ref2;
        if ((_ref1 = _this.sub) != null) {
          _ref1.stop();
        }
        if (!((rule = _this.matchedRule()) && (filter = _this.getFilter()) !== null)) {
          return;
        }
        if (!isServerSearch(rule)) {
          _this.setLoaded(true);
          return;
        }
        _ref2 = getFindParams(rule, filter, _this.limit)
        const selector = _ref2[0]
        const options = _ref2[1];
        _this.setLoaded(false);
        const subName = rule.subscription || "autocomplete-recordset";
        return _this.sub = Meteor.subscribe(subName, selector, options, rule.collection, function() {
          return _this.setLoaded(true);
        });
      };
    })(this));
  }

  AutoComplete.prototype.teardown = function() {
    return this.comp.stop();
  };

  AutoComplete.prototype.matchedRule = function() {
    this.ruleDep.depend();
    if (this.matched >= 0) {
      return this.rules[this.matched];
    } else {
      return null;
    }
  };

  AutoComplete.prototype.setMatchedRule = function(i) {
    this.matched = i;
    return this.ruleDep.changed();
  };

  AutoComplete.prototype.getFilter = function() {
    this.filterDep.depend();
    return this.filter;
  };

  AutoComplete.prototype.setFilter = function(x) {
    this.filter = x;
    this.filterDep.changed();
    return this.filter;
  };

  AutoComplete.prototype.isLoaded = function() {
    this.loadingDep.depend();
    return this.loaded;
  };

  AutoComplete.prototype.setLoaded = function(val) {
    if (val === this.loaded) {
      return;
    }
    this.loaded = val;
    return this.loadingDep.changed();
  };

  AutoComplete.prototype.onKeyUp = function() {
    let matches;
    if (!this.$element) {
      return;
    }
    const startpos = this.element.selectionStart;
    const val = this.getText().substring(0, startpos);

    /*
      Matching on multiple expressions.
      We always go from a matched state to an unmatched one
      before going to a different matched one.
     */
    let i = 0;
    let breakLoop = false;
    const _results = [];
    while (i < this.expressions.length) {
      matches = val.match(this.expressions[i]);
      if (!matches && this.matched === i) {
        this.setMatchedRule(-1);
        breakLoop = true;
      }
      if (matches && this.matched === -1) {
        this.setMatchedRule(i);
        breakLoop = true;
      }
      if (matches && this.filter !== matches[2]) {
        this.setFilter(matches[2]);
        breakLoop = true;
      }
      if (breakLoop) {
        break;
      }
      _results.push(i++);
    }
    return _results;
  };

  AutoComplete.prototype.onKeyDown = function(e) {
    if (this.matched === -1 || (this.constructor.KEYS.indexOf(e.keyCode) < 0)) {
      return;
    }
    switch (e.keyCode) {
      case 9:
      case 13:
        if (this.select()) {
          e.preventDefault();
          e.stopPropagation();
        }
        break;
      case 40:
        e.preventDefault();
        this.next();
        break;
      case 38:
        e.preventDefault();
        this.prev();
        break;
      case 27:
        this.$element.blur();
        this.hideList();
    }
  };

  AutoComplete.prototype.onFocus = function() {
    return Meteor.defer((function(_this) {
      return function() {
        return _this.onKeyUp();
      };
    })(this));
  };

  AutoComplete.prototype.onBlur = function() {
    return Meteor.setTimeout((function(_this) {
      return function() {
        return _this.hideList();
      };
    })(this), 500);
  };

  AutoComplete.prototype.onItemClick = function(doc, e) {
    return this.processSelection(doc, this.rules[this.matched]);
  };

  AutoComplete.prototype.onItemHover = function(doc, e) {
    this.tmplInst.$(".-autocomplete-item").removeClass("selected");
    return $(e.target).closest(".-autocomplete-item").addClass("selected");
  };

  AutoComplete.prototype.filteredList = function() {
    const filter = this.getFilter();
    if (this.matched === -1) {
      return null;
    }
    const rule = this.rules[this.matched];
    if (!(rule.token || filter)) {
      return null;
    }
    const _ref = getFindParams(rule, filter, this.limit)
    const selector = _ref[0]
    const options = _ref[1];
    Meteor.defer((function(_this) {
      return function() {
        return _this.ensureSelection();
      };
    })(this));
    if (isServerSearch(rule)) {
      return AutoCompleteRecords.find({}, options);
    }
    return rule.collection.find(selector, options);
  };

  AutoComplete.prototype.isShowing = function() {
    const rule = this.matchedRule();
    const showing = (rule != null) && (rule.token || this.getFilter());
    if (showing) {
      Meteor.defer((function(_this) {
        return function() {
          _this.positionContainer();
          return _this.ensureSelection();
        };
      })(this));
    }
    return showing;
  };

  AutoComplete.prototype.select = function() {
    const node = this.tmplInst.find(".-autocomplete-item.selected");
    if (node == null) {
      return false;
    }
    const doc = Blaze.getData(node);
    if (!doc) {
      return false;
    }
    this.processSelection(doc, this.rules[this.matched]);
    return true;
  };

  AutoComplete.prototype.processSelection = function(doc, rule) {
    const replacement = getField(doc, rule.field);
    if (!isWholeField(rule)) {
      this.replace(replacement, rule);
      this.hideList();
    } else {
      this.setText(replacement);
      this.onBlur();
    }
    this.$element.trigger("autocompleteselect", doc);
  };

  AutoComplete.prototype.replace = function(replacement) {
    const startpos = this.element.selectionStart;
    const fullStuff = this.getText();
    let val = fullStuff.substring(0, startpos);
    val = val.replace(this.expressions[this.matched], "$1" + this.rules[this.matched].token + replacement);
    const posfix = fullStuff.substring(startpos, fullStuff.length);
    const separator = (posfix.match(/^\s/) ? "" : " ");
    const finalFight = val + separator + posfix;
    this.setText(finalFight);
    const newPosition = val.length + 1;
    this.element.setSelectionRange(newPosition, newPosition);
  };

  AutoComplete.prototype.hideList = function() {
    this.setMatchedRule(-1);
    return this.setFilter(null);
  };

  AutoComplete.prototype.getText = function() {
    return this.$element.val() || this.$element.text();
  };

  AutoComplete.prototype.setText = function(text) {
    if (this.$element.is("input,textarea")) {
      return this.$element.val(text).change();
    } else {
      return this.$element.html(text);
    }
  };


  /*
    Rendering functions
   */

  AutoComplete.prototype.positionContainer = function() {
    let pos;
    const position = this.$element.position();
    const rule = this.matchedRule();
    const offset = getCaretCoordinates(this.element, this.element.selectionStart);
    if ((rule != null) && isWholeField(rule)) {
      pos = {
        left: position.left,
        width: this.$element.outerWidth()
      };
    } else {
      pos = {
        left: position.left + offset.left
      };
    }
    if (this.position === "top") {
      pos.bottom = this.$element.offsetParent().height() - position.top - offset.top;
    } else {
      pos.top = position.top + offset.top + parseInt(this.$element.css('font-size'));
    }
    return this.tmplInst.$(".-autocomplete-container").css(pos);
  };

  AutoComplete.prototype.ensureSelection = function() {
    const selectedItem = this.tmplInst.$(".-autocomplete-item.selected");
    if (!selectedItem.length) {
      return this.tmplInst.$(".-autocomplete-item:first-child").addClass("selected");
    }
  };

  AutoComplete.prototype.next = function() {
    const currentItem = this.tmplInst.$(".-autocomplete-item.selected");
    if (!currentItem.length) {
      return;
    }
    currentItem.removeClass("selected");
    const next = currentItem.next();
    if (next.length) {
      return next.addClass("selected");
    } else {
      return this.tmplInst.$(".-autocomplete-item:first-child").addClass("selected");
    }
  };

  AutoComplete.prototype.prev = function() {
    const currentItem = this.tmplInst.$(".-autocomplete-item.selected");
    if (!currentItem.length) {
      return;
    }
    currentItem.removeClass("selected");
    const prev = currentItem.prev();
    if (prev.length) {
      return prev.addClass("selected");
    } else {
      return this.tmplInst.$(".-autocomplete-item:last-child").addClass("selected");
    }
  };

  AutoComplete.prototype.currentTemplate = function() {
    return this.rules[this.matched].template;
  };

  return AutoComplete;
};

export const AutocompleteTest = {
  records: AutoCompleteRecords,
  isServerSearch: isServerSearch,
  getRegExp: getRegExp,
  getFindParams: getFindParams
};
