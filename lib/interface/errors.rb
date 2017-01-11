module Interface
  module Errors
    BaseError               = Class.new(StandardError)

    OrphanPortError         = Class.new(BaseError)
    ImmutableInterfaceError = Class.new(BaseError)
    InvalidInputError       = Class.new(BaseError)
    HandlerMissingError     = Class.new(BaseError)
    UnexpectedInstanceError = Class.new(BaseError)
  end
end