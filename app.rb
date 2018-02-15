# app.rb
require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = "2066bd9e1604a2beb7fc6c301fbbe205"
    config.channel_token = "v5PUQugKCRhUmBZ/fb9s6zG8b9se+CcgONjpz4syrS6vRvKdoGyEKFvc9ZijdCjZCdyVNQoRGRDzhClCUs7Bl+GxmasbKQzw0X/73xjUDN3r1Ei/uOPlhRWs0KiJELI56Hi8kk9tVVm8+CpSg57wMwdB04t89/1O/w1cDnyilFU="
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: "Hi Master, What do you mean by " + event.message['text']
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        wt = tf.write(response.body)
        client.reply_message(event['replyToken'], {type: 'text', text: "got it bro"})
      end
    end
  }

  "OK"
end
