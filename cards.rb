module PlayingCards
	
	def black?
		self > 26 and self != 53
	end
   
	def red?
      not black?
   end
   
	def suit
		case self
			when 01..13; :h
			when 14..26; :d
			when 27..39; :c
			when 40..52; :s
			when 53..54; :j
		end
	end
	
	def face
		return case n = (self - 1) % 13 + 1
			when 2..9; n.to_s
			when 01; 'A'
         when 10; 'T'
			when 11; 'J'
			when 12; 'Q'
			when 13; 'K'
		end unless self > 52
		
		return case self
			when 53; 'Red'
			when 54; 'Black'
		end unless self > 54
	end
	
	def card_name
		return "#{face} of #{suit}" unless self > 52
		return "#{face} #{suit}"    unless self > 54
	end

	def convert_to_card(c)
		value = case c[0]
			when 'A'; 1
			when 'T'; 11
			when 'J'; 11
			when 'Q'; 12
			when 'K'; 13
			else return c[0].to_i
		end
		return case c[1]
			when 'h'; value
			when 'd'; value+13
			when 'c'; value+13*2
			when 's'; value+13*3
		end
	end
	
end

class Fixnum
	include PlayingCards
end


#cards = (1..52).sort_by{rand}
#puts cards.collect{|card| card.card_name}
#puts "\nYou've got card! It is the #{cards.pop.card_name}."
