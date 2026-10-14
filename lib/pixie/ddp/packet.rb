require "bindata"

module Pixie::Ddp
  class PacketHeader < BinData::Record
    bit2 :protocol_version
    bit1 :_reserved_1
    bit1 :timecode
    bit1 :storage
    bit1 :reply
    bit1 :query
    bit1 :push

    bit4 :_reserved_2
    bit4 :sequence

    bit1 :custom
    bit1 :_reserved_3
    bit3 :data_type
    bit3 :bits_per_pixel

    uint8 :src_dest_id
    uint32be :data_offset
    uint16be :data_length

    uint32be :timestamp, onlyif: :timecode_present?

    def timecode_present? = timecode.nonzero?
  end
end
