require 'packetfu'

require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'packetizer.rb'))

include PacketFu

class Client
  def initialize(iface, tos, addr, pass, port = nil)
    @iface = iface
    @tos = tos
    @port = port
    @daddr = saddr
    @pass
    config = PacketFu::Utils.whoami?(:iface => $iface)
    tcp_pkt = TCPPacket.new(:config => config)
    tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1, :psh => 1)
    tcp_pkt.tcp_dst = @port
    tcp_pkt.tcp_src = rand(8000..65000)
    tcp_pkt.ip_saddr = "153.251.232.153"
    tcp_pkt.ip_daddr = @daddr

    cipher = Encrypter(pass)
    iv = cipher.newIv
    cipher.encrypt(iv, $ipSource)
  end



  def start
    conn = Connector.new(@iface, @tos, @daddr, @pass, "client", @port)
    Thread.new{ readPackets }
    while (1)
      str = STDIN.gets
      conn.send(str)
    end
  end

private

  def tcp
    filter = "tcp and dst port @port and src 23.253.5.96"
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
  end

  end

  def readPackets()
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
end
