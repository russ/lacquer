# Capistrano Recipes for managing varnishd
#
# Add these callbacks to have the varnishd process restart when the server
# is restarted:
#
#   after "deploy:stop",    "delayed_job:stop"
#   after "deploy:start",   "delayed_job:start"
#   after "deploy:restart", "delayed_job:restart"
#
# If you've got varnishd running on a servers, you can also specify
# which servers have varnishd running and should be restarted after deploy.
#
#   set :varnishd_role, :varnish
#

Capistrano::Configuration.instance.load do
  namespace :varnishd do
    def rails_env
      fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
    end
    
    def rake
      fetch(:rake, 'rake')
    end
    
    def roles
      fetch(:varnishd_role, :varnish)
    end
    
    desc "Stop the varnishd process"
    task :stop, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} #{rake} varnishd:stop"
    end

    desc "Start the varnishd process"
    task :start, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} #{rake} varnishd:start"
    end

    desc "Restart the delayed_job process"
    task :restart, :roles => lambda { roles } do
      run "cd #{current_path};#{rails_env} #{rake} varnishd:restart"
    end
  end
end