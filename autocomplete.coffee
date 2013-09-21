class @AutoComplete

  @KEYS: [
    40, # DOWN
    38, # UP
    13, # ENTER
    27, # ESCAPE
    9   # TAB
  ]

  constructor: (@tmplInst, @rules) ->
    # Expressions compiled for range from last word break to current cursor position
    @expressions = (new RegExp('(^|\\b|\\s)' + rule.token + '([\\w.]*)$') for rule in rules)

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

      # Went from matching to not matching
      if not matches and @matched is i
        @matched = -1
        @dontFilter = false
        @hideList()

        breakLoop = true

      #Went from not matching to matching
      if matches and @matched is -1
        @displayList()
        @lastFilter = "\n"
        @matched = i

        breakLoop = true

      if matches and not @dontFilter
        @filterList matches[2]

      break if breakLoop

  onKeyDown: (e) ->
    return if not @listVisible or (@KEYS.indexOf(e.keyCode) < 0)

    switch e.keyCode
      when 9, 13 # TAB, ENTER
        @select()
      when 40
        @next()
      when 38
        @prev()
      when 27
        @$itemList.hide()
        @dontFilter = true

    e.preventDefault()

  # Render the list
  onFocus: (values) ->
    $("body").append @$itemList
    container = @$itemList.find("ul").empty()
    values.forEach $.proxy((e, i) ->
      $item = $(Plugin.ITEM_TEMPLATE)
      @options.elementFactory $item, e
      e.element = $item.appendTo(container).bind("click", $.proxy(@onItemClick, this, e)).bind("mouseover", $.proxy(@onItemHover, this, i))
    , this)
    @index = 0
    @hightlightItem()

  # Get rid of the rendered list
  onBlur: ->
    @$itemList.fadeOut "slow"
    @cleanupHandle = window.setTimeout($.proxy(->
      @$itemList.remove()
    , this), 1000)

  # Replace text with currently selected item
  select: ->
    @replace @filtered[@index].val
    @$element.trigger "mention-selected", @filtered[@index]
    @hideList()

  # Select next item in list
  next: ->
    @index = (@index + 1) % @filtered.length
    @hightlightItem()

  # Select previous item in list
  prev: ->
    @index = (@index + @filtered.length - 1) % @filtered.length
    @hightlightItem()

  filterList: (val) ->
    return  if val is @lastFilter
    @lastFilter = val
    @$itemList.find(".-sew-list-item").remove()
    values = @options.values
    vals = @filtered = values.filter($.proxy((e) ->
      exp = new RegExp("\\W*" + @options.token + e.val + "(\\W|$)")
      return false  if not @options.repeat and @getText().match(exp)
      val is "" or e.val.toLowerCase().indexOf(val.toLowerCase()) >= 0 or (e.meta or "").toLowerCase().indexOf(val.toLowerCase()) >= 0
    , this))
    if vals.length
      @renderElements vals
      @$itemList.show()
    else
      @hideList()

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

