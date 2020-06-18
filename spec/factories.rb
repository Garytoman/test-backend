FactoryBot.define do
  factory :task do
    title         { Faker::Lorem.word } 
    task_start    { DateTime.now.utc - 3.minute}
    task_finish   { DateTime.now.utc + 3.minute }
    email         { Faker::Internet.email }

    factory :past_task do
      task_start  { Faker::Time.between_dates(from: (Date.today - 3), to: Date.today - 2, period: :day) }
      task_finish { Faker::Time.between_dates(from: Date.today - 1, to: Date.today, period: :day) }
    end

    factory :future_task do
      task_start  { Faker::Time.between_dates(from: Date.today + 3, to: Date.today + 4, period: :day) }
      task_finish { Faker::Time.between_dates(from: Date.today + 5, to: Date.today + 6, period: :day) }
    end
  end
end