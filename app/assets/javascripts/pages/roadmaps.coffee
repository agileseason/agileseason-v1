$(document).on 'page:change', ->
  return unless document.body.id == 'roadmaps_show'

  $canvas = $('.canvas')

  # Issues
  issues = $canvas.data('chart-issues')
  issueHeigth = 30
  rowOffset = 2
  max_issue_row = d3.max(issues, (e) -> e.row) + 2 # Plus 2 for xAxis

  # Dates as xAxis
  dates = $canvas.data('chart-dates')

  # Prepare svg canvas
  chart_height = max_issue_row * (issueHeigth + rowOffset)
  chart_width = 1300
  svg = d3.select('.canvas')
    .append('svg')
    .attr
      height: chart_height
      width: chart_width

  # Scale
  max_issue_from = d3.max(issues, (e) -> e.from + e.cycletime)
  xScale = d3.scale.
    linear().
    domain([0, max_issue_from]). # Data minimum and maximum
    range([0, chart_width])  # pixels to map

  # Issue Cycletime Rectangle
  svg.selectAll('rect')
    .data(issues)
    .enter()
    .append('rect')
      .attr
        class: (e) -> "issue #{e.state}"
        width: (e) -> xScale(e.cycletime)
        height: issueHeigth
        x: (e) -> xScale(e.from)
        y: (e, i) ->
          e.row * (issueHeigth + rowOffset)
        number: (e) -> e.number

  # Issues numbers
  svg.selectAll('text')
    .data(issues)
    .enter()
      .append('text')
        .attr
          class: 'issue-number'
          x: (e) -> xScale(e.from) # Copy paste from rect - issues
          y: (e) ->
            e.row * (issueHeigth + rowOffset)
          dx: 6
          dy: issueHeigth / 1.6
        .text((e) -> "##{e.number}")

  # xAxis as Dates
  svg.selectAll('text.x-axis')
    .data(dates)
    .enter()
      .append('text')
      .attr
        class: 'x-axis'
        x: (e) -> xScale(e.from)
        y: (e) -> chart_height
      .text((e) -> e.text)

  # Line now
  xNow = $canvas.data('chart-now')
  svg
    .append('line')
    .style('stroke-dasharray', '3, 3')
    .attr
      class: 'now'
      x1: xScale(xNow)
      y1: 0
      x2: xScale(xNow)
      y2: chart_height
  svg
    .selectAll('text.now')
    .data([14, chart_height])
    .enter()
      .append('text')
      .attr
        class: 'now-title'
        x: xScale(xNow)
        y: (e) -> e
        dx: 6
        dy: -2
      .text('Now')

  $canvas.on 'click', '.issue', ->
    window.location = $canvas.data('chart-issue-url-prefix') + $(@).attr('number')
