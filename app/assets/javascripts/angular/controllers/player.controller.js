app.controller('PlayerController',
  ['$scope',
   '$window',
   'PlayerData',
   'Roster',
   'JsLiteral',
   'KeyCodes',
   'DefaultChart',
   'localStorageService',
   function(
     $scope,
     $window,
     PlayerData,
     Roster,
     JsLiteral,
     KeyCodes,
     DefaultChart,
     LocalStorage
   )
{
  LocalStorage.bind($scope, 'hide_ignored', true);
  LocalStorage.bind($scope, 'roster_ids',   []);
  $scope.roster_indicator = {};
  $scope.league_changed = false;
  $scope.positions = [{id:"ALL"}];
  $scope.selectedPosition = "ALL";
  $scope.player_wrapper = null;
  $scope.player_selected = [];
  $scope.roster_wrapper = null;
  $scope.roster_selected = [];
  $scope.filtered_player_data = [];
  $scope.player_data = [];
  angular.element($window).bind('keyup.delete', function(e) {
    if (KeyCodes.I == e.keyCode) {
      $scope.$apply($scope.ignore_add_players());
    } else if ((KeyCodes.DELETE == e.keyCode) || (KeyCodes.BACKSPACE == e.keyCode)) {
      $scope.$apply($scope.remove_players());
    } else if ((KeyCodes.PLUS == e.keyCode) || (KeyCodes.A == e.keyCode)) {
      $scope.$apply($scope.roster_add_players());
    } else if ((KeyCodes.MINUS == e.keyCode) || (KeyCodes.D == e.keyCode)) {
      $scope.$apply($scope.roster_remove_players());
    }
  });
  $scope.find_player = function(player_id) {
    return _.findWhere($scope.player_data, {id: player_id});
  };
  $scope.clear_progress = function() {
    $scope.progress.message = "";
  };
  $scope.get_selected_ids = function(wrapper, selection) {
    var selected_ids = [];

    if (true == angular.isObject(wrapper)) {
      angular.forEach(selection, function(gitem, i) {
        selected_ids.push(wrapper.getDataTable().getValue(gitem.row, 0));
      });
    }

    return selected_ids;
  };
  $scope.render_roster = function() {
    var roster = [];

    angular.forEach($scope.roster_ids, function(player_id, i) {
      roster.push($scope.find_player(player_id));
    });

    $scope.roster = Roster.create_roster($scope.selectedLeague, roster, "");
    $scope.create_roster_chart();
    $scope.update_chart_columns($scope.roster, $scope.roster_chart);
    $scope.roster_indicator = Roster.get_roster_status(roster, $scope.selectedLeague);
  };
  $scope.remove_players = function() {
    var ids_to_remove = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    if (0 <= ids_to_remove.length) {
      $scope.progress.message = "Removing players.";
      PlayerData
      .save({ignore:ids_to_remove})
      .$promise
      .then(
        function(v){
          $scope.player_wrapper.getChart().setSelection();
          $scope.player_selected = [];
          $scope.get_player_data();
          $scope.alerts.create_success("Removed '" + ids_to_remove.length + "' players.");
        }
      ).catch(
        function(e){
          $scope.alerts.create_error("Unable to remove players.");
        }
      ).finally($scope.clear_progress);
    }
  };
  $scope.set_player_selected = function(selected_items) {
    $scope.player_selected = selected_items;
  };
  $scope.set_player_wrapper = function(wrapper) {
    $scope.player_wrapper = wrapper;
  };
  $scope.set_roster_selected = function(selected_items) {
    $scope.roster_selected = selected_items;
  };
  $scope.set_roster_wrapper = function(wrapper) {
    $scope.roster_wrapper = wrapper;
  };
  $scope.player_chart = DefaultChart.default_chart();
  $scope.roster_chart = DefaultChart.default_chart({data: JsLiteral.get_chart_data($scope.roster)});
  $scope.set_sort = function(sortParams) {
    if (true == angular.isObject(sortParams)) {
      $scope.player_chart.options.sortColumn = sortParams.column;
      $scope.player_chart.options.sortAscending = sortParams.ascending;
    } else if (false == angular.isNumber($scope.player_chart.options.sortColumn)) {
      var i = 0;
      angular.forEach($scope.filtered_player_data[0], function(v, k) {
        if ("avg" == k) {
          $scope.player_chart.options.sortColumn = i - 1;
          return true;
        } else {
          i += 1;
        }
      });
    }
  };
  $scope.create_player_chart = function() {
    $scope.set_sort(null);
    $scope.player_chart.data = JsLiteral.get_chart_data($scope.filtered_player_data, $scope.create_player_dropdown);
  };
  $scope.create_player_dropdown = function(v, player_id) {
    var on_roster = false;

    if (null == v) {
      return v;
    }

    for (var i = 0; i < $scope.roster_ids.length; i += 1) {
      if (player_id == $scope.roster_ids[i]) {
        on_roster = true;
        break;
      }
    }

    return '<ng-player-drop-down' +
           ' scope-id="' + $scope.$id + '"' +
           ' player-id="' + player_id + '"' +
           ' player-ignored="' + v + '"' +
           ' player-on-roster="' + on_roster + '"' +
           '</ng-player-drop-down>';
  };
  $scope.create_roster_chart = function() {
    $scope.roster_chart.data = JsLiteral.get_chart_data($scope.roster, $scope.create_player_dropdown);
  };
  $scope.filter_player_data = function() {
    $scope.update_chart_columns($scope.player_data, $scope.player_chart);

    if ("ALL" == $scope.selectedPosition) {
      $scope.filtered_player_data = $scope.player_data;
    } else {
      $scope.filtered_player_data = _.where($scope.player_data, {pos: $scope.selectedPosition});
    }

    if (true == $scope.hide_ignored) {
      $scope.filtered_player_data = _.where($scope.filtered_player_data, {ignore: false});
    }
  };
  $scope.build_positions = function() {
    $scope.selectedPosition = "ALL";
    $scope.player_chart.options.sortColumn = null;
    $scope.positions = [{id:"ALL"}];
    var positions = {};

    angular.forEach($scope.player_data, function(player, i) {
      if (true !== positions[player.pos]) {
        positions[player.pos] = true;
        $scope.positions.push({id:player.pos});
      }
    });
  };
  $scope.select_league = function(league) {
    $scope.selectedLeague = league;
    $scope.league_changed = true;
    $scope.get_player_data();
  };
  $scope.update_chart_columns = function(data, chart) {
    var i = 0;
    var show_columns = [];
    angular.forEach(data[0], function(v, k) {
      if ("id" != k) {
        show_columns.push(i);
      }

      i += 1;
    });
    if (0 != show_columns.length) {
      chart.view = {columns:show_columns};
    } else {
      chart.view = undefined;
    }
  };
  $scope.get_player_data = function() {
    if ("NONE" != $scope.selectedLeague) {
      $scope.progress.message = "Retrieving player data.";
      PlayerData
      .query({league:$scope.selectedLeague})
      .$promise
      .then(
        function(v){
          $scope.player_data = v;
          $scope.filter_player_data();

          if (true == $scope.league_changed) {
            $scope.build_positions();
            $scope.league_changed = false;
          }
        }
      ).catch(
        function(e){
          $scope.alerts.create_error("Couldn't load player data", e);
        }
      ).finally($scope.clear_progress);
    } else {
      $scope.player_data = [];
      $scope.filter_player_data();
      if (true == $scope.league_changed) {
        $scope.league_changed = false;
      }
    }
  };
  $scope.get_player_details = function() {
    $scope.progress.message = "Processing player details.";
    PlayerData
    .update({league:$scope.selectedLeague})
    .$promise
    .then(
      function(v){
        $scope.alerts.create_success("Retrieved player details.");
        $scope.get_player_data();
      }
    ).catch(
      function(e){
        $scope.alerts.create_error("Unable to get game details", e);
      }
    ).finally($scope.clear_progress);
  };
  $scope.player_data_alter_ignore = function() {
    angular.forEach($scope.player_data, function(player, i) {
      if (-1 != jQuery.inArray(player.id, $scope.ignore_list)) {
        player.ignore = true;
      } else {
        player.ignore = false;
      }
    });
  };
  $scope.ignore_add_players = function() {
    var ids_to_ignore = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    if (0 < ids_to_ignore.length) {
      angular.forEach(ids_to_ignore, function(player_id, i) {
        $scope.ignore_add_player(player_id);
      });

      if (true == $scope.hide_ignored) {
        $scope.player_wrapper.getChart().setSelection();
        $scope.player_selected = [];
      }
    }
  };
  $scope.ignore_add_player = function(player_id) {
    if (-1 == jQuery.inArray(player_id, $scope.ignore_list)) {
      $scope.ignore_list.push(player_id);
    } else {
      var player_on_ignore_list = $scope.find_player(player_id);

      $scope.alerts.create_warn("You've already ignored '" + player_on_ignore_list.name + "'.");
    }

    return true;
  };
  $scope.ignore_remove_player = function(player_id) {
    $scope.ignore_list = _.without($scope.ignore_list, player_id);

    return false;
  };
  $scope.roster_add_players = function() {
    var selected_ids = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    angular.forEach(selected_ids, function(player_id, i) {
      $scope.roster_add_player(player_id);
    });
  };
  $scope.roster_remove_players = function() {
    var selected_ids = $scope.get_selected_ids($scope.roster_wrapper, $scope.roster_selected);

    angular.forEach(selected_ids, function(player_id, i) {
      $scope.roster_remove_player(player_id);
    });
  };
  $scope.roster_add_player = function(player_id) {
    if (-1 == jQuery.inArray(player_id, $scope.roster_ids)) {
      $scope.roster_ids.push(player_id);
    } else {
      var player_on_roster = $scope.find_player(player_id);

      $scope.alerts.create_warn("You've already added '" + player_on_roster.name + "' to your roster.");
    }

    return true;
  };
  $scope.roster_remove_player = function(player_id) {
    $scope.roster_ids = _.without($scope.roster_ids, player_id);

    return false;
  };
  $scope.$watch('filtered_player_data', $scope.create_player_chart, true);
  $scope.$watch('filtered_player_data', $scope.render_roster, true);
  $scope.$watch('selectedPosition', $scope.filter_player_data);
  $scope.$watchCollection('ignore_list',  $scope.player_data_alter_ignore);
  $scope.$watchCollection('ignore_list',  $scope.filter_player_data);
  $scope.$watch('hide_ignored', $scope.filter_player_data);
  $scope.$watchCollection('roster_ids', $scope.render_roster);
}]);
