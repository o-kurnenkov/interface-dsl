module Interface
  # TODO
  # => define Schemas with dry-validation
  class PortEntity < Struct.new(:name)
    WTFError          = Class.new(StandardError)
    InvalidInputError = Class.new(StandardError)

    N_A = 'N/A'.freeze
    LIM = ('-' * 48).freeze

    def describe(text)
      @description = text
    end

    def call(*args, &block)
      if @implementation.nil?
        fail(WTFError.new("WAT A HECK U DOIN'! THERE'S NO IMPLEMENTATION TO CALL!"))
      end

      if !@contract.nil?
        fail(InvalidInputError.new("Empty argument list doesn not comply with the Contract")) if args.empty?

        errors = @contract.call(*args).errors
        fail(InvalidInputError.new(errors)) if errors.any?
      end

      @implementation.call(*args, &block)
    end

    def implementation(klass)
      @implementation = klass
    end

    def contract(validation_schema)
      @contract = validation_schema
    end

    def returns(hash)
      { success: [:ok,    Object],
        failure: [:error, String] }
    end

    #TODO
    def before_call; end
    def after_call; end
    def wrap_call; end

    def doc
      puts <<-DOC
#{LIM}
Name:\t#{ name }
Desc:\t#{        @description    || N_A}
Responsible:\t#{ @implementation || N_A}
Accepts:\t#{     @arguments      || N_A}
Returns:
\tsuccess:\t#{   @returns && @returns.fetch(:success, N_A) || N_A }
\tfailure:\t#{   @returns && @returns.fetch(:failure, N_A) || N_A }
#{LIM}
      DOC
    end
  end
end
