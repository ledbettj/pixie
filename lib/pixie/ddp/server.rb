require "socket"

module Pixie::Ddp
  class Server
    # Senders split frames into packets of up to 1440 bytes of pixel data, but
    # nothing stops one from sending more, so read the largest possible datagram.
    MAX_PACKET = 65_535

    def initialize(host, pixie)
      host, port = host.split(":")
      port = port.to_i

      @pixie  = pixie
      @socket = UDPSocket.new
      @buffer = "\0".b * (pixie.count * 3)
      socket.bind(host, port)
    end

    def start
      loop do
        data, _from = socket.recvfrom(MAX_PACKET)
        handle(data)
      end
    end

    private

    attr_reader :pixie, :socket, :buffer

    # Copy each packet's pixel data into the frame buffer at its byte offset,
    # and show the frame once a packet arrives with the push flag set.
    def handle(data)
      header = PacketHeader.read(data)
      return if header.query.nonzero?

      write(header.data_offset, data.byteslice(header.num_bytes, header.data_length))
      render if header.push.nonzero?
    rescue IOError
      # packet too short to hold a header; ignore it
    end

    def write(offset, payload)
      return if payload.nil? || offset >= buffer.bytesize

      payload = payload.byteslice(0, buffer.bytesize - offset)
      buffer[offset, payload.bytesize] = payload
    end

    def render
      pixie[0..(pixie.count - 1)] = buffer.unpack("C*").each_slice(3).map do |r, g, b|
        (r << 16) | (g << 8) | b
      end
      pixie.render
    end
  end
end
