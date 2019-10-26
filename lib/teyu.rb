require "teyu/version"

module Teyu
  class Error < StandardError; end

  def teyu_init(*arg_names)
    define_initializer = DefineInitializer.new(self, arg_names)
    define_initializer.apply
  end

  class DefineInitializer
    def initialize(klass, arg_names)
      @klass = klass
      @arg_names = arg_names
    end

    def apply
      argument = Teyu::Argument.new(@arg_names)
      # NOTE: accessing local vars is faster than method calls, so cache to local vars
      required_positional_args = argument.required_positional_args
      required_keyword_args = argument.required_keyword_args
      optional_keyword_args = argument.optional_keyword_args
      keyword_args = argument.keyword_args

      @klass.send(:define_method, :initialize) do |*arg_values|
        if arg_values.last.is_a?(Hash)
          positional_arg_values = arg_values[0...-1]
          keyword_arg_values = arg_values.last
        else
          positional_arg_values = arg_values
          keyword_arg_values = {}
        end
        keyword_arg_values_keys = keyword_arg_values.keys

        if required_positional_args.count != positional_arg_values.count
          raise ArgumentError, "wrong number of arguments (given #{positional_arg_values.count}, expected #{required_positional_args.count})"
        end
        missing_keywords = required_keyword_args - keyword_arg_values_keys
        raise ArgumentError, "missing keywords: #{missing_keywords.join(', ')}" unless missing_keywords.empty?
        unknown_keywords = keyword_arg_values_keys - keyword_args
        raise ArgumentError, "unknown keywords: #{unknown_keywords.join(', ')}" unless unknown_keywords.empty?

        # NOTE: `while` is faster than `each` because it does not create a so-called "environment"
        i = 0
        while i < required_positional_args.size
          name = required_positional_args[i]
          value = positional_arg_values[i]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end

        default_keyword_args_keys = optional_keyword_args.keys - keyword_arg_values_keys
        i = 0
        while i < default_keyword_args_keys.size
          name = default_keyword_args_keys[i]
          value = optional_keyword_args[name]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end

        i = 0
        while i < keyword_arg_values_keys.size
          name = keyword_arg_values_keys[i]
          value = keyword_arg_values[name]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end
      end
    end
  end

  class Argument
    REQUIRED_SYMBOL = '!'.freeze

    def initialize(names)
      @names = names
    end

    # method(a, b) => [:a, :b]
    # @return [Array<Symbol>] names of required positional arguments
    def required_positional_args
      @required_positional_args ||= @names.take_while { |arg| !arg.is_a?(Hash) && !arg.to_s.end_with?(REQUIRED_SYMBOL) }
    end

    # method(a!:, b: 'b') => [:a, :b]
    # @return [Array<Symbol>] names of keyword arguments
    def keyword_args
      @keyword_args ||= required_keyword_args + optional_keyword_args.keys
    end

    # method(a!:, b!:) => [:a, :b]
    # @return [Array<Symbol>] names of required keyword arguments
    def required_keyword_args
      @required_keyword_args ||= @names.map(&:to_s).filter { |arg| arg.end_with?(REQUIRED_SYMBOL) }
                         .map { |arg| arg.delete_suffix(REQUIRED_SYMBOL).to_sym }
    end

    # method(a: 'a', b: 'b') => { a: 'a', b: 'b' }
    # @return [Hash] optional keyword arguments with their default values
    def optional_keyword_args
      @optional_keyword_args ||= @names.filter { |arg| arg.is_a?(Hash) }&.inject(:merge) || {}
    end
  end
end
