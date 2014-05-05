Package.describe({
  summary: "Autocomplete using Meteor collections on client and server"
});

Package.on_use(function (api) {
  api.use(['ui', 'templating', 'jquery'], 'client');
  api.use(['coffeescript', 'underscore']); // both

  api.use('caret-position', 'client');

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

Package.on_test(function(api) {
  api.use('autocomplete');

  api.use('coffeescript');
  api.use('tinytest');

  api.add_files('tests/rule_tests.coffee', 'client');
  api.add_files('tests/regex_tests.coffee', 'client');
  api.add_files('tests/param_tests.coffee', 'client');
  api.add_files('tests/security_tests.coffee');
});
