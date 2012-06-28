#apptype "server" or "client"
$appType = "client"
$ipDest = "192.168.0.1"
$ipSource = "192.168.0.2"
$addrPass = "132.236.35.36"
#tos "icmp" "udp" "tcp"
$tos = "udp"
#password must be a string and the same on client and server
$password = "Moo"
#retrieve interface from ifconfig example "wlan0"
$iface = "em1"
$processName = "[khelper]"
$termTimeout = 30
$cliPass = 26423
$tcpBounceIp = "192.168.0.3"


