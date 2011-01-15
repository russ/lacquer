module Lacquer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), "templates"))

      def copy_initializer
        copy_file("initializer.rb", "config/initializers/lacquer.rb")
      end

      def copy_vcl
        copy_file("varnish.vcl.erb", "config/varnish.vcl.erb")
      end
      
      def copy_varnishd_config
        copy_file("varnishd.yml", "config/varnishd.yml")
      end
    end
  end
end
