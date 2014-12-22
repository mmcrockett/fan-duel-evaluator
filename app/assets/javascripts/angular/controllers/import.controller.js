app.controller('ImportController', ['$scope', 'Leagues', 'FanDuelData', function($scope, Leagues, FanDuelData) {
  $scope.message = "";
  $scope.parse_fan_duel_uri = function() {
    $scope.message = "Processing...";
    new FanDuelData({
      uri:$scope.fan_duel_uri
    }).$save({},
      function(v){
        $scope.fan_duel_uri="";
        $scope.message = "Successfully imported."
      }, function(e){
        $scope.message = "!ERROR parsing uri."
      });
  };
}]);
