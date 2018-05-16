require 'net/http'
require 'line/bot'

class KamigoController < ApplicationController
	protect_from_forgery with: :null_session

	def webhook
		#Adjusting reply message
		reply_text = keyword_reply(received_text)

		#Sending message
		response = reply_to_line(reply_text)
		
		#200
		head :ok
	end

	#initializing Line Bot
	def line
		#if line is already initialized, return line. Otherwise initializing new one.
		return @line unless @line.nil?
		#Line Bot API Initialization
		@line = Line::Bot::Client.new{ |config|
			config.channel_secret = '23ae7df34e8bc0cd2e34c2db1b900358'
			config.channel_token = 'P31wHaPvRDyDJat4VwEfNr8alFp6CSjBiHuaDPgdcG2bO/CZYIwzMjF8L1vCGaLsY9+4zmJomgZdVl1372N9MDx00+8v9cGLsp/fQvsDYGTUfnPrpaoTA4oPyh88s89oJvqZEaNJQc19E/3CL9PKFQdB04t89/1O/w1cDnyilFU='
		}
	end

	#retrieving message
	def received_text
		params['events'][0]['message']
		if message.nil?
			nil
		else
			message['text']
		end
		#message['text'] unless message.nil?
	end

	#reply keyword's message
	def keyword_reply(received_text)
		keyword_mapping = {
			'QQ' => '神曲支援: https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s',
			'我難過' => '神曲支援: https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s'
		}

		#search for the keyword
		keyword_mapping[received_text]
	end

	#reply message
	def reply_to_line(message)
		return nil if reply_text.nil?
		
		#retrieving reply token
		reply_token = params['events'][0]['replyToken']
		#retrieve reply
		message = {
			type: 'text',
			text: reply_text
		}

		#sending reply
		line.reply_message(reply_token, message)
	end

	#testing
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
