app.directive('ngLeagueSelector', ['localStorageService', 'Leagues', function(LocalStorage, Leagues) {
  return {
    restrict: 'E',
    template: '<select ng-model="selectedLeague" ng-options="item.id as item.id for item in leagues"></select>',
    scope: {
      onSelectLeague: '&'
    },
    link: function ($scope, elem, attrs) {
      $scope.leagues        = Leagues.options;
      LocalStorage.bind($scope, 'selectedLeague', 'NONE');

      $scope.$watch('selectedLeague', function() {
        $scope.onSelectLeague({league:$scope.selectedLeague});
      });
    }
  }
}]);
