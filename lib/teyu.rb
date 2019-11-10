require "teyu/version"
require "teyu/argument"
require "teyu/perfect_initializer"

module Teyu
  def teyu_init(*params)
    argument = Teyu::Argument.new(params)
    Teyu::PerfectInitializer.new(self, argument).define
  end
end
