module Interface
  class Adapter
    CallingError   = Class.new(StandardError)
    InterfaceError = Class.new(StandardError)

    extend FactoryMethods

    def_factory :call

    def initialize(callable)
      @callable = callable
    end

    def call
      unless callable.respond_to?(:call)
        fail(InterfaceError("#{callable.class} is not callable!"))
      end

      _call
    end

    private

    def _call
      result = callable.call
      if result.is_a?(Array)
        status, _result = result
        status == :ok || fail(ServiceError("Error while calling #{callable.class}: #{_result}"))
        _result
      else
        result
      end
    end
  end
end
