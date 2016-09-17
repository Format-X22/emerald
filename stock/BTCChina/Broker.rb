require 'bigdecimal'
require 'json'
require_relative 'Telegraph'

class Broker

	attr_accessor :book_data, :money_data, :order_data

	def initialize
		@telegraph = Telegraph.new
	end

	def clean
		@book_data = nil
		@money_data = nil
		@order_data = nil
	end

	def order
		raw = @telegraph.send_private 'getOrders', []

		return unless raw

		full = raw['order_btccny'][0]

		return unless full

		@order_data = {
			:id => full['id'],
			:price => full['price'],
			:amount => full['amount_original']
		}
	end

	def order?
		!!order
	end

	def set_order (config)
		type = config[:type]
		price = config[:price]
		btc = money[:btc]
		cny = money[:cny]

		puts '---', 'SET', type, price, btc, cny, '---'

		if type == :ask
			@telegraph.send_private 'sellOrder2', [price.to_f.to_s, (btc / BigDecimal.new(5)).floor(4).to_f.to_s]
		else
			@telegraph.send_private 'buyOrder2', [price.to_f.to_s, (cny / btc / BigDecimal.new(5)).floor(4).to_f.to_s]
		end
	end

	def remove_order
		puts '---', 'REMOVE', '---'

		@telegraph.send_private 'cancelOrder', [order[:id]]
	end

	def book
		unless @book_data
			@book_data = @telegraph.send_public '/data/orderbook'
		end

		@book_data
	end

	def money
		unless @money_data
			money_raw = @telegraph.send_private 'getAccountInfo', []
			balance = money_raw['balance']

			@money_data = {
				:cny => BigDecimal.new(balance['cny']['amount']),
				:btc => BigDecimal.new(balance['btc']['amount'])
			}
		end

		@money_data
	end

end