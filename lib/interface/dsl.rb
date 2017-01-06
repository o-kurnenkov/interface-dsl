require "interface"
require "interface/dsl/version"

module Interface
  module DSL
    OrphanPort         = Class.new(StandardError)
    ImmutableInterface = Class.new(StandardError)

    require "interface/port_group"
    require "interface/port_entity"

    def interface(name, &block)
      if interfaces.key?(name)
        fail(ImmutableInterface.new("Interface can't be redefined or reopened! Use .extend_api method"))
      end

      interfaces.merge!(name => ::Interface::PortGroup.new(name, self).tap do |group|
        group.instance_eval(&block)
      end)
    end

    def defpoint(name, &block)
      check_top_level_enpoint_policy

      points.merge!(name => define_entity(name, &block))
    end

    def method_missing(meth, *args, &block)
      super unless respond_to?(:interfaces) || respond_to?(:points)

      if interfaces.respond_to?(meth)
        interfaces.send(meth)
      elsif points.respond_to?(meth)
        points.send(meth)
      else
        super
      end
    end

    # extend_api(as: 'northbound.operations.truck_load', with_class: TruckLoadAPI)
    def extend_api(as: , with_class: )
      # Maybe Define just a nested interface???
      _merge_point = respond_to?(:points) ? points : self

      _merge_point.merge!(as => with_class)
    end

    def doc
      _name = self.respond_to?(:name) ? self.name : self.class.name
      puts _name
      doc_all_endpoints
      interfaces.each_pair { |_, i| i.doc }
    end

    def interfaces
      @interfaces ||= Hashie::Mash.new
    end

    def points
      @points ||= Hashie::Mash.new
    end

    private

    def check_top_level_enpoint_policy
      return if Interface.config.allow_top_level_api_endpoints? || !top_level?

      fail(OrphanPort.new("Can not be defined as a top level Interface"))
    end

    def top_level?
      if respond_to?(:parent)
        parent.nil? && interfaces.empty?
      else
        interfaces.empty?
      end
    end

    def doc_all_endpoints
      traverse_all(points, print_doc)
    end

    def traverse_all(collection, execute_block)
      collection.each_pair { |name, i| execute_block.call(i) }
    end

    def print_doc
      @print_doc ||= ->(i) { i.doc }
    end

    def define_entity(name, &block)
      ::Interface::PortEntity.new(name).tap { |port| port.instance_eval(&block) }
    end
  end
end
