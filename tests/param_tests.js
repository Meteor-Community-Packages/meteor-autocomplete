import { AutocompleteTest } from "meteor/mizzao:autocomplete";

Tinytest.add("autocomplete - params - default case insensitive", function(test) {
  const rule = {
    field: "foo"
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  test.equal(sel.foo.$regex, "^blah");
  return test.equal(sel.foo.$options, "i");
});

Tinytest.add("autocomplete - params - limit", function(test) {
  const rule = {
    field: "foo"
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  return test.equal(opts.limit, 5);
});

Tinytest.add("autocomplete - params - match all", function(test) {
  const rule = {
    field: "foo",
    matchAll: true
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  return test.equal(sel.foo.$regex, "blah");
});

Tinytest.add("autocomplete - params - replace options", function(test) {
  const rule = {
    field: "foo",
    options: ""
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  test.equal(sel.foo.$regex, "^blah");
  return test.equal(sel.foo.$options, "");
});

Tinytest.add("autocomplete - params - no sort if filter empty", function(test) {
  const rule = {
    field: "foo"
  };
  const filter = "";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  return test.isFalse(opts.sort);
});

Tinytest.add("autocomplete - params - no sort by default", function(test) {
  const rule = {
    field: "foo"
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit)
  const sel = _ref[0];
  const opts = _ref[1];
  return test.isFalse(opts.sort);
});

Tinytest.add("autocomplete - params - sort if enabled and filter exists", function(test) {
  const rule = {
    field: "foo",
    sort: true
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  return test.equal(opts.sort.foo, 1);
});

Tinytest.add("autocomplete - params - incorporate filter", function(test) {
  const rule = {
    field: "foo",
    filter: {
      type: "autocomplete"
    }
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  test.equal(sel.type, "autocomplete");
  return test.isFalse(rule.filter.blah);
});

Tinytest.add("autocomplete - params - custom selector", function(test) {
  const rule = {
    selector: function(filter) {
      return {
        foo: filter
      };
    }
  };
  const filter = "blah";
  const limit = 5;
  const _ref = AutocompleteTest.getFindParams(rule, filter, limit);
  const sel = _ref[0];
  const opts = _ref[1];
  return test.equal(sel.foo, "blah");
});
