###
  Test that rule validations work properly.
###
Cause = new Meteor.Collection(null)

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

Tinytest.add "autocomplete - rules - server side collection with subscription", (test) ->
  settings =
    position: 'bottom'
    limit: 10
    rules: [
      {
        collection: "Cause",
        field: "name",
        matchAll: true,
        subscription: 'causes',
        # template: Template.cause
      }
    ]

  new AutoComplete(settings)
  test.ok()
