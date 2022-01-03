module Pixie
  module Effects
    class Sparkle
      def initialize(driver, count: 4)
        @driver = driver
        @count = count
      end

      def tick(n)
        return if n.odd?

        count.times do
          index = Random.rand(0..(driver.count - 1))
          color = driver[index]
          driver[index] = color.lighten(15).desaturate(15)
        end
      end

      private

      def initialize_colors
        [
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(270, 100, 6)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(270, 100, 12)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(270, 100, 25)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(270, 100, 50)),
        ]
      end

      attr_accessor :count
      attr_reader :driver
    end
  end
end
