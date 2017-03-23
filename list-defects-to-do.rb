require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'
require 'json'

Dotenv.load

trello_api_key, trello_app_token               = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')
trello_board_id, to_do_list_id, defect_label_id = ENV.fetch('CLOUD_BOARD_ID'), ENV.fetch('TO_DO_LIST_ID'), ENV.fetch("DEFECT_LABEL_ID")

unless trello_api_key && trello_app_token && trello_board_id
  puts "Usage: #{__FILE__}"
  exit 1
end

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

board = Trello::Board.find(trello_board_id)

defect_label = board.labels.select {|l| l.id == defect_label_id }.first

to_do_cards = board.lists.select {|l| l.id == to_do_list_id}.first.cards

defect_cards = to_do_cards.select {|c| c.labels.include? defect_label }

puts "Trello Defects Still To Do - Sorted By Ascending Creation Date:\n\n"

defect_cards.sort! {|a,b| a.created_at <=> b.created_at}

puts "Creation Date\tDescription\tTrello Board Link"

defect_cards.each do |card|
  puts "#{card.created_at.strftime('%F')}\t#{card.name}\t#{card.short_url}"
end
