#!/usr/local/bin/ruby
require 'pokerbot'
require 'hand'

p = PokerBot.new('test')
#p.hole_cards = [['A','s'],['K','s']]
#p.calculate_starting_hand

p.infos.position = 4
p.nb_players = 10
0.upto(9) { |i|
   p.button = i
   puts p.position_value
   }
   
   
h1 = Hand.new(['As','3h','4h','6d','8s'])
h2 = Hand.new(['As','3h','4h','6d','8s'])
puts h1.compare(h2)
