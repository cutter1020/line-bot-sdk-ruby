require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'mqtt'
require 'rubygems'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = "U97f1978ea01a7f94867501b8a66b6038"
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  request.body.rewind
  body = request.body.read
  json_body = JSON.parse(body)

  if json_body['ESP']
    message = {
        type: 'text',
        text: json_body['ESP']
      }
      client.push_message("C198376a20d27dd67f2e128560bcebf4d", message)
  else
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          #client.reply_message(event['replyToken'], message)
          #client.push_message("U97f1978ea01a7f94867501b8a66b6038", message)
          #client
         # Publish example
          MQTT::Client.connect('broker.emqx.io') do |c|
            c.publish('cuRRenTtranSformeR', event.message['text'])
            c.publish('cuRRenTtranSformeR', event.source['type'])
          end
        end
      end
    end
  end
  #signature = request.env['HTTP_X_LINE_SIGNATURE']
  #unless client.validate_signature(body, signature)
  #  halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
  #end
  
  #events = client.parse_events_from(body)
  "OK"
end
