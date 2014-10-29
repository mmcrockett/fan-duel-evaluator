app.controller('PlayerController', ['$scope', '$http', '$window', 'PlayerData', 'JsLiteral', 'filterFilter', function($scope, $http, $window, PlayerData, JsLiteral, filter) {
  $scope.wrapper = null;
  angular.element($window).bind('keyup.delete', function(e) {
    if ((46 == e.keyCode) || (8 == e.keyCode)) {
      if (true == angular.isObject($scope.wrapper)) {
        var ids_to_ignore = [];
        angular.forEach($scope.selected, function(gitem, i) {
          ids_to_ignore.push($scope.wrapper.getDataTable().getValue(gitem.row, 0));
        });
        if (0 <= ids_to_ignore.length) {
          new PlayerData({ignore:ids_to_ignore}).$save({}, function(v){$scope.wrapper.getChart().setSelection();$scope.selected = [];$scope.get_player_data();}, function(e){console.error("!ERROR: Unable to hide players.");});
        }
      }
    }
  });
  $scope.selected = [];
  $scope.set_selected = function(selected_items) {
    $scope.selected = selected_items;
  };
  $scope.set_wrapper = function(wrapper) {
    $scope.wrapper = wrapper;
  };
  $scope.filter = filter;
  $scope.positions = [{id:"NONE"}, {id:"QB"}, {id:"WR"}, {id:"RB"}, {id:"TE"}, {id:"K"}, {id:"D"}];
  $scope.selectedPosition = "NONE";
  $scope.selected_player_data = [];
  $scope.player_data = [];
  $scope.chart = {
    "type": "Table",
    "options": {
      "sortAscending": false
    }
  };
  $scope.set_sort = function(sortParams) {
    if (true == angular.isObject(sortParams)) {
      $scope.chart.options.sortColumn = sortParams.column;
      $scope.chart.options.sortAscending = sortParams.ascending;
    } else if (false == angular.isNumber($scope.chart.options.sortColumn)) {
      var i = 0;
      angular.forEach($scope.selected_player_data[0], function(v, k) {
        if ("avg" == k) {
          $scope.chart.options.sortColumn = i;
          return true;
        } else {
          i += 1;
        }
      });
    }
  };
  $scope.create_chart = function() {
    $scope.set_sort(null);
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
