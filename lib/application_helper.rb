class ApplicationHelper
  class << self
    def fetch_config(file)
	  YAML.load(File.read(File.join(File.expand_path('..', __FILE__), '../config', "#{file}.yml")))
    end

    def response(message, keyboard = nil)
      { message: message, keyboard: keyboard }
    end

    def response_with_error(message)
      { message: message, error: true }
    end

    def actions_keyboard(list)
      (list |= ['stop']).map do |name|
  	    name.gsub('_', ' ').capitalize
  	  end
    end
  end
end