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

Handlebars.registerHelper "inputAutocomplete", (rules, options) ->
  return new Handlebars.SafeString Template._inputAutocomplete
    rules: rules
    attributes: buildAttributeString(options.hash)


Handlebars.registerHelper "textareaAutocomplete", (rules, options) ->
  return new Handlebars.SafeString Template._textareaAutocomplete
    rules: rules
    attributes: buildAttributeString(options.hash)
    text: options.fn(this)

# Events on template instances
events =
  "keydown": (e, tmplInst) -> tmplInst._ac.onKeyDown(e)
  "keyup": (e, tmplInst) -> tmplInst._ac.onKeyUp(e)
  "focus": (e, tmplInst) -> tmplInst._ac.onFocus(e)
  "blur": (e, tmplInst) -> tmplInst._ac.onBlur(e)

Template._inputAutocomplete.events = events
Template._textareaAutocomplete.events = events

# Create new autocomplete class for each template instance
create = ->
  @_ac = new AutoComplete(this, this.data.rules)

Template._inputAutocomplete.created = create
Template._textareaAutocomplete.created = create

init = ->
  @_ac.element = @firstNode
  @_ac.$element = $(@firstNode)

Template._inputAutocomplete.rendered = init
Template._textareaAutocomplete.rendered = init
