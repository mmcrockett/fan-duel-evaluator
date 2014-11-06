app.controller('PlayerController', ['$scope', 'Leagues', '$window', 'PlayerData', 'JsLiteral', 'filterFilter', function($scope, Leagues, $window, PlayerData, JsLiteral, filter) {
  $scope.leagues = Leagues.options;
  $scope.selectedLeague = "NONE";
  $scope.positions = [{id:"NONE"}];
  $scope.selectedPosition = "NONE";
  $scope.wrapper = null;
  angular.element($window).bind('keyup.delete', function(e) {
    if ((46 == e.keyCode) || (8 == e.keyCode)) {
      if (true == angular.isObject($scope.wrapper)) {
        var ids_to_ignore = [];
        angular.forEach($scope.selected, function(gitem, i) {
          ids_to_ignore.push($scope.wrapper.getDataTable().getValue(gitem.row, 0));
        });
        if (0 <= ids_to_ignore.length) {
          new PlayerData({ignore:ids_to_ignore}).$save({}, function(v){$scope.wrapper.getChart().setSelection();$scope.selected = [];$scope.get_player_data();$scope.message = "Ignored " + ids_to_ignore.length + " players."}, function(e){$scope.message = "!ERROR: Unable to hide players.";});
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
        if ("average" == k) {
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
    $scope.message = "";
    if ("NONE" == $scope.selectedPosition) {
      $scope.selected_player_data = $scope.player_data;
    } else {
      $scope.selected_player_data = $scope.filter($scope.player_data, {position: $scope.selectedPosition}, true)
    }
  };
  $scope.build_positions = function() {
    $scope.selectedPosition = "NONE";
    $scope.chart.options.sortColumn = null;
    $scope.positions = [{id:"NONE"}];
    var positions = {};

    angular.forEach($scope.player_data, function(player, i) {
      if (true !== positions[player.position]) {
        positions[player.position] = true;
        $scope.positions.push({id:player.position});
      }
    });
  };
  $scope.get_player_data = function() {
    $scope.message = "";
    if ("NONE" != $scope.selectedLeague) {
      PlayerData.query({league:$scope.selectedLeague}, function(v){$scope.player_data = v;$scope.build_positions();$scope.select_player_data();}, function(e){$scope.message = "Couldn't load player data.";});
    }
  };
  $scope.$watch('selected_player_data', $scope.create_chart);
  $scope.$watch('selectedPosition', $scope.select_player_data);
  $scope.$watch('selectedLeague', $scope.get_player_data);
}]);
