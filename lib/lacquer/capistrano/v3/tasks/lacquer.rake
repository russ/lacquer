namespace :load do
  task :defaults do
    set :lacquer_roles, -> { :web }
  end
end

namespace :lacquer do
  %w( start stop restart global_purge status ).each do |name|
    desc "#{name} varnish"
    task name.to_sym do
      on roles(fetch(:lacquer_roles)) do
        within current_release do
          with rails_env: fetch(:rails_env) do
            execute :bundle, "exec rake", "lacquer:varnishd:#{name}"
          end
        end
      end
    end
  end

  after "deploy:rollback", "lacquer:global_purge"
  after "deploy:rollback", "lacquer:restart"
  after "deploy:updated", "lacquer:restart"
end
