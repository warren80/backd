require 'fiddle'

#require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'knock.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'config.rb'))

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
  Server.new(tos, port)
end

def client
  k = Knock.new($iface)
  port = k.knock($ipDest, $tos)
  Client.new($tos, port)
end

set_process_name $processName

if $appType == "server"
   client
 elsif $appType == "client"
   client
 else
   abort "invalid appType"
end
