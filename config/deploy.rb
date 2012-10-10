$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3-p194@rails326'

set :application, "app"
set :repository,  "git://github.com/i-arindam/aapaurmain.git"
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
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
