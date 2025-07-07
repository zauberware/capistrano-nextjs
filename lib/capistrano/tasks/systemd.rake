# frozen_string_literal: true

git_plugin = self

namespace :payloadcms do
  standard_actions = {
    start: 'Start Payload CMS',
    stop: 'Stop Payload CMS (graceful shutdown)',
    status: 'Get Payload CMS Status',
    restart: 'Restart Payload CMS'

  }
  standard_actions.each do |command, description|
    desc description
    task command do
      on roles fetch(:payloadcms_roles) do |role|
        git_plugin.switch_user(role) do
          git_plugin.config_files(role).each do |config_file|
            git_plugin.execute_systemd(command, git_plugin.payloadcms_service_file_name(config_file))
          end
        end
      end
    end
  end

  desc 'Stop Payload CMS gracefully'
  task :quiet do
    on roles fetch(:payloadcms_roles) do |role|
      git_plugin.switch_user(role) do
        git_plugin.stop_payloadcms_gracefully(role)
      end
    end
  end

  desc 'Install Payload CMS systemd service'
  task :install do
    on roles fetch(:payloadcms_roles) do |role|
      git_plugin.switch_user(role) do
        git_plugin.create_systemd_template(role)
      end
    end
    invoke 'payloadcms:enable'
  end

  desc 'Uninstall Payload CMS systemd service'
  task :uninstall do
    invoke 'payloadcms:disable'
    on roles fetch(:payloadcms_roles) do |role|
      git_plugin.switch_user(role) do
        git_plugin.rm_systemd_service(role)
      end
    end
  end

  desc 'Enable Payload CMS systemd service'
  task :enable do
    on roles(fetch(:payloadcms_roles)) do |role|
      git_plugin.config_files(role).each do |config_file|
        git_plugin.execute_systemd('enable', git_plugin.payloadcms_service_file_name(config_file))
      end

      if fetch(:systemctl_user) && fetch(:payloadcms_lingering_user)
        execute :loginctl, 'enable-linger', fetch(:payloadcms_lingering_user)
      end
    end
  end

  desc 'Disable Payload CMS systemd service'
  task :disable do
    on roles(fetch(:payloadcms_roles)) do |role|
      git_plugin.config_files(role).each do |config_file|
        git_plugin.execute_systemd('disable', git_plugin.payloadcms_service_file_name(config_file))
      end
    end
  end

  def fetch_systemd_unit_path
    if fetch(:payloadcms_systemctl_user) == :system
      '/etc/systemd/system/'
    else
      home_dir = backend.capture :pwd
      File.join(home_dir, '.config', 'systemd', 'user')
    end
  end

  def create_systemd_template(role)
    systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)
    backend.execute :mkdir, '-p', systemd_path if fetch(:systemctl_user)

    config_files(role).each do |config_file|
      ctemplate = compiled_template(config_file)
      temp_file_name = File.join('/tmp', "payloadcms.#{config_file}.service")
      systemd_file_name = File.join(systemd_path, payloadcms_service_file_name(config_file))
      backend.upload!(StringIO.new(ctemplate), temp_file_name)
      if fetch(:systemctl_user)
        warn "Moving #{temp_file_name} to #{systemd_file_name}"
        backend.execute :mv, temp_file_name, systemd_file_name
      else
        warn "Installing #{systemd_file_name} as root"
        backend.execute :sudo, :mv, temp_file_name, systemd_file_name
      end
    end
  end

  def rm_systemd_service(role)
    systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)

    config_files(role).each do |config_file|
      systemd_file_name = File.join(systemd_path, payloadcms_service_file_name(config_file))
      if fetch(:systemctl_user)
        warn "Deleting #{systemd_file_name}"
        backend.execute :rm, '-f', systemd_file_name
      else
        warn "Deleting #{systemd_file_name} as root"
        backend.execute :sudo, :rm, '-f', systemd_file_name
      end
    end
  end

  def stop_payloadcms_gracefully(role)
    config_files(role).each do |config_file|
      payloadcms_service = payloadcms_service_unit_name(config_file)
      warn "Stopping #{payloadcms_service} gracefully"
      execute_systemd('stop', payloadcms_service)
    end
  end

  def payloadcms_service_unit_name(config_file)
    if config_file == 'payloadcms.yml'
      fetch(:payloadcms_service_unit_name)
    else
      "#{fetch(:payloadcms_service_unit_name)}.#{config_file.split('.')[0..-2].join('.')}"
    end
  end

  def payloadcms_service_file_name(config_file)
    ## Remove the extension
    config_file = config_file.split('.').join('.')

    "#{payloadcms_service_unit_name(config_file)}.service"
  end

  def config_files(role)
    role.properties.fetch(:payloadcms_config_files) ||
      fetch(:payloadcms_config_files)
  end
end
