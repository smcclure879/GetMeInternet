describe GetMeInternet::EncryptedPacket do
  it "survives transport" do
    pkt = GetMeInternet::Packet.new(
      GetMeInternet::Packet::PacketType::Ping,
      12345u64,
      Bytes[72, 101, 108, 108, 111]
    )
    enc_pkt = GetMeInternet::EncryptedPacket.encrypt(pkt, Sodium::SecretBox.secure_random_key)
    io = IO::Memory.new
    enc_pkt.to_io(io)
    io.rewind
    GetMeInternet::EncryptedPacket.from_io(io).should eq enc_pkt
  end

  it "encrypts and decrypts multiple packets" do
    arr = [
      GetMeInternet::Packet.new(
        GetMeInternet::Packet::PacketType::Ping,
        12345u64,
        Bytes[72, 101, 108, 108, 111]
      ),
      GetMeInternet::Packet.new(
        GetMeInternet::Packet::PacketType::Normal,
        54321u64,
        Bytes[72, 101, 108, 108, 111]
      )
    ]
    key = Sodium::SecretBox.secure_random_key
    enc_pkt = GetMeInternet::EncryptedPacket.encrypt(arr, key)
    enc_pkt.decrypt(key).should eq arr
  end
end
