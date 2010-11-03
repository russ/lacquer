module Lacquer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), "templates"))

      def copy_initializer
        copy_file("initializer.rb", "config/initializers/lacquer.rb")
      end

      def copy_vcl
        copy_file("varnish.sample.vcl", "config/varnish.sample.vcl")
      end
    end
  end
end
