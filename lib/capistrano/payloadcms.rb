# frozen_string_literal: true

begin
  require 'capistrano/pnpm'
rescue LoadError, RuntimeError
  # Ignore missing pnpm dependency in test environment
end

require 'capistrano/plugin'

module Capistrano
  module PayloadcmsCommon
    def compiled_template(config_file = 'payloadcms.yml')
      @config_file = config_file
      local_template_directory = fetch(:payloadcms_service_templates_path)
      search_paths = [
        File.join(local_template_directory, 'payloadcms.service.capistrano.erb'),
        File.expand_path(
          File.join(*%w[.. templates payloadcms.service.capistrano.erb]),
          __FILE__
        )
      ]
      template_path = search_paths.detect { |path| File.file?(path) }
      template = File.read(template_path)
      ERB.new(template, trim_mode: '-').result(binding)
    end

    def pnpm_path
      # Try to find pnpm in various locations

      backend.capture(:which, :pnpm).strip
    rescue StandardError
      # Try nvm path
      begin
        backend.capture(:bash, '-c', 'source ~/.nvm/nvm.sh && which pnpm').strip
      rescue StandardError
        # Fallback to common paths
        [
          '/home/deploy/.nvm/versions/node/v20.19.2/bin/pnpm',
          '/usr/local/bin/pnpm',
          '/usr/bin/pnpm',
          'pnpm'
        ].each do |path|
          return path if backend.test(:test, '-f', path) || path == 'pnpm'
        rescue StandardError
          next
        end
        'pnpm' # Ultimate fallback
      end
    end

    def payloadcms_config
      '' # Payload CMS doesn't use config files like Sidekiq
    end

    def switch_user(role, &)
      su_user = payloadcms_user(role)
      if su_user == role.user
        yield
      else
        as(su_user, &)
      end
    end

    def payloadcms_user(role = nil)
      if role.nil?
        fetch(:payloadcms_user)
      else
        properties = role.properties
        properties.fetch(:payloadcms_user) || # local property for payloadcms only
          fetch(:payloadcms_user) ||
          properties.fetch(:run_as) || # global property across multiple capistrano gems
          role.user
      end
    end
  end

  module Payloadcms
    class Plugin < Capistrano::Plugin
      def define_tasks
        eval_rakefile File.expand_path('tasks/payloadcms.rake', __dir__)
      end

      def set_defaults
        set_if_empty :payloadcms_default_hooks, true

        set_if_empty :payloadcms_env, -> { fetch(:node_env, fetch(:stage)) }
        set_if_empty :payloadcms_roles, fetch(:payloadcms_role, :app)
        set_if_empty :payloadcms_configs, %w[payloadcms] # basic payloadcms config

        set_if_empty :payloadcms_log, -> { File.join(shared_path, 'log', 'payloadcms.log') }
        set_if_empty :payloadcms_error_log, -> { File.join(shared_path, 'log', 'payloadcms.log') }

        set_if_empty :payloadcms_config_files, ['payloadcms.yml']

        # pnpm integration
        append :pnpm_map_bins, 'payload'
      end
    end
  end
end

require_relative 'payloadcms/systemd'

# Create top-level aliases for easier plugin installation
module Capistrano
  PayloadcmsPlugin = Payloadcms::Plugin
  PayloadcmsSystemd = Payloadcms::Systemd
end
