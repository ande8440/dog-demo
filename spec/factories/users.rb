FactoryBot.define do
  factory :user do
    sequence :name do |n|
      "Good User #{n}"
    end

    sequence :email do |n|
      "user_email#{n}@fake.com"
    end

    password { "pass123" }
    password_confirmation { "pass123" }

  end
end
