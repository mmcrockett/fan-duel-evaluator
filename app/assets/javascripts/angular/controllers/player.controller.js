app.controller('PlayerController', ['$scope', '$http', 'PlayerData', 'JsLiteral', 'filterFilter', function($scope, $http, PlayerData, JsLiteral, filter) {
  $scope.filter = filter;
  $scope.positions = [{id:"NONE"}, {id:"QB"}, {id:"WR"}, {id:"RB"}, {id:"TE"}, {id:"K"}, {id:"D"}];
  $scope.selectedPosition = "NONE";
  $scope.selected_player_data = [];
  $scope.player_data = [];
  $scope.chart = {
    "type": "Table",
    "options": {
      "sortColumn": 6,
      "sortAscending": false
    }
  };
  $scope.create_chart = function() {
    $scope.chart.data = JsLiteral.get_chart_data($scope.selected_player_data);
  };
  $scope.select_player_data = function() {
    if ("NONE" == $scope.selectedPosition) {
      $scope.selected_player_data = $scope.player_data;
    } else {
      $scope.selected_player_data = $scope.filter($scope.player_data, {position: $scope.selectedPosition}, true)
    }
  };
  $scope.$watch('selected_player_data', $scope.create_chart);
  $scope.$watch('selectedPosition', $scope.select_player_data);
  $scope.get_player_data = function() {
    PlayerData.query({}, function(v){$scope.player_data = v;$scope.select_player_data();}, function(e){console.error("Couldn't load player data.");});
  };
}]);
