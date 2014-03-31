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
