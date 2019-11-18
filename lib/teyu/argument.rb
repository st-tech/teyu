module Teyu
  class Argument
    REQUIRED_SYMBOL = '!'.freeze
    VARIABLE_NAME_REGEXP = /\A[a-z_][a-z0-9_]*\z/

    def initialize(params)
      @params = params
      validate
    end

    private def validate
      invalid_variable_names = arg_names.reject { |name| VARIABLE_NAME_REGEXP.match?(name) }
      unless invalid_variable_names.empty?
        raise ArgumentError, "invalid variable names: #{invalid_variable_names.join(', ')}"
      end
    end

    # @return [Array<Symbol>] names of arguments
    def arg_names
      @arg_names ||= required_positional_args + required_keyword_args + optional_keyword_args.keys
    end

    # method(a, b) => [:a, :b]
    # @return [Array<Symbol>] names of required positional arguments
    def required_positional_args
      @required_positional_args ||= @params.take_while { |arg| !arg.is_a?(Hash) && !arg.to_s.end_with?(REQUIRED_SYMBOL) }
    end

    # method(a!:, b: 'b') => [:a, :b]
    # @return [Array<Symbol>] names of keyword arguments
    def keyword_args
      @keyword_args ||= required_keyword_args + optional_keyword_args.keys
    end

    # method(a!:, b!:) => [:a, :b]
    # @return [Array<Symbol>] names of required keyword arguments
    def required_keyword_args
      @required_keyword_args ||= @params.map(&:to_s).select { |arg| arg.end_with?(REQUIRED_SYMBOL) }
        .map { |arg| arg.delete_suffix(REQUIRED_SYMBOL).to_sym }
    end

    # method(a: 'a', b: 'b') => { a: 'a', b: 'b' }
    # @return [Hash] optional keyword arguments with their default values
    def optional_keyword_args
      @optional_keyword_args ||= @params.select { |arg| arg.is_a?(Hash) }&.inject(:merge) || {}
    end
  end
end
