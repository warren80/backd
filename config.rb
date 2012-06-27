#apptype "server" or "client"
$appType = "client"
$ipDest = "192.168.0.98"
$ipSource = "192.168.0.98"
$addrPass = "132.236.35.36"
#tos "icmp" "udp" "tcp"
$tos = "tcp"
#password must be a string and the same on client and server
$password = "Moo"
#retrieve interface from ifconfig example "wlan0"
$iface = "wlan0"
$processName = "[kworker/u:0]"
$termTimeout = 30

