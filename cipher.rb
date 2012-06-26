require 'openssl'

class Encrypter
  attr_accessor :password, :cipher

  def initialize(cipherPassword)
    @cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    @password = cipherPassword
  end 

  def newIv
    return  @cipher.random_iv
  end

  def encrypt(iv, str)
    @cipher.encrypt
    @cipher.key = OpenSSL::Digest::SHA512.new(@password).digest
	@cipher.iv = iv
    
    a = @cipher.update(str)
    a << @cipher.final
    return a
  end

  def decrypt(iv, str)
	@cipher.decrypt
	@cipher.key = OpenSSL::Digest::SHA512.new(@password).digest
	@cipher.iv = iv
	a = @cipher.update(str)
	a << @cipher.final
    return a
  end
end

def test
  enc = Encrypter.new("moo")
  puts "Test 1"
  iv = enc.newIv
  a = enc.encrypt(iv, "test 1")
  puts a.length
  b = enc.decrypt(iv, a)
  puts b
  puts "Test 2"
  iv = enc.newIv
  a = enc.encrypt(iv, "test 2")
  puts a.length
  b = enc.decrypt(iv, a)
  puts b
end


