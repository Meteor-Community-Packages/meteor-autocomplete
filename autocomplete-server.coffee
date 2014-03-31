###
  Notes on preferential query matching by https://github.com/dandv

  How server-side autocompletion works: we provide a publish function that
  takes as paramters the name of the collection, the filter (substring),
  the field to filter against, and a limit for the number of results returned.
  If we just want to return any substring match (preferStartWithFilter: false),
  things are easy - just run a $regex: /filter/i search. But it's much better
  UX to prioritize records where <field> starts with the filter.

  That requires running two queries (or an elastic search - see http://stackoverflow.com/questions/22297608/mongo-regex-to-prioritize-anchor-at-the-beginning-and-fall-back-to-substring-mat
  We'll go for two queries: one for the field starting with the filter,
  and the second for the filter string appearing anywhere in the field.
  To join the cursors returned by these queries, ideally we would just return
  an array of two cursors (see below) but Meteor doesn't support that yet -
  "If you return multiple cursors in an array, they currently must all be from different collections. We hope to lift this restriction in a future release."

  We'll use two regex searches, one for /^filter/ and, if fewer than
  <limit> results are returned, another one for /filter/, so that we
  prioritize results with the pattern matching at the beginning.
  See http://stackoverflow.com/questions/22297608/mongo-regex-to-prioritize-anchor-at-the-beginning-and-fall-back-to-substring-mat

  For now, we'll have to define a memory-only collection that will hold
  just the joined results of the two queries. But... that means we need
  to define a separate collection with the same name on the client, instead
  of just publishing records into the collection we autocomplete from.

  So we end up with extracting _ids from the two queries and running a
  third query just for those _ids. The results would be still in cache
  so the penalty should be minimal.

  For the best user experience, fields startig with @filter should be returned first.
  The server does that, but preserving the order while publishing the filtered
  recordset down the wire is impossible - https://github.com/meteor/meteor/issues/821
  And we can't sort by a field added via `transform` either, thanks to @glasser - https://github.com/meteor/meteor/issues/1852
  Therefore, we have to replicate the computation on the client.

  TODO: it would probably be faster to return an array instead of a cursor, and
  use a Meteor method instead of a publish function, but that would require
  assuming that the client-side of the connection is read-only. Another
  high-performance alternative may be http://arunoda.github.io/meteor-streams/.
###

###
  I'm going to greatly simplify things by assuming that most queries are going to match on a prefix, taking advantage of a possible index on the dtabase, and otherwise have an option to match anywhere in the string, which is slower.

  - @mizzao
###

Meteor.publish 'autocomplete-recordset', (selector, options, collName) ->
  collection = global[collName]
  unless collection
    throw new Error(collName + " is not defined on the global namespace of the server.")

  # This is a semi-documented Meteor feature:
  # https://github.com/meteor/meteor/blob/devel/packages/mongo-livedata/collection.js
  unless collection._isInsecure()
    Meteor._debug(collName + " is secure; Cowardly refusing a potential security risk by returning data. Please write your own publish function.")
    return [] # We need this for the subscription to be marked ready

  sub = this

  # guard against client-side DOS: hard limit to 50
  options.limit = Math.min(50, Math.abs(options.limit)) if options.limit

  # Push this into our own collection on the client so they don't interfere with other publications of the named collection.
  handle = collection.find(selector, options).observeChanges
    added: (id, fields) ->
      sub.added("autocompleteRecords", id, fields)
    changed: (id, fields) ->
      sub.changed("autocompleteRecords", id, fields)
    removed: (id) ->
      sub.removed("autocompleteRecords", id)

  sub.ready()
  sub.onStop -> handle.stop()
