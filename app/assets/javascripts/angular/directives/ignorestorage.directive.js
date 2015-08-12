app.directive('ngIgnoreStorage', ['localStorageService', 'Import', function(LocalStorage, Import) {
  return {
    restrict: 'E',
    scope: {
      ignoreList: '=',
      league: '='
    },
    link: function ($scope, elem, attrs) {
      $scope.$watch('ignoreList', function() {
        if ((true == angular.isArray($scope.ignoreList)) && (true == angular.isNumber($scope.ignore_id))) {
          var ignore_lists = LocalStorage.get('ignoreLists', {});

          ignore_lists[$scope.ignore_id] = $scope.ignoreList;
          LocalStorage.set('ignoreLists', ignore_lists);
        }
      });

      $scope.$watch(function() {
        return $scope.league;
      }, function() {
        if (true == angular.isString($scope.league)) {
          Import.get({
              league:$scope.league
            },
            function(v) {
              var ignore_lists = LocalStorage.get('ignoreLists');

              if ((false == angular.isObject(ignore_lists)) || (false == angular.isNumber(v.id)) || (false == angular.isArray(ignore_lists[v.id]))) {
                $scope.ignoreList= [];
              } else {
                $scope.ignoreList = ignore_lists[v.id];
              }

              if (true == angular.isNumber(v.id)) {
                $scope.ignore_id = v.id;
              }
            },
            function(e) {
              console.warn("Couldn't save ignore list '" + e.statusText + "'");
            }
          );
        }
      });
    }
  }
}]);
