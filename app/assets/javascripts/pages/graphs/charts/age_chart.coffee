class @AgeChart extends BarChartBase
  constructor: (root) ->
    super(root)

    @_render_axes()
    @_render_chart()
    @_render_bar_shadow()
    @_render_tooltip()

  _max: ->
    d3.max @data[0], (d) -> d.days

  _prepare_chart: ->
    @area = d3
      .svg
      .area()
      .interpolate 'monotone'
      .x (d) => @x_scale d.number
      .y0 @chart_height
      .y1 (d) => @y_scale d.days

  _render_chart: ->
    n = 0
    @bar = @svg
      .selectAll('.bar')
        .data(@data[n])
      .enter().append('rect')
        .attr('id', (d, i) -> "bar-#{n}-#{i}")
        .attr('class', (d) -> "bar bar-#{n} #{d.age} issue-#{d.number}")
        .attr('x', (d) => @x_scale(d.index) - @bar_width)
        .attr 'width', @bar_width
        .attr 'y', @y_scale(0)
        .attr 'height', @chart_height - @y_scale(0)
    @bar
      .transition()
        .duration(800)
        .delay(80)
        .attr('y', (d) => @y_scale(d.days))
        .attr('height', (d) => @chart_height - @y_scale(d.days))

  _render_bar_shadow: ->
    super()
    @svg
      .selectAll('.bar-shadow')
      .on('click', (d) -> window.showModal(d.issue))

  _render_axes: ->
    @svg
      .append 'g'
        .attr class: 'axis x'
        .attr transform: "translate(0,#{@chart_height})"
        .call @x_axis
      .append 'text'
        .attr 'class', 'title'
        .attr 'y', 20
        .attr 'x', @chart_width / 2
        .style 'text-anchor', 'end'
        .text 'Issues'

    @svg
      .append 'g'
        .attr class: 'axis y'
        .call @y_axis
      .append 'text'
        .attr 'class', 'title'
        .attr 'transform', 'rotate(-90)'
        .attr 'y', -50
        .attr 'x', @margin.bottom - @chart_height / 2
        .style 'text-anchor', 'end'
        .text 'WIP, Days'

  _tooltip_content: (node, d, i, data_item) ->
    "<b>##{d.number}</b><br/>#{d.days} Days"
