#!/usr/local/bin/ruby
class Card
    include Comparable
    
    attr_reader :suit, :rank

    def initialize(code)
      @rank = code[0,1]
      @suit = code[1,2]
    end
    
    def rank_value
      return 14 if @rank == "A"
      return 13 if @rank == "K"
      return 12 if @rank == "Q"
      return 11 if @rank == "J"
      return 10 if @rank == "T"                  
      return @rank.to_i
    end
    
    def <=> (other)
      rank_value <=> other.rank_value
    end
end

class Hand

  attr_reader :cards
  
  def initialize(cards)
    @cards = cards.collect{|card|Card.new(card)}
    puts "new hand: #{cards.join(', ')}"
    @ranks = Hash.new(0)
    @suits = Hash.new(0)
    
    @cards.each do |card|
      @suits[card.suit] += 1
      @ranks[card.rank_value] += 1 
    end
  end
  
  def <=>(other)
      
  end
  
  def evaluate
    return 8 if @ranks.values.max == 4 # four kind
    return 7 if (@ranks.values.sort[-1] == 3 && @ranks.values.sort[-2] == 2) # full
    return 9 if (@suits.values.max == 5 && is_straight?) # str8 flush
    return 6 if @suits.values.max == 5 # flush
    return 5 if is_straight? # str8
    return 4 if @ranks.values.max == 3 # brelan
    return 3 if (@ranks.values.sort[-1] == 2 && @ranks.values.sort[-2] == 2) # 2 pair
    return 2 if @ranks.values.max == 2 # pair
    return 1 if @ranks.values.max == 1 # high card
    raise 'ooops'
  end 
  
  def is_straight?
    #sorted = @cards.sort_by{|card| card.rank_value}
    sorted = @cards.map{|e| e.rank_value}.sort.uniq
    sorted = handle_ace_special_case(sorted) # we loose the Ace
    all_ranks_different = (@ranks.values.max == 1)
    all_ranks_different && (sorted.last - sorted.first == 4)
  end
  
  private
  def handle_ace_special_case(array_of_sorted_cards)
    if (array_of_sorted_cards.last == 14 && array_of_sorted_cards.first.rank == 2) then
      array_of_sorted_cards[-1] = 6 #Card.new("6s") 
    end
    array_of_sorted_cards
  end
  
end

if __FILE__ == $0
   
h = Hand.new(['As','Ah'])
puts h.evaluate

end
