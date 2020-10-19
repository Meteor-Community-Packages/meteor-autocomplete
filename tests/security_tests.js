let AutoCompleteRecords;

if (Meteor.isServer) {
  const SecureCollection = new Mongo.Collection("secure");
  const InsecureCollection = new Mongo.Collection("notsecure");
  if (SecureCollection.find().count() === 0) {
    SecureCollection.insert({
      foo: "bar"
    });
  }
  if (InsecureCollection.find().count() === 0) {
    InsecureCollection.insert({
      foo: "baz"
    });
  }
  InsecureCollection._insecure = true;
  Tinytest.add("autocomplete - server - helper functions exported", function(test) {
    test.isTrue(Autocomplete);
    return test.isTrue(Autocomplete.publishCursor);
  });
}

if (Meteor.isClient) {
  AutoCompleteRecords = AutocompleteTest.records;
  Tinytest.addAsync("autocomplete - security - sub insecure collection", function(test, next) {
    return Meteor.subscribe("autocomplete-recordset", {}, {}, 'InsecureCollection', function() {
      var _ref;
      test.equal(AutoCompleteRecords.find().count(), 1);
      test.equal((_ref = AutoCompleteRecords.findOne()) != null ? _ref.foo : void 0, "baz");
      sub.stop();
      return next();
    });
  });
  Tinytest.addAsync("autocomplete - security - sub secure collection", function(test, next) {
    return Meteor.subscribe("autocomplete-recordset", {}, {}, 'SecureCollection', function() {
      test.equal(AutoCompleteRecords.find().count(), 0);
      test.isFalse(AutoCompleteRecords.findOne());
      sub.stop();
      return next();
    });
  });
}