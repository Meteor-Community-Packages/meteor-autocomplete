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

Handlebars.registerHelper "inputAutocomplete", (triggers, options) ->
  return new Handlebars.SafeString Template._inputAutocomplete
    triggers: triggers
    attributes: buildAttributeString(options.hash)
    ac: new AutoComplete(triggers)

Handlebars.registerHelper "textareaAutocomplete", (triggers, options) ->
  return new Handlebars.SafeString Template._textareaAutocomplete
    triggers: triggers
    attributes: buildAttributeString(options.hash)
    text: options.fn(this)
    ac: new AutoComplete(triggers)

# Events on template instances
events =
  "keydown": (e, tmplInst) -> tmplInst._ac.onKeyDown(e)
  "keyup": (e, tmplInst) -> tmplInst._ac.onKeyUp(e)
  "focus": (e, tmplInst) -> tmplInst._ac.onFocus(e)
  "blur": (e, tmplInst) -> tmplInst._ac.onBlur(e)

Template._inputAutocomplete.events = events
Template._textareaAutocomplete.events = events

# Set nodes on render
init = ->
  @data.ac.element = @firstNode
  @data.ac.$element = $(@firstNode)

Template._inputAutocomplete.rendered = init
Template._textareaAutocomplete.rendered = init

###
  List rendering helpers
###
Template._autocompleteContainer.rendered = ->

Template._autocompleteContainer.shown = -> @listShown()

Template._autocompleteContainer.items = -> @filteredList()

Template._autocompleteContainer.pluck = (field) -> this[field]

Template._autocompleteContainer.events =
  "click": (e, tmplInst) -> tmplInst.data.ac.onItemClick.call(this, e);
  "mouseover": (e, tmplInst) -> tmplInst.data.ac.onItemHover.call(this, e);
