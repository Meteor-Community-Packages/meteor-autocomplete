class @AutoComplete

  @KEYS: [
    40, # DOWN
    38, # UP
    13, # ENTER
    27, # ESCAPE
    9   # TAB
  ]

  constructor: (settings) ->
    @limit = settings.limit || 5
    @position = settings.position || "bottom"

    @rules = settings.rules
    # Expressions compiled for the range from the last word break to the current cursor position
    @expressions = (new RegExp('(^|\\b|\\s)' + rule.token + '([\\w.]*)$') for rule in @rules)

    @matched = -1

    # Reactive dependencies for current matching rule and filter
    @ruleDep = new Deps.Dependency
    @filterDep = new Deps.Dependency
    
    # autosubscribe to the record set published by the server based on the filter
    self = @
    Deps.autorun ->
      if (filter = self.getFilter()) and (rule = self.getRule())
        if typeof rule.collection is "string"  # subscribe only for server-side collections
          # console.debug 'Subscribing to <%s> in <%s>.<%s>', filter, rule.collection, rule.field
          if rule.autocompleteRecordset  # user-managed publication/subscription
            Meteor.subscribe(rule.autocompleteRecordset, rule.collection, rule.field, filter, self.limit, rule.preferStartWithFilter)
          else  # we provide our own slower but functional out-of-the-box publication
            Meteor.subscribe("meteor-autocomplete-recordset", rule.collection, rule.field, filter, self.limit, rule.preferStartWithFilter)

    Session.set("-autocomplete-id", null); # Use this for Session.equals()

  # reactive getters and setters for @filter and the currently matched rule
  getRule: -> if @ruleMatched() then @rules[@matched] else null

  setRuleMatched: (i) ->
    @matched = i
    @ruleDep.changed()

  getFilter: ->
    @filterDep.depend()
    return @filter

  setFilter: (x) ->
    @filter = x
    @filterDep.changed()
    return @filter

  onKeyUp: (e) ->
    startpos = @$element.getCursorPosition() # TODO: this is incorrect on autofocus
    val = @getText().substring(0, startpos)

    ###
      Matching on multiple expressions.
      We always go from a matched state to an unmatched one
      before going to a different matched one.
    ###
    i = 0
    breakLoop = false
    while i < @expressions.length
      matches = val.match(@expressions[i])

      # matching -> not matching
      if not matches and @matched is i
        @setRuleMatched(-1)
        breakLoop = true

      # not matching -> matching
      if matches and @matched is -1
        @setRuleMatched(i)
        breakLoop = true

      # Did filter change?
      if matches and @filter isnt matches[2]
        @setFilter(matches[2])
        breakLoop = true

      break if breakLoop
      i++

  onKeyDown: (e) =>
    return if @matched is -1 or (@constructor.KEYS.indexOf(e.keyCode) < 0)

    switch e.keyCode
      when 9, 13 # TAB, ENTER
        e.stopPropagation() if @select() # Don't jump fields or submit if select successful
      when 40
        @next()
      when 38
        @prev()
      when 27 # ESCAPE; not sure what function this should serve, cause it's vacuous in jquery-sew
        @hideList()

    e.preventDefault()

  onFocus: -> @onKeyUp()

  onBlur: ->
    # We need to delay this so click events work
    # TODO this is a bit of a hack; see if we can't be smarter
    Meteor.setTimeout =>
      @hideList()
    , 500

  onItemClick: (doc, e) =>
    @replace doc[@rules[@matched].field]
    @hideList()

  onItemHover: (doc, e) ->
    Session.set("-autocomplete-id", doc._id)

  # Replace text with currently selected item
  select: ->
    docId = Deps.nonreactive(-> Session.get("-autocomplete-id"))
    return false unless docId # Don't select if nothing matched

    rule = @rules[@matched]
    @replace rule.collection.findOne(docId)[rule.field]
    @hideList()
    return true

  # Select next item in list
  next: ->
    currentItem = @tmplInst.find(".-autocomplete-item.selected")
    return unless currentItem # Don't try to iterate an empty list

    next = $(currentItem).next()
    if next.length
      nextId = Spark.getDataContext(next[0])._id
    else # End of list or lost selection; Go back to first item
      nextId = Spark.getDataContext(@tmplInst.find(".-autocomplete-item:first-child"))._id
    Session.set("-autocomplete-id", nextId)

  # Select previous item in list
  prev: ->
    currentItem = @tmplInst.find(".-autocomplete-item.selected")
    return unless currentItem # Don't try to iterate an empty list

    prev = $(currentItem).prev()
    if prev.length
      prevId = Spark.getDataContext(prev[0])._id
    else # Beginning of list or lost selection; Go to end of list
      prevId = Spark.getDataContext(@tmplInst.find(".-autocomplete-item:last-child"))._id
    Session.set("-autocomplete-id", prevId)

  # Replace the appropriate region
  replace: (replacement) ->
    startpos = @$element.getCursorPosition()
    fullStuff = @getText()
    val = fullStuff.substring(0, startpos)
    val = val.replace(@expressions[@matched], "$1" + @rules[@matched].token + replacement)
    posfix = fullStuff.substring(startpos, fullStuff.length)
    separator = (if posfix.match(/^\s/) then "" else " ")
    finalFight = val + separator + posfix
    @setText finalFight
    @$element.setCursorPosition val.length + 1

  hideList: -> @setRuleMatched(-1)

  getText: ->
    return @$element.val() || @$element.text()

  setText: (text) ->
    if @$element.is("input,textarea")
      @$element.val(text)
    else
      @$element.html(text)

  ###
    Reactive/rendering functions
  ###
  ruleMatched: ->
    @ruleDep.depend()
    return @matched >= 0

  filteredList: ->
    # @ruleDep.depend() # optional as long as we use filterDep, because list will always get re-rendered
    @filterDep.depend()
    return null if @matched is -1

    rule = @rules[@matched]

    fieldspec = {}
    fieldspec[rule.field] = 1
    collection = if typeof rule.collection is "string" then window[rule.collection] else rule.collection

    selector = {}
    if not rule.preferStartWithFilter  # easy case, suboptimal user experience
      selector[rule.field] =
        $regex: @filter
        $options: 'i'
      return collection.find(selector, { sort: fieldspec, limit: @limit })

    # For the best user experience, fields startig with @filter should be returned first.
    # The server does that, but preserving the order while publishing the filtered
    # recordset down the wire is impossible - https://github.com/meteor/meteor/issues/821
    # And we can't sort by a field added via `transform` either, thanks to @glasser - https://github.com/meteor/meteor/issues/1852
    # Therefore, we have to replicate the computation on the client.
    selector[rule.field] =
      $regex: "^" + @filter
      $options: "i"

    resultsStart = collection.find(selector, { sort: fieldspec, limit: @limit })
    found = resultsStart.count()
    return resultsStart if found >= @limit  # found can't possibly be > limit, but better be paranoid

    # Not all results started with @filter, so return the ones that don't, after those that do
    alreadyFound = resultsStart.map (record) -> record._id
    resultsStart.rewind()
    selector[rule.field].$regex = @filter
    selector._id = { $nin: alreadyFound }
    resultsRest = collection.find(
      selector,
      { sort: fieldspec, limit: @limit - found }
    )
    return resultsStart.fetch().concat(resultsRest.fetch())


  # This doesn't need to be reactive because list already changes reactively
  # and will cause all of the items to re-render anyway
  currentTemplate: -> @rules[@matched].template

  getMenuPositioning: ->
    position = @$element.position()
    offset = @$element.getCaretPosition(@position)

    if @position is "top"
      # Do some additional calculation to position menu from bottom
      return {
        left: position.left + offset.left
        bottom: @$element.offsetParent().height() - position.top + @$element.height() - offset.top
      }
    else
      return {
        left: position.left + offset.left
        top: position.top + offset.top
      }
