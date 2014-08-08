Package.describe({
  summary: "Client/server autocompletion designed for Meteor's collections and reactivity",
  version: "0.4.7",
  git: "https://github.com/mizzao/meteor-autocomplete.git"
});

Package.onUse(function (api) {
  api.versionsFrom("METEOR-CORE@0.9.0-atm");

  api.use(['ui', 'templating', 'jquery'], 'client');
  api.use(['coffeescript', 'underscore']); // both

  api.use("dandv:caret-position@2.1.0-3", 'client');

  // Our files
  api.add_files([
    'autocomplete.css',
    'inputs.html',
    'autocomplete-client.coffee',
    'templates.coffee'
  ], 'client');
  
  api.add_files([
    'autocomplete-server.coffee'
  ], 'server');

  api.export('AutocompleteTest', {testOnly: true});
});

Package.onTest(function(api) {
  api.use("mizzao:autocomplete");

  api.use('coffeescript');
  api.use('tinytest');

  api.add_files('tests/rule_tests.coffee', 'client');
  api.add_files('tests/regex_tests.coffee', 'client');
  api.add_files('tests/param_tests.coffee', 'client');
  api.add_files('tests/security_tests.coffee');
});
