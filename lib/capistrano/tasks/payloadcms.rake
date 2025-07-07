namespace :deploy do
  before :starting, :check_payloadcms_hooks do
    invoke 'payloadcms:add_default_hooks' if fetch(:payloadcms_default_hooks)
  end
end

namespace :payloadcms do
  task :add_default_hooks do
    after 'pnpm:install', 'payloadcms:migrate'
    after 'payloadcms:migrate', 'payloadcms:build'
    # after 'deploy:starting', 'payloadcms:quiet' if Rake::Task.task_defined?('payloadcms:quiet')
    after 'deploy:updated', 'payloadcms:stop'
    after 'deploy:published', 'payloadcms:start'
    after 'deploy:failed', 'payloadcms:restart'
  end

  desc 'Build Payload CMS application'
  task :build do
    on roles fetch(:payloadcms_roles) do
      within release_path do
        execute :pnpm, 'build'
      end
    end
  end

  task :migrate do
    on roles fetch(:payloadcms_roles) do
      within release_path do
        execute :pnpm, 'payload migrate'
      end
    end
  end

  desc 'Check Payload CMS application'
  task :check do
    on roles fetch(:payloadcms_roles) do
      within current_path do
        execute :pnpm, 'lint'
      end
    end
  end
end
