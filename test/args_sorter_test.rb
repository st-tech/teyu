require_relative "test_helper"

class Teyu::ArgsSorterTest < Test::Unit::TestCase
  def setup
    @sorter = Teyu::ArgsSorter.new([:a, :b, :c!, { d: 'd' }, { e: 'e' }, :f!])
  end

  def test_required_positional_args
    assert { @sorter.required_positional_args == [:a, :b] }
  end

  def test_keyword_args
    assert { @sorter.keyword_args == [:c, :f, :d, :e] }
  end

  def test_required_keyword_args
    assert { @sorter.required_keyword_args == [:c, :f] }
  end

  def test_optional_keyword_args
    assert { @sorter.optional_keyword_args == { d: 'd', e: 'e' } }
  end
end

