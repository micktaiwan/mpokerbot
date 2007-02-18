require 'TCPClient'
require 'pokerbot'

JOIN_GAME = 20
PONG = 61
ACTION = 30

class PokiClient

   def initialize(player)
      @tcp = PokiTCPClient.new 'hilo.cs.ualberta.ca', 55006 # test room
      #@tcp = TCPClient.new 'games.cs.ualberta.ca', 55501 # Sparbot-1 Heads-Up
      @player = player
   end

   def debug str
      puts "[POKI] " + str
   end
   
   def connect
      @tcp.connect
      debug 'connected'
   end
   
   def get_string(msg,from)
      str = ""
      while(msg[from]!=0)
         str += msg[from].chr
         from += 1
      end
      [str,from+1]
   end
   
   def get_int(msg,from)
      [msg[from,4].reverse.unpack("i")[0],from+4]
   end

   def read
      while true
         id,msg = @tcp.read
         
         case id
         when 21
            debug "good pass" # TODO: interface with PokerPlayer
         when 22
            debug "bad pass" # TODO: interface with PokerPlayer
         when 23
            debug "bad nick" # TODO: interface with PokerPlayer
         when 43 # info
            @player.info(msg.chomp.chomp)
         when 54 # chat
				@player.chat(msg.chomp.chomp)
         when 50 # start game
            @player.bet_size, @player.nb_players, @player.button, @player.position, @player.game_id = msg.unpack("NNNNN")
            @player.to_call = @player.bet_size
            @player.pot_size = 0
            debug  "bet size=#{@player.bet_size}, nb players=#{@player.nb_players}, button=#{@player.button}, position=#{@player.position}, game id=#{@player.game_id}"
            from = 20
            @player.start_hand
            for i in 0..@player.nb_players-1
               name, from  = get_string(msg, from)
               bank_roll, from =  get_int(msg,from)
               face, from =  get_int(msg,from)
               @player.add_player(i,name,bank_roll)
               @player.bank_roll = bank_roll if i==@player.position
            end
         when 51 # hole cards
            who, c1v,c1c,blank,c2v,c2c = msg.unpack("NA1A1A1A1A1")
            if(who==@player.position)
               debug "Our cards: #{c1v+c1c+blank+c2v+c2c}"
               @player.hole_cards = [[c1v,c1c] , [c2v,c2c]]
            else
               debug "Player #{who}'s cards: #{c1v+c1c+blank+c2v+c2c}"
            end   
         when 52 # new round
            round, cards = msg.unpack("NZ14")
            debug "round=#{round}, cards=#{cards}"
            cards.split.map! {|i| [i[0],i[1]]}
            @player.new_round(round,cards)
         when 0
            who = msg.unpack("N")
            debug "who=#{who} fold."
            @player.update(who,[FOLD])
         when 1
            who = msg.unpack("N")
            debug "who=#{who} called."
            @player.update(who,[CALL])
         when 2
            who,amount = msg.unpack("NN")
            debug "who=#{who} raise to #{amount}."
            @player.update(who,[RAISE,amount])
         when 3
            who,amount,msg = msg.unpack("NNZ50")
            debug "who=#{who} blinds #{amount}."
            @player.update(who,[BLIND,amount])
         when 53 # END
            nb_winners = msg.unpack("N")[0]
            debug "nb winners=#{nb_winners}"
            for i in 0..nb_winners-1
               who, from = get_int(msg,4+i*8)
               share, from = get_int(msg,8+i*8)
               @player.winner(who,share)
            end   
            @player.hand_end
            #break
         when 57 # NEXT_TO_ACT
            who, to_call = msg.unpack("NN")
				min, from = get_int(msg,8)
				max, from = get_int(msg,12)
            debug "NEXT: who=#{who}, to_call=#{to_call}, min=#{min}, max=#{max}"
            action, how_much = @player.next(who,to_call,min,max)
            if action != nil and who == @player.position
               send_action(action,how_much)
            end   
         when 60
            debug "PING"
            @tcp.format_send(PONG)
         else
            debug "NOT HANDLED: id=#{id},msg=#{msg}"
            break
         end
         #print ">"
         #i = gets.chomp
         #break if i == " "
      end
   end

   def login
      @tcp.format_send(JOIN_GAME,"micktaiwan\0","918273\0",@tcp.four_bytes(1),"MPokerBot\0")
   end
   
   def send_action(action,how_much) # poki server does not take raise amount
      #debug "Sending our action: #{action}"
      @tcp.format_send(ACTION, @tcp.four_bytes(action))
   end
   
end
