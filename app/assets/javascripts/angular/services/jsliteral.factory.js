app.factory('JsLiteral', function() {
  return {
    get_chart_data: function(input) {
      var output = {};
      output.cols = [];
      output.rows = [];

      angular.forEach(input, function(wdata, i) {
        var row = {c:[]};
        var style = {};

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

          if (("ignore" == k) && (true == v)) {
            style["style"] = "color:#B6B6B4;background-color:#E5E4E2;";
          }

          if ("news" == k) {
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
