var app = angular.module('FanDuelEvaluator', ['ngResource', 'googlechart']);
app.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);
