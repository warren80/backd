require 'packetfu'

require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'packetizer.rb'))

include PacketFu

class Client
  def initialize(iface, tos, addr, pass, port = nil)
    @iface = iface
    @tos = tos
    @port = port
    @daddr = addr
    @pass = pass
    config = PacketFu::Utils.whoami?(:iface => $iface)
    tcp_pkt = TCPPacket.new(:config => config)
    tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1, :psh => 1)
    tcp_pkt.tcp_dst = @port
    tcp_pkt.tcp_src = rand(8000..65000)
    tcp_pkt.ip_saddr = "153.251.232.153"
    tcp_pkt.ip_daddr = @daddr

    cipher = Encrypter.new(pass)
    iv = cipher.newIv
    cipher.encrypt(iv, $ipSource)
  end



  def start
     puts "started"
    conn = Connector.new(@iface, @tos, @daddr, @pass, "client", @port)
    Thread.new{ readPackets }
    while (true)
      str = STDIN.gets
      conn.send(str)
      puts "sent"

    end
  end

private

  def readPackets
    while(true)
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

  def tcp
    filter = "tcp and dst port " + @port.to_s + " and src " + @daddr
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      puts "here"
      pkt = Packet.parse p
      puts tcpRecv(pkt)
    end
  end

  def udp
  end

  def icmp
  end


end
