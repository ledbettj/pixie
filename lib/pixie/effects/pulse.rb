module Pixie
  module Effects
    class Pulse
      def initialize(driver, hue: 20, sat: 100, min: 0, max: 50, step: 2)
        @driver = driver
        @color = [hue, sat, min]
        @step = step
        @min = min
        @max = max
      end

      def tick(_)
        driver[0..(driver.count - 1)] = format('hsl(%d, %d%%, %d%%)', *color)
        color[2] += step
        self.step *= -1 if color[2] >= max || color[2] <= min
      end

      private

      attr_accessor :color, :step
      attr_reader :driver, :min, :max
    end
  end
end
