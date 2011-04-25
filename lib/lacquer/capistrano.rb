# Capistrano tasks for Lacquer

Capistrano::Configuration.instance(:must_exit).load do
  _cset(:lacquer_roles) { :web }

  after "deploy:web:disable", "varnish:global_purge"
  after "deploy:web:enable", "varnish:global_purge"
  after "deploy:rollback", "varnish:global_purge"
  after "deploy:rollback", "varnish:restart"
  after "deploy:update", "varnish:restart"

  namespace :lacquer do
    %w( start stop restart global_purge status ).each do |name|
      task name.to_sym, :roles => lacquer_roles do
        next if find_servers_for_task(current_task).empty?
        Rake::Task["varnishd:#{name}"].invoke
      end
    end
  end
end
