# Raspberry Pi 5 backend: the RP1 chip isn't supported by libws2811, but the
# kernel's ws2812-pio overlay exposes the strip as a device we can write to:
#
#   dtoverlay=ws2812-pio,gpio=18,num_leds=150
#
# Reuses the emulator's in-memory LED buffer and writes it to the device on
# every render instead of printing it.
require_relative "native_emulator"

module Pixie
  module Native
    PIO_DEVICE = ENV.fetch("PIXIE_DEVICE", "/dev/leds0")

    # The driver takes one little-endian u32 per LED, bytes R, G, B, W, and
    # always sends them on the wire as G, R, B. This maps each wire position
    # (the strip type's shift for a color) to the byte the driver sends there.
    PIO_SLOT = { 16 => 1, 8 => 0, 0 => 2 }.freeze

    def self.ws2811_init(config)
      channel = config[:channel][0]
      if channel[:strip_type] & SK6812_SHIFT_WMASK != 0
        raise ArgumentError, "RGBW strips are not supported on #{PIO_DEVICE}"
      end

      @device = File.open(PIO_DEVICE, "wb")
      :success
    end

    def self.ws2811_fini(_config)
      @device&.close
      @device = nil
    end

    def self.ws2811_render(config)
      channel = config[:channel][0]
      type    = channel[:strip_type]
      shifts  = [(type >> 16) & 0xff, (type >> 8) & 0xff, type & 0xff]

      bytes = channel.leds.flat_map do |v|
        pixel = [0, 0, 0, 0]
        [(v >> 16) & 0xff, (v >> 8) & 0xff, v & 0xff].zip(shifts) do |color, shift|
          pixel[PIO_SLOT.fetch(shift)] = color
        end
        pixel
      end

      @device.pwrite(bytes.pack("C*"), 0)
      :success
    end
  end
end
