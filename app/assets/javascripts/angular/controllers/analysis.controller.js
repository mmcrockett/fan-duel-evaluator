app.controller('AnalysisController', ['$scope', '$http', 'AnalysisData', 'filterFilter', function($scope, $http, AnalysisData, filter) {
  $scope.analysis_data = [];
  $scope.chart = {
    "type": "Table",
    "options": {
      //"sortColumn": 6,
      "sortAscending": false
    }
  };
  $scope.create_chart = function() {
    $scope.chart.data = {};
    $scope.chart.data.cols = [];
    $scope.chart.data.rows = [];
    angular.forEach($scope.analysis_data, function(wdata, i) {
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
  $scope.$watch('analysis_data', $scope.create_chart);
  $scope.get_analysis_data = function() {
    AnalysisData.query({}, function(v){$scope.analysis_data = v;}, function(e){console.error("Couldn't load analysis data.");});
  };
}]);
