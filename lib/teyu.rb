require "teyu/version"
require "teyu/argument"
require "teyu/initializer"

module Teyu
  def teyu_init(*params)
    argument = Teyu::Argument.new(params)
    Teyu::Initializer.new(self, argument).define
  end
end
