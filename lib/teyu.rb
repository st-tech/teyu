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

      validate_number_of_required_positional_args = method(:validate_number_of_required_positional_args)
      validate_required_keyword_args = method(:validate_required_keyword_args)

      @klass.send(:define_method, :initialize) do |*arg_values|
        validate_number_of_required_positional_args.call(sorter.required_positional_args, arg_values)
        validate_required_keyword_args.call(sorter.required_keyword_args, arg_values)

        sorter.required_positional_args.zip(arg_values).each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        sorter.optional_keyword_args.each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        keyword_arg_values = arg_values[sorter.required_positional_args.length..].find { |value| value.is_a?(Hash) } || {}
        (sorter.keyword_args & keyword_arg_values.keys).each do |name|
          instance_variable_set(:"@#{name}", keyword_arg_values[name])
        end
      end
    end

    private

    def validate_number_of_required_positional_args(arg_names, arg_values)
      req_arg_names_count = arg_names.count
      req_arg_values_count = arg_values.filter { |value| !value.is_a?(Hash) }.count

      raise ArgumentError, "wrong number of arguments (given #{req_arg_values_count}, expected #{req_arg_names_count})" if req_arg_names_count != req_arg_values_count
    end

    def validate_required_keyword_args(arg_names, arg_values)
      arg_names.each do |name|
        keyword_arg_keys = arg_values.find { |value| value.is_a?(Hash) }&.keys || []
        raise ArgumentError, "(missing keyword: #{name})" unless keyword_arg_keys.include?(name)
      end
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
