module Pixie
  module Effects
    class Pulse < Base
      def initialize(hue: 20, sat: 100, min: 0, max: 50, step: 2)
        super

        @color = [hue, sat, min]
        @step = step
        @min = min
        @max = max
      end

      def render(pixels)
        pixels[0..(pixels.count - 1)] = format('hsl(%d, %d%%, %d%%)', *color)
      end

      def update(pixels)
        color[2] += step
        self.step *= -1 if color[2] >= max || color[2] <= min
      end

      private

      attr_accessor :color, :step
      attr_reader :min, :max
    end
  end
end
