class TelegramBot

  TELEGRAM_API = 'https://api.telegram.org'

  class << self
    def run
  	  Telegram::Bot::Client.run(BOT_CONFIG[:token]) do |bot|
	    bot.listen do |message|
	      if BOT_CONFIG[:whitelist].include?(message.from.id.to_s)
	        response = MessageHandler.new(message).perform

            reply_markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Stop'], resize_keyboard: true)
            text = 'Something went wrong!'

            unless response[:message].blank?
              text = response[:message]
            end

            unless response[:keyboard].blank?
          	  reply_markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: response[:keyboard], resize_keyboard: true)
            end

	        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: reply_markup)
	      else
	        bot.api.send_message(chat_id: message.chat.id, text: 'Access denied!')
	      end
	    end
	  end
    end

    def get_file_url(file_id)
      response = Faraday.new(url: TELEGRAM_API).get("/bot#{BOT_CONFIG[:token]}/getFile?file_id=#{file_id}")
      file_url = nil

      if response.success?
      	file_path = ActiveSupport::JSON.decode(response.body).dig('result', 'file_path')
      	file_url = "#{TELEGRAM_API}/file/bot#{BOT_CONFIG[:token]}/#{file_path}"
      end
      
      return file_url
    end
  end
end
