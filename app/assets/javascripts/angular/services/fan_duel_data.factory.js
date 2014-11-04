app.factory('FanDuelData', ['$resource', function($resource) {
  return $resource('/import.json', {}, {});
}]);
