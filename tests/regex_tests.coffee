
###
  Test that regular expressions match what we think they match.
###
Tinytest.add "autocomplete - regexp - whole field behavior", (test) ->
  rule = {}

  regex = AutocompleteTest.getRegExp(rule)
  matches = "hello there".match(regex)

  test.equal matches[2], "hello there"

Tinytest.add "autocomplete - regexp - token behavior", (test) ->
  rule = {
    token: "!"
  }

  regex = AutocompleteTest.getRegExp(rule)
  matches = "hello !there".match(regex)

  test.equal matches[2], "there"
