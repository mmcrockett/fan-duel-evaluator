app.controller('ImportController', ['$scope', 'Leagues', 'FanDuelData', function($scope, Leagues, FanDuelData) {
  $scope.leagues = Leagues.options;
  $scope.selectedLeague = "NONE";
  $scope.fan_duel_data = "";
  $scope.message = "";
  $scope.fan_duel_game_id = null;
  $scope.add_fan_duel_json = function() {
    new FanDuelData({
      data:$scope.fan_duel_data,
      league:$scope.selectedLeague,
      fd_game_id:$scope.fan_duel_game_id
    }).$save({},
      function(v){
        $scope.fan_duel_data="";
        $scope.fan_duel_game_id=null;
        $scope.message = "Successfully imported."
      }, function(e){
        $scope.message = "!ERROR saving fan duel json."
      });
  };
}]);
