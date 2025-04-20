require "./handler"

module Telegant
  class MessageHandler < Handler
    property pattern : Regex
    def initialize(@pattern : Regex, @callback : Proc(Update, Context, Nil)); end
  
    def match(update : Update) : Bool
      if message = update.message
        if text = message.text
          !!(pattern =~ text)
        else
          false
        end
      else
        false
      end
    end
  end
end 