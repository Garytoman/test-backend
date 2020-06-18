# frozen_string_literal: true

require 'faker'

Task.create(title: Faker::Lorem.word, task_start: DateTime.now, task_finish: DateTime.now + 5.hours, email: Faker::Internet.email)

date1 = DateTime.now - 50.days
date2 = DateTime.now + 100.days

1000.times do
  start = Time.at((date2.to_f - date1.to_f) * rand + date1.to_f)
  finish = start + 3.days

  Task.create(title: Faker::Lorem.word, task_start: start, task_finish: finish, email: Faker::Internet.email)
end
