app.factory('FanDuelData', ['$resource', function($resource) {
  return $resource('/fan_duel_player.json', {}, {});
}]);
