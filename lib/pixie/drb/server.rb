module Pixie::Drb
  class Server

    attr_reader :uri, :pixie
    def initialize(uri = 'druby://0.0.0.0:8787', pixie)
      @pixie = pixie
      @uri   = uri
    end

    def start
      DRb.start_service(uri, pixie)
      DRb.thread.join
    end
  end
end
