app.directive('ngLeagueSelector', ['$cookies', 'Leagues', function($cookies, Leagues) {
  return {
    restrict: 'E',
    template: '<select ng-model="selectedLeague" ng-options="item.id as item.id for item in leagues"></select>',
    scope: {
      onSelectLeague: '&'
    },
    link: function (scope, elem, attrs) {
      scope.leagues = Leagues.options;
      scope.selectedLeague = $cookies.get('selectedLeague');

      if (false == angular.isString(scope.selectedLeague)) {
        scope.selectedLeague = "NONE";
      }

      scope.$watch('selectedLeague', function() {
        $cookies.selectedLeague = scope.selectedLeague;
        scope.onSelectLeague({league:scope.selectedLeague});
      });
    }
  }
}]);
