app.factory('WeekData', ['$resource', function($resource) {
  return $resource('/week_data.json', {}, {});
}]);
