app.controller('PlayerController',
  ['$scope',
   '$window',
   'PlayerData',
   'Roster',
   'JsLiteral',
   'KeyCodes',
   'DefaultChart',
   'localStorageService',
   '$filter',
   function(
     $scope,
     $window,
     PlayerData,
     Roster,
     JsLiteral,
     KeyCodes,
     DefaultChart,
     LocalStorage,
     $filter
   )
  {
  $scope.hide_ignored   = LocalStorage.get('hide_ignored');

  if (false == angular.isDefined($scope.hide_ignored)) {
    $scope.hide_ignored = true;
  }

  $scope.roster_ids     = LocalStorage.get('roster_ids');

  if (false == angular.isArray($scope.roster_ids)) {
    $scope.roster_ids = [];
  }

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
      $scope.$apply($scope.ignore_players());
    } else if ((KeyCodes.DELETE == e.keyCode) || (KeyCodes.BACKSPACE == e.keyCode)) {
      $scope.$apply($scope.remove_players());
    } else if ((KeyCodes.PLUS == e.keyCode) || (KeyCodes.A == e.keyCode)) {
      $scope.$apply($scope.add_player_to_roster());
    } else if ((KeyCodes.MINUS == e.keyCode) || (KeyCodes.D == e.keyCode)) {
      $scope.$apply($scope.remove_player_from_roster());
    }
  });
  $scope.get_selected_ids = function(wrapper, selection) {
    var selected_ids = [];

    if (true == angular.isObject(wrapper)) {
      angular.forEach(selection, function(gitem, i) {
        selected_ids.push(wrapper.getDataTable().getValue(gitem.row, 0));
      });
    }

    return selected_ids;
  };
  $scope.add_player_to_roster = function() {
    var selected_ids = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    angular.forEach(selected_ids, function(player_id, i) {
      if (-1 == jQuery.inArray(player_id, $scope.roster_ids)) {
        $scope.roster_ids.push(player_id);
      } else {
        var player_on_roster = $filter('filter')($scope.player_data, {id: player_id}, true)[0];

        $scope.messages.push("warning You've already added '" + player_on_roster.name + "' to your roster.");
      }
    });
  };
  $scope.remove_player_from_roster = function() {
    var selected_ids = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    angular.forEach(selected_ids, function(player_id, i) {
      var roster_id_index = jQuery.inArray(player_id, $scope.roster_ids);

      if (-1 == roster_id_index) {
        console.warn("Player not found on roster to remove '" + player_id + "'.");
      } else {
        $scope.roster_ids.splice(roster_id_index, 1);
      }
    });
  };
  $scope.render_roster = function() {
    var roster = [];

    angular.forEach($scope.roster_ids, function(player_id, i) {
      roster.push($filter('filter')($scope.player_data, {id: player_id}, true)[0]);
    });

    $scope.roster = Roster.create_roster($scope.selectedLeague, roster, "");
    $scope.create_roster_chart();
    $scope.update_chart_columns($scope.roster, $scope.roster_chart);
  };
  $scope.ignore_players = function() {
    var ids_to_ignore = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    if (0 <= ids_to_ignore.length) {
      if (false == angular.isArray($scope.ignore_list)) {
        $scope.ignore_list = [];
      }

      $scope.ignore_list = $scope.ignore_list.concat(ids_to_ignore);

      if (true == $scope.hide_ignored) {
        $scope.player_wrapper.getChart().setSelection();
        $scope.player_selected = [];
      }
    }
  };
  $scope.remove_players = function() {
    var ids_to_ignore = $scope.get_selected_ids($scope.player_wrapper, $scope.player_selected);

    if (0 <= ids_to_ignore.length) {
      $scope.message = "Adding players to removed list...";
      new PlayerData({ignore:ids_to_ignore}).$save({},
        function(v){
          $scope.player_wrapper.getChart().setSelection();
          $scope.player_selected = [];
          $scope.get_player_data();
          $scope.message = "Removed " + ids_to_ignore.length + " players."
        },
        function(e){
          $scope.message = "!ERROR: Unable to remove players.";
        }
      );
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

    for (var i = 0; i < $scope.roster_ids.length; i += 1) {
      if (player_id == $scope.roster_ids[i]) {
        on_roster = true;
        break;
      }
    }

    return '<ng-player-drop-down player-ignored="' + v + '" player-on-roster="' + on_roster + '"></ng-player-drop-down>';
  };
  $scope.create_roster_chart = function() {
    $scope.roster_chart.data = JsLiteral.get_chart_data($scope.roster);
  };
  $scope.filter_player_data = function() {
    $scope.message = "";
    $scope.update_chart_columns($scope.player_data, $scope.player_chart);

    if ("ALL" == $scope.selectedPosition) {
      $scope.filtered_player_data = $scope.player_data;
    } else {
      $scope.filtered_player_data = $filter('filter')($scope.player_data, {pos: $scope.selectedPosition}, true);
    }

    if (true == $scope.hide_ignored) {
      $scope.filtered_player_data = $filter('filter')($scope.filtered_player_data, {ignore: false}, true);
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
    $scope.message = "";
    if ("NONE" != $scope.selectedLeague) {
      $scope.message = "Retrieving player data...";
      PlayerData.query({league:$scope.selectedLeague},
          function(v){
            $scope.message = "";
            $scope.player_data = v;
            $scope.filter_player_data();

            if (true == $scope.league_changed) {
              $scope.build_positions();
              $scope.league_changed = false;
            }
          },
          function(e){
            $scope.message = "Couldn't load player data.";
          }
      );
    } else {
      $scope.player_data = [];
      $scope.filter_player_data();
      if (true == $scope.league_changed) {
        $scope.league_changed = false;
      }
    }
  };
  $scope.get_player_details = function() {
    $scope.message = "Processing player details...";
    new PlayerData({league:$scope.selectedLeague}).$update({},
        function(v){
          $scope.message="Retrieved player details.";
          $scope.get_player_data();
        },
        function(e){
          $scope.message = "!ERROR: Unable to get game details.";
        });
  };
  $scope.player_data_add_ignore = function() {
    angular.forEach($scope.player_data, function(player, i) {
      if (-1 != jQuery.inArray(player.id, $scope.ignore_list)) {
        player.ignore = true;
      }
    });
  };
  $scope.save_hide_ignored = function() {
    LocalStorage.set('hide_ignored', $scope.hide_ignored);
  };
  $scope.save_roster = function() {
    LocalStorage.set('roster_ids', $scope.roster_ids);
  };
  $scope.$watch('filtered_player_data', $scope.create_player_chart, true);
  $scope.$watch('filtered_player_data', $scope.render_roster, true);
  $scope.$watch('selectedPosition', $scope.filter_player_data);
  $scope.$watch('ignore_list',  $scope.player_data_add_ignore);
  $scope.$watch('ignore_list',  $scope.filter_player_data);
  $scope.$watch('hide_ignored', $scope.filter_player_data);
  $scope.$watch('hide_ignored', $scope.save_hide_ignored);
  $scope.$watchCollection('roster_ids', $scope.render_roster);
  $scope.$watchCollection('roster_ids', $scope.save_roster);
}]);
