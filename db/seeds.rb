require 'faker'

Task.create(title:  Faker::Lorem.word, task_start: DateTime.now.utc, task_finish: DateTime.now.utc + 5.hours, email: Faker::Internet.email)
Task.create(title:  Faker::Lorem.word, task_start: Faker::Time.between_dates(from: Date.today - 3, to: Date.today - 2, period: :day), task_finish: Faker::Time.between_dates(from: Date.today - 1, to: Date.today, period: :day))
Task.create(title:  Faker::Lorem.word, task_start: Faker::Time.between_dates(from: Date.today - 5, to: Date.today - 4, period: :day), task_finish: Faker::Time.between_dates(from: Date.today - 1, to: Date.today, period: :day))
Task.create(title:  Faker::Lorem.word, task_start: Faker::Time.between_dates(from: Date.today + 3, to: Date.today + 4, period: :day), task_finish: Faker::Time.between_dates(from: Date.today + 5, to: Date.today + 6, period: :day))
Task.create(title:  Faker::Lorem.word, task_start: Faker::Time.between_dates(from: Date.today + 5, to: Date.today + 6, period: :day), task_finish: Faker::Time.between_dates(from: Date.today + 5, to: Date.today + 6, period: :day))

date1 = DateTime.now - 50.days
date2 = DateTime.now + 100.days

1000.times do 
  start = Time.at((date2.to_f - date1.to_f)*rand + date1.to_f)
  finish = start + 3.days

  Task.create(title: Faker::Lorem.word, task_start: start, task_finish: finish)
end