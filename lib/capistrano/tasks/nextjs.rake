namespace :deploy do
  before :starting, :check_nextjs_hooks do
    invoke 'nextjs:add_default_hooks' if fetch(:nextjs_default_hooks)
  end
end

namespace :nextjs do
  task :add_default_hooks do
    after 'pnpm:install', 'nextjs:build'
    # after 'deploy:starting', 'nextjs:quiet' if Rake::Task.task_defined?('nextjs:quiet')
    after 'deploy:updated', 'nextjs:stop'
    after 'deploy:published', 'nextjs:start'
    after 'deploy:failed', 'nextjs:restart'
  end

  desc 'Build Next.js application'
  task :build do
    on roles fetch(:nextjs_roles) do
      within release_path do
        execute :pnpm, 'build'
      end
    end
  end

  desc 'Check Next.js application'
  task :check do
    on roles fetch(:nextjs_roles) do
      within current_path do
        execute :pnpm, 'lint'
      end
    end
  end
end
