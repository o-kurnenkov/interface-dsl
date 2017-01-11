module Interface
  class DefaultSettings
    extend ::Dry::Configurable

    setting(:allow_top_level_api_endpoints?, false)
    setting(:response_adapter, ::Interface::DefaultAdapter)
  end
end
