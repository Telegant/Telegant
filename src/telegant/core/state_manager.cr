module Telegant 
  class DialogState
    property dialog_id : String
    property step : String
    property data : Hash(String, String)
    property last_update_id : Int64
    
    def initialize(@dialog_id, @step, @data = {} of String => String, @last_update_id = 0_i64)
    end
  end
   
  class StateManager
    property states : Hash(Int64, DialogState)
    
    def initialize
      @states = {} of Int64 => DialogState
    end
    
    def get_state(user_id : Int64) : DialogState?
      states[user_id]?
    end
    
    def set_state(user_id : Int64, dialog_id : String, step : String, data = {} of String => String, update_id : Int64 = 0_i64)
      states[user_id] = DialogState.new(dialog_id, step, data, update_id)
    end
    
    def clear_state(user_id : Int64)
      states.delete(user_id)
    end
    
    def update_data(user_id : Int64, new_data : Hash(String, String))
      if state = get_state(user_id)
        new_data.each do |key, value|
          state.data[key] = value
        end
      end
    end
  end
end 