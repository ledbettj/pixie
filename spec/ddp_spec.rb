# frozen_string_literal: true

require "socket"

RSpec.describe Pixie::Ddp::Server do
  # Records frames instead of driving LEDs.
  class FakePixie
    attr_reader :count, :frames

    def initialize(count)
      @count  = count
      @frames = []
      @pending = nil
    end

    def []=(_range, colors)
      @pending = colors
    end

    def render
      @frames << @pending
    end
  end

  RED   = 0xff0000
  GREEN = 0x00ff00
  BLUE  = 0x0000ff

  let(:pixie)  { FakePixie.new(4) }
  let(:server) { described_class.new("127.0.0.1:0", pixie) }

  def packet(pixels, offset: 0, push: true, query: false)
    data = pixels.pack("C*")
    flags = 0x40 | (push ? 0x01 : 0) | (query ? 0x02 : 0)
    [flags, 1, 0x0B, 1, offset, data.bytesize].pack("C4Nn") + data
  end

  def receive(data)
    server.send(:handle, data)
  end

  it "renders a frame sent in one packet" do
    receive(packet([255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 0, 0]))
    expect(pixie.frames).to eq([[RED, GREEN, BLUE, RED]])
  end

  it "waits for the push flag before rendering a split frame" do
    receive(packet([255, 0, 0, 0, 255, 0], push: false))
    expect(pixie.frames).to be_empty

    receive(packet([0, 0, 255, 255, 0, 0], offset: 6))
    expect(pixie.frames).to eq([[RED, GREEN, BLUE, RED]])
  end

  it "handles offsets that don't land on a pixel boundary" do
    receive(packet([255, 0], push: false))
    receive(packet([0, 0, 255, 0], offset: 2))
    expect(pixie.frames.last.first(2)).to eq([RED, GREEN])
  end

  it "drops pixel data past the end of the strand" do
    receive(packet([0, 0, 255] * 10))
    expect(pixie.frames).to eq([[BLUE] * 4])
  end

  it "ignores query packets and packets too short for a header" do
    receive(packet([255, 0, 0], query: true))
    receive("\x41\x01".b)
    expect(pixie.frames).to be_empty
  end

  it "receives frames over UDP" do
    port   = server.send(:socket).addr[1]
    thread = Thread.new { server.start }

    UDPSocket.new.send(packet([0, 255, 0] * 4), 0, "127.0.0.1", port)
    50.times { break if pixie.frames.any?; sleep 0.01 }

    expect(pixie.frames).to eq([[GREEN] * 4])
  ensure
    thread&.kill
  end
end
