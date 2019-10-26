class MessageHandler

  GENERAL_ACTIONS = %w(stop)

  def initialize(message)
  	@message = message
    @session = fetch_session
  	@action  = fetch_action  	
  end

  def perform
    unless @session['allow'].include?(@action) || GENERAL_ACTIONS.include?(@action)
      BOT_CACHE.del(BOT_SESSION_CACHE_KEY)
      return ApplicationHelper.response('Undefined action !', ApplicationHelper.actions_keyboard(['start']))
    end

    action_class  = ACTIONS[@action.to_sym][:class_name]
    action_method = ACTIONS[@action.to_sym][:method_name]
    action_allow  = ACTIONS[@action.to_sym][:allow]
    action_expect = ACTIONS[@action.to_sym][:expect]

    result = action_class.constantize.new(@message, @session).public_send(action_method.to_sym)

    if result[:error] || action_allow.blank?
      BOT_CACHE.del(BOT_SESSION_CACHE_KEY)
      return result.slice(:message, :keyboard)
    end
    
    @session['allow'] = action_allow
    @session['expect'] = action_expect
    @session.merge!(result[:session]) unless result[:session].blank?
  
    BOT_CACHE.setex(BOT_SESSION_CACHE_KEY, 3600, ActiveSupport::JSON.encode(@session))

    return result.slice(:message, :keyboard)
  rescue
  	BOT_CACHE.del(BOT_SESSION_CACHE_KEY)
    return ApplicationHelper.response('Something went wrong!', ApplicationHelper.actions_keyboard(['start']))
  end

  private 

  def fetch_session
    if BOT_CACHE.exists(BOT_SESSION_CACHE_KEY)
      ActiveSupport::JSON.decode (BOT_CACHE.get(BOT_SESSION_CACHE_KEY))
    else
      {'allow' => ['start'], 'expect' => nil}
    end
  end

  def fetch_action
    message_text = @message.text.to_s.downcase.gsub(/[^0-9a-z\s]/i, '').strip.gsub(/\s/, '_')
  	(@session['allow'].include?(message_text) || GENERAL_ACTIONS.include?(message_text)) && message_text || @session['expect']
  end
end
