import { AutocompleteTest } from "meteor/mizzao:autocomplete";

/*
  Test that regular expressions match what we think they match.
 */
Tinytest.add("autocomplete - regexp - whole field behavior", function(test) {
  const rule = {};
  const regex = AutocompleteTest.getRegExp(rule);
  const matches = "hello there".match(regex);
  return test.equal(matches[2], "hello there");
});

Tinytest.add("autocomplete - regexp - token behavior", function(test) {
  const rule = {
    token: "!"
  };
  const regex = AutocompleteTest.getRegExp(rule);
  const matches = "hello !there".match(regex);
  return test.equal(matches[2], "there");
});