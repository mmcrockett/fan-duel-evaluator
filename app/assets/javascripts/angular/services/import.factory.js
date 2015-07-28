app.factory('Import', ['$resource', function($resource) {
  return $resource('/imports.json', {}, {});
}]);
