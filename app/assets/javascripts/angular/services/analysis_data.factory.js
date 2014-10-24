app.factory('AnalysisData', ['$resource', function($resource) {
  return $resource('/analysis.json', {}, {});
}]);
