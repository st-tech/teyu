require_relative "test_helper"

class TeyuTest < Test::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Teyu::VERSION
  end

  def test_assign_required_positional_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar
    end

    example = klass.new('Foo', 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_lack_of_required_positional_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_required_keyword_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar!
    end

    example = klass.new('Foo', bar: 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_lack_of_required_keyword_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar!
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_optional_keyword_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_overwrites_optional_keyword_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo', bar: 'BAR')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'BAR' }
  end

  def test_mixed_required_and_optional_keyword_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar, :hoge!, { fuga: 'Fuga' }, { piyo: 'Piyo' }
    end

    example = klass.new('Foo', 'Bar', hoge: 'Hoge', piyo: 'PIYO')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
    assert { example.instance_variable_get('@hoge') == 'Hoge' }
    assert { example.instance_variable_get('@fuga') == 'Fuga' }
    assert { example.instance_variable_get('@piyo') == 'PIYO' }
  end
end

