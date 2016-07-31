
random = require 'src.random'
property = require 'src.property'
lqc = require 'src.quickcheck'
byte = require 'src.generators.byte'
r = require 'src.report'

do_setup = ->
  random.seed()
  lqc.init 100, 100
  lqc.properties = {}
  r.report = ->

describe 'integration with moonscript', ->
  before_each do_setup

  it 'should be possible to write properties in moonscript', ->
    spy_check = spy.new((x) -> x >= 0)

    property 'simple example'
      generators: { byte! }
      check: spy_check

    lqc.check!
    assert.spy(spy_check).was.called(lqc.numtests)

