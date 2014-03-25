meteor-autocomplete
===================

Prefix auto-completion using documents and fields in client- or server-side Meteor collections.

Check out a demo app at http://autocomplete.meteor.com or the [source](https://github.com/mizzao/meteor-autocomplete/tree/master/examples/pubsublocal).

## What's this do?

Auto-completes typing in text `input`s or `textarea`s from different local or remote Meteor collections when triggered by certain symbols. You've probably seen this when referring to users or issues in a GitHub conversation. For example, you may want to ping a user:

![Autocompleting a user](https://raw.github.com/mizzao/meteor-autocomplete/master/docs/mention1.png)

...and ask them to look at a certain item:

![Autocompleting something else](https://raw.github.com/mizzao/meteor-autocomplete/master/docs/mention2.png)

Features:
 - Multiple collection matching with different tokens and fields
 - Fully live and reactive Meteor template rendering of list items
 - Automatically positioned above or below text
 - Mouse or keyboard interaction with autocomplete menu

Meteor's client-side data availability makes this dynamic, full-fledged autocomplete widget possible. Use it in chat rooms, comments, other messaging systems, or whatever strikes your fancy.

## Usage

Use Meteorite to install the package:

```
mrt add autocomplete
```

Add a text `input` or `textarea` to a template in one of the following ways, as a handlebars helper or block helper. Pass in any HTML parameters as the options hash of the Handlebars helper:

```
<template name="foo">
    ... stuff
    {{inputAutocomplete settings id="msg" class="input-xlarge" placeholder="Chat..."}}
    ... more stuff
</template>

<template name="bar">
    ... stuff
    {{#textareaAutocomplete settings id="msg"}}
        {{myStartingText}}
    {{/textareaAutocomplete}}
    ... more stuff
</template>
```

Define a helper for the first argument like the following:

```javascript
Template.foo.settings = function() {
  return {
   position: "top",
   limit: 5,
   rules: [
     {
       token: '@',
       selector: {type: "autocomplete"},
       collection: Meteor.users,
       field: "username",
       template: Template.userPill
     },
     {
       token: '!',
       collection: Dataset,
       options: '',
       matchAll: true,
       field: "_id",
       template: Template.dataPiece
     }
   ]
  }
};
```

- `position` (= `top` or `bottom`) specifies if the autocomplete menu should render above or below the cursor. Select based on the placement of your `input`/`textarea` relative to other elements on the page.
- `limit`: Controls how big the autocomplete menu should get.
- `rules`: An array of matching rules for the autocomplete widget, which will be checked in order
- `token`: What character should trigger this rule
- `collection`: What collection should be used to match for this rule. Must be a `Meteor.Collection` for client-side collections, or a string for remote collections (available in `global` on the server.)
- `options`: `'i'` (default) to specify the regex matching options. Both case-sensitive matches and string start anchors are needed to take advantage of server indices (see below.)
- `matchAll`: `false` (default) to match only fields starting with the matched string. This means that indexes on relevant fields will help. Note that [regular expression searches](http://docs.mongodb.org/manual/reference/operator/query/regex/) can only use an index efficiently when the regular expression has an anchor for the beginning (i.e. `^`) of a string and is a case-sensitive match. Setting this field to `true` will match anywhere in the string, but will not be able to take advantage of server indices.
- `field`: The field of the collection that the rule will match against. Can be nested, i.e. `'profile.foo'`.
- `template`: The template that should be used to render each list item. The template will be passed the entire matched document as a data context, so render list items as fancily as you would like. For example, it's usually helpful to see metadata for matches as in the pictures above.
- `callback`: An optional function which is called with one argument, when an item is selected.

Records that match the filter text typed after the token will be passed to the `template` sorted in ascending order by `field`. For example settings see one of the following:

- https://github.com/mizzao/meteor-autocomplete/blob/master/examples/pubsublocal/client/client.js (from the example app above)
- https://github.com/mizzao/CrowdMapper/blob/master/client/views/chat.coffee#L146 (an example used in a chatroom)

**Simple autocompletion**: If you only need to autocomplete over a single collection and want to match the entire field, specify a `rules` array with a single object where `token` is the empty string: `''`. This is a little janky, but it works - you can offer any suggestions for improvement [here](https://github.com/mizzao/meteor-autocomplete/issues/4).

An autocomplete template is just a normal Meteor template that is passed in the matched document. For example, if you were matching on `Meteor.users` and you just wanted to display the username, you can do something very simple, and display the same field:

```
<template name="userPill">
    <span class="label">{{username}}</span>
</template>
```

However, you might want to do something a little more fancy and show not only the user, but whether they are online or not (with something like the [user-status](https://github.com/mizzao/meteor-user-status) package. In that case you could do something like the following:

```
<template name="userPill">
    <span class="label {{labelClass}}">{{username}}</span>
</template>
```

and accompanying code:

```javascript
Template.userPill.labelClass = function() {
  if this._id === Meteor.userId()
    return "label-warning"
  else if this.profile.online === true
    return "label-success"
  else
    return ""
}
```

This (using normal Bootstrap classes) will cause the user to show up in orange for him/herself, in green for other users that are online, and in grey otherwise. See [CrowdMapper's templates](https://github.com/mizzao/CrowdMapper/blob/master/client/views/common.html) for other interesting things you may want to do.

### Future Work (a.k.a. send pull requests)

- To reduce latency, the server could use `Meteor.methods` to return an array of documents, instead of pub/sub, if the client's cache of the collection is assumed to be read-only.
- The widget can keep track of a list of ordered document ids for matched items instead of just spitting out the fields (which currently should be unique)
- Could potentially support rendering DOM elements instead of just text. However, this can currently be managed in post-processing code for chat/post functions (like how GitHub does it).

### Known Issues

- Empty list (and css shadow) renders if rule activated but no matches (a reactivity headache otherwise, requires some thought to rewrite)
- Cursor position may be incorrect on a focus
- Regexp only matches from beginning to cursor position in word (done in jquery-sew, could use rewrite)
- Escape key behavior copied from jquery-sew but it's rather vacuous
- Enter key doesn't bubble if no match on a rule (possibly a feature)

### Credits/Notes

- If you are not using Meteor, you may want to check out [jquery sew](https://github.com/tactivos/jquery-sew), from which this was heavily modified.
- If you need tag autocompletion only (from one collection, and no text), try either the [x-editable smart package](https://github.com/nate-strauser/meteor-x-editable-bootstrap) with Select2 or [jquery-tokenInput](http://loopj.com/jquery-tokeninput/). Those support rendering DOM elements in the input field.

### Contributors

- Andrew Mao ([mizzao](https://github.com/mizzao))
- Patrick Coffey ([patrickocoffeyo](https://github.com/patrickocoffeyo))
- Alexey Komissarouk ([AlexeyMK](https://github.com/AlexeyMK))
- Tessa Lau ([tlau](https://github.com/tlau))
- Dan Dascalescu ([dandv](https://github.com/dandv))
- Pascal Richier ([pascoual](https://github.com/pascoual))

If you found this package useful, I gratefully accept donations at [Gittip](https://www.gittip.com/mizzao/).
