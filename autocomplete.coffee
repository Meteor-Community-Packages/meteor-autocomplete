class @AutoComplete

  @LIMIT: 5

  @KEYS: [
    40, # DOWN
    38, # UP
    13, # ENTER
    27, # ESCAPE
    9   # TAB
  ]

  constructor: (@rules) ->
    # Expressions compiled for range from last word break to current cursor position
    @expressions = (new RegExp('(^|\\b|\\s)' + rule.token + '([\\w.]*)$') for rule in rules)

    # Reactive dependencies for current matching rule and filter
    @ruleDep = new Deps.Dependency
    @filterDep = new Deps.Dependency
    @indexDep = new Deps.Dependency

  onKeyUp: (e) ->
    startpos = @$element.getCursorPosition()
    val = @getText().substring(0, startpos)

    ###
      Matching on multiple expressions.
      We always go from an matched state to an unmatched one
      before going to a different matched one.
    ###
    i = 0
    breakLoop = false
    while i < @expressions.length
      matches = val.match(@expression[i])

      # matching -> not matching
      if not matches and @matched is i
        @matched = -1
        @ruleDep.changed()
        breakLoop = true

      # not matching -> matching
      if matches and @matched is -1
        @matched = i
        @ruleDep.changed()
        breakLoop = true

      # Did filter change?
      if matches and @filter isnt matches[2]
        @filter = matches[2]
        @filterDep.changed()
        breakLoop = true

      break if breakLoop

  onKeyDown: (e) ->
    return if @matched is -1 or (@KEYS.indexOf(e.keyCode) < 0)

    switch e.keyCode
      when 9, 13 # TAB, ENTER
        @select()
      when 40
        @next()
      when 38
        @prev()
      when 27 # ESCAPE; not sure what function this should serve, cause it's vacuous in jquery-sew
        @matched = -1
        @ruleDep.changed()

    e.preventDefault()

  onFocus: (values) ->
    @index = 0
    @hightlightItem()

  onBlur: ->
    @matched = -1
    @ruleDep.changed()

  onItemClick: (element, e) ->
    @replace element.val
    @$element.trigger "mention-selected", @filtered[@index]
    @hideList()

  onItemHover: (index, e) ->
    @index = index
    @hightlightItem()

  # Replace text with currently selected item
  select: ->
    @replace @filtered[@index].val
    @$element.trigger "mention-selected", @filtered[@index]
    @hideList()

  # Select next item in list
  next: ->
    @index = (@index + 1) % @filterLength
    @indexDep.changed()

  # Select previous item in list
  prev: ->
    @index = (@index + @filterLength - 1) % @filterLength
    @indexDep.changed()

  # Replace the appropriate region
  replace: (replacement) ->
    startpos = @$element.getCursorPosition()
    fullStuff = @getText()
    val = fullStuff.substring(0, startpos)
    val = val.replace(@expression, "$1" + @options.token + replacement)
    posfix = fullStuff.substring(startpos, fullStuff.length)
    separator = (if posfix.match(/^\s/) then "" else " ")
    finalFight = val + separator + posfix
    @setText finalFight
    @$element.setCursorPosition val.length + 1

  getText: ->
    return @$element.val() || @$element.text()

  ###
    Reactive functions
  ###
  listShown: ->
    @ruleDep.depend()
    return @matched >= 0

  filteredList: ->
    # @ruleDep.depend() # optional, cause list will always get re-rendered
    @filterDep.depend()

    return null if matched is -1

    rule = @rules[matched]

    args = {}
    args[rule.field] =
      $regex: @filter
      $options: "i"

    cursor = rule.collection.find(args, {limit: @LIMIT}) # MIND BLOWN!
    @filterLength = cursor.count()
    return cursor

  highlightedId: ->
    @indexDep.depend()
    return @index

  # TODO: this is just a stand-in for actual template rendering
  currentField: -> @rules[matched].field
