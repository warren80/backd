require 'fiddle'

#require File.expand_path(File.join(File.dirname(__FILE__), 'cipher.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'knock.rb'))

def set_process_name name
    RUBY_PLATFORM =~ /linux/ or return
    Fiddle::Function.new(
        DL::Handle['prctl'], [
            Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP,
            Fiddle::TYPE_LONG, Fiddle::TYPE_LONG,
            Fiddle::TYPE_LONG
        ], Fiddle::TYPE_INT
    ).call(15, name.to_s, 0, 0, 0)
    $0 = processName
end

def server
  k = Knock.new($iface)
  port = k.sniff
  puts port
end

def client
  k = Knock.new($iface)
  k.knock($ipDest)
  puts knockSent
end

processName = "[kworker/u:0]"
set_process_name processName

if $appType == "server"
   server
 elsif $appType == "client"
   client
 else
   abort "invalid appType"
end
