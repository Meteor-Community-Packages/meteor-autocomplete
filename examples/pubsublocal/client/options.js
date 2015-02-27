Session.setDefault("position", "top");

Template.options.helpers({
  position: function(arg) {
    return Session.equals("position", arg);
  }
});

Template.options.events({
  "change input": function(e, t) {
    Session.set(e.target.name, e.target.value);
  }
});
