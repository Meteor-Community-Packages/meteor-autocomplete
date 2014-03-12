# We could do the following if we really wanted to prematurely optimize, but these strings are short
# http://trephine.org/t/index.php?title=Efficient_JavaScript_string_building
buildAttributeString = (obj) ->
  arr = []
  for own attr, val of obj
    arr.push attr
    arr.push "=\""
    arr.push val
    arr.push "\" "
  return arr.join ""

Handlebars.registerHelper "inputAutocomplete", (settings, options) ->
  return new Handlebars.SafeString Template._inputAutocomplete
    attributes: buildAttributeString(options.hash)
    ac: new AutoComplete(settings)

Handlebars.registerHelper "textareaAutocomplete", (settings, options) ->
  return new Handlebars.SafeString Template._textareaAutocomplete
    attributes: buildAttributeString(options.hash)
    text: options.fn(this)
    ac: new AutoComplete(settings)

# Events on template instances
events =
  "keydown": (e, tmplInst) -> tmplInst.data.ac.onKeyDown(e)
  "keyup": (e, tmplInst) -> tmplInst.data.ac.onKeyUp(e)
  "focus": (e, tmplInst) -> tmplInst.data.ac.onFocus(e)
  "blur": (e, tmplInst) -> tmplInst.data.ac.onBlur(e)

Template._inputAutocomplete.events = events
Template._textareaAutocomplete.events = events

# Set nodes on render
init = ->
  @data.ac.element = @firstNode
  @data.ac.$element = $(@firstNode)
  @data.ac.tmplInst = this

Template._inputAutocomplete.rendered = init
Template._textareaAutocomplete.rendered = init

###
  List rendering helpers
###
Template._autocompleteContainer.rendered = ->
  showing = @data.matchedRule() isnt null

  if showing and not @showing
    # First render; Pick the first item and set css whenever list gets shown
    $(@find(".-autocomplete-container")).css(@data.getMenuPositioning())

    # Select something if there is anything in the list
    # Shouldn't need to clear id on first render if list cleans up after itself properly
    item = @find(".-autocomplete-item")
    Session.set("-autocomplete-id", Spark.getDataContext(item)._id) if item
  else if showing
    # Re-render; make sure selected item is something in the list or none if list empty
    selectedItem = @find(".-autocomplete-item.selected")

    # TODO: this logic will change once we fix the empty list thing
    unless selectedItem
      newItem = @find(".-autocomplete-item") # Select anything
      if newItem
        Session.set("-autocomplete-id", Spark.getDataContext(newItem)._id)
      else
        Session.set("-autocomplete-id", null)

  @showing = showing

# Don't allow items to be selected if the list empties
# TODO: make this more fine-grained for each item
Template._autocompleteContainer.destroyed = ->
  @data.teardown()
  Session.set("-autocomplete-id", "")

# Retain CSS position across re-rendering. Mechanics will probably change in future Meteor versions.
# Template._autocompleteContainer.preserve = [ ".-autocomplete-container" ]

Template._autocompleteContainer.events =
  # tmplInst.data is the AutoComplete instance
  "click .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemClick(this, e)
  "mouseenter .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemHover(this, e)

Template._autocompleteContainer.shown = -> @matchedRule() isnt null # TODO: and list isnt empty

Template._autocompleteContainer.items = -> @filteredList()

Template._autocompleteContainer.selected = ->
  if Session.equals("-autocomplete-id", @_id) then "selected" else ""

Template._autocompleteContainer.itemTemplate = (ac) ->
  new Handlebars.SafeString( ac.currentTemplate()(this) )

