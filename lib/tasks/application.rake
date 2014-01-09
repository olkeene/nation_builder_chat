namespace :application do
  task :run_grabger => :environment do
    Grabber.new.process!
  end
end