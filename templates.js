import { Template } from "meteor/templating";
import { Blaze } from "meteor/blaze";
import { _ } from "meteor/underscore";

const acEvents = {
  "keydown": function(e, t) {
    return t.ac.onKeyDown(e);
  },
  "keyup": function(e, t) {
    return t.ac.onKeyUp(e);
  },
  "focus": function(e, t) {
    return t.ac.onFocus(e);
  },
  "blur": function(e, t) {
    return t.ac.onBlur(e);
  }
};

Template.inputAutocomplete.events(acEvents);

Template.textareaAutocomplete.events(acEvents);

const attributes = function() {
  return _.omit(this, 'settings');
};

const autocompleteHelpers = {
  attributes: attributes,
  autocompleteContainer: new Template('AutocompleteContainer', function() {
    const ac = new AutoComplete(Blaze.getData().settings);
    this.parentView.templateInstance().ac = ac;
    this.onViewReady(function() {
      ac.element = this.parentView.firstNode();
      return ac.$element = $(ac.element);
    });
    return Blaze.With(ac, function() {
      return Template._autocompleteContainer;
    });
  })
};

Template.inputAutocomplete.helpers(autocompleteHelpers);

Template.textareaAutocomplete.helpers(autocompleteHelpers);

Template._autocompleteContainer.rendered = function() {
  return this.data.tmplInst = this;
};

Template._autocompleteContainer.destroyed = function() {
  return this.data.teardown();
};


/*
  List rendering helpers
 */

Template._autocompleteContainer.events({
  "click .-autocomplete-item": function(e, t) {
    return t.data.onItemClick(this, e);
  },
  "mouseenter .-autocomplete-item": function(e, t) {
    return t.data.onItemHover(this, e);
  }
});

Template._autocompleteContainer.helpers({
  empty: function() {
    return this.filteredList().count() === 0;
  },
  noMatchTemplate: function() {
    return this.matchedRule().noMatchTemplate || Template._noMatch;
  }
});