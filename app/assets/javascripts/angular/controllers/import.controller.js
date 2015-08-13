app.controller('ImportController', ['$scope', 'Leagues', 'Import', function($scope, Leagues, Import) {
  $scope.parse_fan_duel_uri = function() {
    $scope.progress.message = "Importing";
    Import
    .save({uri:$scope.fan_duel_uri})
    .$promise
    .then(
      function(v){
        $scope.fan_duel_uri="";
        $scope.alerts.create_success("Successfully imported.");
      }
    ).catch(
      function(e){
        $scope.alerts.create_error("Parsing failed");
      }
    ).finally(function() {
      $scope.progress.message = "";
    });
  };
}]);
