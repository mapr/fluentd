require_relative '../helper'
require 'fluent/configurable'
require 'fluent/config/element'
require 'fluent/config/section'

module ConfigurableSpec
  class Base1
    include Fluent::Configurable

    config_param :node, :string, default: "node"
    config_param :flag1, :bool, default: false
    config_param :flag2, :bool, default: true

    config_param :name1, :string
    config_param :name2, :string
    config_param :name3, :string, default: "base1"
    config_param :name4, :string, default: "base1"

    config_param :opt1, :enum, list: [:foo, :bar, :baz]
    config_param :opt2, :enum, list: [:foo, :bar, :baz], default: :foo

    def get_all
      [@node, @flag1, @flag2, @name1, @name2, @name3, @name4]
    end
  end

  class Base2 < Base1
    config_set_default :name2, "base2"
    config_set_default :name4, "base2"
    config_set_default :opt1, :bar
    config_param :name5, :string
    config_param :name6, :string, default: "base2"
    config_param :opt3, :enum, list: [:a, :b]

    def get_all
      ary = super
      ary + [@name5, @name6]
    end
  end

  class Base3 < Base2
    config_set_default :opt3, :a
    config_section :node do
      config_param :name, :string, default: "node"
      config_param :type, :string
    end
    config_section :branch, required: true, multi: true do
      config_argument :name, :string
      config_param :size, :integer, default: 10
      config_section :leaf, required: false, multi: true do
        config_param :weight, :integer
        config_section :worm, param_name: 'worms', multi: true do
          config_param :type, :string, default: 'ladybird'
        end
      end
    end

    def get_all
      ary = super
      ary + [@branch]
    end
  end

  class Base4 < Base2
    config_set_default :opt3, :a
    config_section :node, param_name: :nodes do
      config_argument :num, :integer
      config_param :name, :string, default: "node"
      config_param :type, :string, default: "b4"
    end
    config_section :description1, required: false, multi: false do
      config_argument :note, :string, default: "desc1"
      config_param :text, :string
    end
    config_section :description2, required: true, multi: false do
      config_argument :note, :string, default: "desc2"
      config_param :text, :string
    end
    config_section :description3, required: true, multi: true do
      config_argument :note, default: "desc3" do |val|
        "desc3: #{val}"
      end
      config_param :text, :string
    end

    def get_all
      ary = super
      ary + [@nodes, @description1, @description2, @description3]
    end
  end

  class Example0
    include Fluent::Configurable

    config_param :stringvalue, :string
    config_param :boolvalue, :bool
    config_param :integervalue, :integer
    config_param :sizevalue, :size
    config_param :timevalue, :time
    config_param :floatvalue, :float
    config_param :hashvalue, :hash
    config_param :arrayvalue, :array
  end

  class Example1
    include Fluent::Configurable

    config_param :name, :string, alias: :fullname
    config_param :bool, :bool, alias: :flag
    config_section :detail, required: false, multi: false, alias: "information" do
      config_param :address, :string, default: "x"
    end

    def get_all
      [@name, @detail]
    end
  end

  class Example3
    include Fluent::Configurable

    config_param :age, :integer, default: 10

    config_section :appendix, required: true, multi: false, final: true do
      config_param :type, :string
      config_param :name, :string, default: "x"
    end

    def get_all
      [@name, @detail]
    end
  end

  class Example5
    include Fluent::Configurable

    config_param :normal_param, :string
    config_param :secret_param, :string, secret: true

    config_section :section  do
      config_param :normal_param2, :string
      config_param :secret_param2, :string, secret: true
    end
  end

  class Example6
    include Fluent::Configurable
    config_param :obj1, :hash, default: {}
    config_param :obj2, :array, default: []
  end

  module Overwrite
    class Base
      include Fluent::Configurable

      config_param :name, :string, alias: :fullname
      config_param :bool, :bool, alias: :flag
      config_section :detail, required: false, multi: false, alias: "information" do
        config_param :address, :string, default: "x"
      end
    end

    class Required < Base
      config_section :detail, required: true do
        config_param :address, :string, default: "x"
      end
    end

    class Multi < Base
      config_section :detail, multi: true do
        config_param :address, :string, default: "x"
      end
    end

    class Alias < Base
      config_section :detail, alias: "information2" do
        config_param :address, :string, default: "x"
      end
    end

    class DefaultOptions < Base
      config_section :detail do
        config_param :address, :string, default: "x"
      end
    end

    class DetailAddressDefault < Base
      config_section :detail do
        config_param :address, :string, default: "y"
      end
    end

    class AddParam < Base
      config_section :detail do
        config_param :phone_no, :string
      end
    end

    class AddParamOverwriteAddress < Base
      config_section :detail do
        config_param :address, :string, default: "y"
        config_param :phone_no, :string
      end
    end
  end

  module Final
    class Base
      include Fluent::Configurable
      config_section :appendix, multi: false, final: false do
        config_param :name, :string, default: "x"
      end
    end

    class Finalized < Base
      config_section :appendix, final: true do
        config_param :name, :string, default: "y"
        config_param :age, :integer, default: 10
      end
    end

    class InheritsFinalized < Finalized
      config_section :appendix do
        config_param :name, :string, default: "z"
        config_param :age, :integer, default: 20
        config_param :phone_no, :string
      end
    end

    class FinalizedBase
      include Fluent::Configurable
      config_section :appendix, required: true, multi: false, alias: "options", final: true do
        config_param :name, :string, default: "x"
      end
    end

    class InheritsFinalized2 < FinalizedBase
      config_section :appendix do
        config_param :name, :string, default: "y"
        config_param :age, :integer, default: 10
        config_param :phone_no, :string
      end
    end

    class InheritsFinalized3 < InheritsFinalized2
      config_section :appendix do
        config_param :name, :string, default: "y"
        config_param :age, :integer, default: 20
        config_param :phone_no, :string
      end
    end

    # Error
    class InheritsFinalized4 < FinalizedBase
      config_section :appendix, final: false do
        config_param :age, :integer, default: 10
        config_param :phone_no, :string
      end
    end

    class OverwriteRequired < FinalizedBase
      config_section :appendix, required: false do
        config_param :phone_no, :string
      end
    end

    class OverwriteMulti < FinalizedBase
      config_section :appendix, multi: true do
        config_param :phone_no, :string
      end
    end

    class OverwriteAlias < FinalizedBase
      config_section :appendix, alias: "options2" do
        config_param :phone_no, :string
      end
    end
  end
