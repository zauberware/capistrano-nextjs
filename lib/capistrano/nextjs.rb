# frozen_string_literal: true

begin
  require 'capistrano/pnpm'
rescue LoadError, RuntimeError
  # Ignore missing pnpm dependency in test environment
end

require 'capistrano/plugin'

module Capistrano
  module NextjsCommon
    def compiled_template(config_file = 'nextjs.yml')
      @config_file = config_file
      local_template_directory = fetch(:nextjs_service_templates_path)
      search_paths = [
        File.join(local_template_directory, 'nextjs.service.capistrano.erb'),
        File.expand_path(
          File.join(*%w[.. templates nextjs.service.capistrano.erb]),
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

    def nextjs_config
      '' # NextJS doesn't use config files like Sidekiq
    end

    def switch_user(role, &block)
      su_user = nextjs_user(role)
      if su_user == role.user
        yield
      else
        as su_user, &block
      end
    end

    def nextjs_user(role = nil)
      if role.nil?
        fetch(:nextjs_user)
      else
        properties = role.properties
        properties.fetch(:nextjs_user) || # local property for nextjs only
          fetch(:nextjs_user) ||
          properties.fetch(:run_as) || # global property across multiple capistrano gems
          role.user
      end
    end
  end

  module Nextjs
    class Plugin < Capistrano::Plugin
      def define_tasks
        eval_rakefile File.expand_path('tasks/nextjs.rake', __dir__)
      end

      def set_defaults
        set_if_empty :nextjs_default_hooks, true

        set_if_empty :nextjs_env, -> { fetch(:node_env, fetch(:stage)) }
        set_if_empty :nextjs_roles, fetch(:nextjs_role, :app)
        set_if_empty :nextjs_configs, %w[nextjs] # basic nextjs config

        set_if_empty :nextjs_log, -> { File.join(shared_path, 'log', 'nextjs.log') }
        set_if_empty :nextjs_error_log, -> { File.join(shared_path, 'log', 'nextjs.log') }

        set_if_empty :nextjs_config_files, ['nextjs.yml']

        # pnpm integration
        append :pnpm_map_bins, 'next'
      end
    end
  end
end

require_relative 'nextjs/systemd'

# Create top-level aliases for easier plugin installation
module Capistrano
  NextjsPlugin = Nextjs::Plugin
  NextjsSystemd = Nextjs::Systemd
end
