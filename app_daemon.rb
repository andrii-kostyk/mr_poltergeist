require 'rubygems'
require 'daemons'
require 'yaml'

GENERAL = YAML.load(File.read(File.join(File.expand_path('..', __FILE__), 'config', "general.yml")))

Daemons.run_proc('mr_poltergeist', log_output: false, dir: GENERAL['app_path']) do
  exec "ruby #{GENERAL['app_path']}/app.rb"
end
