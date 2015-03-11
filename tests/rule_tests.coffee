###
  Test that rule validations work properly.
###
Cause = new Mongo.Collection(null)

Tinytest.add "autocomplete - rules - vanilla client side collection search", (test) ->
  settings =
    position: 'bottom'
    limit: 10
    rules: [
      {
        collection: Cause,
        field: "name",
        matchAll: true,
      # template: Template.cause
      }
    ]

  test.isFalse(AutocompleteTest.isServerSearch(settings.rules[0]))

  new AutoComplete(settings)
  test.ok()

# From https://github.com/mizzao/meteor-autocomplete/issues/36
Tinytest.add "autocomplete - rules - check for collection string with subscription", (test) ->
  settings =
    position: 'bottom'
    limit: 10
    rules: [
      {
        collection: Cause,
        field: "name",
        matchAll: true,
        subscription: 'causes',
        # template: Template.cause
      }
    ]

  test.throws -> new AutoComplete(settings)

Tinytest.add "autocomplete - rules - server side collection with default sub", (test) ->
  settings =
    position: 'bottom'
    limit: 10
    rules: [
      {
        collection: "Cause",
        field: "name",
        matchAll: true,
        # template: Template.cause
      }
    ]

  test.isTrue(AutocompleteTest.isServerSearch(settings.rules[0]))

  new AutoComplete(settings)
  test.ok()

Tinytest.add "autocomplete - rules - server side collection with custom sub", (test) ->
  settings =
    position: 'bottom'
    limit: 10
    rules: [
      {
        field: "name",
        matchAll: true,
        subscription: 'causes',
        # template: Template.cause
      }
    ]

  test.isTrue(AutocompleteTest.isServerSearch(settings.rules[0]))

  new AutoComplete(settings)
  test.ok()
