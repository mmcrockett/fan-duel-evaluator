app.factory('JsLiteral', function() {
  return {
    get_chart_data: function(input, ignore_callback) {
      var output = {};
      output.cols = [];
      output.rows = [];

      angular.forEach(input, function(wdata, i) {
        var row = {c:[]};
        var style = {};
        var player_id = -1;

        angular.forEach(wdata, function(v, k) {
          if (0 == i) {
            var type = "Unknown";
            if (true == angular.isNumber(v)) {
              type = "number";
            } else if ((true == angular.isString(v)) || (true == angular.isObject(v))) {
              type = "string";
            } else if (true == angular.isDate(v)) {
              type = "date";
            } else if (("boolean" === typeof v) || (null == v)) {
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

          if ("ignore" == k) {
            if (true == v) {
              style["style"] = "color:#848482;background-color:#E5E4E2;";
            }

            output.cols[output.cols.length - 1].type  = "string";
            output.cols[output.cols.length - 1].label = "";

            if (true == angular.isFunction(ignore_callback)) {
              v = ignore_callback(v, player_id);
            }
          }

          if ("id" == k) {
            player_id = v;
          }

          if (("news" == k) && (true == angular.isObject(v))) {
            var DAY = 86400000;
            var WEEK = DAY * 7;

            var timestamp = new Date(v.latest).getTime();
            var diff = Date.now() - timestamp;
            var img_tag = "";
            var summary = "?";

            if (diff < DAY) {
              img_name = "news-breaking.png";
            } else if (diff < WEEK) {
              img_name = "news-recent.png";
            } else {
              img_name = "news-old.png";
            }

            if (true == angular.isString(v.summary)) {
              summary = v.summary
            }

            v = '<img tooltip-class="no-arrow" tooltip-placement="right" tooltip="' + summary + '" class="news" src="/assets' + img_name + '" />';
          }

          row.c.push({v:v, p:style});
        });
        output.rows.push(row);
      });

      return output;
    }
  };
});
