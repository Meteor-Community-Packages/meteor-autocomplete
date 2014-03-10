Package.describe({
  summary: "Symbol-triggered autocompletion using Meteor collections"
});

Package.on_use(function (api) {
  api.use(['handlebars', 'templating'], 'client');
  api.use(['coffeescript'], ['client', 'server']);
  api.use(['jquery'], 'client');

  // Required by caretposition.js right now
  api.use('jquery-migrate');

  // Our files
  api.add_files([
    'autocomplete.css',
    'inputs.html',
    'jquery.caretposition.js',
    'autocomplete-client.coffee',
    'templates.coffee'
  ], 'client');
  
  api.add_files([
    'autocomplete-server.coffee',
  ], 'server');
});
