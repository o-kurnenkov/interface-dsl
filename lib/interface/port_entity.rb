module Interface
  # TODO
  # => define Schemas with dry-validation
  class PortEntity < Struct.new(:name)
    WTFError = Class.new(StandardError)

    N_A = 'N/A'.freeze
    LIM = ('-' * 48).freeze

    def describe(text)
      @description = text
    end

    def call
      if @implementation.nil?
        fail(WTFError.new("WAT A HECK U DOIN'! THERE'S NO IMPLEMENTATION TO CALL!"))
      end

      @implementation.call
    end

    def implementation(klass)
      @implementation = klass
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
