Package.describe({
  name: "nidem-autocomplete",
  summary: "Client/server autocompletion designed for Meteor's collections and reactivity",
  version: "0.5.1",
  git: "https://github.com/nidem/meteor-autocomplete.git"
});

Package.onUse(function (api) {
  api.versionsFrom("1.0");

  api.use(['blaze', 'templating', 'jquery', 'check', 'tracker'], 'client');
  api.use(['coffeescript', 'underscore']); // both
  api.use(['mongo', 'ddp']);

  api.use("dandv:caret-position@2.1.1", 'client');

  // Our files
  api.addFiles([
    'autocomplete.css',
    'inputs.html',
    'autocomplete-client.coffee',
    'templates.coffee'
  ], 'client');

  api.addFiles([
    'autocomplete-server.coffee'
  ], 'server');

  api.export('Autocomplete', 'server');
  api.export('AutocompleteTest', {testOnly: true});
});

Package.onTest(function(api) {
  //api.use("nidem-autocomplete");

  api.use('coffeescript');
  api.use('mongo');
  api.use('tinytest');

  api.use(['blaze', 'templating', 'jquery', 'check', 'tracker'], 'client');
  api.use(['coffeescript', 'underscore']); // both

  api.addFiles([
    'inputs.html',
    'autocomplete-client.coffee',
    'templates.coffee'
  ], 'client');

  api.addFiles([
    'autocomplete-server.coffee'
  ], 'server');

  api.export('Autocomplete', 'server');
  api.export('AutocompleteTest', {testOnly: true});

  api.addFiles('tests/rule_tests.coffee', 'client');
  api.addFiles('tests/regex_tests.coffee', 'client');
  api.addFiles('tests/param_tests.coffee', 'client');
  api.addFiles('tests/security_tests.coffee');
});
