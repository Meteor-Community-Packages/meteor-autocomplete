autocompleteData = ->
  attributes: _.omit(@, 'settings') # Render all but the settings parameter
  ac: new AutoComplete(@settings)

UI.registerHelper "inputAutocomplete", ->
  UI.Component.extend
    kind: "InputAutocomplete",
    data: autocompleteData.call(@)
    render: -> Template._inputAutocomplete

UI.registerHelper "textareaAutocomplete", ->
  UI.Component.extend
    kind: "TextareaAutocomplete",
    data: autocompleteData.call(@)
    render: -> Template._textareaAutocomplete

# Events on template instances, sent to the autocomplete class
events =
  "keydown": (e) -> @ac.onKeyDown(e)
  "keyup": (e) -> @ac.onKeyUp(e)
  "focus": (e) -> @ac.onFocus(e)
  "blur": (e) -> @ac.onBlur(e)

Template._inputAutocomplete.events = events
Template._textareaAutocomplete.events = events

# Set nodes on render in the autocomplete class
# This will re-render on every change due to the Blaze hack above
init = ->
  @data.ac.element = @firstNode
  @data.ac.$element = $(@firstNode)
  @data.ac.tmplInst = this

Template._inputAutocomplete.rendered = init
Template._textareaAutocomplete.rendered = init

###
  List rendering helpers
###

Template._autocompleteContainer.destroyed = ->
  # console.log "autocomplete destroyed"
  @data.teardown()

Template._autocompleteContainer.events =
  # tmplInst.data is the AutoComplete instance
  "click .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemClick(this, e)
  "mouseenter .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemHover(this, e)

Template._autocompleteContainer.empty = -> @filteredList().count() is 0

Template._autocompleteContainer.noMatchTemplate = ->
  @matchedRule().noMatchTemplate || Template._noMatch
