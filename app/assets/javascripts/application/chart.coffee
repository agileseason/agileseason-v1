(($) ->
  $.fn.extend render_chart: ->
    $(@).data('clicks-chart') || @each ->
      chart = new ClicksChart @
      $(@).data 'clicks-chart': chart
) jQuery

class ClicksChart
  constructor: (root) ->
    @$chart = $(root)

    @_prepare_data()
    @_prepare_sizes()
    @_prepare_svg()
    @_prepare_chart()
    @_prepare_scales()
    @_prepare_axes()

    @_render_chart()
    @_render_axes()
    #@_render_tooltip()

  _prepare_data: ->
    @data = @$chart.data('chart-data')

  _prepare_sizes: ->
    @margin = { top: 50, right: 60, bottom: 40, left: 60 }
    @chart_width = @$chart.width() - @margin.left - @margin.right
    @chart_height = @$chart.height() - @margin.top - @margin.bottom

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

  _prepare_chart: ->
    @area = d3
      .svg
      .area()
      .interpolate 'monotone'
      .x (d) => @x_scale d.number
      .y0 @chart_height
      .y1 (d) => @y_scale d.days

  _prepare_scales: ->
    max_days = d3.max @data, (d) -> d.days

    @x_scale = d3
      .time
      .scale()
      .domain [0, @data.length]
      .range [0, @chart_width]

    @y_scale = d3
      .scale
      .linear()
      .domain [0, max_days]
      .range [@chart_height, 0]

  _prepare_axes: ->
    @x_axis = d3
      .svg
      .axis()
      .scale @x_scale
      .orient 'bottom'
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
    bar_step = @chart_width / @data.length / 12
    bar_width = @chart_width / @data.length - bar_step
    _on_bar_mouseover = @_on_bar_mouseover
    _on_bar_mouseout = @_on_bar_mouseout

    @bar = @svg
      .selectAll('.bar')
        .data(@data)
      .enter().append('rect')
        .attr('class', (d) -> "bar #{d.age}")
        .attr('x', (d) => @x_scale(d.index) - bar_width)
        .attr 'width', bar_width
        .attr 'y', @y_scale(0)
        .attr 'height', @chart_height - @y_scale(0)
        .on('mouseover', (d, i) -> _on_bar_mouseover @, d, i)
        .on('mouseout', (d, i) -> _on_bar_mouseout @, d, i)
    @bar
      .transition()
        .duration(800)
        .delay(100)
        .attr('y', (d) => @y_scale(d.days))
        .attr('height', (d) => @chart_height - @y_scale(d.days))

  _render_axes: ->
    @svg
      .append 'g'
        .attr class: 'axis x'
        .attr transform: "translate(0,#{@chart_height})"
        .call @x_axis

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
        .text 'WIP, Days'

  _render_tooltip: ->
    @tooltip = d3
      .selectAll @$chart
      .append 'div'
      .attr class: 'tooltip'
      .style opacity: 0

  _on_bar_mouseover: (node, d, i) =>
    d3.select(node).classed hovered: true

    #hovered_circle = d3.select "#circle-#{i}"
    #hovered_circle.classed hovered: true

    #@tooltip
      #.transition()
      #.duration 200
      #.style opacity: 0.8

    #@tooltip
      #.html @_tooltip_content d.collected_on, d.sum_clicks
      #.style
        #left: "#{@_calculate_tooltip_left hovered_circle}px"
        #top: "#{@_calculate_tooltip_top hovered_circle}px"

  _tooltip_content: (date, value) =>
    "#{ru_locale().timeFormat('%e %B') date}<br/>
      <b>#{numeral(value).format('0,0')} #{p value, 'возврат', 'возврата', 'возвратов'}</b>"

  _calculate_tooltip_left: (circle) =>
    tooltip_width = @tooltip.node().getBoundingClientRect().width
    parseInt(circle.attr('cx')) + @margin.left - tooltip_width / 2

  _calculate_tooltip_top: (circle) =>
    tooltip_height = @tooltip.node().getBoundingClientRect().height
    parseInt(circle.attr('cy')) + @margin.top - tooltip_height - 6

  _on_bar_mouseout: (node, d, i) =>
    d3.select(node).classed hovered: false

    #hovered_circle = d3.select "#circle-#{i}"
    #hovered_circle.classed hovered: false

    #@tooltip
      #.transition()
      #.duration 400
      #.style opacity: 0
