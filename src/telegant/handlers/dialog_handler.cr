require "./handler"

module Telegant
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
end 