end

module Fluent::Config
  class TestConfigurable < ::Test::Unit::TestCase
    sub_test_case 'class defined without config_section' do
      sub_test_case '#initialize' do
        test 'create instance methods and default values by config_param and config_set_default' do
          obj1 = ConfigurableSpec::Base1.new
          assert_equal("node", obj1.node)
          assert_false(obj1.flag1)
          assert_true(obj1.flag2)
          assert_nil(obj1.name1)
          assert_nil(obj1.name2)
          assert_equal("base1", obj1.name3)
          assert_equal("base1", obj1.name4)
          assert_nil(obj1.opt1)
          assert_equal(:foo, obj1.opt2)
        end

        test 'create instance methods and default values overwritten by sub class definition' do
          obj2 = ConfigurableSpec::Base2.new
          assert_equal("node", obj2.node)
          assert_false(obj2.flag1)
          assert_true(obj2.flag2)
          assert_nil(obj2.name1)
          assert_equal("base2", obj2.name2)
          assert_equal("base1", obj2.name3)
          assert_equal("base2", obj2.name4)
          assert_nil(obj2.name5)
          assert_equal("base2", obj2.name6)
          assert_equal(:bar, obj2.opt1)
          assert_equal(:foo, obj2.opt2)
        end
      end

      sub_test_case '#configure' do
        test 'returns configurable object itself' do
          b2 = ConfigurableSpec::Base2.new
          assert_instance_of(ConfigurableSpec::Base2, b2.configure(config_element("", "", {"name1" => "t1", "name5" => "t5", "opt3" => "a"})))
        end

        test 'raise errors without any specifications for param without defaults' do
          b2 = ConfigurableSpec::Base2.new
          assert_raise(Fluent::ConfigError) { b2.configure(config_element("", "", {})) }
          assert_raise(Fluent::ConfigError) { b2.configure(config_element("", "", {"name1" => "t1"})) }
          assert_raise(Fluent::ConfigError) { b2.configure(config_element("", "", {"name5" => "t5"})) }
          assert_raise(Fluent::ConfigError) { b2.configure(config_element("", "", {"name1" => "t1", "name5" => "t5"})) }
          assert_nothing_raised { b2.configure(config_element("", "", {"name1" => "t1", "name5" => "t5", "opt3" => "a"})) }

          assert_equal(["node", false, true, "t1", "base2", "base1", "base2", "t5", "base2"], b2.get_all)
          assert_equal(:a, b2.opt3)
        end

        test 'can configure bool values' do
          b2a = ConfigurableSpec::Base2.new
          assert_nothing_raised { b2a.configure(config_element("", "", {"flag1" => "true", "flag2" => "yes", "name1" => "t1", "name5" => "t5", "opt3" => "a"})) }
          assert_true(b2a.flag1)
          assert_true(b2a.flag2)

          b2b = ConfigurableSpec::Base2.new
          assert_nothing_raised { b2b.configure(config_element("", "", {"flag1" => false, "flag2" => "no", "name1" => "t1", "name5" => "t5", "opt3" => "a"})) }
          assert_false(b2b.flag1)
          assert_false(b2b.flag2)
        end

        test 'overwrites values of defaults' do
          b2 = ConfigurableSpec::Base2.new
          b2.configure(config_element("", "", {"name1" => "t1", "name2" => "t2", "name3" => "t3", "name4" => "t4", "name5" => "t5", "opt1" => "foo", "opt3" => "b"}))
          assert_equal("t1", b2.name1)
          assert_equal("t2", b2.name2)
          assert_equal("t3", b2.name3)
          assert_equal("t4", b2.name4)
          assert_equal("t5", b2.name5)
          assert_equal("base2", b2.name6)
          assert_equal(:foo, b2.opt1)
          assert_equal(:b, b2.opt3)

          assert_equal(["node", false, true, "t1", "t2", "t3", "t4", "t5", "base2"], b2.get_all)
        end

        test 'enum type rejects values which does not exist in list' do
          default = config_element("", "", {"name1" => "t1", "name2" => "t2", "name3" => "t3", "name4" => "t4", "name5" => "t5", "opt1" => "foo", "opt3" => "b"})

          b2 = ConfigurableSpec::Base2.new
          assert_nothing_raised { b2.configure(default) }
          assert_raise(Fluent::ConfigError) { b2.configure(default.merge({"opt1" => "bazz"})) }
          assert_raise(Fluent::ConfigError) { b2.configure(default.merge({"opt2" => "fooooooo"})) }
          assert_raise(Fluent::ConfigError) { b2.configure(default.merge({"opt3" => "c"})) }
        end

        sub_test_case 'default values should be duplicated before touched in plugin code' do
          test 'default object should be dupped for cases configured twice' do
            x6a = ConfigurableSpec::Example6.new
            assert_nothing_raised { x6a.configure(config_element("")) }
            assert_equal({}, x6a.obj1)
            assert_equal([], x6a.obj2)

            x6b = ConfigurableSpec::Example6.new
            assert_nothing_raised { x6b.configure(config_element("")) }
            assert_equal({}, x6b.obj1)
            assert_equal([], x6b.obj2)

            assert { x6a.obj1.object_id != x6b.obj1.object_id }
            assert { x6a.obj2.object_id != x6b.obj2.object_id }

            x6c = ConfigurableSpec::Example6.new
            assert_nothing_raised { x6c.configure(config_element("")) }
            assert_equal({}, x6c.obj1)
            assert_equal([], x6c.obj2)

            x6c.obj1['k'] = 'v'
            x6c.obj2 << 'v'

            assert_equal({'k' => 'v'}, x6c.obj1)
            assert_equal(['v'], x6c.obj2)

            assert_equal({}, x6a.obj1)
            assert_equal([], x6a.obj2)
          end
        end
      end
    end

    sub_test_case 'class defined with config_section' do
      sub_test_case '#initialize' do
        test 'create instance methods and default values as nil for params from config_section specified as non-multi' do
          b4 = ConfigurableSpec::Base4.new
          assert_nil(b4.description1)
          assert_nil(b4.description2)
        end

        test 'create instance methods and default values as [] for params from config_section specified as multi' do
          b4 = ConfigurableSpec::Base4.new
          assert_equal([], b4.description3)
        end

        test 'overwrite base class definition by config_section of sub class definition' do
          b3 = ConfigurableSpec::Base3.new
          assert_equal([], b3.node)
        end

        test 'create instance methods and default values by param_name' do
          b4 = ConfigurableSpec::Base4.new
          assert_equal([], b4.nodes)
          assert_equal("node", b4.node)
        end

        test 'create non-required and multi without any specifications' do
          b3 = ConfigurableSpec::Base3.new
          assert_false(b3.class.merged_configure_proxy.sections[:node].required?)
          assert_true(b3.class.merged_configure_proxy.sections[:node].multi?)
        end
      end

      sub_test_case '#configure' do
        BASE_ATTRS = {
          "name1" => "1", "name2" => "2", "name3" => "3",
          "name4" => "4", "name5" => "5", "name6" => "6",
        }
        test 'checks required subsections' do
          b3 = ConfigurableSpec::Base3.new
          # branch sections required
          assert_raise(Fluent::ConfigError) { b3.configure(config_element('ROOT', '', BASE_ATTRS, [])) }

          # branch argument required
          msg = "'<branch ARG>' section requires argument, in section branch"
          #expect{ b3.configure(e('ROOT', '', BASE_ATTRS, [e('branch', '')])) }.to raise_error(Fluent::ConfigError, msg)
          assert_raise(Fluent::ConfigError.new(msg)) { b3.configure(config_element('ROOT', '', BASE_ATTRS, [config_element('branch', '')])) }

          # leaf is not required
          assert_nothing_raised { b3.configure(config_element('ROOT', '', BASE_ATTRS, [config_element('branch', 'branch_name')])) }

          # leaf weight required
          msg = "'weight' parameter is required, in section branch > leaf"
          branch1 = config_element('branch', 'branch_name', {size: 1}, [config_element('leaf', '10', {"weight" => 1})])
          assert_nothing_raised { b3.configure(config_element('ROOT', '', BASE_ATTRS, [branch1])) }
          branch2 = config_element('branch', 'branch_name', {size: 1}, [config_element('leaf', '20')])
          assert_raise(Fluent::ConfigError.new(msg)) { b3.configure(config_element('ROOT', '', BASE_ATTRS, [branch1, branch2])) }
          branch3 = config_element('branch', 'branch_name', {size: 1}, [config_element('leaf', '10', {"weight" =>  3}), config_element('leaf', '20')])
          assert_raise(Fluent::ConfigError.new(msg)) { b3.configure(config_element('ROOT', '', BASE_ATTRS, [branch3])) }

          ### worm not required

          b4 = ConfigurableSpec::Base4.new

          d1 = config_element('description1', '', {"text" => "d1"})
          d2 = config_element('description2', '', {"text" => "d2"})
          d3 = config_element('description3', '', {"text" => "d3"})
          assert_nothing_raised { b4.configure(config_element('ROOT', '', BASE_ATTRS, [d1.dup, d2.dup, d3.dup])) }

          # description1 cannot be specified 2 or more
          msg = "'<description1>' section cannot be written twice or more"
          assert_raise(Fluent::ConfigError.new(msg)) { b4.configure(config_element('ROOT', '', BASE_ATTRS, [d1.dup, d2.dup, d1.dup, d3.dup])) }

          # description2 cannot be specified 2 or more
          msg = "'<description2>' section cannot be written twice or more"
          assert_raise(Fluent::ConfigError.new(msg)) { b4.configure(config_element('ROOT', '', BASE_ATTRS, [d1.dup, d2.dup, d3.dup, d2.dup])) }

          # description3 can be specified 2 or more
          assert_nothing_raised { b4.configure(config_element('ROOT', '', BASE_ATTRS, [d1.dup, d2.dup, d3.dup, d3.dup])) }
        end

        test 'constructs confuguration object tree for Base3' do
          conf = config_element(
            'ROOT',
            '',
            BASE_ATTRS,
            [
              config_element('node', '', {"type" => "1"}), config_element('node', '', {"name" => "node2","type" => "2"}),
              config_element('branch', 'b1.*', {}, []),
              config_element('branch',
                'b2.*',
                {"size" => 5},
                [
                  config_element('leaf', 'THIS IS IGNORED', {"weight" =>  55}, []),
                  config_element('leaf', 'THIS IS IGNORED', {"weight" =>  50}, [ config_element('worm', '', {}) ]),
                  config_element('leaf', 'THIS IS IGNORED', {"weight" =>  50}, [ config_element('worm', '', {"type" => "w1"}), config_element('worm', '', {"type" => "w2"}) ]),
                ]
                ),
              config_element('branch',
                'b3.*',
                {"size" => "503"},
                [
                  config_element('leaf', 'THIS IS IGNORED', {"weight" =>  55}, []),
                ]
                )
            ],
            )
          b3 = ConfigurableSpec::Base3.new.configure(conf)

          assert_not_equal("node", b3.node) # overwritten

          assert_equal("1", b3.name1)
          assert_equal("2", b3.name2)
          assert_equal("3", b3.name3)
          assert_equal("4", b3.name4)
          assert_equal("5", b3.name5)
          assert_equal("6", b3.name6)

          assert_instance_of(Array, b3.node)
          assert_equal(2, b3.node.size)

          assert_equal("node", b3.node[0].name)
          assert_equal("1", b3.node[0].type)
          assert_equal(b3.node[0].type, b3.node[0][:type])
          assert_equal("node2", b3.node[1].name)
          assert_equal("2", b3.node[1].type)
          assert_equal(b3.node[1].type, b3.node[1][:type])

          assert_instance_of(Array, b3.branch)
          assert_equal(3, b3.branch.size)

          assert_equal('b1.*', b3.branch[0].name)
          assert_equal(10, b3.branch[0].size)
          assert_equal([], b3.branch[0].leaf)

          assert_equal('b2.*', b3.branch[1].name)
          assert_equal(5, b3.branch[1].size)
          assert_equal(3, b3.branch[1].leaf.size)
          assert_equal(b3.branch[1].leaf, b3.branch[1][:leaf])

          assert_equal(55, b3.branch[1].leaf[0].weight)
          assert_equal(0, b3.branch[1].leaf[0].worms.size)

          assert_equal(50, b3.branch[1].leaf[1].weight)
          assert_equal(1, b3.branch[1].leaf[1].worms.size)
          assert_equal("ladybird", b3.branch[1].leaf[1].worms[0].type)

          assert_equal(50, b3.branch[1].leaf[2].weight)
          assert_equal(2, b3.branch[1].leaf[2].worms.size)
          assert_equal("w1", b3.branch[1].leaf[2].worms[0].type)
          assert_equal("w2", b3.branch[1].leaf[2].worms[1].type)

          assert_equal('b3.*', b3.branch[2].name)
          assert_equal(503, b3.branch[2].size)
          assert_equal(1, b3.branch[2].leaf.size)
          assert_equal(55, b3.branch[2].leaf[0].weight)
        end

        test 'constructs confuguration object tree for Base4' do
          conf = config_element(
            'ROOT',
            '',
            BASE_ATTRS,
            [
              config_element('node', '1', {"type" => "1"}), config_element('node', '2', {"name" => "node2"}),
              config_element('description3', '', {"text" => "dddd3-1"}),
              config_element('description2', 'd-2', {"text" => "dddd2"}),
              config_element('description1', '', {"text" => "dddd1"}),
              config_element('description3', 'd-3', {"text" => "dddd3-2"}),
              config_element('description3', 'd-3a', {"text" => "dddd3-3"}),
              config_element('node', '4', {"type" => "four"}),
            ],
            )
          b4 = ConfigurableSpec::Base4.new.configure(conf)

          assert_equal("node", b4.node)

          assert_equal("1", b4.name1)
          assert_equal("2", b4.name2)
          assert_equal("3", b4.name3)
          assert_equal("4", b4.name4)
          assert_equal("5", b4.name5)
          assert_equal("6", b4.name6)

          assert_instance_of(Array, b4.nodes)
          assert_equal(3, b4.nodes.size)
          assert_equal(1, b4.nodes[0].num)
          assert_equal("node", b4.nodes[0].name)
          assert_equal("1", b4.nodes[0].type)
          assert_equal(2, b4.nodes[1].num)
          assert_equal("node2", b4.nodes[1].name)
          assert_equal("b4", b4.nodes[1].type)
          assert_equal(4, b4.nodes[2].num)
          assert_equal("node", b4.nodes[2].name)
          assert_equal("four", b4.nodes[2].type)

          # config_element('description3', '', {"text" => "dddd3-1"}),
          # config_element('description3', 'd-3', {"text" => "dddd3-2"}),
          # config_element('description3', 'd-3a', {"text" => "dddd3-3"}),

          # NoMethodError: undefined method `class' for <Fluent::Config::Section {...}>:Fluent::Config::Section occurred. Should we add class method to Section?
          #assert_equal('Fluent::Config::Section', b4.description1.class.name)
          assert_equal("desc1", b4.description1.note)
          assert_equal("dddd1", b4.description1.text)

          # same with assert_equal('Fluent::Config::Section', b4.description1)
          #assert_equal('Fluent::Config::Section', b4.description2)
          assert_equal("d-2", b4.description2.note)
          assert_equal("dddd2", b4.description2.text)

          assert_instance_of(Array, b4.description3)
          assert_equal(3, b4.description3.size)
          assert_equal("desc3", b4.description3[0].note)
          assert_equal("dddd3-1", b4.description3[0].text)
          assert_equal('desc3: d-3', b4.description3[1].note)
          assert_equal('dddd3-2', b4.description3[1].text)
          assert_equal('desc3: d-3a', b4.description3[2].note)
          assert_equal('dddd3-3', b4.description3[2].text)
        end

        test 'checks missing of specifications' do
          conf0 = config_element('ROOT', '', {}, [])
          ex01 = ConfigurableSpec::Example0.new
          assert_raise(Fluent::ConfigError) { ex01.configure(conf0) }

          complete = config_element('ROOT', '', {
            "stringvalue" => "s1", "boolvalue" => "yes", "integervalue" => "10",
            "sizevalue" => "10m", "timevalue" => "100s", "floatvalue" => "1.001",
            "hashvalue" => '{"foo":1, "bar":2}',
            "arrayvalue" => '[1,"ichi"]',
          })

          checker = lambda { |conf| ConfigurableSpec::Example0.new.configure(conf) }

          assert_nothing_raised { checker.call(complete) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "stringvalue" }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "boolvalue"   }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "integervalue"}) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "sizevalue"   }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "timevalue"   }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "floatvalue"  }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "hashvalue"   }) }
          assert_raise(Fluent::ConfigError) { checker.call(complete.reject{|k,v| k == "arrayvalue"  }) }
        end

        test 'accepts configuration values as string representation' do
          conf = config_element('ROOT', '', {
            "stringvalue" => "s1", "boolvalue" => "yes", "integervalue" => "10",
            "sizevalue" => "10m", "timevalue" => "10m", "floatvalue" => "1.001",
            "hashvalue" => '{"foo":1, "bar":2}',
            "arrayvalue" => '[1,"ichi"]',
          })
          ex = ConfigurableSpec::Example0.new.configure(conf)
          assert_equal("s1", ex.stringvalue)
          assert_true(ex.boolvalue)
          assert_equal(10, ex.integervalue)
          assert_equal(10 * 1024 * 1024, ex.sizevalue)
          assert_equal(10 * 60, ex.timevalue)
          assert_equal(1.001, ex.floatvalue)
          assert_equal({"foo" => 1, "bar" => 2}, ex.hashvalue)
          assert_equal([1, "ichi"], ex.arrayvalue)
        end

        test 'accepts configuration values as ruby value representation (especially for DSL)' do
          conf = config_element('ROOT', '', {
            "stringvalue" => "s1", "boolvalue" => true, "integervalue" => 10,
            "sizevalue" => 10 * 1024 * 1024, "timevalue" => 10 * 60, "floatvalue" => 1.001,
            "hashvalue" => {"foo" => 1, "bar" => 2},
            "arrayvalue" => [1,"ichi"],
          })
          ex = ConfigurableSpec::Example0.new.configure(conf)
          assert_equal("s1", ex.stringvalue)
          assert_true(ex.boolvalue)
          assert_equal(10, ex.integervalue)
          assert_equal(10 * 1024 * 1024, ex.sizevalue)
          assert_equal(10 * 60, ex.timevalue)
          assert_equal(1.001, ex.floatvalue)
          assert_equal({"foo" => 1, "bar" => 2}, ex.hashvalue)
          assert_equal([1, "ichi"], ex.arrayvalue)
        end

        test 'gets both of true(yes) and false(no) for bool value parameter' do
          conf = config_element('ROOT', '', {
            "stringvalue" => "s1", "integervalue" => 10,
            "sizevalue" => 10 * 1024 * 1024, "timevalue" => 10 * 60, "floatvalue" => 1.001,
            "hashvalue" => {"foo" => 1, "bar" => 2},
            "arrayvalue" => [1,"ichi"],
          })
          ex0 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => "true"}))
          assert_true(ex0.boolvalue)

          ex1 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => "yes"}))
          assert_true(ex1.boolvalue)

          ex2 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => true}))
          assert_true(ex2.boolvalue)

          ex3 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => "false"}))
          assert_false(ex3.boolvalue)

          ex4 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => "no"}))
          assert_false(ex4.boolvalue)

          ex5 = ConfigurableSpec::Example0.new.configure(conf.merge({"boolvalue" => false}))
          assert_false(ex5.boolvalue)
        end
      end

      sub_test_case '.config_section' do
        CONF1 = config_element('ROOT', '', {
                                 'name' => 'tagomoris',
                                 'bool' => true,
                               })

        CONF2 = config_element('ROOT', '', {
                                 'name' => 'tagomoris',
                                 'bool' => true,
                               },
                               [config_element('detail', '', { 'phone_no' => "+81-00-0000-0000" }, [])])

        CONF3 = config_element('ROOT', '', {
                                 'name' => 'tagomoris',
                                 'bool' => true,
                               },
                               [config_element('detail', '', { 'address' => "Chiyoda Tokyo Japan" }, [])])

        CONF4 = config_element('ROOT', '', {
                                 'name' => 'tagomoris',
                                 'bool' => true,
                               },
                               [
                                 config_element('detail', '', {
                                                  'address' => "Chiyoda Tokyo Japan",
                                                  'phone_no' => '+81-00-0000-0000'
                                                },
                                                [])
                               ])

        data(conf1: CONF1,
             conf2: CONF2,
             conf3: CONF3,
             conf4: CONF4,)
        test 'base class' do |data|
          assert_nothing_raised { ConfigurableSpec::Overwrite::Base.new.configure(data) }
        end

        test 'subclass cannot overwrite required' do
          assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: required")) do
            ConfigurableSpec::Overwrite::Required.new.configure(CONF1)
          end
        end

        test 'subclass cannot overwrite multi' do
          assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: multi")) do
            ConfigurableSpec::Overwrite::Multi.new.configure(CONF1)
          end
        end

        test 'subclass cannot overwrite alias' do
          assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: alias")) do
            ConfigurableSpec::Overwrite::Alias.new.configure(CONF1)
          end
        end

        test 'subclass uses superclass default options' do
          base = ConfigurableSpec::Overwrite::Base.new.configure(CONF2)
          sub = ConfigurableSpec::Overwrite::DefaultOptions.new.configure(CONF2)
          detail_base = base.class.merged_configure_proxy.sections[:detail]
          detail_sub = sub.class.merged_configure_proxy.sections[:detail]
          detail_base_attributes = {
            requried: detail_base.required,
            multi: detail_base.multi,
            alias: detail_base.alias,
          }
          detail_sub_attributes = {
            requried: detail_sub.required,
            multi: detail_sub.multi,
            alias: detail_sub.alias,
          }
          assert_equal(detail_base_attributes, detail_sub_attributes)
        end

        test 'subclass can overwrite detail.address' do
          base = ConfigurableSpec::Overwrite::Base.new.configure(CONF2)
          target = ConfigurableSpec::Overwrite::DetailAddressDefault.new.configure(CONF2)
          expected_addresses = ["x", "y"]
          actual_addresses = [base.detail.address, target.detail.address]
          assert_equal(expected_addresses, actual_addresses)
        end

        test 'subclass can add param' do
          assert_raise(Fluent::ConfigError.new("'phone_no' parameter is required, in section detail")) do
            ConfigurableSpec::Overwrite::AddParam.new.configure(CONF3)
          end
          target = ConfigurableSpec::Overwrite::AddParam.new.configure(CONF4)
          expected = {
            address: "Chiyoda Tokyo Japan",
            phone_no: "+81-00-0000-0000"
          }
          actual = {
            address: target.detail.address,
            phone_no: target.detail.phone_no
          }
          assert_equal(expected, actual)
        end

        test 'subclass can add param with overwriting address' do
          assert_raise(Fluent::ConfigError.new("'phone_no' parameter is required, in section detail")) do
            ConfigurableSpec::Overwrite::AddParamOverwriteAddress.new.configure(CONF3)
          end
          target = ConfigurableSpec::Overwrite::AddParamOverwriteAddress.new.configure(CONF4)
          expected = {
            address: "Chiyoda Tokyo Japan",
            phone_no: "+81-00-0000-0000"
          }
          actual = {
            address: target.detail.address,
            phone_no: target.detail.phone_no
          }
          assert_equal(expected, actual)
        end

        sub_test_case 'final' do
          CONF = config_element('ROOT', '', {},
                                [config_element('appendix', '', {"phone_no" => "+81-0000-0000"}, [])])
          test 'subclass can overwrite appendix.name, appendix.age w/ level 2' do
            finalized = ConfigurableSpec::Final::Finalized.new
            finalized.configure(CONF)
            expected = { name: "y", age: 10 }
            actual = { name: finalized.appendix.name, age: finalized.appendix.age }
            assert_equal(expected, actual)
          end

          test 'subclass cannot overwrite appendix.name, appendix.age w/ level 3' do
            level3 = ConfigurableSpec::Final::InheritsFinalized.new
            level3.configure(CONF)
            expected = { name: "y", age: 10 }
            actual = { name: level3.appendix.name, age: level3.appendix.age }
            assert_equal(expected, actual)
          end

          test 'inherit finalized base' do
            target1 = ConfigurableSpec::Final::InheritsFinalized2.new
            target1.configure(CONF)
            expected = { name: "x", age: 10 }
            actual1 = { name: target1.appendix.name, age: target1.appendix.age }
            assert_equal(expected, actual1)

            target2 = ConfigurableSpec::Final::InheritsFinalized3.new
            target2.configure(CONF)
            actual2 = { name: target2.appendix.name, age: target2.appendix.age }
            assert_equal(expected, actual2)
          end

          test 'failed to overwrite finalized base' do
            assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite finalized base class's config_section")) do
              ConfigurableSpec::Final::InheritsFinalized4.new.configure(CONF)
            end
          end

          sub_test_case 'overwrite' do
            test 'required' do
              assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: required")) do
                ConfigurableSpec::Final::OverwriteRequired.new.configure(CONF)
              end
            end

            test 'multi' do
              assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: multi")) do
                ConfigurableSpec::Final::OverwriteMulti.new.configure(CONF)
              end
            end

            test 'alias' do
              assert_raise(Fluent::ConfigError.new("BUG: subclass cannot overwrite base class's config_section: alias")) do
                ConfigurableSpec::Final::OverwriteAlias.new.configure(CONF)
              end
            end
          end
        end
      end
    end

    sub_test_case 'class defined with config_param/config_section having :alias' do
      sub_test_case '#initialize' do
        test 'does not create methods for alias' do
          ex1 = ConfigurableSpec::Example1.new
          assert_nothing_raised { ex1.name }
          assert_raise(NoMethodError) { ex1.fullname }
          assert_nothing_raised { ex1.bool }
          assert_raise(NoMethodError) { ex1.flag }
          assert_nothing_raised { ex1.detail }
          assert_raise(NoMethodError) { ex1.information}
        end
      end

      sub_test_case '#configure' do
        test 'provides accessible data for alias attribute keys' do
          ex1 = ConfigurableSpec::Example1.new
          conf = config_element('ROOT', '', {
                                  "fullname" => "foo bar",
                                  "bool" => false
                                },
                                [config_element('information', '', {"address" => "Mountain View 0"})])
          ex1.configure(conf)
          assert_equal("foo bar", ex1.name)
          assert_not_nil(ex1.bool)
          assert_false(ex1.bool)
          assert_not_nil(ex1.detail)
          assert_equal("Mountain View 0", ex1.detail.address)
        end
      end
    end

    sub_test_case ':secret option' do
      setup do
        @conf = config_element('ROOT', '',
                               {
                                 'normal_param' => 'normal',
                                 'secret_param' => 'secret'
                               },
                               [config_element('section', '', {'normal_param2' => 'normal', 'secret_param2' => 'secret'} )])
        @example = ConfigurableSpec::Example5.new
        @example.configure(@conf)
      end

      test 'to_s hides secret config_param' do
        @conf.to_s.each_line { |line|
          key, value = line.strip.split(' ', 2)
          assert_secret_param(key, value)
        }
      end

      test 'config returns masked configuration' do
        conf = @example.config
        conf.each_pair { |key, value|
          assert_secret_param(key, value)
        }
        conf.elements.each { |element|
          element.each_pair { |key, value|
            assert_secret_param(key, value)
          }
        }
      end

      test 'get plugin name when found unknown section' do
        @conf = config_element('ROOT', '',
                               {
                                 'normal_param' => 'normal',
                                 'secret_param' => 'secret'
                               },
                               [config_element('unknown', '', {'normal_param2' => 'normal', 'secret_param2' => 'secret'} )])
        @example = ConfigurableSpec::Example5.new
        @example.configure(@conf)
        @conf.elements.each { |e|
          assert_equal(['ROOT', nil], e.unused_in)
        }
      end

      def assert_secret_param(key, value)
        case key
        when 'normal_param', 'normal_param2'
          assert_equal 'normal', value
        when 'secret_param', 'secret_param2'
          assert_equal 'xxxxxx', value
        end
      end
    end
  end
end
