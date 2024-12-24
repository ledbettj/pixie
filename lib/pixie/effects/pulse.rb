module Pixie
  module Effects
    class Pulse < Base
      def initialize(color:, lum_min: 0, lum_max: 0.50, lum_step: 0.02)
        super

        reconfigure(color: color,
                    lum_min: lum_min,
                    lum_max: lum_max,
                    lum_step: lum_step)
      end

      def reconfigure(color:, lum_min:, lum_max:, lum_step:, **kwargs)
        @color = Kodachroma.paint(color)
        @hsl      = @color.hsl
        @lum_min  = lum_min
        @lum_max  = lum_max
        self.lum_step = lum_step

        hsl.l = hsl.l.clamp(@lum_min, @lum_max)
        self.lum_step *= -1 if hsl.l >= @lum_max
        @current_color = Kodachroma::Color.new(hsl)
        super
      end

      def render(pixels)
        pixels[0..(pixels.count - 1)] = @current_color
      end

      def update(pixels)
        hsl.l += lum_step
        @current_color = Kodachroma::Color.new(hsl)
        self.lum_step *= -1 if hsl.l >= lum_max || hsl.l <= lum_min
      end

      private

      attr_reader :lum_min, :lum_max, :hsl
      attr_accessor :lum_step
    end
  end
end
