require_relative "test_helper"

class TeyuTest < Test::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Teyu::VERSION
  end

  # FYI: name of args type are referenced Method#parameters docs.
  # https://docs.ruby-lang.org/ja/latest/method/Method/i/parameters.html
  def test_assign_req_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar
    end

    example = klass.new('Foo', 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_lack_of_req_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_keyreq_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar!
    end

    example = klass.new('Foo', bar: 'Bar')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_lack_of_keyreq_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, :bar!
    end

    assert_raises ArgumentError do
      klass.new('Foo')
    end
  end

  def test_key_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'Bar' }
  end

  def test_overwrites_key_args
    klass = Class.new do
      extend Teyu
      teyu_init :foo, bar: 'Bar'
    end

    example = klass.new('Foo', bar: 'BAR')
    assert { example.instance_variable_get('@foo') == 'Foo' }
    assert { example.instance_variable_get('@bar') == 'BAR' }
  end

  def test_mixed_keyreq_and_key_args
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

