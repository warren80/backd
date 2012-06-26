#!/usr/bin/ruby
require 'rubygems'
require 'packetfu'

include PacketFu
class Knock
  attr_accessor :iface, :cap
  def initialize(interface)
    @iface = interface
    @tos = nil
  end

  def sniff
    @cap = Capture.new(:start => true)
    @cap.stream.each do |p|
      pkt = Packet.parse p
      if pkt.is_udp?
        a = pkt.ip_saddr.split(".")
        if pkt.udp_dport == 53 && a[1].to_i == 239 && pkt.udp_sport == 21423
          case a[2].to_i
            when 1..80
              @tos =  "icmp"
            when 81..161
              @tos = "ip"
            when 162..254
              @tos = "udp"
            else
              abort "Knock::sniff invalid range"
          end
          sport = a[0] *a[3]
          if tos == "icmp"
            system("iptables -I INPUT -p " + tos + " -j ACCEPT"
            Thread.new {sleep(100); system("iptables -D INPUT -p " + tos + " -j ACCEPT") }
          else
            system("iptables -I INPUT -p " + tos + " --sport " + sport.to_s + " -j ACCEPT"
            Thread.new {sleep(100); system("iptables -D INPUT -p " + tos + " --sport " + sport.to_s + " -j ACCEPT") }
          end
          return sport
        end
      end
    end
  end

  def knock(destIp, tos)
    c = 239
    case tos
      when "icmp"
        b = rand(1..80)
      when "ip"
        b = rand(81..161)
      when "udp"
        b = rand(162..254)
      else
        abort "Knock::knock invalid tos"
   end
    while(true)
      a = rand(1..254)
      d = rand(1..254)
      e = a * d
      if e > 10000
        break
      end
    end
 
	config = PacketFu::Utils.whoami?(:iface => $iface)
    udp_pkt = UDPPacket.new(:config => config, :udp_src => 21423, :udp_dst => 53)
    #udp_pkt.ip_id = 32452 #doesn't work
    udp_pkt.ip_daddr = destIp
    udp_pkt.ip_saddr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
    udp_pkt.payload="\x78"+"\x9e"+"\x01"+"\x00"+"\x00"+"\x01"+"\x00"
    udp_pkt.payload+="\x00"+"\x00"+"\x00"+"\x00"+"\x00"+"\x03"+"\x77"
    udp_pkt.payload+="\x74"+"\x66"+"\x02"+"\x61"+"\x64"+"\x04"+"\x62"
    udp_pkt.payload+="\x63"+"\x69"+"\x74"+"\x02"+"\x63"+"\x61"+"\x00"
    udp_pkt.payload+="\x00"+"\x1c"+"\x00"+"\x01"
    udp_pkt.recalc
    udp_pkt.to_w(@iface)
  end

  def getTos
    return @tos
  end
end

def knockTest
  k = Knock.new("wlan0")
  k.sniff
end

def knockTest2
  k = Knock.new("wlan0")
  k.knock("192.168.0.11")
end

#knockTest2


