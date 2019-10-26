require "teyu/version"

module Teyu
  class Error < StandardError; end

  def teyu_init(*params)
    argument = Teyu::Argument.new(params)
    # FastInitializer works faster than GenericInitializer, but does not work with some case.
    begin
      Teyu::FastInitializer.new(self, argument).define
    rescue SyntaxError
      Teyu::GenericInitializer.new(self, argument).define
    end
  end

  class FastInitializer
    # @param [Class] klass
    # @param [Teyu::Argument] argument
    def initialize(klass, argument)
      @klass = klass
      @argument = argument
    end

    def define
      @klass.class_eval(def_initialize, __FILE__, __LINE__)
    end

    private

    def def_initialize
      <<~EOS
      def initialize(#{def_initialize_args})
        #{def_initialize_body}
      end
      EOS
    end

    def def_initialize_args
      args = []
      args << "#{@argument.required_positional_args.map(&:to_s).join(', ')}"
      args << "#{@argument.required_keyword_args.map { |arg| "#{arg}:" }.join(', ')}"
      # LIMITATION: supports only default arguments which can be stringified.
      args << "#{@argument.optional_keyword_args.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}"
      args.reject! { |arg| arg.empty? }
      args.join(', ')
    end

    def def_initialize_body
      @argument.arg_names.map { |name| "@#{name} = #{name}" }.join("\n  ")
    end
  end

  class GenericInitializer
    # @param [Class] klass
    # @param [Teyu::Argument] argument
    def initialize(klass, argument)
      @klass = klass
      @argument = argument
    end

    def define
      # NOTE: accessing local vars is faster than method calls, so cache to local vars
      required_positional_args = @argument.required_positional_args
      required_keyword_args = @argument.required_keyword_args
      optional_keyword_args = @argument.optional_keyword_args
      keyword_args = @argument.keyword_args

      @klass.define_method(:initialize) do |*given_args|
        if given_args.last.is_a?(Hash)
          given_positional_args = given_args[0...-1]
          given_keyword_args = given_args.last
        else
          given_positional_args = given_args
          given_keyword_args = {}
        end
        given_keyword_args_keys = given_keyword_args.keys

        if required_positional_args.size != given_positional_args.size
          raise ArgumentError, "wrong number of arguments (given #{given_positional_args.size}, expected #{required_positional_args.size})"
        end
        missing_keywords = required_keyword_args - given_keyword_args_keys
        raise ArgumentError, "missing keywords: #{missing_keywords.join(', ')}" unless missing_keywords.empty?
        unknown_keywords = given_keyword_args_keys - keyword_args
        raise ArgumentError, "unknown keywords: #{unknown_keywords.join(', ')}" unless unknown_keywords.empty?

        # NOTE: `while` is faster than `each` because it does not create a so-called "environment"
        i = 0
        while i < required_positional_args.size
          name = required_positional_args[i]
          value = given_positional_args[i]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end

        default_keyword_args_keys = optional_keyword_args.keys - given_keyword_args_keys
        i = 0
        while i < default_keyword_args_keys.size
          name = default_keyword_args_keys[i]
          value = optional_keyword_args[name]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end

        i = 0
        while i < given_keyword_args_keys.size
          name = given_keyword_args_keys[i]
          value = given_keyword_args[name]
          instance_variable_set(:"@#{name}", value)
          i += 1
        end
      end
    end
  end

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
