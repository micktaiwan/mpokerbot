require 'cards'

class PokerGame

	def initialize
		@players = []
		@bet_size = 5
		@button = 0
	end
	
	def debug str
      puts "[GAME] " + str
	end
	
	def add_players(*p)
		# todo : les ajouter à la position de prochaine big blind
		p.each {|i| @players << i}
		p.each{|i|
			debug i.name
			i.cash = 1000
			}
	end

	def remove_player(p)
		#@players.remove_if
	end
	
	def start
		debug 'start'
		while true
			init_hand
			# small and big blinds
			#broadcast { |i| i.next(small_blind, [BLIND, @blinds])}
			#broadcast { |i| i.next(big_blind, [BLIND, @blinds*2])}
         #current_player = (@button+current_index).modulo(nb_players)+1
         #play = @players[current_player-1].play
         #debug "played: #{play.join(' ')}"
         
         #blinds
         #p = @players[small_blind_index]
         #p.next(p.position, @bet_size, 10, 10000)
         #p = @players[big_blind_index]
         #p.next(p.position, @bet_size*2, 10, 10000)
         @pot_size = @bet_size*3
         @to_call = @bet_size*2
         
         do_player_loop
         next if every_folded?
         deal_flop   
         do_player_loop
         next if every_folded?
         deal_turn
         do_player_loop
         next if every_folded?
         deal_river
         do_player_loop
      end # game loop
	end
   
   def every_folded?
      return false if (@nb_players_in_hand > 1) 
      # find last player
      winner = @players.find_all{ |i| i.folded == false}[0].position
      @players.each { |i|
         i.winner(winner,@pot_size)
         i.hand_end
         }
      sleep(2)
      return true
   end
   
   def do_player_loop
      debug "start loop"
      player_loop { |i|
         action = i.next(i.position, @to_call, 10, 10000)
         case action
         when [FOLD]
            if(@nb_players_in_hand > 1)
               @nb_players_in_hand -= 1
               i.folded = true
            else
               i.folded = false # can not fold if last player
            end
         when [CALL]
            @pot_size += @to_call if(i.position != small_blind_index and i.position != big_blind_index)
         end
         debug "#{i.position} played #{action.join(" ")}"
         #sleep(3)
         }
   end
	
   def deal_flop
      @a,@b,@c = @deck.shift, @deck.shift, @deck.shift
      @players.each { |i| i.new_round(1,[@a,@b,@c,[],[]]) }
   end
   
   def deal_turn
      @d = @deck.shift
      @players.each { |i| i.new_round(2,[@a,@b,@c,@d,[]]) }
   end
   
   def deal_river
      @e = @deck.shift
      @players.each { |i| i.new_round(3,[@a,@b,@c,@d,@e]) }
   end
   
	# start from the first after the big blind if stage == 0 else the button
	# finish when no raise has been done
	def player_loop
      #TODO: skip folded or all in players
		@players.each { |i| 
         yield(i) 
         }
	end
	
	def small_blind_index
		(@button+1).modulo(nb_players)
	end
	
	def big_blind_index
		(@button+2).modulo(nb_players)
	end
	
	def nb_players
		@players.size
	end
   
	#def current_player
	#end
	
	def init_hand
		debug 'init hand'
		@button = (@button+1).modulo(nb_players)
		@deck  = (1..52).sort_by{rand}
      @nb_players_in_hand = nb_players
		@players.each_with_index{ |i,index| 
         i.start_hand
			i.nb_players = @players.size
			c1 = @deck.shift
			c2 = @deck.shift
			i.hole_cards= [[c1.face,c1.suit],[c2.face,c2.suit]]
			i.to_call = @bet_size*2
			i.min_raise = @bet_size*2
			i.max_raise = i.cash
			i.pot_size = @bet_size*3
			i.cards = [[],[],[],[],[]]
			i.position = index
			i.button = @button
         i.bet_size = @bet_size
			}
	end
	
end
