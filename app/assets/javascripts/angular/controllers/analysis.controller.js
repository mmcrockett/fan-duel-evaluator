app.controller('AnalysisController', ['$scope', 'Leagues', '$window', 'AnalysisData', 'Roster', 'JsLiteral', '$filter', function($scope, Leagues, $window, AnalysisData, Roster, JsLiteral, $filter) {
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
              var data = Roster.create_roster($scope.selectedLeague, v[i].players, v[i].notes);
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
