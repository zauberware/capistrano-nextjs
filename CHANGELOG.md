# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-07

### Added

- Initial release of capistrano-payloadcms
- Payload CMS application deployment support with Capistrano
- Systemd service integration for Payload CMS applications
- Support for pnpm package manager
- Automatic build and deployment hooks with proper sequencing
- Graceful shutdown support
- Environment variable management
- Service management tasks (start, stop, restart, status)
- Installation and uninstallation of systemd services
- Database migration support before build process
- RuboCop integration for code quality and style enforcement

### Features

- Automatic detection of pnpm executable
- NODE_ENV environment variable management
- Customizable service templates
- User and system service support
- Logging configuration
- Background process management
- Optimized deployment flow: migrate → build → deploy
- Code linting and formatting with RuboCop

### Changed

- Reordered deployment hooks to run migrations before build process
- Improved deployment sequence for better reliability
- Added RuboCop configuration and fixed all linting issues
- Moved development dependencies from gemspec to Gemfile
- Added MFA requirement for gem publishing
