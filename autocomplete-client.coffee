AutoCompleteRecords = new Meteor.Collection("autocompleteRecords")

isServerSearch = (rule) -> _.isString(rule.collection)

validateRule = (rule) ->
  if rule.subscription? and not Match.test(rule.collection, String)
    throw new Error("Collection name must be specified as string for server-side search")

getRegExp = (rule) ->
  if rule.token
    # Expressions for the range from the last word break to the current cursor position
    new RegExp('(^|\\b|\\s)' + rule.token + '([\\w.]*)$')
  else
    # Whole-field behavior - word characters or spaces
    new RegExp('(^)(.*)$')

getFindParams = (rule, filter, limit) ->
  # This is a different 'filter' - the selector from the settings
  # We need to extend so that we don't copy over rule.filter
  selector = _.extend({}, rule.filter || {})
  options = { limit: limit }

  # Match anything, no sort, limit X
  return [ selector, options ] unless filter

  sortspec = {}
  # Only sort if there is a filter, for faster performance on a match of anything
  if rule.field then sortspec[rule.field] = 1
  options.sort = sortspec

  if _.isFunction(rule.selector)
    # Custom selector
    _.extend(selector, rule.selector(filter))
  else
    selector[rule.field] = {
      $regex: if rule.matchAll then filter else "^" + filter
      # default is case insensitive search - empty string is not the same as undefined!
      $options: if (typeof rule.options is 'undefined') then 'i' else rule.options
    }

  return [ selector, options ]

