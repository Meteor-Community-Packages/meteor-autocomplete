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
  return if @rendered
  # Pick the first item on first render, also need to set css

Template._autocompleteContainer.events =
  "click": (e, tmplInst) -> tmplInst.data.ac.onItemClick.call(this, e);
  "mouseover": (e, tmplInst) -> tmplInst.data.ac.onItemHover.call(this, e);

Template._autocompleteContainer.shown = -> @listShown()

Template._autocompleteContainer.items = -> @filteredList()

Template._autocompleteContainer.selected = -> Session.equals("-autocomplete-id", @_id)

Template._autocompleteContainer.itemTemplate = (ac) ->
  new Handlebars.SafeString( ac.currentTemplate()(this) )

