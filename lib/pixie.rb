# frozen_string_literal: true
module Pixie
  # 4 color R, G, B and W ordering
  SK6812_STRIP_RGBW = 0x18100800
  SK6812_STRIP_RBGW = 0x18100008
  SK6812_STRIP_GRBW = 0x18081000
  SK6812_STRIP_GBRW = 0x18080010
  SK6812_STRIP_BRGW = 0x18001008
  SK6812_STRIP_BGRW = 0x18000810
  SK6812_SHIFT_WMASK = 0xf0000000

  # 3 color R, G and B ordering
  WS2811_STRIP_RGB = 0x00100800
  WS2811_STRIP_RBG = 0x00100008
  WS2811_STRIP_GRB = 0x00081000
  WS2811_STRIP_GBR = 0x00080010
  WS2811_STRIP_BRG = 0x00001008
  WS2811_STRIP_BGR = 0x00000810

  # predefined fixed LED types
  WS2812_STRIP  = WS2811_STRIP_GRB
  SK6812_STRIP  = WS2811_STRIP_GRB
  SK6812W_STRIP = SK6812_STRIP_GRBW

  class Error < StandardError
    attr_reader :code, :message

    def initialize(code)
      @code    = code
      @message = Native.ws2811_get_return_t_str(code)
    end
  end
end

require_relative 'pixie/version'
require_relative 'pixie/pixie'
require_relative 'pixie/effects'
require_relative 'pixie/drb'
