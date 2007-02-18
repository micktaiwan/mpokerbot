require 'socket'
require 'timeout'

class PokiTCPClient

	def initialize(ip,port)
		@t = nil
      @ip = ip
      @port = port
	end

	def connect
		begin
         timeout(5) do
            @t = TCPSocket.new(@ip, @port)
         end
		rescue
         @t = nil
         raise
		end
	end
   
	def debug(str)
      #puts "[TCP] " + str
   end
   
	def disconnect
		@t.close if(@t != nil)
	end

	def format_send(id,*msg)
		str = msg.join
      debug "sending #{id}: #{str}"
		send(id,str)
	end

   def four_bytes(s)
      a = s/(256*3)
      b = s/(256*2) - a*(256*3)
      c = s/(256) - b*(256*2)
		d = s-c*256
      [a,b,c,d].pack("cccc")
   end
   
	def send(id,str)
		s = str.size
		raise "msg too long" if s >= 256*256*256*256
      @t.print four_bytes(id)
		@t.print four_bytes(s)
      debug "s size=#{s}, str=#{str}"
		@t.print str if s > 0
	end
	
	def read
		raise "not connected" if @t == nil
		msg = ""
		id = @t.recv(4)
		id = id.unpack("N")[0]
      debug "id=#{id}"
      return if id == nil
		len = @t.recv(4)
      debug "len=#{len[3]}"
		len = len.unpack("N")[0]
      debug "len=#{len}"
		if(len > 0)
			msg = @t.recv(len)
		end
      debug "msg size: #{msg.size}"
		[id,msg]
	end
	
end
