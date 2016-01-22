var app = angular.module('FantasyEvaluator', ['ngResource', 'googlechart', 'ui.bootstrap', 'LocalStorageModule']);
app.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);
app.config(["localStorageServiceProvider", function(localStorageServiceProvider) {
  localStorageServiceProvider.setPrefix('fantasy_evaluator');
}]);
