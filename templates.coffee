# Render all but the settings parameter
attributes = -> _.omit(@, 'settings')

Template.inputAutocomplete.attributes = attributes
Template.textareaAutocomplete.attributes = attributes

# Set this in data as well so we can access it from the template instance
ac = -> @ac = new AutoComplete(@settings)

Template.inputAutocomplete.ac = ac
Template.textareaAutocomplete.ac = ac

# Events on template instances
events =
  "keydown": (e, tmplInst) -> tmplInst.data.ac.onKeyDown(e)
  "keyup": (e, tmplInst) -> tmplInst.data.ac.onKeyUp(e)
  "focus": (e, tmplInst) -> tmplInst.data.ac.onFocus(e)
  "blur": (e, tmplInst) -> tmplInst.data.ac.onBlur(e)

Template.inputAutocomplete.events = events
Template.textareaAutocomplete.events = events

# Set nodes on render
init = ->
  @data.ac.element = @firstNode
  @data.ac.$element = $(@firstNode)
  @data.ac.tmplInst = this

Template.inputAutocomplete.rendered = init
Template.textareaAutocomplete.rendered = init

###
  List rendering helpers
###
Template._autocompleteContainer.rendered = ->
  @data.showing = false

Template._autocompleteContainer.destroyed = ->
  @data.teardown()

Template._autocompleteContainer.events =
  # tmplInst.data is the AutoComplete instance
  "click .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemClick(this, e)
  "mouseenter .-autocomplete-item": (e, tmplInst) -> tmplInst.data.onItemHover(this, e)

Template._autocompleteContainer.shown = -> @isShowing()

Template._autocompleteContainer.items = -> @filteredList()

Template._autocompleteContainer.empty = ->
  (if @filteredList() then @filteredList().count() is 0 else true)

Template._autocompleteContainer.itemTemplate = (ac) -> ac.currentTemplate()

