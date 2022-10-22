module Pixie
  module Effects
    class Wave < Base
      def initialize(color:, interval: 0.075, start: 3)
        super

        reconfigure(color:, interval:, start:)
        @colors = initialize_colors(Kodachroma.paint(color))
        @offset = start
      end

      def reconfigure(color:, **kwargs)
        @colors = initialize_colors(Kodachroma.paint(color))
        super
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

      def initialize_colors(color)
        4.times.map { |i| color.darken(i * 20)  }.reverse
      end

      attr_accessor :colors, :offset
    end
  end
end
