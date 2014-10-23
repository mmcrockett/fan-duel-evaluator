app.controller('WeekDataController', ['$scope', '$http', 'WeekData', 'FanDuelData', function($scope, $http, WeekData, FanDuelData) {
  $scope.week_data = [];
  $scope.fan_duel_data = "";
  $scope.week_field = "";
  $scope.new_week = "";
  $scope.chart = {
    "type": "Table"
  };
  $scope.create_chart = function() {
    $scope.chart.data = {};
    $scope.chart.data.cols = [];
    $scope.chart.data.rows = [];
    angular.forEach($scope.week_data, function(wdata, i) {
      var row = {c:[]};
      angular.forEach(wdata, function(v, k) {
        if (0 == i) {
          var type = "Unknown";
          if (true == angular.isNumber(v)) {
            type = "number";
          } else if (true == angular.isString(v)) {
            type = "string";
          } else if (true == angular.isDate(v)) {
            type = "date";
          } else if ("boolean" === typeof v) {
            type = "boolean";
          } else {
            console.error("!ERROR: type unknown '" + typeof v + "'.");
          }
          $scope.chart.data.cols.push({
            "id"   : k,
            "label": k,
            "type" : type,
          });
        }

        row.c.push({v:v});
      });
      $scope.chart.data.rows.push(row);
    });
  };
  $scope.$watch('week_data', $scope.create_chart);
  $scope.add_week = function() {
    new WeekData({week:$scope.week_field}).$save({}, function(v){$scope.new_week = $scope.week_field;$scope.week_field = "";$scope.get_week_data()}, function(e){console.error("!ERROR adding week data.");});
  };
  $scope.add_fan_duel_json = function() {
    new FanDuelData({data:$scope.fan_duel_data, week:$scope.new_week}).$save({}, function(v){$scope.get_week_data();$scope.new_week="";}, function(e){$scope.get_week_data();console.error("!ERROR saving fan duel json.");});
  };
  $scope.get_week_data = function() {
    WeekData.query({}, function(v){$scope.week_data = v;}, function(e){console.error("Couldn't load week data.");});
  };
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
}]);
