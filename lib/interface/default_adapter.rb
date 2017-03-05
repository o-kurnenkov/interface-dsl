module Interface
  class DefaultAdapter
    extend FactoryMethods
    deffactory :call

    def initialize(callable)
      @callable = callable
    end

    def call(*args, &block)
      _call(*args, &block)
    end

    private

    attr_reader :callable

    def _call(*args, &block)
      status, _result = _handle_request(*args, &block)

      # Response.__ok__(_result)
      # Response.__error__(_result)
      Response.public_send("__#{status}__", _result)
    end

    def _handle_request(*args, &block)
      if callable.respond_to?(:dispatch)
        _wrap(callable.dispatch(*args, &block))
      elsif callable.respond_to?(:call)
        _wrap(callable.call(*args, &block))
      else
        fail(Interface::Errors::AdaptationError.new("#{callable.class} is not callable!"))
      end
    rescue => e
      [:error, e]
    end

    def _wrap(result)
      return [:ok, result] unless result.is_a?(Array)

      status, _result = result
      status == :ok ? [:ok, _result] : [:error, _result]
    end
  end
end
