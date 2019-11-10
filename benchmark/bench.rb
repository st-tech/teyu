require 'benchmark_driver'

Benchmark.driver do |x|
  x.prelude <<~RUBY
    require 'teyu'
    require 'attr_extras'
    class A
      def initialize(a:, b:, c:, d:, e: 'e')
        @a = a
        @b = b
        @c = c
        @d = d
        @e = e
      end
    end

    class B
      extend Teyu
      teyu_init :a!, :b!, :c!, :d!, e: 'e'
    end

    class C
      attr_initialize [:a, :b, :c, :d, e: 'e']
    end

    a, b, c, d = 'a', 'b', 'c', 'd'
    A.new(a: a, b: b, c: c, d: d)
    B.new(a: a, b: b, c: c, d: d)
    C.new(a: a, b: b, c: c, d: d)
  RUBY

  x.report "Normal", %{ A.new(a: a, b: b, c: c, d: d) }
  x.report "teyu", %{ B.new(a: a, b: b, c: c, d: d) }
  x.report "attr_extras", %{ C.new(a: a, b: b, c: c, d: d) }
end
