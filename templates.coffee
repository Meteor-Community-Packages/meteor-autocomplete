# Events on template instances, sent to the autocomplete class
acEvents =
  "keydown": (e, t) -> t.ac.onKeyDown(e)
  "keyup": (e, t) -> t.ac.onKeyUp(e)
  "focus": (e, t) -> t.ac.onFocus(e)
  "blur": (e, t) -> t.ac.onBlur(e)

Template.inputAutocomplete.events(acEvents)
Template.textareaAutocomplete.events(acEvents)

attributes = -> _.omit(@, 'settings') # Render all but the settings parameter

Template.inputAutocomplete.attributes =
Template.textareaAutocomplete.attributes = attributes

Template.inputAutocomplete.autocompleteContainer =
Template.textareaAutocomplete.autocompleteContainer =
new Template('AutocompleteContainer', ->
  ac = new AutoComplete( Blaze.getCurrentData().settings )
  # Set the autocomplete object on the parent template instance
  # TODO: this does not seem like a good API to be using :)
  Template.__updateTemplateInstance(this.parentView).ac = ac
  # Set nodes on render in the autocomplete class
  this.onRendered ->
    ac.element = this.parentView.domrange.firstNode()
    ac.$element = $(ac.element)

  return Blaze.With(ac, -> Template._autocompleteContainer)
)

Template._autocompleteContainer.rendered = ->
  @data.tmplInst = this

Template._autocompleteContainer.destroyed = ->
  # Meteor._debug "autocomplete destroyed"
  @data.teardown()

###
  List rendering helpers
###

Template._autocompleteContainer.events
  # t.data is the AutoComplete instance; `this` is the data item
  "click .-autocomplete-item": (e, t) -> t.data.onItemClick(this, e)
  "mouseenter .-autocomplete-item": (e, t) -> t.data.onItemHover(this, e)

Template._autocompleteContainer.empty = -> @filteredList().count() is 0

Template._autocompleteContainer.noMatchTemplate = ->
  @matchedRule().noMatchTemplate || Template._noMatch
