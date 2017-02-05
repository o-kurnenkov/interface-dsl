module Interface
  class DirectAdapter
    extend FactoryMethods
    deffactory :call

    def initialize(callable)
      @callable = callable
    end

    def call(*args, &block)
      unless @callable.respond_to?(:call)
        fail(Interface::Errors::AdaptationError.new("#{@callable.class} is not callable!"))
      end

      @callable.call(*args, &block)
    end
  end
end
