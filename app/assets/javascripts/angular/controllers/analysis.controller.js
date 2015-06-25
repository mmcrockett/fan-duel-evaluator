app.controller('AnalysisController', ['$scope', 'AnalysisData', 'Roster', 'JsLiteral', function($scope, AnalysisData, Roster, JsLiteral) {
  $scope.rosters = [];
  $scope.message = "";
  $scope.select_league = function(selectedLeague) {
    $scope.message = "";
    if ("NONE" != selectedLeague) {
      $scope.message = "Retrieving rosters...";
      AnalysisData.query({league:selectedLeague},
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
              var data = Roster.create_roster(selectedLeague, v[i].players, v[i].notes);
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
}]);
