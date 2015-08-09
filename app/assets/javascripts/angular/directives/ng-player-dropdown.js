app.directive('ngPlayerDropDown', [function() {
  return {
    restrict: 'E',
    template: '<span class="dropdown">' +
                '<a data-toggle="dropdown" href="#" class="player-drop-down" aria-haspopup="true" aria-expanded="false">' +
                  '<span class="caret"></span>' +
                '</a>' +
                '<ul class="dropdown-menu">' +
                  '<li ng-hide="playerIgnored">Add to Ignore</li>' +
                  '<li ng-show="playerIgnored">Remove from Ignore</li>' +
                  '<li ng-hide="playerOnRoster">Add to Roster</li>' +
                  '<li ng-show="playerOnRoster">Remove from Roster</li>' +
                '</ul>' +
              '</span>',
    scope: {
      playerIgnored : '=',
      playerOnRoster: '='
    },
    link: function (scope, elem, attrs) {
    }
  }
}]);
