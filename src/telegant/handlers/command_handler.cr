require "./handler"

module Telegant
  class CommandHandler < Handler
    property command : String
    def initialize(@command : String, @callback : Proc(Update, Context, Nil)); end

    def match(update : Update) : Bool
      if message = update.message
        if text = message.text
          text.starts_with?("/" + command)
        else
          false
        end
      else
        false
      end
    end
     
    def extract_args(text : String) : String
      text.sub(/^\/#{command}(@\w+)?/, "").strip
    end
  end
end 