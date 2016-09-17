require 'bigdecimal'

class Book

	def parse (value)
		value.gsub! /\{"asks":\[|\],|"date".*/, ''

		split = value.split '"bids":['

		{
			:asks => parse_glass(split[0]),
			:bids => parse_glass(split[1])
		}
	end

	def parse_glass (glass)
		result = []
		glass.gsub! /^\[|\]$/, ''

		glass.split('[').each do |raw_order|
			split = raw_order.split ','

			result.push({
				:price => BigDecimal.new(split[0]),
				:amount => BigDecimal.new(split[1])
			})
		end

		result
	end

end