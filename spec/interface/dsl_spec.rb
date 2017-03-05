require "spec_helper"

# class SomeClass
#   def self.call({})
#     puts "ok"
#   end
# end

# class SomeFacade
#   extend Interface::DSL

#   interface(:northbound) do |northbound|
#     northbound.defpoint(:user_friendly) do |op|
#       describe  "Does something"
#       handler   SomeClass
#       contract  Dry::Validation.Schema { required(:name).filled }
#       returns   Interface::DefaultAdapter
#     end
#   end
# end

# That's an ugly draft. Will be moved to shared
class TryThinking; end
class SomeHandler; end
class IncrementAdapter < Struct.new(:callable)
  extend FactoryMethods
  deffactory :call

  def call
    callable.call + 1
  end
end

describe Interface::DSL do
  let(:placebo)        { Class.new }
  let(:settings_class) { Class.new }

  before do
    placebo.extend(Interface::DSL)
  end

  describe '.defsettings' do
    describe 'behaviour' do
      it 'exposes .defsettings method' do
        expect(placebo.respond_to?(:defsettings)).to be_truthy
        expect(placebo.respond_to?(:_settings)).to be_truthy
      end

      it 'allows client to set settings container class or module' do
        placebo.defsettings(settings_class)

        expect(placebo._settings).to eq(settings_class)
      end
    end

    describe 'dependency on settings class' do
      let(:configs) { [:allow_top_level_api_endpoints?] }

      it 'fails if client sets instance instead of class or module' do
        expect { placebo.defsettings(123) }.to raise_error(::Interface::Errors::UnexpectedInstanceError)
      end

      describe 'Default Settings' do
        let(:config) { Interface::DefaultSettings.config }

        it 'exposes .config method' do
          expect(Interface::DefaultSettings).to respond_to(:config)
        end

        describe '.config' do
          it 'implements all expected methods' do
            expect(config.response_adapter).to eq(::Interface::DefaultAdapter)
            expect(config.allow_top_level_api_endpoints?).to eq(false)
          end
        end
      end

      it 'fails if given settings class does not implement all necessary settings'
    end
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
      placebo.interface(:new_api) { }

      expect { placebo.interface(:new_api) { } }.to raise_error(::Interface::Errors::ImmutableInterfaceError)
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

  describe '.returns' do
    it 'exposes .retrurns method' do
      expect(placebo.respond_to?(:returns)).to be_truthy
    end

    it 'uses DefaultAdapter by default' do
      expect(placebo._interface_adapter).to eq(::Interface::DefaultAdapter)
    end

    it 'registers response adapter' do
      placebo.returns(::Interface::DirectAdapter)

      expect(placebo._interface_adapter).to eq(::Interface::DirectAdapter)
    end
  end

  describe '.defpoint' do
    before do
      allow(placebo).to receive(:define_entity).with(:test_endpoint) { { name => "test_endpoint_handler" } }
    end

    it 'fails upon attempt to define endpoint at top level API' do
      expect { placebo.defpoint(:test_endpoint) }.to raise_error(::Interface::Errors::OrphanPortError)
    end

    it 'does not define endpoint in a top level API as a side-effect' do
      placebo.interface(:new_api) do
        defpoint(:test_endpoint) { }
      end

      expect(placebo.points).to be_empty
    end

    it 'exposes new endpoint in a given interface' do
      placebo.interface(:new_api) do
        defpoint(:test_endpoint) { }
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
      humanoid.interface(:base_functions) do
        defpoint(:jump) { }
      end

      jump_extension.extend(Interface::DSL)
      jump_extension.interface(:jumping) do
        defpoint(:on_one_leg) { }
      end

      think_extension.extend(Interface::DSL)
      think_extension.interface(:thinking) do
        defpoint(:thoroughly) { }
      end
    end

    it 'passes preconditions check' do
      expect(humanoid.interfaces.keys).to eq(['base_functions'])
      expect(humanoid.base_functions.points.keys).to eq(['jump'])
    end

    it 'extends top-level interface' do
      humanoid.extend_api(as: 'vital_functions', with_class: think_extension)

      expect(humanoid.vital_functions.thinking.thoroughly.name).to eq(:thoroughly)
    end

    it 'extends nested interface' do
      humanoid.base_functions.extend_api(as: 'physical', with_class: jump_extension)

      expect(humanoid.base_functions.physical.jumping.on_one_leg.name).to eq(:on_one_leg)
    end
  end

  context 'interface endpoints' do
    let(:humanoid)       { Class.new }
    let(:happy_response) { "Happy Humanoid's Dream" }

    before do
      humanoid.extend(Interface::DSL)
      humanoid.interface(:brain) do
        defpoint(:think) do
          handler TryThinking
        end
      end
    end

    describe '#call' do
      it 'calls .call method on endpoint handler class' do
        # allow(TryThinking).to receive(:call).and_return(happy_response)
        allow(TryThinking).to receive(:call).and_return(happy_response)

        expect(humanoid.brain.think.call.result).to eq(happy_response)
      end

      it 'fails with specific error if handler is not callable' do
        humanoid.interface(:failure) { defpoint(:apparent) {} }

        expect { humanoid.failure.apparent.call }.to raise_error(Interface::Errors::HandlerMissingError)
      end

      context 'interface adaptation' do
        let(:broken_api)   { 'broken API!' }
        let(:valid_result) { 'valid result!' }

        context 'default reliable adapter' do
          before do
            placebo.interface(:adaptation) do
              defpoint(:service) do
                handler SomeHandler
              end
            end
          end

          describe 'Response object' do
            before { allow(SomeHandler).to receive(:call) { } }

            it 'returns Response object' do
              expect(placebo.adaptation.service.call.class).to eq(::Interface::Response)
            end

            it 'has ok? method' do
              expect(placebo.adaptation.service.call).to respond_to(:ok?)
            end

            it 'has result method' do
              expect(placebo.adaptation.service.call).to respond_to(:result)
            end

            it 'has errors method' do
              expect(placebo.adaptation.service.call).to respond_to(:errors)
            end
          end

          context 'when handler raises error' do
            before { allow(SomeHandler).to receive(:call) { fail(broken_api) } }

            it 'returns Response is not ok' do
              expect(placebo.adaptation.service.call.ok?).to eq(false)
            end

            it 'contains exception object in colelction of errors' do
              expect(placebo.adaptation.service.call.errors.first.message).to eq(broken_api)
            end

            it 'has void result' do
              expect(placebo.adaptation.service.call.result).to be_nil
            end
          end

          context 'when handler returns simple result' do
            before { allow(SomeHandler).to receive(:call) { valid_result } }

            it 'returns Response is not ok' do
              expect(placebo.adaptation.service.call.ok?).to be_truthy
            end

            it 'has empty colelction of errors' do
              expect(placebo.adaptation.service.call.errors).to be_empty
            end

            it 'has void result' do
              expect(placebo.adaptation.service.call.result).to eq(valid_result)
            end
          end

          context 'when handler returns [:ok, result]' do
            before { allow(SomeHandler).to receive(:call) { [:ok, valid_result] } }

            it 'returns Response is not ok' do
              expect(placebo.adaptation.service.call.ok?).to be_truthy
            end

            it 'has empty colelction of errors' do
              expect(placebo.adaptation.service.call.errors).to be_empty
            end

            it 'has void result' do
              expect(placebo.adaptation.service.call.result).to eq(valid_result)
            end
          end

          context 'when handler returns [:error, result]' do
            before { allow(SomeHandler).to receive(:call) { [:error, broken_api] } }

            it 'returns Response is not ok' do
              expect(placebo.adaptation.service.call.ok?).to eq(false)
            end

            it 'contains exception object in colelction of errors' do
              expect(placebo.adaptation.service.call.errors.first).to eq(broken_api)
            end

            it 'has void result' do
              expect(placebo.adaptation.service.call.result).to be_nil
            end
          end
        end

        context 'direct adapter' do
          let(:error) { Class.new(StandardError) }

          before do
            placebo.interface(:adaptation) do
              returns ::Interface::DirectAdapter

              defpoint(:service) do
                handler SomeHandler
              end
            end
          end

          it "fails if handler is not callable" do
            expect { placebo.adaptation.service.call }.to raise_error(::Interface::Errors::AdaptationError)
          end

          it "relays handler's response" do
            allow(SomeHandler).to receive(:call) { valid_result }

            expect(placebo.adaptation.service.call).to eq(valid_result)
          end

          it "relays handler's exceptions" do
            allow(SomeHandler).to receive(:call) { raise(error.new) }

            expect { placebo.adaptation.service.call }.to raise_error(error)
          end
        end

        context 'use separate adapter per interface section' do
          before do
            allow(SomeHandler).to receive(:call).and_return(1)

            placebo.interface(:base_adaptation) do
              returns ::Interface::DirectAdapter

              defpoint(:service) do
                handler SomeHandler
              end

              interface(:nested_interface) do
                returns IncrementAdapter

                defpoint(:service) do
                  handler SomeHandler
                end
              end

              interface(:interface_with_default_adapter) do
                defpoint(:service) do
                  handler SomeHandler
                end
              end
            end
          end

          it "relays handler's response in base section" do
            expect(placebo.base_adaptation.service.call).to eq(1)
          end

          it "increments result in nested section" do
            expect(placebo.base_adaptation.nested_interface.service.call).to eq(2)
          end

          it "use default adapter in nested section without explicitly declared adapter" do
            expect(placebo.base_adaptation.interface_with_default_adapter.service.call.result).to eq(1)
          end
        end
      end

      context 'input arguments validation' do
        context 'passes arguments to handler class' do
          before do
            TryThinking.instance_eval <<-EOF
              def call(options = {})
                options[:input]
              end
            EOF
          end

          it 'accepts args (stupid name I know)' do
            expect(humanoid.brain.think.call(input: 123).result).to eq(123)
          end

          it 'passes block to handler class' do
            TryThinking.instance_eval <<-EOF
              def call(&block)
                block.call
              end
            EOF

            expect((humanoid.brain.think.call { 123 }).result).to eq(123)
          end

          it 'works fine if handler accepts arguments, but called without args' do
            expect(humanoid.brain.think.call.result).to eq(nil)
          end
        end

        context 'input arguments validation' do
          before do
            schema = Dry::Validation.Schema do
              required(:address).schema do
                required(:city).filled(min_size?: 3)

                required(:country).schema do
                  required(:name).filled
                end
              end
            end

            humanoid.interface(:cognition) do
              defpoint(:criticism) do
                contract  &schema
                handler   TryThinking
              end
            end

            allow(TryThinking).to receive(:call).and_return(happy_response)
          end

          it 'fails with specific error if input does not comply with contract' do
            expect { humanoid.cognition.criticism.call(bla: 'wat') }.to raise_error(Interface::Errors::InvalidInputError)
          end

          it "fails with specific error if called with zero arity"  do
            expect { humanoid.cognition.criticism.call }.to raise_error(Interface::Errors::InvalidInputError)
          end
        end
      end
    end
  end

  describe '.doc' do
  end
end
