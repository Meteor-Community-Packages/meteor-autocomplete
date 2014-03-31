Tinytest.add "autocomplete - params - default case insensitive", (test) ->
  rule =
    field: "foo"
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal sel.foo.$regex, "^blah"
  test.equal sel.foo.$options, "i"

Tinytest.add "autocomplete - params - limit", (test) ->
  rule =
    field: "foo"
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal opts.limit, 5

Tinytest.add "autocomplete - params - match all", (test) ->
  rule =
    field: "foo"
    matchAll: true
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal sel.foo.$regex, "blah"

Tinytest.add "autocomplete - params - replace options", (test) ->
  rule =
    field: "foo"
    options: ""
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal sel.foo.$regex, "^blah"
  test.equal sel.foo.$options, ""

Tinytest.add "autocomplete - params - no sort if filter empty", (test) ->
  rule =
    field: "foo"
  filter = ""
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.isFalse opts.sort

Tinytest.add "autocomplete - params - sort if filter exists", (test) ->
  rule =
    field: "foo"
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal opts.sort.foo, 1

Tinytest.add "autocomplete - params - incorporate filter", (test) ->
  rule =
    field: "foo"
    filter: {type: "autocomplete"}
  filter = "blah"
  limit = 5

  [sel, opts] = AutocompleteTest.getFindParams(rule, filter, limit)

  test.equal sel.type, "autocomplete"
  test.isFalse rule.filter.blah # should not be modified


