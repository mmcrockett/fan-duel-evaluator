app.factory('Roster', ['$filter', function($filter) {
  return {
    create_roster: function(league, roster, name) {
      var total_row = {};
      var ignore_columns = ["id"];
      var new_roster = [];
      var league_ordered_columns = {
        NHL: ["LW", "RW", "C", "D", "G"],
        NBA: ["PG", "SG", "SF", "PF", "C"],
        NFL: ["QB", "RB", "WR", "TE", "K", "D"],
        MLB: ["P","C","1B","2B","3B","SS","OF"],
        CBB: ["F", "G"]
      }
      var ordered_columns = league_ordered_columns[league];

      if (false == angular.isArray(ordered_columns)) {
        if (true == angular.isString(league)) {
          console.warn("Missing sort for '" + league + "'.");
        }

        return roster
      }

      for (var i = 0; i < ordered_columns.length; i += 1) {
        angular.forEach($filter('filter')(roster, {pos:ordered_columns[i]}, true), function(player, i) {
          new_roster.push(player);
        });
      }

      angular.forEach(new_roster, function(player, i) {
        angular.forEach(player, function(v, k) {
          if (0 == i) {
            if ("name" == k) {
              total_row[k] = "Totals (" + name + ")";
            } else if ("id" == k) {
              total_row[k] = 0;
            } else if (true == angular.isNumber(v)) {
              total_row[k] = 0;
            } else if (true == angular.isString(v)) {
              total_row[k] = "";
            } else if (("boolean" === typeof v) || (null == v)) {
              total_row[k] = null;
            } else {
              total_row[k] = "";
            }
          }

          if ((true == angular.isNumber(v)) && (-1 == ignore_columns.indexOf(k))) {
            total_row[k] += v;
          }
        });
      });

      angular.forEach(total_row, function(v, k) {
        if (true == angular.isNumber(v)) {
          if (-1 != k.indexOf('value')) {
            total_row[k] = Math.round(v.toFixed(1)/new_roster.length);
          } else {
            total_row[k] = +v.toFixed(1);
          }
        }
      });

      new_roster.push(total_row);

      return new_roster;
    }
  };
}]);
