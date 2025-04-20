require "./handler"

module Telegant
  class CallbackQueryHandler < Handler
    property data_pattern : Regex
    def initialize(@data_pattern : Regex, @callback : Proc(Update, Context, Nil)); end
    
    def match(update : Update) : Bool
      if query = update.callback_query
        if data = query.data
          !!(data =~ data_pattern)
        else
          false
        end
      else
        false
      end
    end    
  end
end 