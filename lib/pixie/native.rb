module Pixie
  module Native
    require 'ffi'
    extend FFI::Library
    ffi_lib 'libws2811'

    RPI_PWM_CHANNELS = 2

    DEFAULT_TARGET_FREQ = 800_000
    DEFAULT_GPIO_PIN    = 18
    DEFAULT_DMA_CHANNEL = 10
    DEFAULT_STRIP_TYPE  = Pixie::WS2812_STRIP

    class Ws2811Channel < FFI::Struct
      layout :gpionum,    :int,
             :invert,     :int,
             :count,      :int,
             :strip_type, :int,
             :leds,       :pointer,
             :brightness, :uint8,
             :wshift,     :uint8,
             :rshift,     :uint8,
             :gshift,     :uint8,
             :bshift,     :uint8,
             :gamma,      :pointer
    end

    class Ws2811 < FFI::Struct
      layout :render_wait_time, :uint64,
             :ws2811_device,    :pointer,
             :rpi_hw,           :pointer,
             :freq,             :uint32,
             :dmanum,           :int,
             :channel,          [Ws2811Channel, RPI_PWM_CHANNELS]
    end

    enum :ws2811_return_t, [
      :success,               0,
      :err_generic,          -1,
      :err_out_of_memory,    -2,
      :err_hw_not_supported, -3,
      :err_mem_lock,         -4,
      :err_mmap,             -5,
      :err_map_registers,    -6,
      :err_gpio_init,        -7,
      :err_pwm_setup,        -8,
      :err_mailbox_dev,      -9,
      :err_dma,              -10,
      :err_illegal_gpio,     -11,
      :err_pcm_setup,        -12,
      :err_spi_setup,        -13,
      :err_spi_transfer,     -14
    ]

    attach_function :ws2811_init,   [Ws2811.by_ref], :ws2811_return_t
    attach_function :ws2811_fini,   [Ws2811.by_ref], :void
    attach_function :ws2811_render, [Ws2811.by_ref], :ws2811_return_t
    attach_function :ws2811_wait,   [Ws2811.by_ref], :ws2811_return_t

    attach_function :ws2811_get_return_t_str, [:ws2811_return_t], :string
    attach_function :ws2811_set_custom_gamma_factor, [Ws2811.by_ref, :double], :void
  end
end
