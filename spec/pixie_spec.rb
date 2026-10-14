# frozen_string_literal: true

RSpec.describe Pixie do
  it "has a version number" do
    expect(Pixie::VERSION).not_to be nil
  end

  describe Pixie::Pixie do
    subject(:pixels) { described_class.new(Pixie::WS2811_STRIP_RGB, 5) }

    def hexes(colors)
      colors.map(&:to_hex)
    end

    it "accepts inclusive ranges" do
      pixels[0..4] = "red"
      expect(hexes(pixels[0..4])).to all(eq("#ff0000"))
    end

    it "accepts exclusive ranges up to the strand length" do
      pixels[0...5] = %w[red blue]
      expect(hexes(pixels[0...5])).to eq(%w[#ff0000 #0000ff #ff0000 #0000ff #ff0000])
    end

    it "accepts endless and beginless ranges" do
      pixels[2..] = "blue"
      pixels[..1] = "red"
      expect(hexes(pixels[nil..])).to eq(%w[#ff0000 #ff0000 #0000ff #0000ff #0000ff])
    end

    it "treats empty ranges as a no-op" do
      expect(pixels[3...3]).to eq([])
    end

    it "raises when a range runs past the strand" do
      expect { pixels[0..5] = "red" }.to raise_error(ArgumentError)
      expect { pixels[0...6] }.to raise_error(ArgumentError)
    end
  end
end
