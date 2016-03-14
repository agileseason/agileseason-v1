class @BarChartBase
  constructor: (root) ->
    @$chart = $(root)
    @_prepare_data()
    @_prepare_sizes()
    @_prepare_svg()
    @_prepare_scales()
    @_prepare_chart()
    @_prepare_axes()

  _prepare_data: ->
    raw_data = @$chart.data('chart-data')
    if (Array.isArray(raw_data))
      @data = []
      @data.push raw_data
    else
      @data = (raw_data[key] for key of raw_data)

  # TODO right max
  _max: ->
    d3.max @data[0], (d) -> d

  # TODO right length
  _length: ->
    @data[0].length

  _prepare_sizes: ->
    @margin = { top: 50, right: 60, bottom: 40, left: 60 }
    @chart_width = @$chart.width() - @margin.left - @margin.right
    @chart_height = @$chart.height() - @margin.top - @margin.bottom
    bar_step = @chart_width / @_length() / 20
    @bar_width = @chart_width / @_length() - bar_step

  _prepare_svg: ->
    @svg = d3
      .selectAll @$chart
      .append 'svg'
        .attr
          width: @chart_width + @margin.left + @margin.right
          height: @chart_height + @margin.top + @margin.bottom
      .append 'g'
        .attr
          transform: "translate(#{@margin.left},#{@margin.top})"

  _prepare_scales: ->
    # Override

  _prepare_chart: ->
    # Override

  _prepare_axes: ->
    # Override

class @FrequencyChart extends @BarChartBase
  constructor: (root) ->
    super(root)

    @colors = ['#f2a03e', '#bf4a4e']

    @_render_axes()
    @_render_chart()
    @_render_bar_shadow()
    @_render_tooltip()

  _prepare_scales: ->
    @x_scale = d3
      .scale
      .linear()
      .domain [0, @_length()]
      .range [0, @chart_width]

    @y_scale = d3
      .scale
      .linear()
      .domain [0, @_max()]
      .range [@chart_height, 0]

  _prepare_chart: ->
    @area = d3
      .svg
      .area()
      .interpolate 'monotone'
      .x (d, i) => @x_scale i
      .y0 @chart_height
      .y1 (d) => @y_scale d

  _prepare_axes: ->
    @x_axis = d3
      .svg
      .axis()
      .scale @x_scale
      .orient 'bottom'
      .tickFormat d3.numberFormat
      .tickPadding 6
      .outerTickSize 1

    @y_axis = d3
      .svg
      .axis()
      .scale @y_scale
      .orient 'left'
      .tickFormat d3.numberFormat
      .tickPadding 15
      .outerTickSize 1

  _render_chart: ->
    for data, i in @data
      bar = @svg
        .selectAll(".bar-#{i}")
          .data(data)
        .enter().append('rect')
          .attr('class', (d) -> "bar bar-#{i}")
          .attr('style', (d) => "fill: #{@colors[i]}")
          .attr('x', (d, i) => @x_scale(i + 1) - @bar_width)
          .attr 'width', @bar_width
          .attr 'y', @y_scale(0)
          .attr 'height', @chart_height - @y_scale(0)
      bar
        .transition()
          .duration(800)
          .delay(80)
          .attr('y', (d) => @y_scale(d))
          .attr('height', (d) => @chart_height - @y_scale(d))

  _render_bar_shadow: ->
    _on_bar_mouseover = @_on_bar_mouseover
    _on_bar_mouseout = @_on_bar_mouseout

    @bar_shadow = @svg
      .selectAll('.bar-shadow')
        .data(@data[0])
      .enter().append('rect')
        .attr('class', (d) -> 'bar-shadow')
        .attr('id', (d, i) -> "bar-shadow-#{i}")
        .attr('x', (d, i) => @x_scale(i + 1) - @bar_width)
        .attr 'width', @bar_width
        .attr 'y', 0
        .attr 'height', @chart_height
        .on('mouseover', (d, i) -> _on_bar_mouseover @, d, i)
        .on('mouseout', (d, i) -> _on_bar_mouseout @, d, i)

  _render_axes: ->
    @svg
      .append 'g'
        .attr class: 'axis x'
        .attr transform: "translate(0,#{@chart_height})"
        .call @x_axis
      .append 'text'
        .attr 'class', 'title'
        .attr 'y', 36
        .attr 'x', @chart_width / 2
        .style 'text-anchor', 'end'
        .text 'Cycle time in days'

    @svg
      .selectAll '.tick text'
      .attr 'dx', "#{-@bar_width / 2 + 2}"

    @svg
      .append 'g'
        .attr class: 'axis y'
        .call @y_axis
      .append 'text'
        .attr 'class', 'title'
        .attr 'transform', 'rotate(-90)'
        .attr 'y', -45
        .attr 'x', @margin.bottom - @chart_height / 2
        .style 'text-anchor', 'end'
        .text 'Issues'

  _on_bar_mouseover: (node, d, i) =>
    d3.select(node).classed hovered: true

    @tooltip
      .transition()
      .duration 200
      .style opacity: 0.8

    bar = d3.select "#bar-shadow-#{i}"
    @tooltip
      .html @_tooltip_content i
      .style
        left: "#{@_calculate_tooltip_left bar}px"
        top: "#{@_calculate_tooltip_top bar}px"

  _tooltip_content: (day) ->
    "#{day} Day"

  _calculate_tooltip_left: (bar) =>
    tooltip_width = @tooltip.node().getBoundingClientRect().width
    parseInt(bar.attr('x')) + @margin.left +
      parseInt(bar.attr('width')) / 2 - 10

  _calculate_tooltip_top: (bar) =>
    tooltip_height = @tooltip.node().getBoundingClientRect().height
    parseInt(bar.attr('y')) + tooltip_height + @margin.top + 26

  _on_bar_mouseout: (node, d, i) =>
    d3.select(node).classed hovered: false

    @tooltip
      .transition()
      .duration 400
      .style opacity: 0

  _render_tooltip: ->
    @tooltip = d3
      .selectAll @$chart
      .append 'div'
      .attr class: 'tooltip'
      .style opacity: 0
