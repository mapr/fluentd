require_relative '../helper'
require 'fluent/plugin_helper/child_process'
require 'fluent/plugin/base'

class ThreadTest < Test::Unit::TestCase
  def setup
    @d = Dummy.new
    @d.configure(config_element())
    @d.start
  end

  class Dummy < Fluent::Plugin::Base
    helpers :child_process
    def configure(conf)
      super
      @_child_process_kill_timeout = 1
    end
  end

  test 'can be instantiated under state that timer is not running' do
    d1 = Dummy.new
    assert d1.respond_to?(:timer_running?)
    assert !d1.timer_running?
  end

  test 'can be configured and started' do
    d1 = Dummy.new
    assert_nothing_raised do
      d1.configure(config_element())
    end
    assert d1.plugin_id
    assert d1.log

    d1.start
  end

  test 'can execute external command asyncronously' do
    m = Mutex.new
    m.lock
    ary = []
    @d.child_process_execute(:t0, 'echo', arguments: ['foo', 'bar']) do |io|
      m.lock
      io.read # discard
      ary << 2
      m.unlock
    end
    ary << 1
    m.unlock
    Thread.pass until m.locked?
    m.lock
    m.unlock
    assert_equal [1,2], ary
  end

  test 'can execute external command at just once, which finishes immediately' do
    m = Mutex.new
    t1 = Time.now
    ary = []
    @d.child_process_execute(:t1, 'echo', arguments: ['foo', 'bar']) do |io|
      m.lock
      ary << io.read
      assert io.eof?
      m.unlock
    end
    Thread.pass until m.locked?
    m.lock
    m.unlock
    assert{ Time.now - t1 < 2.0 } # immediately?
  end

  test 'can execute external command at just once, which runs long time'
  test 'can execute external command many times, which finishes immediately'
  test 'can execute external command many times, with leading once executed immediately'
  test 'does not execute long running external command in parallel in default'
  test 'can execute long running external command in parallel if specified'
  test 'can control i/o read/write mode'
  test 'can control external encodings'
  test 'can specify subprocess name'
end
