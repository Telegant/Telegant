class Update
  include JSON::Serializable
  
  getter update_id : Int64
  getter message : MessageModel?
  getter edited_message : MessageModel?
  getter callback_query : CallbackQueryModel?
end 