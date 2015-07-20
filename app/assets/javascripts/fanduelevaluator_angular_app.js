var app = angular.module('FanDuelEvaluator', ['ngResource', 'ngCookies', 'googlechart', 'ui.bootstrap']);
app.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);
