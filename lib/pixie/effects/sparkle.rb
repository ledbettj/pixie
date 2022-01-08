module Pixie
  module Effects
    class Sparkle < Base
      def initialize(interval: 0.075, count: 4)
        super

        @count = count
      end

      def render(pixels)
        indexes.each do |index|
          color = pixels[index]
          pixels[index] = color.lighten(35).desaturate(15)
        end
      end

      def update(pixels)
        @indexes = update_indexes(pixels)
      end

      private

      def update_indexes(pixels)
        count.times.map { Random.rand(0..(pixels.count - 1)) }
      end

      attr_reader :indexes
      attr_accessor :count
    end
  end
end
