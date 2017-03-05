module Interface
  class PortEntity
    N_A = 'N/A'.freeze
    LIM = ('-' * 48).freeze

    attr_reader :name

    def initialize(name, adapter)
      @name, @adapter = name, adapter
    end

    def describe(text)
      @description = text
    end

    def struct(*fields)
      @struct = fields
    end

    def proxy_factory(klass)
      @proxy_factory = klass
    end

    def proxy(obj, options={})
      return nil unless @proxy_factory
      @proxy_factory.call(struct: @struct, contract: @contract, handler: @handler).new(obj, options)
    end

    def call(*args, &block)
      if @handler.nil?
        fail(::Interface::Errors::HandlerMissingError.new("Handler is undefined"))
      end

      if !@contract.nil?
        fail(::Interface::Errors::InvalidInputError.new("Empty argument list doesn not comply with the Contract")) if args.empty?

        errors = @contract.call(*args).errors
        fail(::Interface::Errors::InvalidInputError.new(errors)) if errors.any?
      end

      _callee.call(*args, &block)
    end

    def handler(klass)
      @handler = klass
    end

    def contract(&validation_schema)
      @contract = validation_schema
    end

    def returns(klass)
      @adapter = klass
    end

    def before_call; end
    def after_call; end
    def wrap_call; end

    def doc
      puts <<-DOC
#{LIM}
Name:\t#{ name }
Desc:\t#{        @description    || N_A}
Responsible:\t#{ @handler || N_A}
Accepts:\t#{     @arguments      || N_A}
Returns:
\tsuccess:\t#{   @returns && @returns.fetch(:success, N_A) || N_A }
\tfailure:\t#{   @returns && @returns.fetch(:failure, N_A) || N_A }
#{LIM}
      DOC
    end

    private

    def _callee
      return @handler if @adapter.nil?

      @adapter.new(@handler)
    end
  end
end
