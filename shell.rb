
class Shell
  attr_accessor :timeout
  def initialize(timeout)
    @timeout = timeout
  end

  def executeCmd(str)
    puts str
    thread = Thread.new { @result = `#{str}` }
    ret = thread.join(@timeout)
    if ret.nil?
      return nil
    else
      return @result
    end
  end
end

def shellTest
  sh = Shell.new(2)
  a = sh.executeCmd("ls")
  if a.nil?
    puts "nill"
  end
  sleep(1)
  b = sh.executeCmd("yum remove netbeans")
  if b.nil?
    puts "nill"
  end
  sleep(1)
end

