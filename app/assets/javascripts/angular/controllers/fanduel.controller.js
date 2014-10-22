app.controller('FanDuelController', ['$scope', '$http', function($scope, $http) {
  $scope.cshart = {
  "type": "Table",
  "data": {
    "cols": [
      {
        "id": "month",
        "label": "Month",
        "type": "string",
        "p": {}
      },
      {
        "id": "laptop-id",
        "label": "Laptop",
        "type": "number",
        "p": {}
      },
      {
        "id": "desktop-id",
        "label": "Desktop",
        "type": "number",
        "p": {}
      },
      {
        "id": "server-id",
        "label": "Server",
        "type": "number",
        "p": {}
      },
      {
        "id": "cost-id",
        "label": "Shipping",
        "type": "number"
      }
    ],
    "rows": [
      {
        "c": [
          {
            "v": "January"
          },
          {
            "v": 19,
            "f": "42 items"
          },
          {
            "v": 12,
            "f": "Ony 12 items"
          },
          {
            "v": 7,
            "f": "7 servers"
          },
          {
            "v": 4
          }
        ]
      },
      {
        "c": [
          {
            "v": "February"
          },
          {
            "v": 13
          },
          {
            "v": 1,
            "f": "1 unit (Out of stock this month)"
          },
          {
            "v": 12
          },
          {
            "v": 2
          }
        ]
      },
      {
        "c": [
          {
            "v": "March"
          },
          {
            "v": 24
          },
          {
            "v": 0
          },
          {
            "v": 11
          },
          {
            "v": 6
          }
        ]
      }
    ]
  },
  "options": {
    "title": "Sales per month",
    "isStacked": "true",
    "fill": 20,
    "displayExactValues": true,
    "vAxis": {
      "title": "Sales unit",
      "gridlines": {
        "count": 6
      }
    },
    "hAxis": {
      "title": "Date"
    }
  },
  "formatters": {},
  "displayed": true
};
/*
  $http.get('/key.json').then(function(result) {$scope.crypt.setKey(result.data);});
  $scope.reset_data = function() {
    $scope.login_data = {password: ""};
    $scope.register_data = {password: ""};
    $scope.error = "";
  };
  $scope.reset_data();
  $scope.login = function() {
    var user = new User($scope.login_data);
    user.$login({password: $scope.crypt.encrypt(user.password)}, function(v){location.reload(true);}, function(v){$scope.reset_data();$scope.error = "Username or password incorrect.";});
  };
  $scope.register = function() {
    var user = new User($scope.register_data);
    user.$register(
      {password: $scope.crypt.encrypt(user.password)},
      function(v){location.reload(true);},
      function(v){
        $scope.reset_data();
        angular.forEach(v.data, function(v, k) {
            if ("" !== $scope.error) {
              $scope.error += " AND ";
            }
            $scope.error += k + " " + v[0];
          }
        );
      }
    );
  };*/
}]);
