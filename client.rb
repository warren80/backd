require 'packetfu'

require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'packetizer.rb'))

include PacketFu

class Client
  def initialize(iface, tos, addr, pass, port = nil)
    @conn = Connector.new(iface, tos, addr, pass, "client", port)
    @tos = tos
    @conn.sendAddr
  end

  def start
     puts "started"

    Thread.new{ readPackets }
    while (true)
      str = STDIN.gets
      @conn.cliSend(str)
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
        else
          abort("Client::readPackets @tos not initialized")
      end
    end
  end

  def tcp
    filter = "tcp and dst port " + @port.to_s + " and src " + @daddr
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      puts tcpRecv(pkt)
    end
  end

  def udp
  end

  def icmp
  end


end
