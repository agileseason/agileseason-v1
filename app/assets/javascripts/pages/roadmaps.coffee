$(document).on 'page:change', ->
  return unless document.body.id == 'roadmaps_show'

  $canvas = $('.canvas')

  # Issues
  issues = $canvas.data('chart-issues')
  issueHeigth = 30
  rowOffset = 2
  max_issue_row = d3.max(issues, (e) -> e.row + 1) # Plus 1 for xAxis

  # Dates as xAxis
  yXAxis = (issueHeigth + rowOffset) * $canvas.data('chart-issue-rows')
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
        y: (e) -> yXAxis
      .text((e) -> e.text)
