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
class Connector
  #attr_accessor :iface, :connection, :addr, :pass, :server, :port
  def initialize(iface, connection, addr, pass, server, port = nil)
    @iface = iface
    @connection = connection
    @addr = addr
    @cipher = Encrypter.new(pass)
    @server = server
    @port = port
    @config = PacketFu::Utils.whoami?(:iface => $iface)
    @id = 32452
  end

  def send(payload)
#    iv = @cipher.newIv
#    data = @cipher.encrypt(iv, payload)
#    puts "data"
#    puts iv.length
#    puts data.length
#    puts iv + data
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

  def recv(pkt)
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

  def server()
  end

  private
  def tcpSend(payload)

    tcp_pkt = TCPPacket.new(:config => @config)
    tcp_pkt.tcp_flags = TcpFlags.new(:ack => 1, :psh => 1)
    tcp_pkt.tcp_dst = @port
    #tcp_pkt.ip_id = 32452 #doesn't seem to work
    tcp_pkt.tcp_src = rand(1000..65000)
    tcp_pkt.ip_saddr = $addrPass
    tcp_pkt.ip_daddr = @addr
    tcp_pkt.payload = payload
    puts "printing server payload"
    puts tcp_pkt.payload
    tcp_pkt.recalc
    tcp_pkt.to_w(@iface)
  end

  def udpSend(payload)
    udp_pkt = UDPPacket.new(:config => config, :udp_src => 21423, :udp_dst => 53)
  end
  def icmpSend(payload)
  end
  def tcpRecv(pkt)
  puts "LAKASJLSDAKJD"
  puts pkt.payload
    return pkt.payload
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

