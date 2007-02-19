FOLD 	= 0
CALL 	= 1
RAISE = 2
BLIND = 3

   def action_str(a)
      return case a[0]
         when FOLD;  "FOLD"
         when CALL;  "CALL"      
         when RAISE; "RAISE #{a[1]}"      
         when BLIND; "BLIND #{a[1]}"
         else raise "unknown action #{a}"
      end
   end


class PlayerInfos

   attr_accessor(
      :name,      
      :position,
      :bank_roll,    # how much money he currently has
		:folded,			# hand folded (false or true)
      :last_action,
      :hand_amount,  # how much money he put in this hand
      :loop_amount, # how much money he put in this loop
      :total_amount # how much money he won
      )
      
   def initialize(name, position, bank_roll)
      @name, @position, @bank_roll = name, position, bank_roll
		@folded = false
      @last_action = nil
      @total_amount = @hand_amount = @loop_amount = 0
   end

   def to_s
      "#{name} (#{position}) #{action_str(last_action)}. Loop amount: #{loop_amount} Hand amount: #{hand_amount}. Bank roll: #{bank_roll}"
   end

end


class PokerPlayer

	attr_accessor(
      :infos,           # common player info
		:hole_cards, 	# [['A','s'],['7','c']] see module cards for definition of cards
		:to_call, 		# amount to put on the table if you want to call
      :blinds,     # small blind amount
		:min_raise, 	# minimum amount for raising
		:max_raise,		# maximum amount for raising (== cash if no limit)
		:pot_size, 		# how much in the pot counting the current players bets
		:cards,			# cards on the table, ex: [[3,s],[4,h],[K,d],[],[]]
		:button,			# position of the button
		:nb_players,	# nb of players
      :game_id,      # current game id
      :who,          # who must act
      :round,        # round 0=preflop, 1 flop, 2 turn, 3 river
      :players
		)
		
	def initialize(name)
		@name = name
      @total_amount = 0
      @infos = PlayerInfos.new(name,0,0)      
      start_hand
	end
	
   def start_hand
      clear_players
		@round =  @to_call = @blinds = @pot_size = @min_raise = @max_raise =  0
		@hole_cards = @cards = []
   end
   
   def add_player(position, name, bank_roll)
      debug "Adding player #{name}, position=#{position}, bank roll=#{bank_roll}"
      @players[position] = PlayerInfos.new(name, position, bank_roll)
   end
   
   def clear_players
      @players = Hash.new
   end
  
	# return the action
	# [0]: fold
	# [1]: calls
	# [2,howmuch]: raise
	def play
		[FOLD]
	end
	
	# tells who is the next player to play and if it us return our action
	def next(is_blind,who, to_call, min, max)
      #debug "NEXT is #{@players[who].name} (#{who}), to_call=#{to_call}"
      @who, @to_call, @min_raise, @max_raise = who, to_call, min, max
      return play if(!is_blind and who==@infos.position)
      return nil
	end
   
   def small_blind?(who)
      return true if who == (@button+1).modulo(@nb_players)
      return false
   end
   
   def big_blind?(who)
      return true if who == (@button+2).modulo(@nb_players)
      return false
   end


   def player_bets(who,amount)
		@pot_size += amount
      @players[who].hand_amount += amount
      @players[who].loop_amount += amount
      @players[who].bank_roll -= amount
      if(who==@infos.position) # ourself
         @infos.hand_amount += amount
         @infos.loop_amount += amount
         @infos.bank_roll -= amount
      end
      
   end
   
	# tells the action played
   def update(who,action)
      @players[who].last_action = action
		case action[0]
			when FOLD
            @players[who].folded = true
			when CALL
            player_bets(who,@to_call)
			when RAISE
            @to_call  = action[1]
            player_bets(who,action[1]-@players[who].loop_amount)
			when BLIND
            player_bets(who,action[1])
      end
      debug "UPDATE "+ @players[who].to_s + " Pot: #{@pot_size}. To call: #{@to_call}"
   end
   
   def winner(who,share)
      debug "#{@players[who].name} wins #{share}"
      if(who==@infos.position)
         @infos.hand_amount += share 
      end
   end
   
   def hand_end
      @infos.total_amount += @infos.hand_amount
      debug "STATS: hand: #{@infos.hand_amount}, total:#{@infos.total_amount}"
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

