app.factory('JsLiteral', function() {
  return {
    get_chart_data: function(input) {
      var output = {};
      output.cols = [];
      output.rows = [];

      angular.forEach(input, function(wdata, i) {
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

            output.cols.push({
              "id"   : k,
              "label": k,
              "type" : type,
            });
          }

          row.c.push({v:v});
        });
        output.rows.push(row);
      });

      return output;
    }
  };
});
