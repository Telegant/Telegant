module Telegant 
  class Dispatcher
    property handlers : Array(Handler) = [] of Handler
    property middlewares : Array(MiddlewareHandler) = [] of MiddlewareHandler
    property handler_middlewares : Hash(Handler, Array(String)) = {} of Handler => Array(String)
    
    def register(handler)
      if handler.is_a?(MiddlewareHandler)
        insert_middleware(handler)
      else
        handlers << handler
      end
    end
    
    def apply_middlewares(handler, middleware_names : Array(String))
      handler_middlewares[handler] = middleware_names
    end
    
    private def insert_middleware(middleware)
      index = middlewares.bsearch_index { |m| m.priority > middleware.priority } || middlewares.size
      middlewares.insert(index, middleware)
    end
    
    def dispatch(update : Update, bot : Bot, client : HTTP::Client, state_manager : StateManager)
      ctx = Context.new(update, bot, client, state_manager)
       
      middlewares.each do |middleware|
        next unless middleware.name == "global"
        result = middleware.call(update, ctx)
        if !result
          return 
        end
        break if ctx.skip_next_handlers
      end
      
      return if ctx.skip_next_handlers
      
      handlers.each do |h|
        if h.match(update)
          if middleware_names = handler_middlewares[h]?
            should_proceed = true
            
            middlewares.each do |middleware|
              next unless middleware_names.includes?(middleware.name)
              result = middleware.call(update, ctx)
              if !result
                should_proceed = false
                break
              end
            end
            
            next unless should_proceed
          end
          
          h.call(update, ctx)
          break if ctx.skip_next_handlers
        end
      end
    end
  end
end 