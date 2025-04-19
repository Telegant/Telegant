module Telegant 
  class Bot
    property token : String
    property client : HTTP::Client
    property dispatcher : Dispatcher
    property state_manager : StateManager
     
    class_property instance : Bot?
     
    HANDLER_REGISTRY = {
      "Hears" => {
        class_name: "MessageHandler", 
        regex_pattern: true,
        supports_dialog: true
      },
      "Command" => {
        class_name: "CommandHandler", 
        regex_pattern: false,
        supports_dialog: true
      },
      "CallbackQuery" => {
        class_name: "CallbackQueryHandler", 
        regex_pattern: true,
        supports_dialog: true
      } 
    }

    def initialize(@token : String)
      @client = HTTP::Client.new("api.telegram.org", tls: true)
      @dispatcher = Dispatcher.new
      @state_manager = StateManager.new
      Bot.instance = self
      register_handlers
    end
     
    macro register_handlers
      {% for method in @type.methods %}
        {% apply_middleware_ann = method.annotation(ApplyMiddleware) %}
        {% dialog_ann = method.annotation(Dialog) %}
        {% step_ann = method.annotation(Step) %}
        {% middleware_ann = method.annotation(Middleware) %}
         
        {% if middleware_ann %}
          {% priority = middleware_ann.args[0] %}
          {% name = middleware_ann.args[1] || "global" %}
          
          dispatcher.register ::Telegant::MiddlewareHandler.new(
            {{priority}},
            {{name}},
            ->(update : Update, bot : Context) { result = {{method.name}}(update, bot); result.is_a?(Bool) ? result : true }
          )
        {% else %}
          {% is_dialog = dialog_ann && step_ann %}
          {% dialog_id = dialog_ann ? dialog_ann.args[0] : nil %}
          {% step_id = step_ann ? step_ann.args[0] : nil %}
          {% handler_registered = false %}
           
          {% for handler_type, config in HANDLER_REGISTRY %}
            {% if method.annotations.any? { |a| a.name.stringify == handler_type } %}
              {% handler_registered = true %}
              {% class_name = config[:class_name] %}
              {% regex_pattern = config[:regex_pattern] %}
              {% supports_dialog = config[:supports_dialog] %}
               
              {% if is_dialog && !supports_dialog %}
                {% next %}
              {% end %}
               
              {% for ann in method.annotations %}
                {% if ann.name.stringify == handler_type %}
                  {% for arg in ann.args %}
                    {% if is_dialog %} 
                      %inner_handler = ::Telegant::{{class_name.id}}.new(
                        {% if regex_pattern %}
                          Regex.new("^#{{{arg}}}$"),
                        {% else %}
                          {{arg}},
                        {% end %}
                        ->(update : Update, bot : Context) { nil }
                      )
                       
                      %handler = ::Telegant::DialogHandler.new(
                        {{dialog_id}},
                        {{step_id}},
                        ->(update : Update, bot : Context) { {{method.name}}(update, bot); nil },
                        %inner_handler
                      )
                    {% else %} 
                      %handler = ::Telegant::{{class_name.id}}.new(
                        {% if regex_pattern %}
                          Regex.new("^#{{{arg}}}$"),
                        {% else %}
                          {{arg}},
                        {% end %}
                        ->(update : Update, bot : Context) { {{method.name}}(update, bot); nil }
                      )
                    {% end %}
                     
                    dispatcher.register(%handler)
                    
                    # Apply middleware if needed
                    {% if apply_middleware_ann %}
                      dispatcher.apply_middlewares(%handler, [{{apply_middleware_ann.args.splat}}])
                    {% end %}
                  {% end %}
                {% end %}
              {% end %}
            {% end %}
          {% end %}
           
          {% if is_dialog && !handler_registered %}
            %handler = ::Telegant::DialogHandler.new(
              {{dialog_id}},
              {{step_id}},
              ->(update : Update, bot : Context) { {{method.name}}(update, bot); nil }
            )
            
            dispatcher.register(%handler)
            
            {% if apply_middleware_ann %}
              dispatcher.apply_middlewares(%handler, [{{apply_middleware_ann.args.splat}}])
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    def api_request(method : String, payload : Hash(String, JSONType)) : JSON::Any
      res = client.post("/bot#{token}/#{method}",
                        headers: HTTP::Headers{"Content-Type" => "application/json"},
                        body: payload.to_json)
      JSON.parse(res.body)
    end

    def start(offset : Int64 = 0_i64, timeout : Int64 = 30_i64)
      loop do
        begin
          response = api_request("getUpdates", {"offset" => offset, "timeout" => timeout} of String => JSONType)
          if response["result"]?
            response["result"].as_a.each do |upd|
              update = Update.from_json(upd.to_json)
              dispatcher.dispatch(update, self, client, state_manager)
              offset = update.update_id + 1
            end
          else
            puts "Error: Response missing 'result' key: #{response}"
          end
        rescue e
          puts "Error: #{e.message}"
          sleep(5.seconds)
        end
      end
    end
  end
end 