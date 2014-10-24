app.controller('WeekDataController', ['$scope', '$http', 'WeekData', 'FanDuelData', 'JsLiteral', function($scope, $http, WeekData, FanDuelData, JsLiteral) {
  $scope.week_data = [];
  $scope.fan_duel_data = "";
  $scope.week_field = "";
  $scope.new_week = "";
  $scope.chart = {
    "type": "Table",
    "sortColumn": 1,
    "sortAscending": false
  };
  $scope.create_chart = function() {
    $scope.chart.data = JsLiteral.get_chart_data($scope.week_data);
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
}]);
