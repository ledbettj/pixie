module Pixie
  module Effects
    class Wave
      def initialize(driver, hue: 270, sat: 100, max: 50, start: 3)
        @driver = driver
        @colors = initialize_colors(hue, sat, max)
        @offset = start
      end

      def tick(_)
        driver[offset % driver.count] = colors[3]
        driver[(offset - 1) % driver.count] = colors[2]
        driver[(offset - 2) % driver.count] = colors[1]
        driver[(offset - 3) % driver.count] = colors[0]
        self.offset = (offset + 1) % driver.count
      end

      private

      def initialize_colors(hue, sat, max)
        [
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(hue, sat, max / 8)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(hue, sat, max / 4)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(hue, sat, max / 2)),
          Kodachroma::Color.new(Kodachroma::ColorModes::Hsl.new(hue, sat, max)),
        ]
      end

      attr_accessor :colors, :offset
      attr_reader :driver
    end
  end
end
