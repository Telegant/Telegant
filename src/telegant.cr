require "http/client"
require "json"

require "./telegant/**"

annotation Hears; end
annotation Command; end
annotation CallbackQuery; end
annotation Dialog; end
annotation Step; end
annotation Middleware; end
annotation ApplyMiddleware; end

module Telegant
  alias JSONType = Nil | Bool | Int32 | Int64 | Float64 | String | Array(JSONType) | Hash(String, JSONType)
end 