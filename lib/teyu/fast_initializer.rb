module Teyu
  # This initializer works fast, but has a limitation that it does not work under some circumstances.
  class FastInitializer
    def initialize(klass, argument)
      @klass = klass
      @argument = argument
    end

    def define
      @klass.class_eval(def_initialize, __FILE__, __LINE__)
    end

    private def def_initialize
      <<~EOS
      def initialize(#{def_initialize_args})
        #{def_initialize_body}
      end
      EOS
    end

    private def def_initialize_args
      args = []
      args << "#{@argument.required_positional_args.map(&:to_s).join(', ')}"
      args << "#{@argument.required_keyword_args.map { |arg| "#{arg}:" }.join(', ')}"
      # LIMITATION:
      # supports only default values which can be stringified such as `1`, `"a"`, `[1]`, `{a: 1}`.
      # Note that the default value objects are newly created everytime on a method call.
      args << "#{@argument.optional_keyword_args.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}"
      args.reject { |arg| arg.empty? }.join(', ')
    end

    private def def_initialize_body
      @argument.arg_names.map { |name| "@#{name} = #{name}" }.join("\n  ")
    end
  end
end
