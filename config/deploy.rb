# config valid only for Capistrano 3.1
require 'thor'
lock '3.2.1'

set :application, 'fan-duel-evaluator'
set :repo_url, 'https://github.com/mmcrockett/fan-duel-evaluator.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, 'unified'

# Default deploy_to directory is /var/www/my_app
set :tmp_dir, '/home/fanduel/tmp'
set :deploy_to, '/home/fanduel/fanduel.mmcrockett.com'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Backup SQLite DB'
  task :backup_db do
    on roles(:app), in: :sequence, wait: 5 do
      if test("[ -f #{release_path.join('db/production.sqlite3')} ]")
        execute :cp, release_path.join('db/production.sqlite3'), shared_path.join('production.backup.sqlite3')
      end
    end
  end

  desc 'Copy SQLite DB'
  task :copy_db do
    on roles(:app), in: :sequence, wait: 5 do
      if test("[ -f #{shared_path.join('production.backup.sqlite3')} ]")
        execute :cp, shared_path.join('production.backup.sqlite3'), release_path.join('db/production.sqlite3')
      end
    end
  end

  after :started, :backup_db
  before :migrate, :copy_db
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end