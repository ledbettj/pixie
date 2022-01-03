require 'kodachroma'
require_relative 'native'

module Pixie
  class Pixie
    # Construct a new Pixie context.
    # @example
    #   pixels = Pixie::Pixie.new(Pixie::WS2811_STRIP_RGB, 50)
    # @param type [Number] one of the Pixie::WS2811_* or Pixie::SK6812* constants
    # @param count [Number] how many LEDs are present on the strand.
    # @param opts [Hash] initialization options.
    # @option opts [Number] :frequency
    # @option opts [Number] :dma
    # @option opts [Number] :gpio
    def initialize(type, count, opts = {})
      @type   = type
      @count  = count
      @config = initialize_config(opts)

      ObjectSpace.define_finalizer(self, self.class.finalize(config))
    end

    # Set the color of an individual or range of LEDs.
    #
    # To set an individual LED, pass a single number as the index and
    # either a String, Number, or Kodachroma::Color as the value:
    # @example
    #   pixels[1] = "hsl(140, 100%, 50%)"
    # To set a range of LEDs, pass a Range as the index and either an array of or a
    # single Number, String, Kodachroma::Color. If there are not enough matching entries
    # in the given array, the colors will wrap around as needed.
    # @example
    #   pixels[0..9] = ["red", "green", "blue"]
    # @param index [Number, Range] The LED(s) to modify.
    # @param value [String, Number, Kodachroma::Color, Array] Color(s) to assign to the given LED(s)
    def []=(index, value)
      if index.is_a?(Range)
        write_leds_at(index, value)
      else
        led_at(index).write_uint32(uint_from_color(value))
      end
    end

    # Get the currently set color of a single LED or range of LEDs.
    #
    # To retrieve a single LED's color, pass a single number as the index:
    #
    # pixels[0]
    #
    # To retrieve multiple LED colors, pass a range:
    #
    # pixels[0..2]
    #
    # @param index [Number, Range]
    # @return [Kodachroma::Color, Array]
    def [](index)
      if index.is_a?(Range)
        read_leds_at(index)
      else
       uint_to_color(led_at(index).read_uint32)
      end
    end

    # Commit any changes to the LEDs.
    def render
      rc = Native.ws2811_render(config)
      raise ::Pixie::Error, rc unless rc == :success
    end

    # Turn off all LEDs.
    def clear
      ptr = config[:channel][0][:leds]
      count.times do
        ptr.write_uint32(0)
        ptr = ptr + 4
      end

      render
    end

    private

    attr_reader :config, :count, :type

    def initialize_config(opts)
      Native::Ws2811.new.tap do |c|
        c[:freq]   = opts.fetch(:frequency, Native::DEFAULT_TARGET_FREQ)
        c[:dmanum] = opts.fetch(:dma, Native::DEFAULT_DMA_CHANNEL)
        c[:channel][1] = Native::Ws2811Channel.new.clear
        c[:channel][0] = Native::Ws2811Channel.new.clear.tap do |ch|
          ch[:gpionum]    = opts.fetch(:gpio, Native::DEFAULT_GPIO_PIN)
          ch[:count]      = count
          ch[:brightness] = 255
          ch[:strip_type] = type
        end

        rc = Native.ws2811_init(c)
        raise ::Pixie::Error, rc unless rc == :success
      end
    end

    def led_at(index)
      check_bounds(index)
      config[:channel][0][:leds] + (4 * index)
    end

    def read_leds_at(range)
      check_bounds(range.first)
      check_bounds(range.last)

      range.map do |index|
        ptr = config[:channel][0][:leds] + (4 * index)
        uint_to_color(ptr.read_uint32)
      end
    end

    def write_leds_at(range, value)
      check_bounds(range.first)
      check_bounds(range.last)
      values = Array(value).map { |v| uint_from_color(v) }

      n = 0
      range.each_with_index do |index, i|
        ptr = config[:channel][0][:leds] + (4 * index)
        ptr.write_uint32(values[i % values.length])
      end
    end

    def check_bounds(index)
      raise ArgumentError, 'Index out of bounds' if index < 0 || index >= count
    end

    def uint_from_color(color)
      color = Kodachroma.paint(color) if color.is_a?(String)

      return color.to_i unless color.is_a?(Kodachroma::Color)

      rgb = color.rgb
      (rgb.r.to_i << 16 | rgb.g.to_i << 8 | rgb.b.to_i)
    end

    def uint_to_color(uint)
      Kodachroma::ColorModes::Rgb.new(
        (uint >> 16) & 0xFF,
        (uint >> 8) & 0xFF,
        (uint >> 0) & 0xFF
      )
    end

    def self.finalize(config)
      proc { Native.ws2811_fini(config) }
    end
  end
end
