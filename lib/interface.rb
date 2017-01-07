require 'dry-configurable'
require 'dry-validation'
require 'factorymethods'
require 'interface/dsl/version'
require 'hashie'

module Interface
  autoload :PortGroup,       'interface/port_group'
  autoload :PortEntity,      'interface/port_entity'
  autoload :Errors,          'interface/errors'

  autoload :DefaultSettings, 'interface/default_settings'
  autoload :DefaultAdapter,  'interface/default_adapter'
end