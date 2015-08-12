app.controller('AnalysisController', ['$scope', 'AnalysisData', 'Roster', 'DefaultChart', 'JsLiteral', function($scope, AnalysisData, Roster, DefaultChart, JsLiteral) {
  $scope.rosters = [];
  $scope.select_league = function(selectedLeague) {
    if ("NONE" != selectedLeague) {
      $scope.messages.push("Retrieving rosters.");
      AnalysisData.query({league:selectedLeague},
          function(v){
            $scope.rosters = [];

            for (var i = 0; i < v.length; i += 1) {
              var chart = DefaultChart.default_chart();
              var data = Roster.create_roster(selectedLeague, v[i].players, v[i].notes);
              chart.data = JsLiteral.get_chart_data(data);
              $scope.update_chart_columns(data, chart);
              $scope.rosters.push({chart:chart, name:v[i].notes});
            }
          },
          function(e){
            $scope.messages.push("error Couldn't load rosters '" + e.message + "'.");
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
