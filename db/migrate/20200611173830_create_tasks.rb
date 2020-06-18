# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.datetime :task_start
      t.datetime :task_finish
      t.string :email

      t.timestamps
    end
  end
end
