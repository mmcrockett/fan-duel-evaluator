app.factory('Roster', [function() {
  return {
    IGNORE_COLUMNS : ['id'],
    COLUMNS_BY_LEAGUE_ORDERED : {
        NHL: ["LW", "RW", "C", "D", "G"],
        NBA: ["PG", "SG", "SF", "PF", "C"],
        NFL: ["QB", "RB", "WR", "TE", "K", "D"],
        MLB: ["P","C","1B","2B","3B","SS","OF","OF","OF"],
        CBB: ["F", "G"]
    },
    get_roster_status: function(roster, league) {
      var roster_status      = {};

      if (true == angular.isString(league)) {
        var missing_columns    = _.extend([], this.COLUMNS_BY_LEAGUE_ORDERED[league]);
        var overfilled_columns = [];

        positions_filled = _.pluck(roster, 'pos');

        angular.forEach(positions_filled, function(position, i) {
          var index = _.indexOf(missing_columns, position);

          if (-1 == index) {
            overfilled_columns.push(position);
          } else {
            missing_columns.splice(index, 1);
          }
        });

        missing_columns = _.uniq(missing_columns);

        if ((0 == missing_columns.length) && (0 == overfilled_columns.length)) {
          roster_status = {
            classes : 'roster-valid',
            message : 'Roster complete!',
            alerts  : ['alert', 'alert-success']
          };
        } else if ((0 != missing_columns.length) && (0 == overfilled_columns.length)) {
          roster_status = {
            classes : 'roster-in-progress',
            message : 'Still need ' + missing_columns + '.',
            alerts  : ['alert', 'alert-warning']
          };
        } else if ((0 == missing_columns.length) && (0 != overfilled_columns.length)) {
          roster_status = {
          classes : 'roster-invalid',
          message : '!Too many ' + overfilled_columns + '.',
          alerts  : ['alert', 'alert-danger']
          };
        } else { // ((0 != missing_columns.length) && (0 != overfilled_columns.length))
          roster_status = {
            classes : 'roster-invalid',
            message : '!Too many ' + overfilled_columns + '. And still need ' + missing_columns + '.',
            alerts  : ['alert', 'alert-danger']
          };
        }
      }

      return roster_status;
    },
    format_row: function(row, n) {
      angular.forEach(row, function(v, k) {
        if (true == angular.isNumber(v)) {
          if ((-1 != k.indexOf('value')) && (true == angular.isNumber(n))) {
            row[k] = Math.round(v.toFixed(1)/n);
          } else {
            row[k] = +v.toFixed(1);
          }
        }
      });

      return row;
    },
    column_default_values: function(k,v) {
      if ("id" == k) {
        return 0;
      } else if (true == angular.isNumber(v)) {
        return 0;
      } else if (true == angular.isString(v)) {
        return "";
      } else if (("boolean" === typeof v) || (null == v)) {
        return null;
      } else {
        return "";
      }
    },
    add_missing_players: function(columns, roster) {
      var $scope = this;
      var missing_columns = angular.copy(columns);

      if (0 != roster.length) {
        angular.forEach(roster, function(player, i) {
          missing_columns = _.without(missing_columns, player.pos);
        });

        angular.forEach(missing_columns, function(column, i) {
          var new_player = angular.merge({}, roster[0]);

          angular.forEach(new_player, function(v, k) {
            if ("name" == k) {
              new_player[k] = 'Empty ' + column;
            } else if ("pos" == k) {
              new_player[k] = column;
            } else {
              new_player[k] = $scope.column_default_values(k,v);
            }
          });

          roster.push(new_player);
        });

        return roster;
      }

      return roster;
    },
    create_total_row: function(roster) {
      var $scope = this;
      var total_row = {};

      angular.forEach(roster, function(player, i) {
        angular.forEach(player, function(v, k) {
          if (0 == i) {
            if ("name" == k) {
              total_row[k] = "Totals (" + name + ")";
            } else {
              total_row[k] = $scope.column_default_values(k,v);
            }
          }

          if ((true == angular.isNumber(v)) && (-1 == jQuery.inArray(k, $scope.IGNORE_COLUMNS))) {
            total_row[k] += v;
          }
        });
      });

      return total_row;
    },
    create_roster: function(league, roster, name) {
      var $scope = this;
      var total_row = null;
      var new_roster = [];
      var ordered_columns = angular.copy($scope.COLUMNS_BY_LEAGUE_ORDERED[league]);

      if (false == angular.isArray(ordered_columns)) {
        if (true == angular.isString(league)) {
          console.warn("Missing sort for '" + league + "'.");
        }

        return roster
      }

      angular.forEach(_.uniq(ordered_columns), function(column, i) {
        angular.forEach(_.where(roster, {pos:column}), function(player, i) {
          new_roster.push(player);
        });
      });

      total_row = $scope.create_total_row(new_roster);
      total_row = $scope.format_row(total_row);

      new_roster = $scope.add_missing_players(ordered_columns, new_roster);

      new_roster.push(total_row);

      return new_roster;
    }
  };
}]);
