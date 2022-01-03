module Pixie
  module Effects
    class Driver
      attr_reader :stack, :delay, :pixels

      def initialize(pixels, delay: 0.075)
        @pixels = pixels
        @delay  = delay
        @stack  = []
      end

      def append(effect_klass, **kwargs)
        stack.push(effect_klass.new(pixels, **kwargs))
        self
      end

      def run(iterations = 100)
        iterations.times do |i|
          stack.each{ |s| s.tick(i) }
          pixels.render
          sleep(delay)
        end
      end
    end
  end
end
