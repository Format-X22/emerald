require_relative 'Analyst'
require_relative 'Broker'

class Trader

	TRADE_INTERVAL = 1

	def initialize
		@broker = Broker.new
		@analyst = Analyst.new @broker
		trade_loop
	end

	def trade_loop
		trade
		sleep TRADE_INTERVAL
		trade_loop
	end

	def trade
		@broker.clean
		@analyst.make_analytics

		if @broker.order?
			unless @analyst.order_supported?
				@broker.remove_order
			end
		else
			if @analyst.good_position?
				@broker.set_order @analyst.good_position
			end
		end
	end

end