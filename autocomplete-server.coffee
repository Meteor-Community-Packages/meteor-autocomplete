# How server-side autocompletion works: we provide a publish function that
# takes as paramters the name of the collection, the filter (substring),
# the field to filter against, and a limit for the number of results returned.
# If we just want to return any substring match (preferStartWithFilter: false),
# things are easy - just run a $regex: /filter/i search. But it's much better
# UX to prioritize records where <field> starts with the filter.

# That requires running two queries (or an elastic search - see http://stackoverflow.com/questions/22297608/mongo-regex-to-prioritize-anchor-at-the-beginning-and-fall-back-to-substring-mat
# We'll go for two queries: one for the field starting with the filter,
# and the second for the filter string appearing anywhere in the field.
# To join the cursors returned by these queries, ideally we would just return
# an array of two cursors (see below) but Meteor doesn't support that yet -
# "If you return multiple cursors in an array, they currently must all be from different collections. We hope to lift this restriction in a future release."

# For now, we'll have to define a memory-only collection that will hold
# just the joined results of the two queries. But... that means we need
# to define a separate collection with the same name on the client, instead
# of just publishing records into the collection we autocomplete from.

# So we end up with extracting _ids from the two queries and running a
# third query just for those _ids. The results would be still in cache
# so the penalty should be minimal.

# TODO: it would probably be faster to return an array instead of a cursor, and
# use a Meteor method instead of a publish function, but that would require
# assuming that the client-side of the connection is read-only. Another
# high-performance alternative may be http://arunoda.github.io/meteor-streams/.

Meteor.publish 'meteor-autocomplete-recordset', (collection, field, filter, limit, preferStartWithFilter) ->
  # 'Autocompleting <%s> in <%s>.<%s> up to <%s>', filter, collection, field, limit
  return null unless filter

  # guard against client-side DOS: hard limit to 50
  limit = Math.abs(limit)
  limit = 50 if limit > 50

  # We'll use two regex searches, one for /^filter/ and, if fewer than
  # <limit> results are returned, another one for /filter/, so that we
  # prioritize results with the pattern matching at the beginning.
  # See http://stackoverflow.com/questions/22297608/mongo-regex-to-prioritize-anchor-at-the-beginning-and-fall-back-to-substring-mat
  fieldspec = {}
  fieldspec[field] = 1

  selector = {}

  if !preferStartWithFilter
    selector[field] = { $regex: filter, $options: 'i' }
    return global[collection].find(
      selector,
      {
        sort: fieldspec,
        limit: limit
      }
)
  selector[field] = { $regex: '^' + filter, $options: 'i' }
  resultsStart = global[collection].find(
    selector,
    { sort: fieldspec, limit: limit }
  )

  found = resultsStart.count()
  return resultsStart if found >= limit  # found can't possibly be > limit, but better be paranoid

  # We don't have enough matches where the filter is at the beginning of the field,
  # so look for when it's any substring now.
  alreadyFound = resultsStart.map (record) -> record._id

  selector[field].$regex = filter
  selector._id = { $nin: alreadyFound }  # exclude results we've found already

  # 'Finding', limit-found, 'results for', selector
  resultsAnywhere = global[collection].find(
    selector,
    {
      fields: { _id: 1 },  # we don't need anything else now
      sort: fieldspec,
      limit: limit - found
    }
  )
  resultsAnywhere.forEach (record) ->
    alreadyFound.push record._id

  selector = { _id: { $in: alreadyFound } }
  return global[collection].find(selector)
