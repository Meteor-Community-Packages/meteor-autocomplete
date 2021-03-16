import { Mongo } from "meteor/mongo";
import { Meteor } from "meteor/meteor";

export const Autocomplete = function() {
  function Autocomplete() {}

  Autocomplete.publishCursor = function(cursor, sub) {
    return Mongo.Collection._publishCursor(cursor, sub, "autocompleteRecords");
  };

  return Autocomplete;

};

/*
Meteor.publish('autocomplete-recordset', function(selector, options, collName) {
  const collection = new Mongo.Collection(collName);
  if (!collection) {
    throw new Error(collName + ' is not defined on the global namespace of the server.');
  }
  if (!collection._isInsecure()) {
    Meteor._debug(collName + ' is a secure collection, therefore no data was returned because the client could compromise security by subscribing to arbitrary server collections via the browser console. Please write your own publish function.');
    return [];
  }
  if (options.limit) {
    options.limit = Math.min(50, Math.abs(options.limit));
  }
  Autocomplete.publishCursor(collection.find(selector, options), this);
  return this.ready();
});
 */
