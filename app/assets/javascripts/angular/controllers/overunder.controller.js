app.controller('OverUnderController', ['$scope', 'Leagues', '$window', 'OverUnderData', 'JsLiteral', '$filter', function($scope, Leagues, $window, OverUnderData, JsLiteral, $filter) {
  $scope.league_changed = false;
  $scope.leagues = Leagues.options;
  $scope.selectedLeague = "NONE";
  $scope.overunder_wrapper = null;
  $scope.overunder_data = [];
  $scope.set_overunder_wrapper = function(wrapper) {
    $scope.overunder_wrapper = wrapper;
  };
  $scope.overunder_chart = {
    "type": "Table",
    "options": {
      "sortAscending": false
    }
  };
  $scope.set_sort = function(sortParams) {
    if (true == angular.isObject(sortParams)) {
      $scope.overunder_chart.options.sortColumn = sortParams.column;
      $scope.overunder_chart.options.sortAscending = sortParams.ascending;
      $scope.recalculate += 1;
    } else if (false == angular.isNumber($scope.overunder_chart.options.sortColumn)) {
      var i = 0;
      angular.forEach($scope.overunder_data[0], function(v, k) {
        if ("score" == k) {
          $scope.overunder_chart.options.sortColumn = i;
          return true;
        } else {
          i += 1;
        }
      });
      $scope.recalculate += 1;
    }
  };
  $scope.create_overunder_chart = function() {
    $scope.set_sort(null);
    $scope.overunder_chart.data = JsLiteral.get_chart_data($scope.overunder_data);
  };
  $scope.select_overunder_data = function() {
    $scope.message = "";
    $scope.update_chart_columns($scope.overunder_data, $scope.overunder_chart);
    $scope.recalculate += 1;
  };
  $scope.calculate_value = function() {
    var cost   = 0;
    var points = 0;
    var i = 0;
    var column_name = null;
    var sorted_overunder_data = null;

    angular.forEach($scope.overunder_data[0], function(v, k) {
      if ($scope.overunder_chart.options.sortColumn == (i - 1)) {
        column_name = k;
      }
      i += 1;
    });

    for (var i = 0; i < $scope.overunder_data.length; i += 1) {
      var wdata = $scope.overunder_data[i];
      var count_data = wdata[column_name];
      cost   += wdata.cost;

      if (true == angular.isNumber(count_data)) {
        points += count_data;
      } else {
        points += wdata.avg;
      }
    }

    $scope.avg_value = parseInt(cost/points);
  };
  $scope.select_league = function() {
    $scope.league_changed = true;
    $scope.get_overunder_data();
  };
  $scope.update_chart_columns = function(data, chart) {
    var i = 0;
    var show_columns = [];
    angular.forEach(data[0], function(v, k) {
      if ("id" != k) {
        show_columns.push(i);
      }

      i += 1;
    });
    if (0 != show_columns.length) {
      chart.view = {columns:show_columns};
    } else {
      chart.view = undefined;
    }
  };
  $scope.get_overunder_data = function() {
    $scope.message = "";
    if ("NONE" != $scope.selectedLeague) {
      $scope.message = "Retrieving overunder data...";
      OverUnderData.query({league:$scope.selectedLeague},
          function(v){
            $scope.message = "";
            $scope.overunder_data = v;
            $scope.select_overunder_data();
            if (true == $scope.league_changed) {
              $scope.league_changed = false;
            }
          },
          function(e){
            $scope.message = "Couldn't load overunder data.";
          }
      );
    } else {
      $scope.overunder_data = [];
      $scope.select_overunder_data();
      if (true == $scope.league_changed) {
        $scope.league_changed = false;
      }
    }
  };
  $scope.$watch('overunder_data', $scope.create_overunder_chart);
  $scope.$watch('selectedLeague', $scope.select_league);
  $scope.$watch('recalculate', $scope.calculate_value);
}]);