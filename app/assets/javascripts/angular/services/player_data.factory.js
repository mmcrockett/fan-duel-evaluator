app.factory('PlayerData', ['$resource', function($resource) {
  return $resource('/players.json', {}, {});
}]);
