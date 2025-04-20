module Telegant 
  abstract class Handler
    getter callback : Proc(Update, Context, Nil)
    def initialize(@callback : Proc(Update, Context, Nil)); end
    abstract def match(update : Update) : Bool
    def call(update : Update, ctx : Context)
      @callback.call(update, ctx)
      nil
    end
  end
 
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
   
  class DialogHandler < Handler
    property dialog_id : String
    property step : String
    property inner_handler : Handler?
    
    def initialize(@dialog_id : String, @step : String, @callback : Proc(Update, Context, Nil), @inner_handler = nil); end
    
    def match(update : Update) : Bool 
      user_id = if msg = update.message
        msg.from.try &.id
      elsif query = update.callback_query
        query.from.id
      else
        nil
      end
      
      return false unless user_id
       
      if msg = update.message
        if text = msg.text
          return false if text.starts_with?("/") && @inner_handler.nil?
        end
      end
       
      if state_manager = Bot.instance.try &.state_manager
        if state = state_manager.get_state(user_id) 
          return false if state.last_update_id == update.update_id
          
          dialog_state_matches = state.dialog_id == dialog_id && state.step == step
           
          if dialog_state_matches && inner_handler
            return inner_handler.not_nil!.match(update)
          end
          
          return dialog_state_matches
        end
      end
      
      false
    end
  end
  
  class MiddlewareHandler
    property priority : Int32
    property name : String
    property callback : Proc(Update, Context, Bool)
    
    def initialize(@priority : Int32, @name : String, @callback : Proc(Update, Context, Bool)); end
    
    def match(update : Update) : Bool
      true
    end
    
    def call(update : Update, ctx : Context) : Bool
      @callback.call(update, ctx)
    end
  end
end 