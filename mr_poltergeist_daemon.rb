require 'rubygems'
require 'daemons'

Daemons.run_proc('mr_poltergeist_app', log_output: false, dir: '/home/pi/mr_poltergeist') do
  exec "ruby /home/pi/mr_poltergeist/mr_poltergeist_app.rb"
end
