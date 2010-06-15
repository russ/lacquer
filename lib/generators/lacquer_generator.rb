require 'rails/generators'

class LacquerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def install
    copy_file('varnish.sample.vcl', 'config/varnish.sample.vcl')
    copy_file('initializer.rb', 'config/initializers/lacquer.rb')
  end
end
