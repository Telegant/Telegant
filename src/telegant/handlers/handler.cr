module Telegant 
  abstract class Handler
    getter callback : Proc(Update, Context, Nil)
    def initialize(@callback : Proc(Update, Context, Nil)); end
    abstract def match(update : Update) : Bool
    def call(update : Update, ctx : Context)
      @callback.call(update, ctx)
      nil
    end
  end
end 