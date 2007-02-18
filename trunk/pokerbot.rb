require 'pokerplayer'

class PokerBot < PokerPlayer

	def initialize(name)
		super(name)
      read_starting_hand_eval
	end
	
   def debug(str)
      puts "[#{name.upcase}] " + str
   end
   
	def play
		calculate_hand
		debug "PLAYING #{@hole_cards} - to_call: #{@to_call}, pot size: #{@pot_size}, win percent: #{@win_percent}, max call: #{(@pot_size*@win_percent).floor}"
		if @win_percent < 0.3 # no chances to win
			if @to_call==0 or (@to_call<=10 and @round==0) # TODO: il faut tenir compte des chances d'amélioration (tirages) pour augementer ce seuil
				action = [CALL] # TODO: tenir compte des hand history (personne n'a raisé et au bouton ) pour peut-être raiser
				# un bluff est posible que si on a un tirage ou un pourcentage pas trop petit
			else
				action = [FOLD]
			end
		else # chances to win
			if (@to_call > @pot_size*@win_percent)  and (@to_call > 10 and @round>0) # taking count of the pot
				action = [FOLD]
			#elsif @to_call < (@pot_size*@win_percent) / 3
	      #    #@bank_roll -= @to_call+@raise
	      #   @hand_amount -= @to_call+@raise
	      #   action = [RAISE,@raise]
			else
	         #puts @bank_roll, @to_call
	         #@bank_roll -= @to_call
	         @hand_amount -= @to_call
				action = [CALL]
			end
		end
      debug "ACTION=#{action_str(action[0])}. Paid so far: #{@hand_amount}$. Bank roll: #{@bank_roll}"
      action
   end
	
	# gives raw win percent without hand history/bluff/player stat
	def calculate_hand
		case round
         when 0; @win_percent = calculate_starting_hand
         when 1; @win_percent = calculate_postflop_hand
         when 2; @win_percent = calculate_postflop_hand
         when 3; @win_percent = calculate_postflop_hand
      end
		@raise = @max_raise
		#@raise = @pot_size/2
      debug "round #{round}: #{@hole_cards} value=#{@win_percent}"
      sleep(2)
	end

   def position_value
      if(@button < @position)
         return @nb_players-(@position-@button)
      else
         return @button-@position
      end
   end

   def calculate_starting_hand
      a = @hole_cards[0]
      b = @hole_cards[1]
      s = same_suit?(@hole_cards) ? "s":""
      return @starting_hand_eval[a[0]+b[0]+s]
   end
   
   def same_suit?(cards)
      suit = nil
      cards.each { |c|
         return false if suit!=nil and c[1]!=suit
         suit = c[1] if suit == nil
         }
      return true
   end
   
   def calculate_postflop_hand
      return calculate_starting_hand # temporary
		
		a = @hole_cards[0]
      b = @hole_cards[1]
      if a[0] == b[0]
         return 1 if above_ten.include?(a[0])
         return 0.5
      end      
      # else
      return 0.2
   end
   
	#######
   private
   #######
   
   def read_starting_hand_eval
      @starting_hand_eval = Hash.new
      File.open("start_hand_eval.txt").each_line { |l|
         arr = l.split
         next if(l == "")
         @starting_hand_eval[arr[0]] = arr[1].to_f
         }
   end
   
   
end

################################################################################
if __FILE__ == $0

   require 'test/unit'

   class TC_MyTest < Test::Unit::TestCase

      def setup
         @p = PokerBot.new('test')
      end

      # def teardown
      # end

      def test_same_suit
         assert(@p.same_suit?([['A','s'],['K','s'],['10','s']]))
         assert(!@p.same_suit?([['A','s'],['K','s'],['10','d']]))
      end
      
      def test_position_value
         @p.position = 4
         @p.nb_players = 10
         rv = []
         0.upto(9) { |i|
            @p.button = i
            rv << @p.position_value
            }
         assert(rv.join=="6789012345")
      end
   end

end
