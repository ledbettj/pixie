module Pixie::Drb
  class Client
    attr_reader :uri, :pixie

    def initialize(uri)
      DRb.start_service
      @uri = uri
      @pixie = DRbObject.new_with_uri(uri)
    end
  end
end
