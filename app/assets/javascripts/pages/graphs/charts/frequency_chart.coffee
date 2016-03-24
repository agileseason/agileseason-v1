class @FrequencyChart extends BarChartBase
  constructor: (root) ->
    super(root)

    @_render_axes()
    @_render_chart()
    @_render_bar_shadow()
    @_render_tooltip()

  _prepare_chart: ->
    @area = d3
      .svg
      .area()
      .interpolate 'monotone'
      .x (d, i) => @x_scale i
      .y0 @chart_height
      .y1 (d) => @y_scale d

  _bar_step: -> 0

  _render_chart: ->
    for data, n in @data
      bar = @svg
        .selectAll(".bar-#{n}")
          .data(data)
        .enter().append('rect')
          .attr('id', (d, i) -> "bar-#{n}-#{i}")
          .attr('class', (d) -> "bar bar-#{n}")
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

  _tooltip_content: (node, d, i, data_item) ->
    "Issues: #{data_item} Closed for: #{i + 1}d"
