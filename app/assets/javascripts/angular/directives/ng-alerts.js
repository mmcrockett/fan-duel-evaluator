app.directive('ngAlerts', [function() {
  return {
    restrict: 'E',
    template: '<div ng-repeat="alert in alerts" ng-class="alert.classes" data="{{alert.index}}" role="alert">' +
                '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
                '<strong>{{alert.prefix}}</strong>{{alert.msg}}' +
              '</div>',
    scope: {
      messages     : '=messages',
      alertFactory : '=factory'
    },
    link: function ($scope, elem, attrs) {
      if (false == angular.isArray($scope.messages)) {
        $scope.messages = [];
      }

      if (false == angular.isObject($scope.alertFactory)) {
        $scope.alertFactory = {
          create_error : function(msg, e) {
            if (true == angular.isObject(e)) {
              $scope.messages.push("error " + msg + " '" + e.statusText + "'.");
            } else {
              $scope.messages.push("error " + msg);
            }
          },
          create_warn  : function(msg) {
            $scope.messages.push("warn " + msg);
          },
          create_success  : function(msg) {
            $scope.messages.push("success " + msg);
          },
          create_info  : function(msg) {
            $scope.messages.push("info " + msg);
          }
        }
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

          $scope.messages = _.uniq($scope.messages);

          for(var i = 0; i < $scope.messages.length; i += 1) {
            var type        = null;
            var prefix      = null;
            var type_found  = false;
            var msg         = $scope.messages[i];

            if (-1 != msg.toLowerCase().indexOf('warn')) {
              type       = 'warning';
              prefix     = 'WARN! ';
              type_found = true;
            } else if (-1 != msg.toLowerCase().indexOf('error')) {
              type       = 'danger';
              prefix     = 'ERR! ';
              type_found = true;
            } else if (-1 != msg.toLowerCase().indexOf('success')) {
              type       = 'success';
              prefix     = 'Success! ';
              type_found = true;
            } else {
              type       = 'info';
              prefix     = 'Note! ';

              if (-1 != msg.toLowerCase().indexOf('info')) {
                type_found = true;
              } else {
                type_found = false;
              }
            }

            if (true == type_found) {
              var first_space = msg.indexOf(' ');

              msg = msg.substr(first_space + 1);
            }

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
