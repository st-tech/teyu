require_relative "test_helper"

class Teyu::ArgumentTest < Test::Unit::TestCase
  def setup
    @argument = Teyu::Argument.new([:a, :b, :c!, { d: 'd' }, { e: 'e' }, :f!])
  end

  def test_arg_names
    assert { @argument.arg_names == [:a, :b, :c, :f, :d, :e] }
  end

  def test_required_positional_args
    assert { @argument.required_positional_args == [:a, :b] }
  end

  def test_keyword_args
    assert { @argument.keyword_args == [:c, :f, :d, :e] }
  end

  def test_required_keyword_args
    assert { @argument.required_keyword_args == [:c, :f] }
  end

  def test_optional_keyword_args
    assert { @argument.optional_keyword_args == { d: 'd', e: 'e' } }
  end

  def test_validate
    assert_raises ArgumentError do
      Teyu::Argument.new([:"a); def initialize("])
    end
  end
end

