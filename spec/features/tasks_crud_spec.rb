require 'rails_helper'

RSpec.feature 'Tasks CRUD', type: :feature do
  describe 'User request index page' do
    scenario 'show past, current & future tasks' do
      @past_task = create(:past_task)
      @current_task = create(:task)
      @future_task = create(:future_task)
      visit tasks_path

      expect(page).to have_css('.past-container')
      expect(page).to have_css('.current-container')
      expect(page).to have_css('.future-container')
      expect(page).to have_css('.task-card')
      expect(page).to have_content(@past_task.title)
      expect(page).to have_content(@current_task.title)
      expect(page).to have_content(@future_task.title)
    end
  end

  describe 'User request show page' do
    scenario 'show task data' do
      @task = create(:task)
      visit task_path(@task)

      expect(page).to have_css('.task-show')
      expect(page).to have_content(@task.title)
    end
  end

  describe 'User attempts to create a task' do
    before(:each) { visit new_task_path }

    context 'with missing data' do
      scenario 'with empty task title show errors' do
        fill_in('task_task_start', with: DateTime.now)
        fill_in('task_task_finish', with: DateTime.now + 15.minutes)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_css('.task-edit')
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.title.blank'))
        expect(page).to have_content(I18n.t("tasks.create_error"))
        
      end

      scenario 'with empty task_start show errors' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_finish', with: DateTime.now)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.task_start.blank'))
        expect(page).to have_content(I18n.t("tasks.create_error"))
      end

      scenario 'with empty task_finish show errors' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: DateTime.now)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.task_finish.blank'))
        expect(page).to have_content(I18n.t("tasks.create_error"))
      end
    end

    context 'with invalid data' do
      scenario 'task_finish before task starts' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: DateTime.now + 15.minutes)
        fill_in('task_task_finish', with: DateTime.now)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)

        expect(page).to have_content(I18n.t('activerecord.errors.invalid_date_range'))
        expect(page).to have_content(I18n.t("tasks.create_error"))
      end

      scenario 'task overlap another existing task' do
        @task = create(:task)
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: @task.task_start + 5.minutes)
        fill_in('task_task_finish', with: @task.task_finish - 5.minutes)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)

        expect(page).to have_content(I18n.t('activerecord.errors.overlap_error'))
        expect(page).to have_content(I18n.t("tasks.create_error"))
      end
    end

    context 'with correct data filled' do
      scenario 'show confirmation message' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: DateTime.now)
        fill_in('task_task_finish', with: DateTime.now + 15.minutes)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(1)
        
        expect(page).to have_content(I18n.t("tasks.task_created"))
      end
    end
  end

  describe 'User attempts to update a task' do
    before(:each) do
      @task = create(:task)
      visit edit_task_path(@task) 
    end

    context 'with missing data' do
      scenario 'with empty task title show errors' do
        fill_in('task_title', with: '')
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_css('.task-edit')
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.title.blank'))
        expect(page).to have_content(I18n.t("tasks.update_error"))
      end

      scenario 'with empty task_start show errors' do
        fill_in('task_task_start', with: '')
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.task_start.blank'))
        expect(page).to have_content(I18n.t("tasks.update_error"))
      end

      scenario 'with empty task_finish show errors' do
        fill_in('task_task_finish', with: '')
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_content(I18n.t('activerecord.errors.models.task.attributes.task_finish.blank'))
        expect(page).to have_content(I18n.t("tasks.update_error"))
      end
    end

    context 'with invalid data' do
      scenario 'task_finish before task starts' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: DateTime.now + 15.minutes)
        fill_in('task_task_finish', with: DateTime.now)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)

        expect(page).to have_content(I18n.t('activerecord.errors.invalid_date_range'))
        expect(page).to have_content(I18n.t("tasks.update_error"))
      end

      scenario 'task overlap another existing task' do
        @another_task = create(:future_task)
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: @another_task.task_start + 5.minutes)
        fill_in('task_task_finish', with: @another_task.task_finish - 5.minutes)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)

        expect(page).to have_content(I18n.t('activerecord.errors.overlap_error'))
        expect(page).to have_content(I18n.t("tasks.update_error"))
      end
    end

    context 'with correct data filled' do
      scenario 'show confirmation message' do
        fill_in('task_title', with: Faker::Lorem.word)
        fill_in('task_task_start', with: DateTime.now)
        fill_in('task_task_finish', with: DateTime.now + 15.minutes)
        
        expect{find(:button, 'commit').click}.to change{Task.count}.by(0)
        
        expect(page).to have_content(I18n.t("tasks.task_updated"))
      end
    end
  end
end