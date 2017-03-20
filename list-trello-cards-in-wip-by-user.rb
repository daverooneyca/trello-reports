require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'
require 'json'

WIP_LIST_ID = "57ff9e36f4f7ce41e9fe41f4"

Dotenv.load

trello_api_key, trello_app_token, trello_board_id = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN'), ENV.fetch('CLOUD_BOARD_ID')

unless trello_api_key && trello_app_token && trello_board_id 
  puts "Usage: TRELLO_KEY=<trello-key> TRELLO_TOKEN=<trello-token> #{__FILE__} <trello-board-id>"
  exit 1
end

puts "Trello Items In Progress by Person:"

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

board = Trello::Board.find(trello_board_id)

members = board.members

wip_members = []

wip_cards = board.lists.select {|l| l.id == WIP_LIST_ID}.first.cards

wip_cards.each do |card|
  wip_members << card.members.flatten if card.members.size > 0
end

wip_by_member = {}

members.each do |m|
  count = wip_members.count {|wm| wm.first.id == m.id }
  
  wip_by_member[m.username] = count if count > 0
end

wip_report = Hash[wip_by_member.sort_by{|k, v| v}.reverse]

wip_report.each_key do |k|
  puts "#{k} : #{wip_report[k]}"
end
