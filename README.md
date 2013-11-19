meteor-autocomplete
===================

Prefix auto-completion using documents and fields in local Meteor collections.

## What's this do?

Auto-completes typing in text `input`s or `textarea`s from different Meteor collections when triggered by certain symbols. You've probably seen this when referring to users or issues in a GitHub conversation. For example, you may want to ping a user:

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

```coffeescript
Template.foo.settings = function() {
  return {
   position: "top",
   limit: 5,
   rules: [
     {
       token: '@',
       collection: Meteor.users,
       field: "username",
       template: Template.userPill
     },
     {
       token: '!',
       collection: Dataset,
       field: "_id",
       template: Template.dataPiece
     }
   ]
  }
};
```

- `position` (= `top` or `bottom`) specifies if the autocomplete menu should render above or below the cursor. Select based on the placement of your `input`/`textarea` relative to other elements on the page.
- `limit` controls how big the autocomplete menu should get.
- `rules`: an array of matching rules for the autocomplete widget, which will be checked in order
- `token`: what character should trigger this rule
- `collection`: what collection should be used to match for this rule
- `field`: the field of the collection that the rule will match against
- `template`: the template that should be used to render each list item. The template will be passed the entire matched document as a data context, so render list items as fancily as you would like. For example, it's usually helpful to see metadata for matches as in the pictures above.

Example of an autocomplete template:
```
<template name="userPill">
    <span class="label">{{username}}</span>
</template>
```

### Future Work (a.k.a. send pull requests)

- Allow publish/subscribe for autocomplete in addition to client-side search, making autocompletion for potentially much larger collections possible with a small latency hit. Should be pretty easy to do (just move find cursor to a publication instead of updating on the client) but not sure how common this use case is. Raise an issue or try this in a fork if you really want it.
- The widget can keep track of a list of ordered document ids for matched items instead of just spitting out the fields (which currently should be unique)
- Could potentially support rendering DOM elements instead of just text. However, this can currently be managed in post-processing code for chat/post functions (like how GitHub does it).

### Known Issues

- Empty list (and css shadow) renders if rule activated but no matches (a reactivity headache otherwise, requires some though to rewrite)
- Cursor position may be incorrect on a focus
- Regexp only matches from beginning to cursor position in word (done in jquery-sew, could use rewrite)
- Escape key behavior copied from jquery-sew but it's rather vacuous
- Enter key doesn't bubble if no match on a rule (possibly a feature)

### Credits/Notes

- If you are not using Meteor, you may want to check out [jquery sew](https://github.com/tactivos/jquery-sew), from which this was heavily modified.
- If you need tag autocompletion only (from one collection, and no text), try either the [x-editable smart package](https://github.com/nate-strauser/meteor-x-editable-bootstrap) with Select2 or [jquery-tokenInput](http://loopj.com/jquery-tokeninput/). Those support rendering DOM elements in the input field.

### Contributors

Andrew Mao ([mizzao](https://github.com/mizzao))
Patrick Coffey ([patrickocoffeyo](https://github.com/patrickocoffeyo))
Tessa Lau ([tlau](https://github.com/tlau))
