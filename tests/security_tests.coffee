if Meteor.isServer
  @SecureCollection = new Meteor.Collection("secure")
  @InsecureCollection = new Meteor.Collection("notsecure")

  if SecureCollection.find().count() is 0
    SecureCollection.insert
      foo: "bar"

  if InsecureCollection.find().count() is 0
    InsecureCollection.insert
      foo: "baz"

  InsecureCollection._insecure = true

if Meteor.isClient
  AutoCompleteRecords = AutocompleteTest.records

  Tinytest.addAsync "autocomplete - security - sub insecure collection", (test, next) ->
    sub = Meteor.subscribe "autocomplete-recordset", {}, {}, 'InsecureCollection', ->
      test.equal AutoCompleteRecords.find().count(), 1
      test.equal AutoCompleteRecords.findOne()?.foo, "baz"
      sub.stop()
      next()

  Tinytest.addAsync "autocomplete - security - sub secure collection", (test, next) ->
    sub = Meteor.subscribe "autocomplete-recordset", {}, {}, 'SecureCollection', ->
      test.equal AutoCompleteRecords.find().count(), 0
      test.isFalse AutoCompleteRecords.findOne()
      sub.stop()
      next()

