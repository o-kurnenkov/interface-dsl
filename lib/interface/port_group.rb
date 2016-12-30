require 'hashie'

module Interface
  class PortGroup
    include ::Interface::DSL

    attr_reader :name, :parent

    def initialize(name, parent=nil)
      @name = name
      @parent = parent
    end
  end
end
