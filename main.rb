require 'fiddle'

require File.expand_path(File.join(File.dirname(__FILE__), 'knock.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'config.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'client.rb'))

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
  k = nil
  s = Server.new(tos, port)
  s.start
end

def client
  k = Knock.new($iface)
  port = k.knock($ipDest, $tos)
  c = Client.new($iface, $tos, $ipDest, $password, port)
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
