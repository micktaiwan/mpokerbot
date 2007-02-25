#!/usr/local/bin/ruby
require 'pokerplayer'
require 'hand'

class PokerBot < PokerPlayer

	def initialize(name, mode='cash')
		super(name)
      @mode = mode
      read_starting_hand_eval
	end
	
   def debug(str)
      puts "[#{@infos.name}] " + str.to_s
   end
   
	def play
		debug "===== PLAYING #{@hole_cards} - to_call: #{@to_call}, pot size: #{@pot_size}"
      action = calculate_hand
      debug "ACTION=#{action_str(action)}"
      action
   end
	
	def calculate_hand
      return calculate_starting_hand if @round == 0
      calculate_postflop_hand
	end

   def position_value
      if(@button < @infos.position)
         return @nb_players-(@infos.position-@button)
      else
         return @button-@infos.position
      end
   end

   def calculate_starting_hand
      a = @hole_cards[0]
      b = @hole_cards[1]
      s = same_suit?(@hole_cards) ? "s":""
      if(value_order(a[0]) > value_order(b[0]))
         str = a[0]+b[0]+s
      else
         str = b[0]+a[0]+s
      end
      v = @starting_hand_eval[str]
      return [RAISE,20] if v > 0.5
      return [RAISE,10] if v > 0
      return [CALL] if v > -0.1
      return [FOLD]
   end
   
   def same_suit?(cards)
      suit = nil
      cards.each { |c|
         return false if suit!=nil and c[1]!=suit
         suit = c[1] if suit == nil
         }
      return true
   end
   
   def value_order(c)
   		return case c
			when 'A'; 14
			when 'T'; 10
			when 'J'; 11
			when 'Q'; 12
			when 'K'; 13
			else return c.to_i
		end
   end
   
   def calculate_postflop_hand
		a = @hole_cards[0]
      b = @hole_cards[1]
      #debug "cards = #{@cards}"
      #debug "#{(@hole_cards+@cards).join(" ")}"
      h1 = Hand.new((@hole_cards+@cards).reject{|e| e==[]}.map{|e| e.join})
      h2 = Hand.new((@cards).reject{|e| e==[]}.map{|e| e.join})
      a = h1.evaluate
      b = h2.evaluate
      v = a - b
      debug "Hand value: #{a} - #{b} = #{v}"
      #exit
      # TODO: tenir compte des ameliorations (outs)
      
      return [RAISE,20] if v > 1
      return [CALL] if v > 0
      return [CALL] if @to_call == 0
      return [FOLD]
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

