module Teyu
  # This initializer supports all cases, but works slow
  class GenericInitializer
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
          # NOTE: In Ruby, objects of default arguments are newly created everytime on a method call.
          #
          #     def test(a: "a")
          #       puts a.object_id
          #     end
          #     test #=> 70273097887660
          #     test #=> 70273097887860
          #
          # In a method argument, it is possible to suppress the new object creation like:
          #
          #     $a = "a"
          #     def test(a: $a)
          #       puts a.object_id
          #     end
          #     test #=> 70273097887860
          #     test #=> 70273097887860
          #
          # But, we do not support a such feature in this gem. That's why we `dup` here.
          value = value.dup
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
end
