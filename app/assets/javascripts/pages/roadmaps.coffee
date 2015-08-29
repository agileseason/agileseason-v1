$(document).on 'page:change', ->
  return unless document.body.id == 'roadmaps_show'

  $canvas = $('.canvas')

  # Issues
  issues = $canvas.data('chart-issues')
  issueHeigth = 40
  rowOffset = 20

  # Dates as xAxis
  yXAxis = (issueHeigth + rowOffset) * $canvas.data('chart-issue-rows')
  dates = $canvas.data('chart-dates')

  # Prepare svg canvas
  svg = d3.select('.canvas')
    .append('svg')
    .attr
      height: 280
      width: 2000

  # Issue Cycletime Rectangle
  svg.selectAll('rect')
    .data(issues)
    .enter()
    .append('rect')
      .attr
        class: 'issue'
        width: (e) -> e.cycletime
        height: issueHeigth
        x: (e) -> e.from
        y: (e, i) ->
          e.row * (issueHeigth + rowOffset)

  # Issues numbers
  svg.selectAll('text')
    .data(issues)
    .enter()
      .append('text')
        .attr
          class: 'issue-number'
          x: (e) -> e.from # Copy paste from rect - issues
          y: (e) ->
            e.row * (issueHeigth + rowOffset)
          dx: 6
          dy: issueHeigth / 2
        .text((e) -> "##{e.number}")

  # xAxis as Dates
  svg.selectAll('text.x-axis')
    .data(dates)
    .enter()
      .append('text')
      .attr
        class: 'x-axis'
        x: (e) -> e.from
        y: (e) -> yXAxis
      .text((e) -> e.text)
