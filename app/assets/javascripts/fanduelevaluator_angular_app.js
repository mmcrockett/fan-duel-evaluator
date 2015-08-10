var app = angular.module('FanDuelEvaluator', ['ngResource', 'ngCookies', 'googlechart', 'ui.bootstrap', 'angular.filter']);
app.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);
