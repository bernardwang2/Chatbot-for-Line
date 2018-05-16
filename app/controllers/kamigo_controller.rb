require 'net/http'
require 'line/bot'

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
		#Line Bot API Initialization
		client = Line::Bot::Client.new{ |config|
			config.channel_secret = '23ae7df34e8bc0cd2e34c2db1b900358'
			config.channel_token = 'P31wHaPvRDyDJat4VwEfNr8alFp6CSjBiHuaDPgdcG2bO/CZYIwzMjF8L1vCGaLsY9+4zmJomgZdVl1372N9MDx00+8v9cGLsp/fQvsDYGTUfnPrpaoTA4oPyh88s89oJvqZEaNJQc19E/3CL9PKFQdB04t89/1O/w1cDnyilFU='
		}

		#retrieving reply token
		reply_token = params['events'][0]['replyToken']
		#retrieve reply
		message = {
			type: 'text',
			text: '那個 Please'
		}

		#Sending message
		response = client.reply_message(reply_token, message)
		
		#200
		head :ok
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
