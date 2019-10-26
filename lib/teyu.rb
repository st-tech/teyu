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
      sorter = Teyu::ArgsSorter.new(@arg_names)
      # NOTE: accessing local vars is faster than method calls, so cache to local vars
      required_positional_args = sorter.required_positional_args
      required_keyword_args = sorter.required_keyword_args
      optional_keyword_args = sorter.optional_keyword_args
      keyword_args = sorter.keyword_args

      validate_number_of_required_positional_args = method(:validate_number_of_required_positional_args)
      validate_required_keyword_args = method(:validate_required_keyword_args)
      validate_keyword_args = method(:validate_keyword_args)

      @klass.send(:define_method, :initialize) do |*arg_values|
        if arg_values.last.is_a?(Hash)
          positional_arg_values = arg_values[0...-1]
          keyword_arg_values = arg_values.last
        else
          positional_arg_values = arg_values
          keyword_arg_values = {}
        end

        validate_number_of_required_positional_args.call(required_positional_args, positional_arg_values)
        validate_required_keyword_args.call(required_keyword_args, keyword_arg_values)
        validate_keyword_args.call(keyword_args, keyword_arg_values)

        required_positional_args.zip(arg_values).each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        optional_keyword_args.each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        keyword_arg_values.each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end
      end
    end

    private

    def validate_number_of_required_positional_args(required_positional_args, positional_arg_values)
      if required_positional_args.count != positional_arg_values.count
        raise ArgumentError, "wrong number of arguments (given #{positional_arg_values.count}, expected #{required_positional_args.count})"
      end
    end

    def validate_required_keyword_args(required_keyword_args, keyword_arg_values)
      missing_keywords = required_keyword_args - keyword_arg_values.keys
      raise ArgumentError, "missing keywords: #{missing_keywords.join(', ')}" unless missing_keywords.empty?
    end

    def validate_keyword_args(keyword_args, keyword_arg_values)
      unknown_keywords = keyword_arg_values.keys - keyword_args
      raise ArgumentError, "unknown keywords: #{unknown_keywords.join(', ')}" unless unknown_keywords.empty?
    end
  end

  class ArgsSorter
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
