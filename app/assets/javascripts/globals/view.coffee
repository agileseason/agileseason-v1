class @View
  constructor: ($root) ->
    @_initialize($root)
    @initialize()
    @initialized = true

  on: ->
    @$root.on.apply(@$root, arguments)

  trigger: ->
    @$root.trigger.apply(@$root, arguments)

  $: (selector) ->
    $(selector, @$root)

  # внутренняя инициализация
  _initialize: (root) ->
    @$root = $(root)
    @root = @$root[0]
    @$root.data view_object: @
