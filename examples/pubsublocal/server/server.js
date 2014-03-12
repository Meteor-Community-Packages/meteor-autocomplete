Meteor.startup(function () {
  if (!BigCollection.find().count()) {
    // Create a "large" collection with a series of records that area easy to
    // predict by a human, but not continuous, so that only some searches will
    // match. For example, all 4-letter words that can be typed with the 20
    // letters from 'a' to 't'. Furthermore, stuff them in the database in a
    // non-alphabetical order, to test how sorting works.
    var someLetters = 'tsrqponmlkjihgfedcba'.split('');
    for (var i1 = 0; i1 < someLetters.length; i1++) {
      for (var i2 = 0; i2 < someLetters.length; i2++) {
        for (var i3 = 0; i3 < someLetters.length; i3++) {
          for (var i4 = 0; i4 < someLetters.length; i4++) {
            BigCollection.insert({
              _id: i1.toString() + '-' + i2.toString() + '-' + i3.toString() + '-' + i4.toString(),
              name: someLetters[i1]+someLetters[i2]+someLetters[i3]+someLetters[i4]
            })
          }
        }
      }
    }
  }

  // Create an index on the name field of BigCollection
  BigCollection._ensureIndex({name: 1});
});

// don't publish anything - the out-of-the-box server code will take care of that
