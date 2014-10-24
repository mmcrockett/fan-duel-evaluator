app.controller('AnalysisController', ['$scope', '$http', 'AnalysisData', 'JsLiteral', function($scope, $http, AnalysisData, JsLiteral) {
  $scope.analysis_data = [];
  $scope.chart = {
    "type": "Table",
    "options": {
      //"sortColumn": 6,
      "sortAscending": false
    }
  };
  $scope.create_chart = function() {
    $scope.chart.data = JsLiteral.get_chart_data($scope.analysis_data);
  };
  $scope.$watch('analysis_data', $scope.create_chart);
  $scope.get_analysis_data = function() {
    AnalysisData.query({}, function(v){$scope.analysis_data = v;}, function(e){console.error("Couldn't load analysis data.");});
  };
}]);
