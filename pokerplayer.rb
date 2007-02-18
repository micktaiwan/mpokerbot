FOLD 	= 0
CALL 	= 1
RAISE = 2
BLIND = 3

class PlayerInfos

   attr_accessor(
      :name,      
      :position,
      :bank_roll,
		:folded
      )
      
   def initialize(name, position, bank_roll)
      @name, @position, @bank_roll = name, position, bank_roll
		@folded == false
   end
   
end


class PokerPlayer

	attr_accessor(
		:name, 			# player name
		:hole_cards, 	# [,] see module cards for definition of cards
		:to_call, 		# amount to put on the table if you want to call
      :bet_size,     # small blind amount
		:min_raise, 	# minimum amount for raising
		:max_raise,		# maximum amount for raising (== cash if no limit)
		:cash, 			# how much money you have left
		:pot_size, 		# how much in the pot counting the current players bets
		:cards,			# cards on the table, ex: [[3,s],[4,h],[K,d],[],[]]
		:position,		# position at the table
		:button,			# position of the button
		:nb_players,	# nb of players
      :game_id,      # current game id
      :who,          # who must act
      :bank_roll,    # how much money we currently have
      :hand_amount,  # how much money we put in this hand
      :round,        # round 0=preflop, 1 flop, 2 turn, 3 river
      :total_amount, # how much money we won
		:folded			# hand folded (false or true)
		)
		
	def initialize(name)
		@name = name
      @total_amount = 0
      start_hand
	end
	
   def start_hand
      debug 'start hand'
      clear_players
		@round = @bank_roll = @hand_amount = @to_call = @bet_size = @pot_size = @min_raise = @max_raise = @cash = 0
		@hole_cards = @cards = []
   end
   
   def add_player(position, name, bank_roll)
      debug "Adding player #{name}, position=#{position}, bank roll=#{bank_roll}"
      @players << PlayerInfos.new(name, position, bank_roll)
   end
   
   def clear_players
      @players = []
   end
   
	# return the action
	# [0]: fold
	# [1]: calls
	# [2,howmuch]: raise
	def play
		[FOLD]
	end
	
	# tells who is the next player to play and if it us return our action
	def next(who, to_call, min, max)
      debug "NEXT who=#{who}, to_call=#{to_call}"
      @who, @to_call, @min_raise, @max_raise = who, to_call, min, max
      rv = [CALL]
      if(who==@position)
         if @round==0
            if small_blind?(who)
               debug "I am small blind" 
               @hand_amount -= @to_call
               return rv
            elsif big_blind?(who)
               debug "I am big blind"
               @hand_amount -= @to_call
               return rv
            end
         end   
         rv = play
      end
      return rv
	end
   
   def small_blind?(who)
      return true if who == (@button+1).modulo(@nb_players)
      return false
   end
   
   def big_blind?(who)
      return true if who == (@button+2).modulo(@nb_players)
      return false
   end

   
	# tells the action played
   def update(who,action)
		case action[0]
			when FOLD
            #todo: flag it folded
			when CALL
				@pot_size += @to_call
			when RAISE
				@pot_size += action[1]
            @to_call  += action[1]
			when BLIND
				@pot_size += action[1]
      end
      debug "UPDATE #{who} action: #{action}.  Pot: #{@pot_size}. To call: #{to_call}"
   end
   
   def action_str(a)
      return case a
         when FOLD;  "FOLD"
         when CALL;  "CALL"      
         when RAISE; "RAISE"      
         when BLIND; "BLIND"
         else "???"
      end
   end
   
   def winner(who,share)
      debug "#{who} wins #{share}"
      if(who==@position)
         @hand_amount += share 
      end
   end
   
   def hand_end
      @total_amount += @hand_amount
      debug "hand: #{@hand_amount}, total:#{@total_amount}"
   end

	def info(str)
		puts "INFO: #{str}"
	end
	
	def chat(str)
		puts "CHAT: #{str}"
	end
   
   def new_round(r, c)
      @round, @cards = r, c
   end
   
end

