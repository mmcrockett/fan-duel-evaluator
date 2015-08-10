app.directive('ngAlerts', ['$filter', function($filter) {
  return {
    restrict: 'E',
    template: '<div ng-repeat="alert in alerts" ng-class="alert.classes" data="{{alert.index}}" role="alert">' +
                '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
                '<strong>{{alert.prefix}}</strong>{{alert.msg}}' +
              '</div>',
    scope: {
      messages: '=messages'
    },
    link: function ($scope, elem, attrs) {
      if (false == angular.isArray($scope.messages)) {
        $scope.messages = [];
      }

      if (false == angular.isArray($scope.alerts)) {
        $scope.alerts = [];
      }

      elem.on('close.bs.alert', function(ngEvent) {
        var i = Number(ngEvent.target.getAttribute('data'));
        $scope.messages.splice(i, 1);
      });

      $scope.$watch(
        function() {
          return $scope.messages.length;
        },
        function() {
          $scope.alerts = [];

          $scope.messages = $filter('unique')($scope.messages);

          for(var i = 0; i < $scope.messages.length; i += 1) {
            var type   = 'info';
            var prefix = 'Note! ';
            var msg  = $scope.messages[i];
            var first_space = msg.indexOf(' ');

            if (-1 != msg.toLowerCase().indexOf('warn')) {
              type = 'warning';
              prefix = 'WARN! ';
            } else if (-1 != msg.toLowerCase().indexOf('error')) {
              type   = 'danger';
              prefix = 'ERROR! ';
            } else if (-1 != msg.toLowerCase().indexOf('success')) {
              type = 'success';
              prefix = 'Success!: ';
            }

            msg = msg.substr(first_space + 1);

            $scope.alerts.push({
              prefix  : prefix,
              msg     : msg,
              classes : ['alert', 'alert-' + type, 'alert-dismissible'],
              index   : i
            });
          }
        }
      );
    }
  }
}]);
