# frozen_string_literal: true

module Capistrano
  module Payloadcms
    class Systemd < Capistrano::Plugin
      include PayloadcmsCommon
      def define_tasks
        eval_rakefile File.expand_path('../tasks/systemd.rake', __dir__)
      end

      def set_defaults
        set_if_empty :systemctl_bin, '/bin/systemctl'
        set_if_empty :service_unit_user, :user
        set_if_empty :systemctl_user, fetch(:service_unit_user, :user) == :user

        set_if_empty :payloadcms_service_unit_name, -> { "#{fetch(:application)}_payloadcms_#{fetch(:stage)}" }
        set_if_empty :payloadcms_lingering_user, -> { fetch(:lingering_user, fetch(:user)) }

        ## Payload CMS environment variables
        set_if_empty :payloadcms_service_unit_env_files, -> { fetch(:service_unit_env_files, []) }
        set_if_empty :payloadcms_service_unit_env_vars, lambda {
          base_vars = fetch(:service_unit_env_vars, [])
          base_vars + ["NODE_ENV=#{fetch(:payloadcms_env, 'production')}"]
        }

        set_if_empty :payloadcms_service_templates_path, fetch(:service_templates_path, 'config/deploy/templates')
      end

      def systemd_command(*args)
        command = [fetch(:systemctl_bin)]

        command << '--user' unless fetch(:service_unit_user) == :system

        command + args
      end

      def sudo_if_needed(*command)
        if fetch(:service_unit_user) == :system
          backend.sudo command.map(&:to_s).join(' ')
        else
          backend.execute(*command)
        end
      end

      def execute_systemd(*args)
        sudo_if_needed(*systemd_command(*args))
      end
    end
  end
end
