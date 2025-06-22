# Capistrano::NextJS

NextJS integration for Capistrano with systemd support.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-nextjs'
```

And then execute:

```bash
bundle install
```

## Usage

Add the following to your `Capfile`:

```ruby
require 'capistrano/pnpm'
require 'capistrano/nextjs'
install_plugin Capistrano::NextjsPlugin
install_plugin Capistrano::NextjsSystemd
```

Add the following to your `config/deploy.rb`:

```ruby
# NextJS configuration
set :nextjs_roles, :app
set :nextjs_env, fetch(:stage)
```

## Available Tasks

- `cap nextjs:start` - Start NextJS application
- `cap nextjs:stop` - Stop NextJS application
- `cap nextjs:restart` - Restart NextJS application
- `cap nextjs:status` - Check NextJS application status
- `cap nextjs:install` - Install systemd service
- `cap nextjs:uninstall` - Uninstall systemd service
- `cap nextjs:build` - Build NextJS application
- `cap nextjs:check` - Check NextJS application (lint)

## Configuration

The gem automatically integrates with your deployment process:

- Stops the service before deployment
- Starts the service after successful deployment
- Restarts the service if deployment fails

## Requirements

- Node.js
- pnpm
- systemd (for service management)

## License

The gem is available as open source under the terms of the [LGPL-3.0 License](https://opensource.org/licenses/LGPL-3.0).
