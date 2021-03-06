require 'net/http'
require 'line/bot'

class KamigoController < ApplicationController
	protect_from_forgery with: :null_session

	def webhook
		#Learning message
		reply_text = learn(channel_id, received_text)

		#Adjusting reply message
		reply_text = keyword_reply(channel_id, 0received_text) if reply_text.nil?

		#echo
		reply_text = echo2(channel_id, received_text) if reply_text.nil?

		#save the conversation
		save_to_received(channel_id, received_text)
		save_to_reply(channel_id,reply_text)

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
			config.channel_secret = ''
			config.channel_token = ''
		}
	end

	#retrieving message
	def received_text
		message = params['events'][0]['message']
		if message.nil?
			nil
		else
			message['text']
		end
		#message['text'] unless message.nil?
	end

	#Learning message function
	def learn(channel_id, received_text)
		#if it is not learn, exit
		return nil unless received_text[0..5] == 'learn;' 

		received_text = received_text[6..-1]
		semicolon_index = received_text.index(';')

		#if no semicolon, exit
		return nil if semicolon_index.nil?

		keyword = received_text[0..semicolon_index-1]
		message = received_text[semicolon_index+1..-1]

		KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
		'Got it!'
	end

	#reply keyword's message
	def keyword_reply(channel_id, received_text)
		message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message 
		return message unless message.nil?
		KeywordMapping.where(keyword: received_text).last&message
	end

	#reply message
	def reply_to_line(reply_text)
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

	#channel_id
	def channel_id
		source = params['events'][0]['source']
		return source['groupId'] || source['roomId'] || source['userId']
	end

	#save conversation
	def save_to_received(channel_id, received_text)
		return if received_text.nil?
		Received.create(channel_id: channel_id, text: received_text)
	end

	#save reply
	def save_to_reply(channel_id, reply_text)
		return if reply_text.nil?
		Reply.create(channel_id: channel_id, text: reply_text)
	end

	#echo
	def echo2(channel_id, received_text)
		#if channel_id does not have previous received text, ignore
		recent_received_texts = Received.where(channel_id: channel_id).last(5)&.pluck(:text)
		return nil unless received_text.in? recent_received_texts

		#if bot already reply the received_text, ignore
		last_reply_text = Reply.where(channel_id: channel_id).last&.text
		return nil if last_reply_text == received_text

		received_text
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

end
