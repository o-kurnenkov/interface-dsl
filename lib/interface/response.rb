module Interface
  class Response
    def self.__ok__(result)
      new(result: result)
    end

    def self.__error__(errors)
      new(errors: Array(errors))
    end

    attr_accessor :errors, :result

    def initialize(result: nil, errors: [])
      @errors = errors
      @result = result
      @is_ok  = errors.empty?
    end

    def ok?
      @is_ok
    end
  end
end
