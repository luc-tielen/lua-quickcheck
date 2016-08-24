
random = require 'lqc.random'
property = require 'lqc.property'
lqc = require 'lqc.quickcheck'
byte = require 'lqc.generators.byte'
r = require 'lqc.report'

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

