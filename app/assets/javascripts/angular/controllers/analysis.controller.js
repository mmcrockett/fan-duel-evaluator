app.controller('AnalysisController', ['$scope', 'Leagues', '$window', 'AnalysisData', 'JsLiteral', '$filter', function($scope, Leagues, $window, AnalysisData, JsLiteral, $filter) {
  $scope.leagues = Leagues.options;
  $scope.selectedLeague = "NONE";
  $scope.rosters = [];
  $scope.message = "";
  $scope.get_rosters = function() {
    $scope.message = "";
    if ("NONE" != $scope.selectedLeague) {
      $scope.message = "Retrieving rosters...";
      AnalysisData.query({league:$scope.selectedLeague},
          function(v){
            $scope.message = "";
            $scope.rosters = [];

            for (var i = 0; i < v.length; i += 1) {
              var chart = {
                type: "Table",
                options: {
                  sortAscending: false
                }
              };
              var data = $scope.calculate_roster(v[i].players, v[i].notes);
              chart.data = JsLiteral.get_chart_data(data);
              $scope.update_chart_columns(data, chart);
              $scope.rosters.push(chart);
            }
          },
          function(e){
            $scope.message = "Couldn't load rosters.";
          }
      );
    } else {
      $scope.rosters = [];
    }
  };
  $scope.select_league = function() {
    $scope.get_rosters();
  };
  $scope.calculate_roster = function(roster, name) {
    var total_row = {};
    var ignore_columns = ["id"];
    roster = $filter('orderBy')(roster, 'pos', true);

    angular.forEach(roster, function(player, i) {
      angular.forEach(player, function(v, k) {
        if (0 == i) {
          if ("name" == k) {
            total_row[k] = "Totals (" + name + ")";
          } else if ("id" == k) {
            total_row[k] = 0;
          } else if (true == angular.isNumber(v)) {
            total_row[k] = 0;
          } else if (true == angular.isString(v)) {
            total_row[k] = "";
          }
        }

        if ((true == angular.isNumber(v)) && (-1 == ignore_columns.indexOf(k))) {
          total_row[k] += v;
        }
      });
    });

    angular.forEach(total_row, function(v, k) {
      if (true == angular.isNumber(v)) {
        total_row[k] = +v.toFixed(1);
      }
    });

    roster.push(total_row);

    return roster;
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
  $scope.$watch('selectedLeague', $scope.select_league);
}]);
