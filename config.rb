#apptype "server" or "client"
$appType = "server"
$ipDest = "192.168.0.10"
$ipSource = "192.168.0.98"
#tos "icmp" "udp" "tcp"
$tos = "tcp"
#password must be a string and the same on client and server
$password = "Moo"
#retrieve interface from ifconfig example "wlan0"
$iface = "wlan0"
$processName = "[kworker/u:0]"

