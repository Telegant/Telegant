class CallbackQueryModel
  include JSON::Serializable
  
  getter id : String
  getter from : UserModel
  getter message : MessageModel?
  getter data : String?
  getter chat_instance : String?
end 