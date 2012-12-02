module Lacquer
  class Varnishd
    attr_accessor :listen, :telnet, :sbin_path, :bin_path, :storage, :working_dir, :user, :backend, :params, :use_sudo, :pid_path

    cattr_accessor :started_check_delay, :vcl_script_filename
    self.started_check_delay = 1
    self.vcl_script_filename = 'config/varnish.vcl'

    def self.root_path
      Rails.root
    end

    def self.env
      Rails.env
    end

    def self.config_file
      root_path.join('config/varnishd.yml')
    end

    def self.config
      YAML.load(File.read(config_file))[env].stringify_keys
    end

    def initialize(settings = self.class.config)
      self.listen, self.telnet, self.backend, self.sbin_path, self.bin_path, self.storage, self.working_dir, self.user, self.params, self.use_sudo, self.pid_path =
        settings.values_at("listen", "telnet", "backend", "sbin_path", "bin_path", "storage", "working_dir", "user", "params", "use_sudo", "pid_path")
    end

    def render_vcl
      require 'erubis'
      eruby = Erubis::Eruby.new(erb_vcl_script_filename.read)
      eruby.result(binding)
    end

    def generate_vcl
      if erb_vcl_script_filename.exist?
        log "#{erb_vcl_script_filename} found rendering to #{vcl_script_filename}"
        File.open(vcl_script_filename, "w") do |vcl|
          vcl.write(render_vcl)
        end
      end
    end

    def start
      if running?
        log("Already running")
        return
      end
      generate_vcl
      execute("#{varnishd_cmd} #{args} #{params_args}")
      sleep(self.class.started_check_delay)
      log("Failed to start varnishd daemon") unless running?
    end

    def stop
      if running?
        execute("#{'sudo ' if use_sudo}kill #{pid}")
        pid_file.delete
      else
        log("pid file not found or varnishd not running")
      end
    end

    def reload
      if running?
        generate_vcl
        reload_id = "reload#{Time.now.usec}"
        load_cmd = "#{varnishadm_cmd} vcl.load #{reload_id} #{options['-f']}"
        use_cmd = "#{varnishadm_cmd} vcl.use #{reload_id}"
        execute "#{load_cmd} && #{use_cmd}"
      else
        start
      end
    end

    def running?
      !!pid && !!execute("ps p #{pid}").include?(pid.to_s) # works with sudo
    end

    def args
      options.map { |k, v| "#{k} #{v}" }.join(" ")
    end

    def params_args
      params.map { |k, v| "-p #{k}=#{v}" }.join(" ")
    end

    def options
      opt = {}
      opt["-P"] = pid_file
      opt["-a"] = listen
      opt["-T"] = telnet        if telnet.present?
      opt["-n"] = working_dir   if working_dir.present?
      opt["-u"] = user          if user.present?
      opt["-s"] = eval(%Q("#{storage}"))
      opt["-f"] = vcl_script_filename
      opt
    end

    def params
      @params || {}
    end

    protected

    def varnishd_cmd
      "#{'sudo ' if use_sudo}#{Pathname.new(sbin_path).join('varnishd')}"
    end

    def varnishadm_cmd
      "#{'sudo ' if use_sudo}#{Pathname.new(bin_path).join('varnishadm')} -T #{options['-T']}"
    end

    def pid_file
      pid_computed_path.join("varnishd.#{self.class.env}.pid")
    end

    def pid_computed_path
      if self.pid_path
        Pathname.new self.pid_path
      else
        self.class.root_path.join('log/')
      end
    end

    def vcl_script_filename
      self.class.root_path.join(self.class.vcl_script_filename)
    end

    def erb_vcl_script_filename
      vcl_script_filename.sub_ext('.vcl.erb')
    end

    def log(message)
      puts "** [#{self.class.name}] #{message}"
    end

    def execute(cmd)
      log(cmd)
      `#{cmd}`
    end

    def pid
      if pid_file.exist?
        pid_file.read
      else
        nil
      end
    end
  end
end
