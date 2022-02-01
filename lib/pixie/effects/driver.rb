module Pixie
  module Effects
    class Driver
      attr_reader :stack, :pixels

      def initialize(pixels)
        @pixels = pixels
        @stack  = []
      end

      def append(effect_klass, **kwargs)
        stack.push(effect_klass.new(**kwargs))
        self
      end

      def as_json
        { effects: stack.map(&:as_json) }
      end

      def remove(index)
        stack.delete_at(index)
      end

      def run(end_time)
        while (t = Time.now) < end_time
          stack
            .select { |effect| effect.update?(t) }
            .each   { |effect| effect.update(pixels); effect.post_update(t) }

          stack.each { |effect| effect.render(pixels) }
          pixels.render

          to_sleep = stack.map { |effect| effect.sleep_after(t) }&.min || 1.0

          sleep(to_sleep)
        end
      end
    end
  end
end
