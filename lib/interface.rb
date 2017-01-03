require 'dry-configurable'
require 'factorymethods'

module Interface
  extend ::Dry::Configurable

  setting(:allow_top_level_api_endpoints?, false)
end