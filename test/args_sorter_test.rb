require_relative "test_helper"

class Teyu::ArgsSorterTest < Test::Unit::TestCase
  def setup
    @sorter = Teyu::ArgsSorter.new([:a, :b, :c!, { d: 'd' }, { e: 'e' }, :f!])
  end

  def test_req_args
    assert { @sorter.req_args == [:a, :b] }
  end

  def test_keyword_args
    assert { @sorter.keyword_args == [:c, :f, :d, :e] }
  end

  def test_keyreq_args
    assert { @sorter.keyreq_args == [:c, :f] }
  end

  def test_key_args
    assert { @sorter.key_args == { d: 'd', e: 'e' } }
  end
end

