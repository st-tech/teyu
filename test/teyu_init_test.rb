require_relative "test_helper"
require 'ostruct'

class TeyuInitTest < Test::Unit::TestCase
  module GenericTeyu
    def teyu_init(*params)
      argument = Teyu::Argument.new(params)
      Teyu::GenericInitializer.new(self, argument).define
    end
  end

  data(:module, [GenericTeyu, Teyu], keep: true)
  def test_assign_positional_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar
    end

    example = klass.new('Foo', 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_lack_of_positional_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_unnecessary_positional_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar
    end

    assert_raises ArgumentError do
      klass.new('Foo', 'Bar', 'Baz')
    end
  end

  def test_required_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar!
    end

    example = klass.new('Foo', bar: 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_missing_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar!
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_unknown_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar!
    end

    assert_raises ArgumentError do
      klass.new('Foo', bar: 'Bar', baz: 'Baz')
    end
  end

  def test_optional_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_overwrites_optional_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo', bar: 'BAR')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'BAR' }
  end

  def test_mixed_required_and_optional_keyword_args(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, :bar, :hoge!, { fuga: 'Fuga' }, { piyo: 'Piyo' }
    end

    example = klass.new('Foo', 'Bar', hoge: 'Hoge', piyo: 'PIYO')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
    assert { example.instance_variable_get('@hoge') == 'Hoge' }
    assert { example.instance_variable_get('@fuga') == 'Fuga' }
    assert { example.instance_variable_get('@piyo') == 'PIYO' }
  end

  def test_optional_keyword_args_with_various_types(data)
    klass = Class.new do
      extend data[:module]
      teyu_init str: 'str', int: 1, arr: [1, '1'], hash: {key: 1}
    end

    example = klass.new
    assert { example.instance_variable_get('@str') == 'str' }
    assert { example.instance_variable_get('@int') == 1 }
    assert { example.instance_variable_get('@arr') == [1, '1'] }
    assert { example.instance_variable_get('@hash') == {key: 1} }
  end

  def test_optional_keyword_args_with_objects(data)
    obj = OpenStruct.new(k: "v")
    klass = Class.new do
      extend data[:module]
      teyu_init a: obj
    end

    example = klass.new()
    assert { example.instance_variable_get('@a') == obj }
  end

  def test_optional_keyword_args_that_values_are_newly_created(data)
    klass = Class.new do
      extend data[:module]
      teyu_init :foo, bar: 'Bar'
    end

    bar1 = klass.new('Foo').instance_variable_get('@bar')
    bar2 = klass.new('Foo').instance_variable_get('@bar')
    assert { bar1.object_id != bar2.object_id }
  end

  def test_define_invalid_names(data)
    assert_raises ArgumentError do
      Class.new do
        extend data[:module]
        teyu_init :"a); File.read('/etc/password'); def initialize("
      end
    end
  end
end
