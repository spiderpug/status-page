$(function() {
  var render, renderGraphs;

  render = function(series, canvas) {
    var dateEnd, dateStart, daySpan, format, h, line, lines, main_path, max, min, padb, padl, padr, padt, timeFormat, units, vis, w, x, xAxis, y, yAxis, yax, _ref;
    w = canvas.data('width');
    h = canvas.data('height');

    if (!series.data.length) {
      return;
    }
    format = function(d) {
      return d3.format(".3")(d) + units;
    };
    timeFormat = function(d) {
      if (d < 60) {
        return "" + d + "m";
      } else {
        return "" + (d / 60) + "h";
      }
    };
    units = series.unit;
    data = series.data.map(function(d, i) {
      return [new Date(d[0] * 1000), d[1]];
    }).sort(function(a, b) {
      return d3.ascending(a[0], b[0]);
    });
    _ref = [6, 50, 2, 16], padt = _ref[0], padl = _ref[1], padr = _ref[2], padb = _ref[3];
    max = d3.max(data, function(d) {
      return d[1];
    });
    min = d3.min(data, function(d) {
      return d[1];
    });
    if (units === '%') {
      if (max === min) {
        max = 100;
      }
      if (!(min < 99)) {
        min = 99;
      }
    }
    dateStart = data[0][0];
    dateEnd = data[data.length - 1][0];
    daySpan = Math.round((dateEnd - dateStart) / (1000 * 60 * 60 * 24));
    x = d3.scaleTime().domain([dateStart, dateEnd]).range([0, w - padl - padr]);
    y = d3.scaleLinear().domain([min, max]).range([h - padb - padt, 0]);
    xAxis = d3.axisBottom(x).tickSize(5).ticks(3).tickFormat(function(d) {
      if (daySpan <= 1) {
        return d3.timeFormat('%H:%M')(d).replace(/\s/, '').replace(/^0/, '');
      } else {
        return d3.timeFormat('%m/%d')(d).replace(/\s/, '').replace(/^0/, '').replace(/\/0/, '/');
      }
    });
    yAxis = d3.axisLeft(y).tickPadding(5).tickSize(w).ticks(2).tickFormat(format);
    vis = d3.select(canvas.get(0)).append('svg').attr('width', w).attr('height', h + padt + padb).attr('class', 'viz').append('svg:g').attr('transform', "translate(" + padl + "," + padt + ")");
    vis.append("g").attr("class", "x axis").attr('transform', "translate(0, " + (h - padt - padb) + ")").call(xAxis);

    line = d3.line().x(function(d) { return x(d[0]); }).y(function(d) { return y(d[1]); }).curve(d3.curveLinear);
    yax = vis.append("g").attr("transform", "translate(" + w + ", 0)").attr("class", "y axis").call(yAxis)
    lines = vis.selectAll('path.cumulative').data([data]).enter();
    main_path = lines.append('path').attr('class', 'path').attr('d', line);
  };

  calcAverage = function(series) {
    var values = series.data.map(function(point) { return point[1]; });
    var sum = values.reduce(function(a, b) { return a + b; }, 0);
    return d3.format(".3")(sum / values.length) + series.unit;
  };

  renderGraphs = function() {
    var containers = $('.graph-container').each(function() {
      var data, $canvas;
      $canvas = $(this);
      data = JSON.parse($canvas.attr('data-string') || '[]');

      if (!data || data.length == 0) {
        $canvas.remove();
        return true;
      }

      $.each(data, function() {
        var desc = $('<div>')
        .data('width', $canvas.data('width'))
        .data('height', $canvas.data('height'));
        $canvas.append(desc);
        var left = $("<div class='left'>");
        left.append($('<p class="metric">').text(this.name));
        left.append($('<p class="average">').text(calcAverage(this)));
        desc.append(left);
        render(this, desc);
      })
    });
  };
  renderGraphs();
});
