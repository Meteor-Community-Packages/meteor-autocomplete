meteor-autocomplete
===================

Prefix auto-completion using documents and fields in local Meteor collections.

## What's this do?

## Usage

```
{
    token: '@'
    collection: Foo
    field: "name"
}
```

### Known Issues

- Not changing selection of item when current selection loses match
- Empty list (shadow) renders if rule matches but no content (a reactivity headache otherwise)
- Items that disappear from list may get selected
- Cursor position may be incorrect on a focus
- Regexp does not always match on entire word

### Credits/Notes

- If you are not using Meteor, you may want to check out [jquery sew](https://github.com/tactivos/jquery-sew), from which this was heavily modified.
- If you need tag autocompletion only (and no symbols), try either the [x-editable smart package](https://github.com/nate-strauser/meteor-x-editable-bootstrap) with Select2 or [jquery-tokenInput](http://loopj.com/jquery-tokeninput/).
