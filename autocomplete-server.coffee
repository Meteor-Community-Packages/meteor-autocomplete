Meteor.publish 'autocomplete-recordset', (selector, options, collName) ->
  collection = global[collName]
  unless collection
    throw new Error(collName + ' is not a defined on the global namespace of the server.')

  # This is a semi-documented Meteor feature:
  # https://github.com/meteor/meteor/blob/devel/packages/mongo-livedata/collection.js
  unless collection._isInsecure()
    Meteor._debug(collName + ' is a secure collection, therefore no data was returned because the client could compromise security by subscribing to arbitrary server collections via the browser console. Please write your own publish function.')
    return [] # We need this for the subscription to be marked ready

  sub = this

  # guard against client-side DOS: hard limit to 50
  options.limit = Math.min(50, Math.abs(options.limit)) if options.limit

  # Push this into our own collection on the client so they don't interfere with other publications of the named collection.
  handle = collection.find(selector, options).observeChanges
    added: (id, fields) ->
      sub.added('autocompleteRecords', id, fields)
    changed: (id, fields) ->
      sub.changed('autocompleteRecords', id, fields)
    removed: (id) ->
      sub.removed('autocompleteRecords', id)

  sub.ready()
  sub.onStop -> handle.stop()
