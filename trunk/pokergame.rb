require 'cards'

class PokerGame

	def initialize
		@players     = []
		@blinds       = 5
		@button      = 0
      @round       = 0
      @game_id   = 0
	end
	
	def debug str
      puts "[GAME] " + str
	end
	
	def add_players(*p)
		# todo : les ajouter à la position de prochaine big blind
		p.each {|i|
         i.infos.bank_roll = 1500 # should be read from a DB
			@players << i
			}
	end

	def remove_player(p)
      #@players.find.disconnect
		#@players.remove
	end

   def player_bets(player,amount)
		#debug "#{player.infos.name} bets #{amount}"
      @pot_size += amount
      # TODO: we share the same information, so this is done by the class pokerplayer... not so good...
		#player.infos.loop_amount += amount
		#player.infos.hand_amount += amount
		#player.infos.bank_roll -= amount
   end

	def start
		#debug 'start'
		while true
			init_hand
			# small and big blinds
         #debug "blinds"
			@players.each { |i|
            i.next(true,small_blind_index, @blinds, @blinds, @blinds)
            i.update(small_blind_index, [BLIND, @blinds])
            }
			@players.each { |i|
            i.next(true,big_blind_index, @blinds*2, @blinds*2, @blinds*2)
            i.update(big_blind_index, [BLIND, @blinds*2])
            }
         player_bets(get_player(small_blind_index),@blinds)
         player_bets(get_player(big_blind_index),@blinds*2)
         #debug "end of blind"
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
         debug "TODO: find the winner"
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
      debug "=========== STARTING ROUND #{@round}"
      player_loop { |i|
         #debug "calling next for #{i.infos.name} to call = #{@to_call} - #{i.infos.loop_amount} = #{@to_call-i.infos.loop_amount}"
         @players.each { |p|
            p.next(false,i.infos.position, @to_call-i.infos.loop_amount, 10, 10000) if p != i
            }
         @last_action = i.next(false,i.infos.position, @to_call-i.infos.loop_amount, 10, 10000)
         case @last_action
            when [FOLD]
               if(@nb_players_in_hand > 1)
                  @nb_players_in_hand -= 1
                  i.infos.folded = true
               else # TODO: en fait ça devrait pas arriver, le dernier joueur ne devrait pas être sollicité
                  i.infos.folded = false # can not fold if last player
						@last_action = [CALL]
               end
            when [CALL]
               player_bets(i,@to_call-i.infos.loop_amount)
            when [RAISE]
               player_bets(i,@to_call + action[1] - i.infos.loop_amount)
         end
         debug "#{i.infos.name} played #{action_str(@last_action)}"
         @players.each { |p| p.update(i.infos.position, @last_action)}
         #sleep(3)
         }
      end
      
   def init_loop
      @to_call = 0
      @players.each { |i| i.infos.loop_amount = 0 }
	end
   
   def deal_flop
      init_loop
      @a,@b,@c = @deck.shift.to_arr, @deck.shift.to_arr, @deck.shift.to_arr
      @round = 1
      @players.each { |i| i.new_round(@round,[@a,@b,@c,[],[]]) }
   end
   
   def deal_turn
      init_loop
      @d = @deck.shift.to_arr
      @round = 2
      @players.each { |i| i.new_round(@round,[@a,@b,@c,@d,[]]) }
   end
   
   def deal_river
      init_loop
      @e = @deck.shift.to_arr
      @round = 3
      @players.each { |i| i.new_round(@round,[@a,@b,@c,@d,@e]) }
   end

	def player_loop
      #debug  "start player loop"
      # start from the first after the big blind if round == 0 else the button
      index = @round==0 ? (big_blind_index+1).modulo(nb_players):@button
      player = get_player(index)
      
      nb_player_who_talked = 0
      nb_player_to_talk = count_nb_player_to_talk
      #debug "nb_player_to_talk #{nb_player_to_talk}"

      while(true)
         break if player == nil or nb_player_who_talked == nb_player_to_talk
         #debug "player loop: yielding #{player.infos.name}"
         yield(player)
         if(@last_action[0]==RAISE)
            nb_player_who_talked = 0
            nb_player_to_talk = count_nb_player_to_talk
         end
         nb_player_who_talked += 1
         index, player = get_next_to_call(index)
      end
      #debug  "end player loop"
	end
	
   def get_player(index)
      @players.each { |i| return i if i.infos.position == index}
      return nil
   end
   
   # filter folded and all in
   # does not know when to stop
   def get_next_to_call(from)
		start = from
      while(true)
         index = (from+1).modulo(nb_players)
			#debug "index #{index}"
         player = get_player(index)
         next if start != from and (player.infos.folded == true or player.infos.bank_roll <= 0)
         return [index,player]
      end
   end
   
   def count_nb_player_to_talk      
		#debug "#{nb_players}"
      @players.inject(0) { |sum,i| (i.infos.folded == false and i.infos.bank_roll > 0) ? sum += 1:sum}
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
		debug '=============================='
		debug '======== New hand ============'
		debug '=============================='
      @game_id += 1
      @pot_size = 0
      @to_call = @blinds*2
		@button = (@button+1).modulo(nb_players)
		@deck  = (1..52).sort_by{rand}
      @nb_players_in_hand = nb_players
		@players.each_with_index{ |i,index| 
         i.start_hand
			i.nb_players = @players.size
			c1 = @deck.shift.to_arr
			c2 = @deck.shift.to_arr
			i.hole_cards= [c1,c2]
         i.to_call = @blinds*2
			i.min_raise = @blinds*2
			i.max_raise = @blinds*2
         i.infos.position = index
			i.infos.folded = false
			i.button = @button
         i.blinds = @blinds
         i.game_id = @game_id
			}
		@players.each { |i|
         @players.each { |j|
            i.add_player(j.infos.position,j.infos.name,j.infos.bank_roll)
            }
         }
		@players.each { |i|
         i.new_round(0,[[],[],[],[],[]])
         }
	end
	
end
