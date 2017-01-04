require "spec_helper"

# class SomeFacade
#   extend Interface::DSL

#   interface(:northbound) do |northbound|
#     northbound.defpoint(:user_friendly) do |op|
#       op.describe "does something with user"
#       op.implementation Object
#       op.accepts(user: Class, params: Hash)
#       op.returns(
#         success: [:ok,    Object],
#         failure: [:error, String]
#       )
#     end
#   end
# end

describe Interface::DSL do
  let(:placebo) { Class.new }

  before do
    placebo.extend(Interface::DSL)
  end

  describe '.interface' do
    it 'exposes .interface method' do
      expect(placebo.respond_to?(:interface)).to be_truthy
    end

    it 'has empty interfaces' do
      expect(placebo.interfaces.empty?).to be_truthy
    end

    it 'registers given interface' do
      placebo.interface(:i_test) { }

      expect(placebo.interfaces.empty?).to be_falsey
      expect(placebo.interfaces.keys).to eq(['i_test'])
    end

    it 'does not mutate any interface' do
      placebo.interface(:new_api) {  }

      expect { placebo.interface(:new_api) { |i| } }.to raise_error(Interface::DSL::ImmutableInterface)
    end

    it 'exposes new interface as method' do
      placebo.interface(:new_api) { }

      # can't check placebo.respond_to?(:new_api) due to dynamic dispatch via method_missing
      expect(placebo.interfaces).to respond_to(:new_api)
      expect(placebo.new_api.name).to eq(:new_api)
    end

    it 'creates nested interface' do
      placebo.interface(:new_api) { }

      expect(placebo.new_api.interfaces).to be_empty
    end
  end

  describe '.defpoint' do
    before do
      allow(placebo).to receive(:define_entity).with(:test_endpoint) { { name => "test_endpoint_implementation" } }
    end

    it 'fails upon attempt to define endpoint at top level API' do
      expect { placebo.defpoint(:test_endpoint) }.to raise_error(::Interface::DSL::OrphanPort)
    end

    it 'does not define endpoint in a top level API as a side-effect' do
      placebo.interface(:new_api) do |i|
        i.defpoint(:test_endpoint) { |p| }
      end

      expect(placebo.points).to be_empty
    end

    it 'exposes new endpoint in a given interface' do
      placebo.interface(:new_api) do |i|
        i.defpoint(:test_endpoint) { |p| }
      end

      expect(placebo.new_api.points.keys).to eq(['test_endpoint'])
    end
  end

  describe '.extend_api' do
    let(:humanoid)        { Class.new }
    let(:jump_extension)  { Class.new }
    let(:think_extension) { Class.new }

    before do
      humanoid.extend(Interface::DSL)
      humanoid.interface(:base_functions) do |ext|
        ext.defpoint(:jump) {  }
      end

      jump_extension.extend(Interface::DSL)
      jump_extension.interface(:jumping) do |ext|
        ext.defpoint(:on_one_leg) {  }
      end

      think_extension.extend(Interface::DSL)
      think_extension.interface(:thinking) do |ext|
        ext.defpoint(:deeply) {  }
      end
    end

    it 'passes preconditions check' do
      expect(humanoid.interfaces.keys).to eq(['base_functions'])
      expect(humanoid.base_functions.points.keys).to eq(['jump'])
    end

    it 'extends top-level interface' do
      humanoid.extend_api(as: 'vital_functions', with_class: think_extension)

      expect(humanoid.vital_functions.thinking.deeply.name).to eq(:deeply)
    end

    it 'extends nested interface' do
      humanoid.base_functions.extend_api(as: 'physical', with_class: jump_extension)

      expect(humanoid.base_functions.physical.jumping.on_one_leg.name).to eq(:on_one_leg)
    end
  end

  context 'interface endpoints' do
    let(:humanoid)       { Class.new }
    let(:try_thinking)   { Class.new }
    let(:happy_response) { "Happy Humanoid's Dream" }

    before do
      humanoid.extend(Interface::DSL)

      humanoid.interface(:brain) do |i|
        i.defpoint(:think) do |thought|
          thought.implementation try_thinking
        end
      end
    end

    describe '#call' do
      it 'calls .call method on endpoint implementation class' do
        allow(try_thinking).to receive(:call).and_return(happy_response)

        expect(humanoid.brain.think.call).to eq(happy_response)
      end

      it 'fails with specific error if implementation is not callable' do
        humanoid.interface(:failure) { |i| i.defpoint(:apparent) {}  }

        expect { humanoid.failure.apparent.call }.to raise_error(::Interface::PortEntity::WTFError)
      end

      context 'input arguments validation' do
        context 'passes arguments to implmentation class' do
          before do
            try_thinking.instance_eval <<-EOF
              def call(options = {})
                options[:input]
              end
            EOF
          end

          it 'accepts args (stupid name I know)' do
            expect(humanoid.brain.think.call(input: 123)).to eq(123)
          end

          it 'passes block to implementation class' do
            try_thinking.instance_eval <<-EOF
              def call(&block)
                block.call
              end
            EOF

            expect(humanoid.brain.think.call { 123 }).to eq(123)
          end

          it 'works fine if implementation accepts arguments, but called without args' do
            expect(humanoid.brain.think.call).to eq(nil)
          end
        end

        context 'input arguments validation' do
          let(:schema) do
            Dry::Validation.Schema do
              required(:address).schema do
                required(:city).filled(min_size?: 3)

                required(:country).schema do
                  required(:name).filled
                end
              end
            end
          end

          before do
            humanoid.interface(:cognition) do |i|
              i.defpoint(:criticism) do |thought|
                thought.contract       schema
                thought.implementation try_thinking
              end
            end

            allow(try_thinking).to receive(:call).and_return(happy_response)
          end

          it 'fails with specific error if input does not comply with contract' do
            expect { humanoid.cognition.criticism.call(bla: 'wat') }.to raise_error(::Interface::PortEntity::InvalidInputError)
          end

          it "fails with specific error if called with zero arity"  do
            expect { humanoid.cognition.criticism.call }.to raise_error(::Interface::PortEntity::InvalidInputError)
          end
        end
      end
    end
  end

  describe '.doc' do
  end
end
