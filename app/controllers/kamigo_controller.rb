require 'net/http'

class KamigoController < ApplicationController
	protect_from_forgery with: :null_session

	def eat
		render plain: "good good"
	end

	def request_headers
		render plain: request.headers.to_h.reject{ |key,vale|
			key.include? '.'
		}.map{ |key, value|
			"#{key}: #{value}"
		}.sort.join("\n")
	end

	def request_body
		render plain: request.body
	end

	def response_headers
		response.headers['5566'] = 'QQ'
		render plain: response.headers.to_h.map{ |key, value|
			"#{key}: #{value}"
		}.sort.join("\n")
	end

	def show_response_body
		puts "===Before Response.body:#{response.body}==="
		render plain: "hahahahaha"
		puts "===After Response.body:#{response.body}==="
	end

	def webhook
		render plain: params
	end

	def sent_request
		uri = URI('http://localhost:3000/kamigo/response_body')
		http = Net::HTTP.new(uri.host, uri.port)
		http_request = Net::HTTP::Get.new(uri)
		http_response = http.request(http_request)

		render plain: JSON.pretty_generate({
			request_class: request.class,
			response_class: response.class,
			http_request_class: http_request.class,
			http_response_class: http_response.class
		})
	end

	def translate_to_korean(message)
		"#{message}油~"
	end
end
