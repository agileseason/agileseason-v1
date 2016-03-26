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

  _max: ->
    max = Number.MIN_SAFE_INTEGER
    for data, n in @data
      max_tmp = d3.max(data, (d) -> d)
      max = max_tmp if max_tmp > max
    max

  _length: ->
    @data[0].length

  _bar_step: ->
    0.05

  _prepare_sizes: ->
    @margin = { top: 50, right: 60, bottom: 40, left: 60 }
    @chart_width = @$chart.width() - @margin.left - @margin.right
    @chart_height = @$chart.height() - @margin.top - @margin.bottom
    bar_step = @chart_width / @_length() * @_bar_step()
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

  _prepare_chart: ->
    # Override
  _render_axes: ->
    # Override
  _render_chart: ->
    # Override

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

  _render_tooltip: ->
    @tooltip = []
    for data, n in @data
      @tooltip[n] = d3
        .selectAll @$chart
        .append 'div'
        .attr class: "tooltip tooltip-#{n}"
        .style opacity: 0

  _on_bar_mouseover: (node, d, i) =>
    return unless d
    d3.select(node).classed hovered: true

    for data, n in @data
      @tooltip[n]
        .transition()
        .duration 100
        .style opacity: 0.8

      bar = d3.select("#bar-#{n}-#{i}")
      bar.classed hovered: true

      @tooltip[n]
        .html @_tooltip_content(node, d, i, data[i])
        .style
          left: "#{@_calculate_tooltip_left(bar, n)}px"
          top: "#{@_calculate_tooltip_top(bar, n)}px"

  _tooltip_content: (node, d, i, data_item) ->
    "<b>##{d.number}</b><br/>#{d.days} Days"

  _calculate_tooltip_left: (bar, n) =>
    tooltip_width = @tooltip[n].node().getBoundingClientRect().width
    parseInt(bar.attr('x')) + @margin.left + @bar_width / 2 - tooltip_width / 2

  _calculate_tooltip_top: (bar, n) =>
    tooltip_height = @tooltip[n].node().getBoundingClientRect().height
    parseInt(bar.attr('y')) + @margin.top - tooltip_height - 10

  _on_bar_mouseout: (node, d, i) =>
    d3.select(node).classed hovered: false

    for data, n in @data
      d3.select("#bar-#{n}-#{i}").classed hovered: false
      @tooltip[n].style opacity: 0
