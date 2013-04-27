require "rvm/capistrano"
require "bundler/capistrano"
require "bundler/setup"
require "delayed/recipes"
require "newrelic/recipes"

# Server ruby gem and gemset name
set :rvm_ruby_string, 'ruby-1.9.3-p194@rails326'
# Specifying a system wide install
set :rvm_type, :system

set :application, "app"
set :repository,  "git://github.com/i-arindam/aapaurmain.git"
set :branch, 'master'
set :scm, :git

# Allows server to do git pull on every deploy, not do a git clone.
set :deploy_via, :remote_cache

set :deploy_to, "/home/aapaurmain/#{application}/capped"

role :web, "dep"
role :app, "dep"
role :db,  "dep", :primary => true

set :user, "deployer"

set :scm_username, "i-arindam"
set :scm_password, "Hu57l3r!am"

before 'deploy', 'deploy:check_revision'

# after "deploy:update_code", "daemons:delayed_jobs:restart"

# Clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
after "deploy:update", "newrelic:notice_deployment"

namespace :deploy do

  task :default do
    # daemons.delayed_jobs.kill
    migrations
    restart
  end

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
 
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "cd #{current_path} && kill -s USR2 `cat /tmp/unicorn.aapaurmain.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat /tmp/unicorn.aapaurmain.pid`"
  end
end

namespace :daemons do

  namespace :delayed_jobs do

    desc "Stop old delayed jobs"
    task :kill, roles: :web do
      run "cd #{current_path} && RAILS_ENV=production script/delayed_job stop"
    end

    desc "Restart delayed jobs in current path"
    task :restart, :roles => :web do
      run "cd #{current_path} && rails g delayed_job && RAILS_ENV=production script/delayed_job restart"
    end
  end
end
