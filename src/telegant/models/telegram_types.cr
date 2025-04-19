module Telegant 
  class User
    include JSON::Serializable
    
    getter id : Int64
    getter is_bot : Bool
    getter first_name : String
    getter last_name : String?
    getter username : String?
    getter language_code : String?
    
    def to_s(io : IO)
      last_name_str = last_name ? " " + last_name.not_nil! : ""
      username_str = username || "N/A"
      io << "User(id: #{id}, name: #{first_name}#{last_name_str}, username: #{username_str})"
    end
  end

  class Chat
    include JSON::Serializable
    
    getter id : Int64
    getter type : String
    getter title : String?
    getter username : String?
    getter first_name : String?
    getter last_name : String?
    
    def to_s(io : IO)
      name = if title
               "\"#{title}\""
             elsif first_name
               last_name_str = last_name ? " " + last_name.not_nil! : ""
               "#{first_name}#{last_name_str}"
             else
               "Unknown"
             end
      io << "Chat(id: #{id}, type: #{type}, name: #{name})"
    end
  end

  class Message
    include JSON::Serializable
    
    getter message_id : Int32
    getter from : User?
    getter chat : Chat
    getter date : Int64
    getter text : String?
    getter reply_to_message : Message?
    
    def to_s(io : IO)
      text_display = text || "[no text]"
      from_display = from || "N/A"
      io << "Message(id: #{message_id}, text: \"#{text_display}\", from: #{from_display}, chat: #{chat})"
    end
     
    def to_s_short
      text_display = if txt = text
        txt.size > 20 ? txt[0..20] + "..." : txt
      else
        "[no text]"
      end
      "Message(id: #{message_id}, text: \"#{text_display}\")"
    end
  end

  class CallbackQuery
    include JSON::Serializable
    
    getter id : String
    getter from : User
    getter message : Message?
    getter data : String?
    getter chat_instance : String?
    
    def to_s(io : IO)
      data_display = data || "[no data]"
      message_display = message.try &.to_s_short || "N/A"
      io << "CallbackQuery(id: #{id}, data: \"#{data_display}\", from: #{from}, message: #{message_display})"
    end
  end

  class Update
    include JSON::Serializable
    
    getter update_id : Int64
    getter message : Message?
    getter edited_message : Message?
    getter callback_query : CallbackQuery?
    
    def to_s(io : IO)
      io << "Update(id: #{update_id})\n"
      io << "  message: #{message || "nil"}\n" 
      io << "  edited_message: #{edited_message || "nil"}\n"
      io << "  callback_query: #{callback_query || "nil"}"
    end
  end
end 