class PoltergeistManager
  def initialize(message, session)
  	@session = session
    @message = message
  end

  def start
  	keyboard = ApplicationHelper.actions_keyboard(%w(torrent))
  	message = 'Select action.'

  	ApplicationHelper.response(message, keyboard)
  end

  def stop
  	ApplicationHelper.response('OK', ApplicationHelper.actions_keyboard(%w(start)))
  end
end