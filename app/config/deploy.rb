# Capifony documentation: http://capifony.org
# Capistrano documentation: https://github.com/capistrano/capistrano/wiki

# Be more verbose by uncommenting the following line
# logger.level = Logger::MAX_LEVEL

set :application, "hellobell"
set :domain,      "95.142.160.33"
set :deploy_to,   "/var/www/demo"
set :app_path,    "app"
set :user,        "root"

role :web,        domain
role :app,        domain
role :db,         domain, :primary => true

set :scm,         :git
set :repository,  "git@github.com:KnpLabs/HelloBell.git"
set :branch,      "demo"
set :deploy_via,  :remote_cache

ssh_options[:forward_agent] = true

set :use_composer,   true
set :update_vendors, true

set :writable_dirs,     ["app/cache", "app/logs"]
set :webserver_user,    "www-data"
set :permission_method, :acl

set :shared_files,    ["app/config/parameters.yml", "web/.htaccess", "web/robots.txt"]
set :shared_children, ["app/logs", "web/uploads", "web/assets", "app/Resources/blacklist"]

set :model_manager, "doctrine"

set :use_sudo,    false

set :keep_releases, 3

before 'symfony:composer:update', 'symfony:copy_vendors'

namespace :symfony do
  desc "Copy vendors from previous release"
  task :copy_vendors, :except => { :no_release => true } do
    if Capistrano::CLI.ui.agree("Do you want to copy last release vendor dir then do composer install ?: (y/N)")
      capifony_pretty_print "--> Copying vendors from previous release"

      run "cp -a #{previous_release}/vendor #{latest_release}/"
      capifony_puts_ok
    end
  end
end

after "deploy:update", "deploy:cleanup"
after "deploy", "deploy:set_permissions"
