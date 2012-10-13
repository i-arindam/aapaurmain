# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require "bundler/capistrano"
set :rvm_ruby_string, 'ruby-1.9.3-p194@rails326'
set :rvm_type, :system

set :application, "app"
set :repository,  "git://github.com/i-arindam/aapaurmain.git"
set :branch, 'master'
set :rvm_type, :system
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/aapaurmain/#{application}/capped"

role :web, "dep"
role :app, "dep"
role :db,  "dep", :primary => true

set :user, "deployer"
# set :password, "Depl0y1ngat0nce"

set :scm_username, "i-arindam"
set :scm_password, "Hu57l3r!am"

# before 'deploy:setup', 'rvm:install_rvm'
# before 'deploy:setup', 'rvm:install_ruby'

# set :rvm_install_ruby, :install

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

namespace :deploy do

  task :default do
    update
    if File.exists?("/tmp/unicorn.aapaurmain.pid")
      restart
    else
      start
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat /tmp/unicorn.aapaurmain.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat /tmp/unicorn.aapaurmain.pid`"
  end
end
