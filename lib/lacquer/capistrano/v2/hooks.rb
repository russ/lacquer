# Capistrano tasks for Lacquer

Capistrano::Configuration.instance(:must_exit).load do
  _cset(:lacquer_roles) { :web }

  after "deploy:web:disable", "lacquer:global_purge"
  after "deploy:web:enable", "lacquer:global_purge"
  after "deploy:rollback", "lacquer:global_purge"
  after "deploy:rollback", "lacquer:restart"
  after "deploy:update", "lacquer:restart"

  namespace :lacquer do
    %w( start stop restart global_purge status reload ).each do |name|
      desc "#{name} varnish"
      task name.to_sym, :roles => lacquer_roles do
        next if find_servers_for_task(current_task).empty?
        run "cd #{current_path} && #{rake} lacquer:varnishd:#{name}"
      end
    end
  end
end
