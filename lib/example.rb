class ExampleAPI
  extend Interface::DSL

  interface(:northbound) do |northbound|
    northbound.defpoint(:user_friendly) do |op|
      describe  "Does something"
      handler   Object
      contract  Dry::Validation.Schema { required(:name).filled }
      returns   Interface::DefaultAdapter
    end
  end
end
