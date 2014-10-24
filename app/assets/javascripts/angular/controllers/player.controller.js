app.controller('PlayerController', ['$scope', '$http', 'PlayerData', 'filterFilter', function($scope, $http, PlayerData, filter) {
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
    $scope.chart.data = {};
    $scope.chart.data.cols = [];
    $scope.chart.data.rows = [];
    angular.forEach($scope.selected_player_data, function(wdata, i) {
      var row = {c:[]};
      angular.forEach(wdata, function(v, k) {
        if (0 == i) {
          var type = "Unknown";
          if (true == angular.isNumber(v)) {
            type = "number";
          } else if (true == angular.isString(v)) {
            type = "string";
          } else if (true == angular.isDate(v)) {
            type = "date";
          } else if ("boolean" === typeof v) {
            type = "boolean";
          } else {
            console.error("!ERROR: type unknown '" + typeof v + "'.");
          }
          $scope.chart.data.cols.push({
            "id"   : k,
            "label": k,
            "type" : type,
          });
        }

        row.c.push({v:v});
      });
      $scope.chart.data.rows.push(row);
    });
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
