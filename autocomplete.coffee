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


Handlebars.registerHelper "textareaAutocomplete", (triggers, options) ->
  return new Handlebars.SafeString Template._textareaAutocomplete
    triggers: triggers
    attributes: buildAttributeString(options.hash)
    text: options.fn(this)

Template._inputAutocomplete.rendered = ->

Template._textareaAutocomplete.rendered = ->
