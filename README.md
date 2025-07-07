# Capistrano::PayloadCMS

Payload CMS integration for Capistrano with systemd support.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-payloadcms'
```

And then execute:

```bash
bundle install
```

## Usage

Add the following to your `Capfile`:

```ruby
require 'capistrano/pnpm'
require 'capistrano/payloadcms'
install_plugin Capistrano::PayloadcmsPlugin
install_plugin Capistrano::PayloadcmsSystemd
```

Add the following to your `config/deploy.rb`:

```ruby
# Payload CMS configuration
set :payloadcms_roles, :app
set :payloadcms_env, fetch(:stage)
```

## Available Tasks

- `cap payloadcms:start` - Start Payload CMS application
- `cap payloadcms:stop` - Stop Payload CMS application
- `cap payloadcms:restart` - Restart Payload CMS application
- `cap payloadcms:status` - Check Payload CMS application status
- `cap payloadcms:install` - Install systemd service
- `cap payloadcms:uninstall` - Uninstall systemd service
- `cap payloadcms:build` - Build Payload CMS application
- `cap payloadcms:check` - Check Payload CMS application (lint)

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
