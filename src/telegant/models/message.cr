class MessageModel
  include JSON::Serializable
  
  getter message_id : Int32
  getter from : UserModel?
  getter chat : ChatModel
  getter date : Int64
  getter text : String?
  getter reply_to_message : MessageModel?
end 