require_relative '../helper'
require 'fluent/plugin_helper/event_emitter'
require 'fluent/plugin/base'

class EventEmitterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  class Dummy < Fluent::Plugin::Base
    helpers :event_emitter
  end

  test 'can be instantiated to be able to emit with router' do
    d1 = Dummy.new
    assert d1.respond_to?(:router)
    assert d1.respond_to?(:emits?)
    assert d1.emits?
    d1.stop; d1.shutdown; d1.close; d1.terminate
  end

  test 'can be configured with valid router' do
    d1 = Dummy.new
    assert d1.emits?
    assert_nil d1.router

    assert_nothing_raised do
      d1.configure(config_element())
    end

    assert d1.router

    d1.shutdown

    assert_nil d1.router
    d1.stop; d1.shutdown; d1.close; d1.terminate
  end
end
