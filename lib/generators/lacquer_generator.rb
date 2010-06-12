require 'rails/generators'

class LacquerGenerator < Rails::Generators::Base
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def install_lacquer
    copy_file('varnish.sample.vcl', 'config/varnish.sample.vcl')
    copy_file('initializer.rb', 'config/initializers/lacquer.rb')
  end
end
