require 'cards'

class PokerGame

	def initialize
		@players = []
		@blinds = 5
		@button = 0
      @round = 0
	end
	
	def debug str
      puts "[GAME] " + str
	end
	
	def add_players(*p)
		# todo : les ajouter à la position de prochaine big blind
		p.each {|i| @players << i}
	end

	def remove_player(p)
		#@players.remove_if
	end

   def player_bets(player,amount)
         debug "#{player.infos.name} bets #{amount}"
         player.infos.loop_amount += amount
         player.infos.hand_amount += amount
         player.infos.bank_roll -= amount
   end

	def start
		debug 'start'
		while true
			init_hand
			# small and big blinds
         debug "blinds"
			@players.each { |i|
            i.next(true,small_blind_index, @blinds, @blinds, @blinds)
            i.update(small_blind_index, [BLIND, @blinds])
            }
			@players.each { |i|
            i.next(true,big_blind_index, @blinds*2, @blinds*2, @blinds*2)
            i.update(big_blind_index, [BLIND, @blinds*2])
            }
         #player_bets(get_player(small_blind_index),@blinds)
         #player_bets(get_player(big_blind_index),@blinds*2)
         debug "end of blind"

         @pot_size = @blinds*3
         @to_call = @blinds*2
         @players.each { |i| i.new_round(0,[[],[],[],[],[]]) }
         @to_call = @blinds*2
         
         do_player_loop
         next if every_folded?
         deal_flop   
         @to_call = 0
         @players.each { |i| i.infos.loop_amount = 0 }
         do_player_loop
         next if every_folded?
         deal_turn
         @to_call = 0
         @players.each { |i| i.infos.loop_amount = 0 }
         do_player_loop
         next if every_folded?
         deal_river
         @to_call = 0
         @players.each { |i| i.infos.loop_amount = 0 }
         do_player_loop
         break
      end # game loop
	end
   
   def every_folded?
      return false if (@nb_players_in_hand > 1) 
      # find last player
      winner = @players.find_all{ |i| i.infos.folded == false}[0].infos.position
      @players.each { |i|
         i.winner(winner,@pot_size)
         i.hand_end
         }
      #sleep(2)
      return true
   end
   
   def do_player_loop
      puts
      debug "=== STARTING ROUND #{@round}"
      player_loop { |i|
         debug "calling next for #{i.infos.name} to call = #{@to_call} - #{i.infos.loop_amount} = #{@to_call-i.infos.loop_amount}"
         @last_action = i.next(false,i.infos.position, @to_call-i.infos.loop_amount, 10, 10000)
         case @last_action
            when [FOLD]
               if(@nb_players_in_hand > 1)
                  @nb_players_in_hand -= 1
                  i.infos.folded = true
               else
                  i.infos.folded = false # can not fold if last player
               end
            when [CALL]
               @pot_size += @to_call #if(@round!=0 or (i.infos.position != small_blind_index and i.infos.position != big_blind_index))
            when [RAISE]
               @pot_size += @to_call + action[1]
         end
         debug "#{i.infos.name} played #{@last_action.join('=>')}"
         @players.each { |p| p.update(i.infos.position, @last_action)}
         #sleep(3)
         }
   end
	
   def deal_flop
      @a,@b,@c = @deck.shift, @deck.shift, @deck.shift
      @round = 1
      @players.each { |i| i.new_round(@round,[@a,@b,@c,[],[]]) }
   end
   
   def deal_turn
      @d = @deck.shift
      @round = 2
      @players.each { |i| i.new_round(@round,[@a,@b,@c,@d,[]]) }
   end
   
   def deal_river
      @e = @deck.shift
      @round = 3
      @players.each { |i| i.new_round(@round,[@a,@b,@c,@d,@e]) }
   end

	def player_loop
      debug  "start loop"
      # start from the first after the big blind if round == 0 else the button
      index = @round==0 ? (big_blind_index+1).modulo(nb_players):@button
      player = get_player(index)
      
      nb_player_who_talked = 0
      nb_player_to_talk = count_nb_player_to_talk
      debug "nb_player_to_talk #{nb_player_to_talk}"

      while(true)
         break if player == nil or nb_player_who_talked == nb_player_to_talk
         debug "player_loop: yielding #{player.infos.name}"
         yield(player)
         if(@last_action[0]==RAISE)
            nb_player_who_talked = 0
            nb_player_to_talk = count_nb_player_to_talk
         end
         nb_player_who_talked += 1
         index, player = get_next_to_call(index)
      end
      debug  "end loop"
	end
	
   def get_player(index)
      @players.each { |i| return i if i.infos.position == index}
      return nil
   end
   
   # filter folded and all in
   # does not know when to stop
   def get_next_to_call(from)
      while(true)
         debug "."
         index = (from+1).modulo(nb_players)
         player = get_player(index)
         next if player.infos.folded == true or player.infos.bank_roll == 0
         return [index,player]
      end
   end
   
   def count_nb_player_to_talk      
      @players.inject(0) {|sum,i| sum+=1 if(i.infos.folded == false and i.infos.bank_roll > 0)}
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
         i.to_call = @blinds*2
			i.min_raise = @blinds*2
			i.max_raise = @blinds*2
			i.pot_size = 0 # will be updated
			i.cards = [[],[],[],[],[]]
         i.infos.position = index
         i.infos.bank_roll = 1500
			i.button = @button
         i.blinds = @blinds
			}
		@players.each { |i|
         @players.each { |j|
            i.add_player(j.infos.position,j.infos.name,j.infos.bank_roll)
            }
         }
	end
	
end
