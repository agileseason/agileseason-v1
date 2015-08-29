$(document).on 'page:change', ->
  return unless document.body.id == 'roadmaps_show'

  # Issues
  issues = [
    { row: 0, from: 0, cycletime: 40, number: 84 }
    { row: 1, from: 0, cycletime: 140, number: 90 }
    { row: 0, from: 60, cycletime: 90, number: 75 }
  ]
  issueHeigth = 40
  rowOffset = 20

  # Dates as xAxis
  yXAxis = (issueHeigth + rowOffset) * 2 # Max row from 'issues' + 1
  dates = [
    { from: 0, text: '06 Aug' },
    { from: 60, text: '07 Aug' }
  ]

  height = 280
  width = 2000

  svg = d3.select('.canvas')
    .append('svg')
    .attr('width', width)
    .attr('height', height)

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
