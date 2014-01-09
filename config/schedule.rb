# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end

set :output, "/var/www/news_stream/current/log/cron_log.log"

every 5.minutes do
  rake 'application:run_grabger'
end

# Learn more: http://github.com/javan/whenever
