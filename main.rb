require 'pokerbot'
require 'pokergame'

bot1 = PokerBot.new('BOT 0')
bot2 = PokerBot.new('BOT 1')

game = PokerGame.new
game.add_players(bot1,bot2)
game.start
