Package.describe({
  name: "mizzao:autocomplete",
  summary: "Client/server autocompletion designed for Meteor's collections and reactivity",
  version: "1.0.0",
  git: "https://github.com/mizzao/meteor-autocomplete.git"
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
  api.use("mizzao:autocomplete");

  api.use('mongo');
  api.use('tinytest');

  api.addFiles('tests/rule_tests.js', 'client');
  api.addFiles('tests/regex_tests.js', 'client');
  api.addFiles('tests/param_tests.js', 'client');
  api.addFiles('tests/security_tests.js');
});
