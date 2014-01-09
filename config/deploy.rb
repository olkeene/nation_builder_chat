load 'deploy/assets'

# RVM integration
# http://beginrescueend.com/integration/capistrano/
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "1.9.3@news_stream"
set :rvm_type, :user

# main details
set  :rails_env, 'production'
set  :application, "news_stream"
role :web, '67lz-bwls.accessdomain.com'
role :app, '67lz-bwls.accessdomain.com'
role :db,  '67lz-bwls.accessdomain.com', :primary => true

# Bundler integration (bundle install)
# http://gembundler.com/deploying.html
require "bundler/capistrano"
set :bundle_without,  [:development, :test]

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :user, "deploy"
set :deploy_to, "/var/www/news_stream"
set :use_sudo, false

# Must be set for the password prompt from git to work
# http://help.github.com/deploy-with-capistrano/
#default_run_options[:pty] = true
#ssh_options[:forward_agent] = true
set :scm, :git
set :repository, 'git@bitbucket.org:olkeene/news-stream.git'
set :branch, "master"
set :deploy_via, :remote_cache

# Multiple Stages Without Multistage Extension
# https://github.com/capistrano/capistrano/wiki/2.x-Multiple-Stages-Without-Multistage-Extension
#desc "Deploy using internal address"
#task :internal do
#  server "192.168.3.21", :app, :web, :db, :primary => true
#end

#desc "Deploy using external address"
#task :external do
#  server "XXX.XXX.XXX.XXX", :app, :web, :db, :primary => true
#end

# http://modrails.com/documentation/Users%20guide%20Nginx.html#capistrano
namespace :deploy do
  # If you are using Passenger mod_rails uncomment this:
   task :start do ; end
   task :stop  do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app do
    out = ['database.yml'].map do |file|
       "ln -nfs #{shared_path}/config/#{file} #{release_path}/config/#{file}"
    end.join(' && ')
    run(out)
  end

  desc "tail log files"
  task :tail, :roles => :app do
    run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  namespace :db do
    desc "Execute db seed"
    task :seed, :roles => :db do
      run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=#{rails_env}"
    end

    desc "Execute db seed"
    task :migrate, :roles => :db do
      run "cd #{current_path} && bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
    end

    desc "Execute migrations and seed"
    task :migrate_seed, :roles => :db do
      run "cd #{release_path} && bundle exec rake db:create db:migrate db:seed RAILS_ENV=#{rails_env}"
    end
  end
end

after  'deploy:update_code', 'deploy:symlink_shared'
after  'deploy:update_code', 'deploy:db:migrate_seed'
#after  'deploy:update_code', 'sidekiq:restart'
before 'deploy:assets:precompile', 'deploy:symlink_shared'

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts
