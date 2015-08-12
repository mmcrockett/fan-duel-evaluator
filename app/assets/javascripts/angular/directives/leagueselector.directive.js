app.directive('ngLeagueSelector', ['localStorageService', 'Leagues', function(LocalStorage, Leagues) {
  return {
    restrict: 'E',
    template: '<select ng-model="selectedLeague" ng-options="item.id as item.id for item in leagues"></select>',
    scope: {
      onSelectLeague: '&'
    },
    link: function ($scope, elem, attrs) {
      $scope.leagues        = Leagues.options;
      $scope.selectedLeague = LocalStorage.get('selectedLeague', 'NONE');
      LocalStorage.bind($scope, 'selectedLeague');

      $scope.$watch('selectedLeague', function() {
        $scope.onSelectLeague({league:$scope.selectedLeague});
      });
    }
  }
}]);
