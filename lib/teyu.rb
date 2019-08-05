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

      validate_number_of_req_args = method(:validate_number_of_req_args)
      validate_keyreq_args = method(:validate_keyreq_args)

      @klass.send(:define_method, :initialize) do |*arg_values|
        validate_number_of_req_args.call(sorter.req_args, arg_values)
        validate_keyreq_args.call(sorter.keyreq_args, arg_values)

        sorter.req_args.zip(arg_values).each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        sorter.key_args.each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end

        keyword_arg_values = arg_values[sorter.req_args.length..].find { |value| value.is_a?(Hash) } || {}
        (sorter.keyword_args & keyword_arg_values.keys).each do |name|
          instance_variable_set(:"@#{name}", keyword_arg_values[name])
        end
      end
    end

    private

    def validate_number_of_req_args(arg_names, arg_values)
      req_arg_names_count = arg_names.count
      req_arg_values_count = arg_values.filter { |value| !value.is_a?(Hash) }.count

      raise ArgumentError, "wrong number of arguments (given #{req_arg_values_count}, expected #{req_arg_names_count})" if req_arg_names_count != req_arg_values_count
    end

    def validate_keyreq_args(arg_names, arg_values)
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
    # @return [Array<Symbol>] req arg names
    def req_args
      @req_args ||= @names.take_while { |arg| !arg.is_a?(Hash) && !arg.to_s.end_with?(REQUIRED_SYMBOL) }
    end

    # method(a!:, b: 'b') => [:a, :b]
    # @return [Array<Symbol>] keyword arg names
    def keyword_args
      @keyword_args ||= keyreq_args + key_args.keys
    end

    # method(a!:, b!:) => [:a, :b]
    # @return [Array<Symbol>] keyreq arg names
    def keyreq_args
      @keyreq_args ||= @names.map(&:to_s).filter { |arg| arg.end_with?(REQUIRED_SYMBOL) }
                         .map { |arg| arg.delete_suffix(REQUIRED_SYMBOL).to_sym }
    end

    # method(a: 'a', b: 'b') => { a: 'a', b: 'b' }
    # @return [Hash] keyword args with default value
    def key_args
      @key_args ||= @names.filter { |arg| arg.is_a?(Hash) }&.inject(:merge) || {}
    end
  end
end
