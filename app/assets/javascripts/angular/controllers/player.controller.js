app.controller('PlayerController', ['$scope', 'Leagues', '$window', 'PlayerData', 'JsLiteral', '$filter', function($scope, Leagues, $window, PlayerData, JsLiteral, $filter) {
  $scope.league_changed = false;
  $scope.leagues = Leagues.options;
  $scope.selectedLeague = "NONE";
  $scope.positions = [{id:"NONE"}];
  $scope.selectedPosition = "NONE";
  $scope.value   = 0;
  $scope.wrapper = null;
  angular.element($window).bind('keyup.delete', function(e) {
    if ((46 == e.keyCode) || (8 == e.keyCode)) {
      if (true == angular.isObject($scope.wrapper)) {
        var ids_to_ignore = [];
        angular.forEach($scope.selected, function(gitem, i) {
          ids_to_ignore.push($scope.wrapper.getDataTable().getValue(gitem.row, 0));
        });
        if (0 <= ids_to_ignore.length) {
          $scope.message = "Adding players to ignore list...";
          new PlayerData({ignore:ids_to_ignore}).$save({},
            function(v){
              $scope.wrapper.getChart().setSelection();
              $scope.selected = [];
              $scope.get_player_data();
              $scope.message = "Ignored " + ids_to_ignore.length + " players."
            },
            function(e){
              $scope.message = "!ERROR: Unable to hide players.";
            }
          );
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
          $scope.chart.options.sortColumn = i - 1;
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
      $scope.selected_player_data = $filter('filter')($scope.player_data, {pos: $scope.selectedPosition}, true);
    }

    $scope.calculate_avg_value();
  };
  $scope.calculate_avg_value = function() {
    var top_25 = 0;
    var cost   = 0;
    var points = 1;

    $scope.selected_player_data = $filter('orderBy')($scope.selected_player_data, 'avg', true);

    top_25 = $scope.selected_player_data.length * 0.25;

    for (var i = 0; i < (top_25); i += 1) {
      var wdata = $scope.selected_player_data[i];
      if (i < top_25) {
        cost   += wdata.cost;
        points += wdata.avg;
      }
    }

    $scope.value = parseInt(cost/points);
  };
  $scope.build_positions = function() {
    $scope.selectedPosition = "NONE";
    $scope.chart.options.sortColumn = null;
    $scope.positions = [{id:"NONE"}];
    var positions = {};

    angular.forEach($scope.player_data, function(player, i) {
      if (true !== positions[player.pos]) {
        positions[player.pos] = true;
        $scope.positions.push({id:player.pos});
      }
    });
  };
  $scope.select_league = function() {
    $scope.league_changed = true;
    $scope.get_player_data();
  };
  $scope.update_chart_columns = function() {
    var i = 0;
    var show_columns = [];
    angular.forEach($scope.selected_player_data[0], function(v, k) {
      if ("id" != k) {
        show_columns.push(i);
      }

      i += 1;
    });
    $scope.chart.view = {columns:show_columns};
  };
  $scope.get_player_data = function() {
    $scope.message = "";
    if ("NONE" != $scope.selectedLeague) {
      $scope.message = "Retrieving player data...";
      PlayerData.query({league:$scope.selectedLeague},
          function(v){
            $scope.message = "";
            $scope.player_data = v;
            $scope.select_player_data();
            if (true == $scope.league_changed) {
              $scope.build_positions();
              $scope.update_chart_columns();
              $scope.league_changed = false;
            }
          },
          function(e){
            $scope.message = "Couldn't load player data.";
          }
      );
    } else {
      $scope.player_data = [];
      $scope.select_player_data();
      if (true == $scope.league_changed) {
        $scope.update_chart_columns();
        $scope.league_changed = false;
      }
    }
  };
  $scope.get_player_details = function() {
    $scope.message = "Processing player details...";
    new PlayerData({league:$scope.selectedLeague}).$update({},
        function(v){
          $scope.message="Retrieved player details.";
          $scope.get_player_data();
        },
        function(e){
          $scope.message = "!ERROR: Unable to get game details.";
        });
  };
  $scope.$watch('selected_player_data', $scope.create_chart);
  $scope.$watch('selectedPosition', $scope.select_player_data);
  $scope.$watch('selectedLeague', $scope.select_league);
}]);
