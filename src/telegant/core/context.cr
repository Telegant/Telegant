module Telegant 
  class Context
    getter update : Update
    getter bot : Bot
    getter client : HTTP::Client
    getter state_manager : StateManager
    property skip_next_handlers : Bool = false
    
    def initialize(@update : Update, @bot : Bot, @client : HTTP::Client, @state_manager : StateManager)
    end
     
    def current_dialog
      user_id = from_id
      return nil unless user_id
      state_manager.get_state(user_id)
    end
    
    def start_dialog(dialog_id : String, step : String, data = {} of String => String)
      user_id = from_id
      return unless user_id
      state_manager.set_state(user_id, dialog_id, step, data, update.update_id)
    end
    
    def next_step(step : String)
      user_id = from_id
      return unless user_id
      if state = current_dialog
        state_manager.set_state(user_id, state.dialog_id, step, state.data, update.update_id)
      end
    end
    
    def end_dialog
      user_id = from_id
      return unless user_id
      state_manager.clear_state(user_id)
    end
    
    def set_dialog_data(key : String, value : String)
      user_id = from_id
      return unless user_id
      if state = current_dialog
        state.data[key] = value
      end
    end
    
    def get_dialog_data(key : String) : String?
      if state = current_dialog
        state.data[key]?
      else
        nil
      end
    end
    
    def skip_remaining_handlers
      @skip_next_handlers = true
    end
     
    def message
      update.message
    end
    
    def message_text
      message.try &.text
    end
    
    def callback_query
      update.callback_query
    end
    
    def callback_data
      callback_query.try &.data
    end
    
    def chat_id
      if msg = message
        return msg.chat.id
      elsif query = callback_query
        if msg = query.message
          return msg.chat.id
        end
      end
      nil
    end
    
    def message_id
      message.try &.message_id
    end
    
    def from_id
      if msg = message
        return msg.from.try &.id
      elsif query = callback_query
        return query.from.id
      end
      nil
    end
    
    def from_username
      if msg = message
        return msg.from.try &.username
      elsif query = callback_query
        return query.from.username
      end
      nil
    end
     
    def send_message(chat_id : Int64 | String, text : String,
                    parse_mode : String? = nil,
                    reply_markup : String? = nil) : JSON::Any
      bot.api_request("sendMessage", {
        "chat_id" => chat_id, 
        "text" => text,
        "parse_mode" => parse_mode,
        "reply_markup" => reply_markup
      }.compact)
    end

    def answer_callback_query(callback_query_id : String, text : String? = nil) : JSON::Any
      bot.api_request("answerCallbackQuery", {
        "callback_query_id" => callback_query_id,
        "text" => text
      }.compact)
    end

    def edit_message_text(chat_id : Int64 | String, message_id : Int32, text : String,
                         parse_mode : String? = nil,
                         reply_markup : String? = nil) : JSON::Any
      bot.api_request("editMessageText", {
        "chat_id" => chat_id, 
        "message_id" => message_id, 
        "text" => text,
        "parse_mode" => parse_mode,
        "reply_markup" => reply_markup
      }.compact)
    end
    
    def send_photo(chat_id : Int64 | String, photo : String,
                  caption : String? = nil,
                  parse_mode : String? = nil,
                  reply_markup : String? = nil) : JSON::Any
      bot.api_request("sendPhoto", {
        "chat_id" => chat_id, 
        "photo" => photo,
        "caption" => caption,
        "parse_mode" => parse_mode,
        "reply_markup" => reply_markup
      }.compact)
    end
     
    def send_photo(photo : String, caption : String? = nil, parse_mode : String? = nil, reply_markup : String? = nil)
      if id = chat_id
        send_photo(id, photo, caption, parse_mode, reply_markup)
      end
    end
    
    def send_document(chat_id : Int64 | String, document : String,
                     caption : String? = nil,
                     parse_mode : String? = nil,
                     reply_markup : String? = nil) : JSON::Any
      bot.api_request("sendDocument", {
        "chat_id" => chat_id, 
        "document" => document,
        "caption" => caption,
        "parse_mode" => parse_mode,
        "reply_markup" => reply_markup
      }.compact)
    end
     
    def send_document(document : String, caption : String? = nil, parse_mode : String? = nil, reply_markup : String? = nil)
      if id = chat_id
        send_document(id, document, caption, parse_mode, reply_markup)
      end
    end
    
    def delete_message(chat_id : Int64 | String, message_id : Int32) : JSON::Any
      bot.api_request("deleteMessage", {
        "chat_id" => chat_id, 
        "message_id" => message_id
      })
    end
     
    def delete_message(message_id : Int32)
      if id = chat_id
        delete_message(id, message_id)
      end
    end
     
    def reply(text : String, parse_mode : String? = nil, reply_markup : String? = nil)
      if id = chat_id
        send_message(id, text, parse_mode, reply_markup)
      end
    end
    
    def answer_callback(text : String? = nil)
      if query = callback_query
        answer_callback_query(query.id, text)
      end
    end
    
    def edit_message(text : String, parse_mode : String? = nil, reply_markup : String? = nil)
      if id = chat_id
        if query = callback_query
          if msg = query.message
            edit_message_text(id, msg.message_id, text, parse_mode, reply_markup)
          end
        end
      end
    end
     
    def inline_keyboard_markup(buttons : Array(Array(Hash(String, String)))) : String
      markup = {"inline_keyboard" => buttons}
      markup.to_json
    end
 
    def inline_button(text : String, callback_data : String) : Hash(String, String)
      {"text" => text, "callback_data" => callback_data}
    end

    # Create a url button
    def url_button(text : String, url : String) : Hash(String, String)
      {"text" => text, "url" => url}
    end
     
    def api_request(method : String, payload : Hash(String, JSONType?)) : JSON::Any 
      cleaned_payload = {} of String => JSONType
      payload.each do |k, v|
        cleaned_payload[k] = v.as(JSONType) unless v.nil?
      end
      bot.api_request(method, cleaned_payload)
    end
  end
end 