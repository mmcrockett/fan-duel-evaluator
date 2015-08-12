app.controller('ImportController', ['$scope', 'Leagues', 'Import', function($scope, Leagues, Import) {
  $scope.parse_fan_duel_uri = function() {
    $scope.messages.push("Starting import.");
    new Import({
      uri:$scope.fan_duel_uri
    }).$save({},
      function(v){
        $scope.fan_duel_uri="";
        $scope.messages.push("Successfully imported.");
      }, function(e){
        $scope.messages.push("error parsing uril '" + e.message + "'.");
      });
  };
}]);
