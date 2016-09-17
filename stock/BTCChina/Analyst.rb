require 'bigdecimal'
require_relative 'Book'

class Analyst

	GOOD_AMOUNT = BigDecimal.new('4')
	MIN_FAR = BigDecimal.new('0.999')
	MAX_FAR = BigDecimal.new('1.001')
	SUPPORT_STEP = BigDecimal.new('0.01')
	BTC_COE = BigDecimal.new('4000')

	attr_accessor :book, :supported, :good_position

	def initialize (broker)
		@broker = broker
	end

	def make_analytics
		analytics_book_data
		analytics_supported
		analytics_good_position
	end

	def order_supported?
		!!@supported
	end

	def good_position?
		!!@good_position
	end

	private

	def analytics_book_data
		raw_book = @broker.book

		book_parser = Book.new
		@book = book_parser.parse raw_book

		edge_ask = @book[:asks].last
		edge_bid = @book[:bids].first

		@book[:asks] = filter @book[:asks], edge_ask, MAX_FAR
		@book[:bids] = filter @book[:bids], edge_bid, MIN_FAR
	end

	def filter (glass, edge, far)
		filter_far(filter_good(glass), edge, far)
	end

	def filter_good (glass)
		glass.select { |value|
			value[:amount] > GOOD_AMOUNT
		}
	end

	def filter_far (glass, edge, far)
		edge_far = edge[:price] * far

		glass.select { |value|
			price = value[:price]

			if far > BigDecimal.new(1)
				price <= edge_far
			else
				price >= edge_far
			end
		}
	end

	def analytics_supported
		return unless @broker.order?

		order_price = @broker.order[:price]
		step = SUPPORT_STEP

		@supported = false

		book[:asks].each { |order|
			price = order[:price]

			if price - step == order_price
				@supported = true
				break
			end
		}

		book[:bids].each { |order|
			price = order[:price]

			if price + step == order_price
				@supported = true
				break
			end
		}
	end

	def analytics_good_position
		return if @broker.order?

		money = @broker.money
		cny = money[:cny]
		btc = money[:btc]
		btc_eq = btc * BTC_COE

		if btc_eq > cny
			order = @book[:asks].last

			if order
				@good_position = {
					:type => :ask,
					:price => order[:price] - SUPPORT_STEP
				}
			end
		else
			order = @book[:bids].first

			if order
				@good_position = {
					:type => :bid,
					:price => order[:price] + SUPPORT_STEP
				}
			end
		end

	end

end