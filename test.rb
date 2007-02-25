#!/usr/local/bin/ruby
require 'test/unit'
require 'pokerbot'
require 'hand'

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
      @p.infos.position = 4
      @p.nb_players = 10
      rv = []
      0.upto(9) { |i|
         @p.button = i
         rv << @p.position_value
         }
      assert(rv.join=="6789012345")
   end
   
   def test_suite
      h1 = Hand.new(['9s', 'Ts', 'Js', 'Qd', 'Ks', 'Td', 'Qh'])
      assert(h1.evaluate == 5)
      h1 = Hand.new(['5s', 'Ts', 'Js', 'Qd', 'Ks', 'Ad'])
      assert(h1.evaluate == 5)
   end
   
end
