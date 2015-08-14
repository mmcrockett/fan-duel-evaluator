app.directive('ngPlayerDropDown', [function() {
  return {
    restrict: 'E',
    template: '<span dropdown dropdown-append-to-body>' +
                '<a dropdown-toggle href="" class="player-drop-down" >' +
                  '<span class="caret"></span>' +
                '</a>' +
                '<ul class="dropdown-menu">' +
                  '<li ng-hide="playerOnRoster"><a href="" ng-click="rosterAdd()">Add to Roster</a></li>' +
                  '<li ng-show="playerOnRoster"><a href="" ng-click="rosterRemove()">Remove from Roster</a></li>' +
                  '<li ng-hide="playerIgnored"> <a href="" ng-click="ignoreAdd()">Ignore</a></li>' +
                  '<li ng-show="playerIgnored"> <a href="" ng-click="ignoreRemove()">Un-Ignore</a></li>' +
                '</ul>' +
              '</span>',
    scope: {
      playerIgnored : '=',
      playerOnRoster: '=',
      playerId      : '=',
      scopeId       : '='
    },
    link: function ($scope) {
      $scope.getPlayerControllerScope = function() {
        if (false == angular.isObject($scope.playerControllerScope)) {
          var _scope = $scope;

          for (var i = 0; i < 5; i += 1) {
            if ($scope.scopeId == _scope.$id) {
              $scope.playerControllerScope = _scope;
              break;
            } else if (true == angular.isObject(_scope.$parent)) {
              _scope = _scope.$parent;
            } else {
              console.error("!ERROR: Out of parent scopes.");
              break;
            }
          }
        }

        return $scope.playerControllerScope;
      };

      $scope.ignoreAdd = function () {
        $scope.playerIgnored = $scope.getPlayerControllerScope().ignore_add_player($scope.playerId);
      };

      $scope.ignoreRemove = function () {
        $scope.playerIgnored = $scope.getPlayerControllerScope().ignore_remove_player($scope.playerId);
      };

      $scope.rosterAdd = function () {
        $scope.playerOnRoster = $scope.getPlayerControllerScope().roster_add_player($scope.playerId);
      };

      $scope.rosterRemove = function () {
        $scope.playerOnRoster = $scope.getPlayerControllerScope().roster_remove_player($scope.playerId);
      };
    }
  }
}]);
