import { Mongo } from "meteor/mongo";
import { AutocompleteTest, AutoComplete } from "meteor/mizzao:autocomplete";

/*
  Test that rule validations work properly.
*/
const Cause = new Mongo.Collection(null);

Tinytest.add("autocomplete - rules - vanilla client side collection search", (test) => {
  const settings = {
    position: 'bottom',
    limit: 10,
    rules: [
      {
        collection: Cause,
        field: "name",
        matchAll: true
      }
    ]
  };
  test.isFalse(AutocompleteTest.isServerSearch(settings.rules[0]));
  new AutoComplete(settings);
  return test.ok();
});

Tinytest.add("autocomplete - rules - check for collection string with subscription", (test) => {
  const settings = {
    position: 'bottom',
    limit: 10,
    rules: [
      {
        collection: Cause,
        field: "name",
        matchAll: true,
        subscription: 'causes'
      }
    ]
  };
  return test.throws(function() {
    return new AutoComplete(settings);
  });
});

Tinytest.add("autocomplete - rules - server side collection with default sub", (test) => {
  const settings = {
    position: 'bottom',
    limit: 10,
    rules: [
      {
        collection: "Cause",
        field: "name",
        matchAll: true
      }
    ]
  };
  test.isTrue(AutocompleteTest.isServerSearch(settings.rules[0]));
  new AutoComplete(settings);
  return test.ok();
});

Tinytest.add("autocomplete - rules - server side collection with custom sub", (test) => {
  const settings = {
    position: 'bottom',
    limit: 10,
    rules: [
      {
        field: "name",
        matchAll: true,
        subscription: 'causes'
      }
    ]
  };
  test.isTrue(AutocompleteTest.isServerSearch(settings.rules[0]));
  new AutoComplete(settings);
  return test.ok();
});
