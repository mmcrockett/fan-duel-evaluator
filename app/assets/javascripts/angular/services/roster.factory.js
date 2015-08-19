app.factory('Roster', ['localStorageService', function(LocalStorage) {
  return function(league, name) {
    var IGNORE_COLUMNS = ['id'];
    var COLUMNS_BY_LEAGUE_ORDERED = {
        NHL: ["LW", "RW", "C", "D", "G"],
        NBA: ["PG", "SG", "SF", "PF", "C"],
        NFL: ["QB", "RB", "WR", "TE", "K", "D"],
        MLB: ["P","C","1B","2B","3B","SS","OF","OF","OF"],
        CBB: ["F", "G"]
    };

    this.m_league  = league;
    this.m_name    = name;
    this.m_players = [];

    this.format_row = function(row, n) {
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
    };

    this.column_default_values = function(k,v) {
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
    };

    this.columns = function(league) {
      var columns = COLUMNS_BY_LEAGUE_ORDERED[league];

      if (true == angular.isArray(columns)) {
        return _.extend([], columns);
      } else {
        return [];
      }
    };

    this.add_player = function(player) {
      var scope = this;

      if (true == angular.isObject(player)) {
        if (false == _.contains(scope.m_players, player)) {
          scope.m_players.push(player);
        }
      }
    };

    this.players = function() {
      return this.m_players;
    };

    this.total_row = function() {
      var scope = this;
      var total_row = {};

      angular.forEach(scope.m_players, function(player, i) {
        angular.forEach(player, function(v, k) {
          if (0 == i) {
            if ("name" == k) {
              var total_row_name = "Totals";

              if (true == angular.isString(scope.m_name)) {
                total_row_name = total_row_name + " (" + scope.m_name + ")";
              }

              total_row[k] = total_row_name;
            } else {
              total_row[k] = scope.column_default_values(k,v);
            }
          }

          if ((true == angular.isNumber(v)) && (-1 == jQuery.inArray(k, IGNORE_COLUMNS))) {
            total_row[k] += v;
          }
        });
      });

      return total_row;
    };

    this.players_ordered_with_totals = function() {
      var scope = this;
      var new_roster = [];
      var ordered_columns = scope.columns(scope.m_league);

      if (false == angular.isArray(ordered_columns)) {
        return scope.players();
      }

      angular.forEach(_.uniq(ordered_columns), function(column, i) {
        angular.forEach(_.where(scope.m_players, {pos:column}), function(player, i) {
          new_roster.push(player);
        });
      });

      new_roster.push(scope.format_row(scope.total_row()));

      return new_roster;
    };

    this.players_with_ghosts = function() {
      var scope      = this;
      var new_roster = _.extend({}, this, {m_players : []});

      angular.forEach(scope.players(), function(player, i) {
        new_roster.add_player(player);
      });

      angular.forEach(scope.missing_positions(), function(missing_position, i) {
        new_roster.add_player(new_roster.create_fake_player(missing_position));
      });

      return new_roster.players_ordered_with_totals();
    };

    this.create_fake_player = function(position) {
      var scope      = this;
      var new_player = _.extend({}, scope.m_players[0]);

      angular.forEach(new_player, function(v, k) {
        if ("name" == k) {
          new_player[k] = 'Empty ' + position;
        } else if ("pos" == k) {
          new_player[k] = position;
        } else {
          new_player[k] = scope.column_default_values(k,v);
        }
      }, this);

      return new_player;
    };

    this.positions_with_count = function() {
      var scope = this;
      return _.countBy(scope.columns(scope.m_league), function(v) { return v; });
    };

    this.missing_positions = function() {
      var scope = this;
      var missing_positions = [];

      angular.forEach(scope.positions_with_count(), function(maximum_count, position) {
        var remaining_count = maximum_count - _.where(scope.m_players, {pos : position}).length;

        _.times(remaining_count, function() { missing_positions.push(position); });
      });

      return missing_positions;
    };

    this.overfilled_positions = function() {
      var scope      = this;
      var overfilled_positions = [];

      angular.forEach(scope.positions_with_count(), function(maximum_count, position) {
        var overcount = _.where(scope.m_players, {pos : position}).length - maximum_count;

        _.times(overcount, function() { overfilled_positions.push(position); });
      });

      return overfilled_positions;
    };

    this.get_status = function() {
      var scope      = this;
      var roster_status      = {};

      if ((true == angular.isString(scope.m_league)) && (0 != scope.players().length)) {
        var missing_positions    = _.uniq(scope.missing_positions());
        var overfilled_positions = _.uniq(scope.overfilled_positions());

        if ((0 == missing_positions.length) && (0 == overfilled_positions.length)) {
          roster_status = {
            classes : 'roster-valid',
            message : 'Roster complete!',
            alerts  : ['alert', 'alert-success']
          };
        } else if ((0 != missing_positions.length) && (0 == overfilled_positions.length)) {
          roster_status = {
            classes : 'roster-in-progress',
            message : 'Still need ' + missing_positions.join(', ') + '.',
            alerts  : ['alert', 'alert-warning']
          };
        } else if ((0 == missing_positions.length) && (0 != overfilled_positions.length)) {
          roster_status = {
            classes : 'roster-invalid',
            message : '!Too many ' + overfilled_positions.join(', ') + '.',
            alerts  : ['alert', 'alert-danger']
          };
        } else { // ((0 != missing_positions.length) && (0 != overfilled_positions.length))
          roster_status = {
            classes : 'roster-invalid',
            message : '!Too many ' + overfilled_positions.join(', ') + ' (and still need ' + missing_positions.join(', ') + ').',
            alerts  : ['alert', 'alert-danger']
          };
        }
      }

      return roster_status;
    };
  };
}]);
