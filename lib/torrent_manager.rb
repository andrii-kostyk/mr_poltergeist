class TorrentManager
	
  def initialize(message, session)
  	@session = session
    @message = message
  end

  def actions
  	keyboard = ApplicationHelper.actions_keyboard(ACTIONS[:torrent][:allow])
  	message = 'Select action.'

  	ApplicationHelper.response(message, keyboard)
  end

  def login
  	response = request(:post, '/login', {
      body: {
      	username: SECRETS[:qbittorrent][:login],
      	password: SECRETS[:qbittorrent][:password],
      }
  	})

  	if response.try(:success?)
  	  cookie = response.headers['set-cookie'].to_s.split(';').fetch(0, '').split('=')
  	  BOT_CACHE.setex(TORRENT_TOKEN_CACHE_KEY, 3600, cookie[1].to_s)
  	  ApplicationHelper.response('Success!')
  	else
  	  ApplicationHelper.response_with_error('Something went wrong')
  	end
  end

  def list
  	response = request(:get, '/query/torrents', {
      token: "SID=#{get_token}"
    })

    torrent_list = ActiveSupport::JSON.decode(response.body) rescue []

    if torrent_list.blank?
      return ApplicationHelper.response_with_error('List empty.')
    end 

    torrent_list = ActiveSupport::JSON.decode(response.body)
    mapping = {}
    titles = []
    keys = []

    torrent_list.each_with_index do |item, item_index|
      current_index = item_index + 1
      size = (item['size'].to_f / (1024.0 * 1024.0 * 1024)).round(2)
      progress = (item['progress'].to_f * 100).round(1)
      eta = Time.at(item['eta']).utc.strftime('%Hh %Mm')
      speed = (item['dlspeed'].to_f / (1024.0 * 1024.0)).round(2)

      titles << "#{item['name']} \n Index: #{current_index} \n Size: #{size} GB \n Speed: #{speed} Mib/s \n Done: #{progress} % \n Status: #{item['state']} \n ETA: #{eta}"
      keys << "Select [#{current_index}]"
      mapping["item_#{current_index}"] = item['hash']
    end

  	{ 
  	  message: titles.join("\n \n"), 
  	  keyboard: ApplicationHelper.actions_keyboard(['list_torrent'] + keys), 
  	  session: {'torrent_list' => mapping }
  	}
  end

  def details
    index = @message.text.to_s.gsub(/[^0-9]/i, '')
    hash = @session.dig('torrent_list', "item_#{index}")

    if hash.blank?
      ApplicationHelper.response_with_error('Undefined index!')
    end

  	{ 
  	  keyboard: ApplicationHelper.actions_keyboard(ACTIONS[:torrent_details][:allow]),
  	  session: {'current_torrent_item' => hash },
  	  message: 'Select command.'
  	}
  end

  def pause
    hash = @session['current_torrent_item']

    if hash.blank?
      ApplicationHelper.response_with_error('Undefined hash!')
    end

  	response = request(:post, '/command/pause', {
      token: "SID=#{get_token}",
      body: {
      	hash: hash
      }
    })

    ApplicationHelper.response('Success!')
  end

  def resume
    hash = @session['current_torrent_item']

    if hash.blank?
      ApplicationHelper.response_with_error('Undefined hash!')
    end

  	response = request(:post, '/command/resume', {
      token: "SID=#{get_token}",
      body: {
      	hash: hash
      }
    })

    ApplicationHelper.response('Success!')
  end

  def delete_from_list
    hash = @session['current_torrent_item']

    if hash.blank?
      ApplicationHelper.response_with_error('Undefined hash!')
    end

  	response = request(:post, '/command/delete', {
      token: "SID=#{get_token}",
      body: {
      	hashes: hash
      }
    })

    ApplicationHelper.response('Success!')
  end

  def delete_with_data
    hash = @session['current_torrent_item']

    if hash.blank?
      ApplicationHelper.response_with_error('Undefined hash!')
    end

  	response = request(:post, '/command/deletePerm', {
      token: "SID=#{get_token}",
      body: {
      	hashes: hash
      }
    })

    ApplicationHelper.response('Success!')
  end

  def add
  	keyboard = ApplicationHelper.actions_keyboard(ACTIONS[:add_torrent][:allow])
  	message = 'Select type.'

  	ApplicationHelper.response(message, keyboard)
  end

  def by_file
  	ApplicationHelper.response('Select file.')
  end

  def download_file
  	unless @message[:document].try(:[], :mime_type) == 'application/x-bittorrent'
  	  return ApplicationHelper.response_with_error('Wrong file type.')
  	end

    file_id = @message.document.file_id
    file_name = @message.document.file_name
    file_url = TelegramBot.get_file_url(file_id)

    open("#{GENERAL[:qbittorrent][:autoload_path]}/#{file_name}", 'wb') do |file|
      file << open(file_url).read
    end

  	ApplicationHelper.response('Success!')
  end

  private

  def request(http_method, action, params)
    Faraday.new(url: GENERAL[:qbittorrent][:server]).public_send(http_method) do |req|
      req.url(action)

      unless params[:inline].blank?
        params[:inline].each do |item|
          req.params[item[:key]] = item[:value]
        end
      end
      
      unless params[:token].blank?
        req.headers = {'Cookie' => params[:token]}
      end

      unless params[:body].blank?
      	req.body = params[:body]
      end
    end
  rescue
  	return nil
  end

  def get_token
  	BOT_CACHE.get(TORRENT_TOKEN_CACHE_KEY)
  end

end
