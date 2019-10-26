require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'open-uri'
require 'rake'
require 'active_support/all'
require 'telegram/bot'
require 'redis'
require 'faraday'

# Bundler.require(:default)

%w(config lib).each do |folder|
  Dir[File.join(File.expand_path('..', __FILE__), folder, '*.rb')].each do |file| 
  	require file
  end
end

BOT_CACHE = Redis.new(host: "127.0.0.1", port: 6379)

BOT_CONFIG = ApplicationHelper.fetch_config('telegram').with_indifferent_access
TORRENT_CONFIG = ApplicationHelper.fetch_config('qbittorrent').with_indifferent_access
ACTIONS = ApplicationHelper.fetch_config('actions').with_indifferent_access

TORRENT_TOKEN_CACHE_KEY = 'mr_poltergeist_qbittorrent_session'
BOT_SESSION_CACHE_KEY = 'mr_poltergeist_session'

TelegramBot.run
