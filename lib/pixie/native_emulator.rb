require "paint"

module Pixie
  module Native
    DEFAULT_TARGET_FREQ = -1
    DEFAULT_DMA_CHANNEL = -1
    DEFAULT_GPIO_PIN = -1

    def self.ws2811_init(_config)
      :success
    end

    def self.ws2811_fini(config); end

    def self.ws2811_get_return_t_str(rc)
      "Oops: #{rc}"
    end

    def self.ws2811_render(config)
      s = config[:channel][0].leds.map do |v|
        Paint["#", "##{v.to_s(16).rjust(6, "0")}"]
      end.join("")
      print "\r#{s}"
      sleep(0.01)
      :success
    end

    class FakePointer
      attr_reader :memory, :index

      def initialize(memory, index: 0)
        @index = index
        @memory = memory
      end

      def write_uint32(value)
        memory[index] = value
      end

      def read_uint32
        memory[index]
      end

      def +(other)
        FakePointer.new(memory, index: index + other / 4)
      end
    end

    class Ws2811Channel
      attr_reader :data, :leds

      def initialize
        @data = { leds: nil }
        @leds = []
      end

      def clear
        self
      end

      def [](key)
        data[key]
      end

      def []=(key, value)
        if key == :count
          @leds = [0] * value
          self[:leds] = FakePointer.new(leds)
        end
        data[key] = value
      end
    end

    class Ws2811
      attr_reader :data

      def initialize
        @data = { channel: [Ws2811Channel.new, Ws2811Channel.new] }
      end

      def [](key)
        data[key]
      end

      def []=(key, value)
        data[key] = value
      end
    end
  end
end
