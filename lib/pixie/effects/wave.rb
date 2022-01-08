module Pixie
  module Effects
    class Wave < Base
      def initialize(interval: 0.075, hue: 270, sat: 100, max: 50, start: 3)
        super
        @colors = initialize_colors(hue, sat, max)
        @offset = start
      end

      def render(pixels)
        pixels[offset % pixels.count] = colors[3]
        pixels[(offset - 1) % pixels.count] = colors[2]
        pixels[(offset - 2) % pixels.count] = colors[1]
        pixels[(offset - 3) % pixels.count] = colors[0]
      end

      def update(pixels)
        self.offset = (offset + 1) % pixels.count
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
    end
  end
end
