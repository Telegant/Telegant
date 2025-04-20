require "./handler"

module Telegant
  class MiddlewareHandler
    property priority : Int32
    property name : String
    property callback : Proc(Update, Context, Bool)
    
    def initialize(@priority : Int32, @name : String, @callback : Proc(Update, Context, Bool)); end
    
    def match(update : Update) : Bool
      true
    end
    
    def call(update : Update, ctx : Context) : Bool
      @callback.call(update, ctx)
    end
  end
end 