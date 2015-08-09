app.factory('DefaultChart', function() {
  return {
    default_chart: function(options) {
      var defaults = {
        type: "Table",
        options: {
          sortAscending: false,
          allowHtml:     true,
          width:         '100%'
        }
      }

      if (true == angular.isUndefined(options)) {
        options = {};
      } else if (false == angular.isObject(options)) {
        console.error("Unexpected format, need object and got '" + options + "'.");
        options = {};
      }

      return angular.merge({}, defaults, options);
    }
  };
});
