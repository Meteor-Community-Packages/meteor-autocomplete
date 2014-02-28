Package.describe({
  summary: "symbol-triggered autocompletion using Meteor collections"
});

Package.on_use(function (api) {
  api.use(['handlebars', 'templating'], 'client');
  api.use(['coffeescript', 'jquery'], 'client');

  // Required by caretposition.js right now
  api.use('jquery-migrate');

  // Our files
  api.add_files([
      'autocomplete.css',
      'inputs.html',
      'jquery.caretposition.js',
      'autocomplete.coffee',
      'templates.coffee'
  ], 'client');
});
