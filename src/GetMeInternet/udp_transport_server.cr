require "./transport"
require "../address"

module GetMeInternet
  class UDPTransportServer
    include TransportServer
    include TransportSinglePacket

    def initialize(config : ConfigHash)
      @sock = UDPSocket.new
      @sock.bind "0.0.0.0", config["port"].to_u16
    end

    delegate close, to: @sock

    def recv_packets(key) : Array(Tuple(Packet,UInt64))
      # TODO: use the same buffer throughout instead of a new one
      # every time
      message, client_addr = @sock.receive
      
      pkt = EncryptedPacket.from_bytes(message)
      return [{pkt.decrypt(key), client_addr.address_as_u32.to_u64}]
    end

    def send_single_packet(pkt : EncryptedPacket,
                           route : UInt64)
      @sock.send(pkt.to_bytes, Socket::IPAddress.new(route.to_u32))
    end
  end
end
