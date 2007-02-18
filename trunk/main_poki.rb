#!/usr/local/bin/ruby
require 'pokiclient'
require 'pokerbot'

bot = PokerBot.new('MPokerBot')
p = PokiClient.new(bot)
p.connect
p.login
p.read
