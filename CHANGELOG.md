
2.0.2 / 2017-10-19
==================

  * Implemented legacy contextualization fallback for OpenNebula

2.0.1 / 2017-10-19
==================

  * Added support for logging to syslog
  * Added support for legacy contextualization mixins
  * Updated dependencies

2.0.0 / 2017-10-04
==================

  * Fixed state handling for `inactive`
  * Added debug logging to async actions
  * Compute save w/ clean-up and cloudkeeper attribute removal
  * Fixing path handling bug in `bin/oneresource`
  * Moving XPATH counter to ONe lib extensions
  * Add automatic Docker image build via CircleCI
  * Add Dockerfile for building a dockerized version
  * Moving `oneresources` to `oneresource`
  * Added legacy and GPU-enabled resource templates
  * More appropriate attribute name for GPUs
  * Minor dependency updates
  * Fixed const loading problems on R2.2 and R2.3
  * Using separate MIME type for `occi+json`

2.0.0.beta.2 / 2017-09-15
==================

  * Added CHANGELOG.md
  * Catching OCCI Argument Errors during parsing
  * Moved instance actions to async `ActiveJob`s
  * Cleaned up old logging syntax
  * Add onetoken util that creates cloud tokens