getField = (obj, str) ->
  obj = obj[key] for key in str.split(".")
  return obj

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
    validateRule(rule) for rule in @rules

    @expressions = (getRegExp(rule) for rule in @rules)

    @matched = -1
    @loaded = true

    # Reactive dependencies for current matching rule and filter
    @ruleDep = new Deps.Dependency
    @filterDep = new Deps.Dependency
    @loadingDep = new Deps.Dependency
    
    # autosubscribe to the record set published by the server based on the filter
    # This will tear down server subscriptions when they are no longer being used.
    @sub = null
    @comp = Deps.autorun =>
      # Stop any existing sub immediately, don't wait
      @sub?.stop()

      return unless (rule = @matchedRule()) and (filter = @getFilter()) isnt null

      # subscribe only for server-side collections
      unless isServerSearch(rule)
        @setLoaded(true) # Immediately loaded
        return

      [ selector, options ] = getFindParams(rule, filter, @limit)

      # console.debug 'Subscribing to <%s> in <%s>.<%s>', filter, rule.collection, rule.field
      @setLoaded(false)
      subName = rule.subscription || "autocomplete-recordset"
      @sub = Meteor.subscribe(subName,
        selector, options, rule.collection, => @setLoaded(true))

  teardown: ->
    # Stop the reactive computation we started for this autocomplete instance
    @comp.stop()

  # reactive getters and setters for @filter and the currently matched rule
  matchedRule: ->
    @ruleDep.depend()
    if @matched >= 0 then @rules[@matched] else null

  setMatchedRule: (i) ->
    @matched = i
    @ruleDep.changed()

  getFilter: ->
    @filterDep.depend()
    return @filter

  setFilter: (x) ->
    @filter = x
    @filterDep.changed()
    return @filter

  isLoaded: ->
    @loadingDep.depend()
    return @loaded

  setLoaded: (val) ->
    return if val is @loaded # Don't cause redraws unnecessarily
    @loaded = val
    @loadingDep.changed()

  onKeyUp: ->
    return unless @$element # Don't try to do this while loading
    startpos = @element.selectionStart
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
        @setMatchedRule(-1)
        breakLoop = true

      # not matching -> matching
      if matches and @matched is -1
        @setMatchedRule(i)
        breakLoop = true

      # Did filter change?
      if matches and @filter isnt matches[2]
        @setFilter(matches[2])
        breakLoop = true

      break if breakLoop
      i++

  onKeyDown: (e) ->
    return if @matched is -1 or (@constructor.KEYS.indexOf(e.keyCode) < 0)

    e.preventDefault()
    switch e.keyCode
      when 9, 13 # TAB, ENTER
        e.stopPropagation() if @select() # Don't jump fields or submit if select successful
      when 40 # DOWN
        @next()
      when 38 # UP
        @prev()
      when 27 # ESCAPE
        @$element.blur()
        @hideList()

    return

  onFocus: ->
    # We need to run onKeyUp after the focus resolves,
    # or the caret position (selectionStart) will not be correct
    Meteor.defer => @onKeyUp()

  onBlur: ->
    # We need to delay this so click events work
    # TODO this is a bit of a hack; see if we can't be smarter
    Meteor.setTimeout =>
      @hideList()
    , 500

  onItemClick: (doc, e) => @processSelection(doc, @rules[@matched])

  onItemHover: (doc, e) ->
    @tmplInst.$(".-autocomplete-item").removeClass("selected")
    $(e.target).closest(".-autocomplete-item").addClass("selected")

  filteredList: ->
    # @ruleDep.depend() # optional as long as we use depend on filter, because list will always get re-rendered
    filter = @getFilter() # Reactively depend on the filter
    return null if @matched is -1

    rule = @rules[@matched]
    # Don't display list unless we have a token or a filter (or both)
    # Single field: nothing displayed until something is typed
    return null unless rule.token or filter

    [ selector, options ] = getFindParams(rule, filter, @limit)

    Meteor.defer => @ensureSelection()

    # if server collection, the server has already done the filtering work
    return AutoCompleteRecords.find({}, options) if isServerSearch(rule)

    # Otherwise, search on client
    return rule.collection.find(selector, options)

  isShowing: ->
    rule = @matchedRule()
    # Same rules as above
    showing = rule isnt null and (rule.token or @getFilter())

    # Do this after the render
    if showing
      Meteor.defer =>
        @positionContainer()
        @ensureSelection()

    return showing

  # Replace text with currently selected item
  select: ->
    doc = UI.getElementData @tmplInst.find(".-autocomplete-item.selected")
    return false unless doc # Don't select if nothing matched

    @processSelection(doc, @rules[@matched])
    return true

  processSelection: (doc, rule) ->
    replacement = getField(doc, rule.field)

    if rule.token
      @replace(replacement, rule)
    else
      # Empty string or doesn't exist?
      # Single-field replacement: replace whole field
      @setText(replacement)
      # Blur field so it doesn't get auto selected again
      @$element.blur()

    # TODO: behave better if the callback throws an error
    rule.callback?(doc, @$element) # Notify that the item has been selected
    @hideList()
    return

  # Replace the appropriate region
  replace: (replacement) ->
    startpos = @element.selectionStart
    fullStuff = @getText()
    val = fullStuff.substring(0, startpos)
    val = val.replace(@expressions[@matched], "$1" + @rules[@matched].token + replacement)
    posfix = fullStuff.substring(startpos, fullStuff.length)
    separator = (if posfix.match(/^\s/) then "" else " ")
    finalFight = val + separator + posfix
    @setText finalFight

    newPosition = val.length + 1
    @element.setSelectionRange(newPosition, newPosition)
    return

  hideList: ->
    @setMatchedRule(-1)
    @setFilter(null)

  getText: ->
    return @$element.val() || @$element.text()

  setText: (text) ->
    if @$element.is("input,textarea")
      @$element.val(text)
    else
      @$element.html(text)

  ###
    Rendering functions
  ###
  positionContainer: ->
    # First render; Pick the first item and set css whenever list gets shown
    position = @$element.position()
    offset = getCaretCoordinates(@element, @element.selectionStart)

    pos = {
      left: position.left + offset.left
    }

    # Position menu from top (above) or from bottom of caret (below, default)
    if @position is "top"
      pos.bottom = @$element.offsetParent().height() - position.top - offset.top
    else
      pos.top = position.top + offset.top + parseInt(@$element.css('font-size'))

    @tmplInst.$(".-autocomplete-container").css(pos)

  ensureSelection : ->
    # Re-render; make sure selected item is something in the list or none if list empty
    selectedItem = @tmplInst.$(".-autocomplete-item.selected")

    unless selectedItem.length
      # Select anything
      @tmplInst.$(".-autocomplete-item:first-child").addClass("selected")

  # Select next item in list
  next: ->
    currentItem = @tmplInst.$(".-autocomplete-item.selected")
    return unless currentItem.length # Don't try to iterate an empty list
    currentItem.removeClass("selected")

    next = currentItem.next()
    if next.length
      next.addClass("selected")
    else # End of list or lost selection; Go back to first item
      @tmplInst.$(".-autocomplete-item:first-child").addClass("selected")

  # Select previous item in list
  prev: ->
    currentItem = @tmplInst.$(".-autocomplete-item.selected")
    return unless currentItem.length # Don't try to iterate an empty list
    currentItem.removeClass("selected")

    prev = currentItem.prev()
    if prev.length
      prev.addClass("selected")
    else # Beginning of list or lost selection; Go to end of list
      @tmplInst.$(".-autocomplete-item:last-child").addClass("selected")

  # This doesn't need to be reactive because list already changes reactively
  # and will cause all of the items to re-render anyway
  currentTemplate: -> @rules[@matched].template

AutocompleteTest =
  records: AutoCompleteRecords
  getRegExp: getRegExp
  getFindParams: getFindParams
