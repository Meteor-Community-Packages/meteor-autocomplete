// client-only collection to demo interoperability with server-side one
Fruits = new Meteor.Collection(null);
['Apple', 'Banana', 'Cherry', 'Date', 'Fig', 'Lemon', 'Melon', 'Prune', 'Raspberry', 'Strawberry', 'Blueberry', 'Blackberry', 'Boysenberry', 'Licorice', 'Watermelon', 'Tomato', 'Jackfruit', 'Kiwi', 'Lime', 'Clementine', 'Tangerine', 'Orange', 'Grape'].forEach(function (fruit) {
  Fruits.insert({type: fruit})
});

Template.body.settings = {
  position: 'bottom',
  limit: 30,  // more than 20, to emphasize matches outside strings *starting* with the filter
  rules: [
    {
      token: '@',
      // string means a server-side collection; otherwise, assume a client-side collection
      collection: 'BigCollection',
      field: 'name',
      // set to true to search anywhere in the field, which cannot use an index.
      template: Template.serverCollectionPill
    },
    {
      token: '!',
      collection: Fruits,  // Meteor.Collection object means client-side collection
      field: 'type',
      template: Template.clientCollectionPill,
      matchAll: true  // 'ba' will match 'bar' and 'baz' first, then 'abacus'
    }
  ]
};
