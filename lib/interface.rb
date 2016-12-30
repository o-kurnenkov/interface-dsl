require 'dry-configurable'

module Interface
  extend ::Dry::Configurable

  setting(:allow_top_level_api_endpoints?, false)
end