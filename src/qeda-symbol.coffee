#
# Class for schematics symbol
#
class QedaSymbol
  #
  # Constructor
  #
  constructor: (element, @groups, @name) ->
    @settings = element.library.symbol
    @shapes = []
    @attributes = []
    @currentLineWidth = 0
    sides = ['left', 'right', 'top', 'bottom']
    schematic = element.schematic
    for side in sides
      @[side] = []
      if schematic[side]?
        groups = element.parseMultiple schematic[side]
        for group in groups
          pinGroup = element.pinGroups[group]
          if (@groups.indexOf(group) isnt -1) and pinGroup?
            if @[side].length > 0
              @[side].push '-' # Insert gap
            @[side] = @[side].concat pinGroup

    both = @left.filter((v) => (v isnt '-') and (@right.indexOf(v) isnt -1))
    delta = Math.ceil((@right.length - @left.length + both.length) / 2)
    toLeft = both[0..(delta-1)]
    toRight = both[delta..]
    @left = @left.filter((v) => toRight.indexOf(v) is -1)
    @right = @right.filter((v) => toLeft.indexOf(v) is -1)

    @x = 0
    @y = 0
    @cx = 0
    @cy = 0

  #
  # Align number to grid
  #
  alignToGrid: (n, method = 'round') ->
    Math[method](n / @settings.gridSize) * @settings.gridSize

  #
  # Add arc
  #
  arc: (x, y, radius, start, end) ->
    @_addShape 'arc', { x: @cx + x, y: @cy + y, radius: radius, start: start, end: end }
    this

  #
  # Add attribute
  #
  attribute: (name, attribute) ->
    attribute.name = name
    attribute.fontSize ?= @settings.fontSize[name] ? @settings.fontSize.default
    @attributes[name] = @_addShape 'attribute',  attribute
    this

  #
  # Change center point
  #
  center: (x, y) ->
    @cx = x
    @cy = y
    this

  #
  # Add circle
  #
  circle: (x, y, radius) ->
    @_addShape 'circle', { x: @cx + x, y: @cy + y, radius: radius }
    this

  icon: (x, y, iconObj) ->
    iconObj.draw x, y
    this

  #
  # Flip vertically
  #
  invertVertical: ->
    props = ['y', 'y1', 'y2', 'height']
    for shape in @shapes
      for prop in props
        if shape[prop]? then shape[prop] *= -1
      if shape['points']?
        shape['points'] = shape['points'].map((v, i) -> if i % 2 is 1 then -v else v)

  #
  # Add line
  #
  line: (x1, y1, x2, y2) ->
    if (x1 isnt x2) or (y1 isnt y2)
      @_addShape 'line', { x1: @cx + x1, y1: @cy + y1, x2: @cx + x2, y2: @cy + y2 }
    this

  #
  # Line to current position
  #
  lineTo: (x, y) ->
    @line @x, @y, x, y
    @moveTo x, y

  #
  # Set current line width
  #
  lineWidth: (lineWidth) ->
    @currentLineWidth = lineWidth
    this

  #
  # Change current position
  #
  moveTo: (x, y) ->
    @x = x
    @y = y
    this

  #
  # Add pin
  #
  pin: (pin) ->
    pin.fontSize ?= @settings.fontSize.pin
    pin.space ?= @settings.space.pin
    pin.x = @cx + pin.x
    pin.y = @cy + pin.y
    @_addShape 'pin', pin
    this

  #
  # Add polyline/polygon
  #
  poly: (points..., fill) ->
    count = points.length/2
    for i in [0..(count - 1)]
      points[2*i] = @cx + points[2*i]
      points[2*i + 1] = @cy + points[2*i + 1]
    @_addShape 'poly', { points: points, fill: fill }
    this

  #
  # Add polyline
  #
  polyline: (points...) ->
    @poly points..., 'none'

  #
  # Add rectangle
  #
  rectangle: (x1, y1, x2, y2, fill = 'none') ->
    @_addShape 'rectangle', { x1: @cx + x1, y1: @cy + y1, x2: @cx + x2, y2: @cy + y2, fill: fill }
    this

  #
  # Resize symbol to new grid size
  #
  resize: (gridSize, needRound = false) ->
    factor = gridSize / @settings.gridSize
    props = ['x', 'x1', 'x2', 'y', 'y1', 'y2', 'width', 'height', 'length', 'lineWidth', 'fontSize', 'space', 'radius']
    for shape in @shapes
      for prop in props
        if shape[prop]?
           value = shape[prop] * factor
           if needRound then value = Math.round value
           shape[prop] = value
      if shape['points']?
        shape['points'] = shape['points'].map((v) -> v * factor)
        if needRound then shape['points'] = shape['points'].map((v) -> Math.round(v))


  #
  # Get text height
  #
  textWidth: (text, textType = 'default') ->
    @settings.fontSize[textType] * text.length

  #
  # Add arbitrary shape object
  #
  _addShape: (kind, shape) ->
    obj =
      kind: kind
    for own prop of shape
      obj[prop] = shape[prop]
    obj.lineWidth ?= @currentLineWidth
    @shapes.push obj
    obj

module.exports = QedaSymbol
