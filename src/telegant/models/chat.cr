class ChatModel
  include JSON::Serializable
  
  getter id : Int64
  getter type : String
  getter title : String?
  getter username : String?
  getter first_name : String?
  getter last_name : String?
end 