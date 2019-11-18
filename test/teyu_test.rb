require_relative "test_helper"

class TeyuTest < Test::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Teyu::VERSION
  end
end
