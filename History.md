## vNEXT

* Fix an issue where an extraneous `collection` field was required for custom server-side subscriptions. (#40)

## v0.5.1

* Allow either top or bottom positioning in both normal and whole-field modes. (#75)

## v0.5.0

* Switch to jQuery events instead of callbacks; you can now detect autocomplete selections using a template's event map. **Callbacks are no longer supported.** See the demo for a use example. (#48, #56)

## v0.4.10

* Make the `Autocomplete.publishCursor(cursor, subscription)` function available on the server, which greatly simplifies the process of returning results for an autocomplete query over a publication.
* Update the usage of the Mongo Collection API changed in Meteor 0.9.1 and later. 

## v0.4.9

* Update usage of template helpers for Meteor 0.9.4. (#66, #67)
* Don't follow the cursor in whole-field autocompletion mode (#55, #63 -thanks @cretep).
* Better compatibility of whole-field mode when using `TAB` and `Shift+TAB` after selections. (#64) 

## v0.4.8

* Updates for Meteor 0.9.1 APIs, since we use a lot of weird stuff. This is just to get things working; expect some general cleanup in the future as Meteor's API stabilizes for 1.0.

## v0.4.7

* **Updated for Meteor 0.9.**
* Made pre-sorting the autocomplete list an option that is off by default, for better performance on searches over large collections, especially on the client.
* Fix errors resulting from trying to select nonexistent items.

## v0.4.6

* Refactor UI components using the new Blaze API on Meteor 0.8.3, with Blaze Views.
* Restore textarea block helper content.

## v0.4.5

* Temporarily disable textarea block helper content until the Blaze API is updated.

## v0.4.4

* Simulate pre-Blaze rendering behavior to properly deal with changing data contexts, until an updated Blaze Component API is released.
* Support a custom specified template when no match is found. (#25)

## v0.4.3

* Fix an issue where caret position was incorrect on a focus.

## v0.4.2

* Use the Meteor caret-position package instead of the `jquery-caretposition` and `jquery-migrate` packages.
* Added some validation for specifying rules, and tests for regular expressions.
* Improve behavior of whole-field (tokenless) autocompletion.
* Pressing the escape key while autocompleting now blurs the field.

## v0.4.1

* Allow for creating any custom selector from an autocomplete match, in addition to the standard `$regex` behavior.

## v0.4.0

* Revamped the behavior of token-less autocompletion. (See #4, #27, and #33)
* The selection callback now passes the input element as the second argument. (#31)

## v0.3.0

* Update for Meteor 0.8.0 (Blaze). **NOTE: You will need to update your app to use this version.** (#22)

## v0.2.4

This is the last version of autocomplete that will support Meteor <0.8.0 (Blaze).

* Add an optional `filter` field to allow additional static filters on a collection search. (#21)
* Only insecure collections can be searched by default on the server side. **If you are using the default implementation, you will need to write your own publish function**. (#20)
* Add automated testing infrastructure.

## v0.2.3

* Support nested values for `field`, i.e. `'profile.foo'`. (#19)

## v0.2.2

* Provided an option for callbacks when an item is selected and inserted (#18).

## v0.2.1

* Fixed a bug with CSS positioning of the autocomplete popup.
* Provided more control over regex options. Default option is case-insensitive `'i'`.

## v0.2.0

* Added server-side (pub/sub) autocompletion (#6) - many thanks to @dandv; see #17 for implementation discussion.

## v0.1.1

* Increased z-index on autocomplete container (#8).
* Added jquery-migrate package to temporarily support caret position operations on Meteor 0.7.1.2 (this will be fixed in the future).

## v0.1.0

* First release.
