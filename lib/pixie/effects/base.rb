module Pixie
  module Effects
    class Base
      attr_reader :interval, :last_update, :config

      def initialize(color:, interval: 0.075, **kwargs)
        @interval    = interval
        @last_update = Time.at(0)
        @config = kwargs.merge(color: color, interval: interval)
      end

      def reconfigure(**kwargs)
        @config = kwargs
      end

      def update?(now)
        diff = now - last_update
        diff >= interval
      end

      def sleep_after(now)
        return 0 if update?(now)

        interval - (now - last_update)
      end

      def update(pixels)
      end

      def post_update(now)
        @last_update = now
      end

      def render(pixels)

      end
    end
  end
end
