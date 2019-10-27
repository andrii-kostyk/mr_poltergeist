require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'open-uri'
require 'rake'
require 'active_support/all'
require 'telegram/bot'
require 'redis'
require 'faraday'
require 'pry'

%w(config lib).each do |folder|
  Dir[File.join(File.expand_path('..', __FILE__), folder, '*.rb')].each do |file| 
  	require file
  end
end

SECRETS = ApplicationHelper.fetch_config('secrets').with_indifferent_access
GENERAL = ApplicationHelper.fetch_config('general').with_indifferent_access
ACTIONS = ApplicationHelper.fetch_config('actions').with_indifferent_access

BOT_CACHE = Redis.new(host: GENERAL[:redis][:host], port: GENERAL[:redis][:port])
TORRENT_TOKEN_CACHE_KEY = 'mr_poltergeist_qbittorrent_session'
BOT_SESSION_CACHE_KEY = 'mr_poltergeist_session'

TelegramBot.run
