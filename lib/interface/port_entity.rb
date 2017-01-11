module Interface
  class PortEntity < Struct.new(:name, :default_adapter)
    N_A = 'N/A'.freeze
    LIM = ('-' * 48).freeze

    def describe(text)
      @description = text
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

      # this is a decent source of bugs.
      caller =  if !@adapter.nil?
                  @adapter.new(@handler)
                elsif !default_adapter.nil?
                  default_adapter.new(@handler)
                else
                  @handler
                end

      caller.call(*args, &block)
    end

    def handler(klass)
      @handler = klass
    end

    def contract(validation_schema)
      @contract = validation_schema
    end

    def returns(klass)
      @adapter = klass
    end

    # def returns(hash)
    #   { success: [:ok,    Object],
    #     failure: [:error, String] }
    # end

    #TODO
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
  end
end
