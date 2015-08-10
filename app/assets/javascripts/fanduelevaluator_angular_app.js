var app = angular.module('FanDuelEvaluator', ['ngResource', 'googlechart', 'ui.bootstrap', 'angular.filter', 'LocalStorageModule']);
app.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);
app.config(function(localStorageServiceProvider) {
  localStorageServiceProvider.setPrefix('fantasy_evaluator');
});
