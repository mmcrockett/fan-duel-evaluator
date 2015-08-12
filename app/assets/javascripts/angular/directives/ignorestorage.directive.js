app.directive('ngIgnoreStorage', ['localStorageService', 'Import', function(LocalStorage, Import) {
  return {
    restrict: 'E',
    scope: {
      ignoreList: '=',
      league: '='
    },
    link: function ($scope, elem, attrs) {
      $scope.$watch(function() {
        return $scope.league;
      }, function() {
        if (true == angular.isString($scope.league)) {
          console.log("Calling import get.");
          Import.get({
              league:$scope.league
            },
            function(v) {
              if (true == angular.isNumber(v.id)) {
                var key = 'ignoreList_' + $scope.league + '_' + v.id;
                LocalStorage.bind($scope, 'ignoreList', [], key);
              } else {
                console.warn("Import id not a number '" + v.id + "'");
              }
            },
            function(e) {
              console.warn("Couldn't get import id '" + e.statusText + "'");
            }
          );
        }
      });
    }
  }
}]);
