require 'net/http'
require 'date'
require 'uri'
require 'openssl'
require 'base64'
require 'json'

class Telegraph

	KEY_PUBLIC = '1712a4f0-1703-42d7-9121-de880ffc7db6'
	KEY_PRIVATE = 'c89056cb-8e27-4732-a3a1-a07f9453e835'

	def send_public (endpoint)
		Net::HTTP.get('data.btcchina.com', endpoint)
	end

	def send_private (method, params)
		request = Net::HTTP.new('10.0.1.2', 3000)
		request.local_host = '10.0.1.2'

		json = JSON.generate({
			:method => method,
			:params => params
		})

		raw = request.post2('/', json, {'Content-Type' => 'application/json'}).body

		JSON.parse(raw)['result']
	end

end