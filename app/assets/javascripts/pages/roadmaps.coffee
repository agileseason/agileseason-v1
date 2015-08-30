$(document).on 'page:change', ->
  return unless document.body.id == 'roadmaps_show'

  $canvas = $('.canvas')
  is_no_scale = $canvas.data('chart-mode') == '1:1'

  # Issues
  issues = $canvas.data('chart-issues')
  issueHeigth = 30
  rowOffset = 2
  max_issue_row = d3.max(issues, (e) -> e.row) + 2 # Plus 2 for xAxis
  max_issue_x = d3.max(issues, (e) -> e.from + e.cycletime)

  # Prepare svg canvas
  chart_height = max_issue_row * (issueHeigth + rowOffset)
  chart_width = if is_no_scale then max_issue_x else $(document).width() - 50
  svg = d3.select('.canvas')
    .append('svg')
    .attr
      height: chart_height
      width: chart_width

  # Scale
  if is_no_scale
    xScale = (x) -> x
  else
    xScale = d3.scale.
      linear().
      domain([0, max_issue_x]). # Data minimum and maximum
      range([0, chart_width])  # pixels to map

  # Issue Cycletime Rectangle
  svg.selectAll('rect')
    .data(issues)
    .enter()
    .append('rect')
      .attr
        class: (d) -> "issue #{d.state}"
        width: (d) -> xScale(d.cycletime)
        height: issueHeigth
        x: (d) -> xScale(d.from)
        y: (d) ->
          d.row * (issueHeigth + rowOffset)
        number: (d) -> d.number
        title: (d) -> d.title
      .on 'mouseover', (d, i) ->
        issue_mouseover(@, d, i)
      .on 'mouseout', (d, i) ->
        issue_mouseout(@, d, i)

  # xAxis as Dates
  dates = $canvas.data('chart-dates')
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

issue_mouseover = (node, issue, row) ->
  $node = $(node)
  #right
  left = parseInt($node.attr('x')) + parseInt($node.attr('width')) + 4
  top = parseInt($node.attr('y'))
  # bottom
  #left = parseInt($node.attr('x')) + 4
  #top = parseInt($node.attr('y')) + parseInt($node.attr('height')) + 20

  d3.select('.canvas .tooltip')
    .html tooltip_content(issue)
    .transition()
    .duration 100
    .style opacity: 0.95
    .style
      left: "#{left}px"
      top: "#{top}px"

issue_mouseout = ($node, issue, row) ->
  d3.select('.canvas .tooltip')
    .transition()
    .duration 0
    .style opacity: 0

tooltip_content = (issue) ->
  "<div class='number'>##{issue.number}</div>
    <div class='title'>#{issue.title}</div>
    <div>Created at <b>#{issue.created_at}</b></div>
    <div>Closed at <b>#{issue.closed_at}</b></div>
    <div>Current column is <b>#{issue.column}</b> #{if issue.is_archive then '[archived]' else ''}</div>
    "
