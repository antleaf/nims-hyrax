# Based on: https://github.com/samvera/hyrax/blob/master/spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    sequence(:display_name) { |n| "User #{n}"}
    sequence(:user_identifier) { |n| "identifier_#{n}" }
    password { 'password' }

    transient do
      # Allow for custom groups when a user is instantiated.
      # @example create(:user, groups: 'avacado')
      groups { [] }
    end

    trait :mock_groups do
      # TODO: Register the groups for the given user key such that we can remove the following from other specs:
      #   `allow(::User.group_service).to receive(:byname).and_return(user.user_key => ['admin'])``
      after(:build) do |user, evaluator|
        # In case we have the instance but it has not been persisted
        ::RSpec::Mocks.allow_message(user, :groups).and_return(Array.wrap(evaluator.groups))
        # Given that we are stubbing the class, we need to allow for the original to be called
        ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).and_call_original
        # We need to ensure that each instantiation of the admin user behaves as expected.
        # This resolves the issue of both the created object being used as well as re-finding the created object.
        ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).with(user: user).and_return(Array.wrap(evaluator.groups))
      end
    end

    trait :guest do
      guest { true }
    end

    trait :email do
      sequence(:display_name) { |n| "Email user #{n}"}
      guest { true }
      employee_type_code { '60' }
    end

    trait :admin do
      roles { build_list :role, 1, :admin }
      guest { false }
      employee_type_code { '11' }
    end

    trait :nims_researcher do
      sequence(:display_name) { |n| "Researcher #{n}"}
      guest { false }
      employee_type_code { '11' }
    end

    trait :nims_other do
      sequence(:display_name) { |n| "Non-Researcher #{n}"}
      guest { false }
      employee_type_code { '21' }
    end

    trait :external_researcher do
      sequence(:display_name) { |n| "External-Researcher #{n}"}
      guest { false }
      employee_type_code { '30' }
    end
  end
end
