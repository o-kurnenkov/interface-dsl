module Interface
  class DefaultAdapter
    CallingError   = Class.new(StandardError)
    InterfaceError = Class.new(StandardError)

    extend FactoryMethods

    deffactory :call

    def initialize(callable)
      @callable = callable
    end

    def call(*args, &block)
      unless callable.respond_to?(:call)
        fail(InterfaceError("#{callable.class} is not callable!"))
      end

      _call(*args, &block)
    end

    private

    attr_reader :callable

    def _call(*args, &block)
      result = callable.call(*args, &block)
      if result.is_a?(Array)
        status, _result = result
        status == :ok || fail(CallingError("Error while calling #{callable.class}: #{_result}"))
        _result
      else
        result
      end
    end
  end
end
