require "teyu/fast_initializer"
require "teyu/generic_initializer"

module Teyu
  # This initializer tries the fast initializer, and then fallback to generic initializer if failed.
  class Initializer
    def initialize(klass, argument)
      @klass = klass
      @argument = argument
    end

    def define
      begin
        Teyu::FastInitializer.new(@klass, @argument).define
      rescue SyntaxError
        Teyu::GenericInitializer.new(@klass, @argument).define
      end
    end
  end
end
