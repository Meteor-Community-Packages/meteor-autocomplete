Package.describe({
    summary: "symbol-triggered autocompletion using Meteor collections"
});

Package.on_use(function (api) {
    api.use(['handlebars', 'templating'], 'client');
    api.use(['coffeescript', 'jquery'], 'client');

    // Our files
    api.add_files([
        'inputs.html',
        'caretposition.js',
        'sew.js',
        'autocomplete.coffee'
    ], 'client');

});
