require 'PokerBot'

p = PokerBot.new('test')
#p.hole_cards = [['A','s'],['K','s']]
#p.calculate_starting_hand

p.position = 4
p.nb_players = 10
0.upto(9) { |i|
   p.button = i
   puts p.position_value
   }