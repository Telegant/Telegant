class UserModel
  include JSON::Serializable
  
  getter id : Int64
  getter is_bot : Bool
  getter first_name : String
  getter last_name : String?
  getter username : String?
  getter language_code : String?
end 