sprintf = require('sprintf-js').sprintf
assembly = require './assembly'
calculator = require './calculator'
copper = require './copper'
courtyard = require './courtyard'
silkscreen = require './silkscreen'

module.exports = (pattern, element) ->
  housing = element.housing
  settings = pattern.settings
  leadCount = housing.leadCount ? 2*(housing.rowCount + housing.columnCount)

  abbr = 'BGA'
  option = 'bga'

  pattern.name ?= sprintf "%s%d%s%dP%dX%d_%dX%dX%d%s",
    abbr,
    leadCount,
    if settings.ball.collapsible then 'C' else 'N'
    [housing.pitch*100
    housing.columnCount
    housing.rowCount
    housing.bodyLength.nom*100
    housing.bodyWidth.nom*100
    housing.height.max*100]
    .map((v) => Math.round v)...,
    settings.densityLevel

  housing.rowPitch ?= housing.pitch
  housing.columnPitch ?= housing.pitch

  padParams = calculator.gridArray pattern, housing, option
  pad =
    type: 'smd'
    width: padParams.width
    height: padParams.height
    shape: 'circle'
    layer: ['topCopper', 'topMask', 'topPaste']

  copper.gridArray pattern, element, pad
  silkscreen.gridArray pattern, housing
  assembly.polarized pattern, housing
  courtyard.gridArray pattern, housing, padParams.courtyard