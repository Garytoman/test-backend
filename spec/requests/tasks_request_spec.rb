# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:valid_params) do
    {
      task: {
        title: Faker::Lorem.word,
        task_start: DateTime.now,
        task_finish: DateTime.now + 3.hours,
        email: Faker::Internet.email
      }
    }
  end

  let(:invalid_params) do
    {
      task: {
        title: Faker::Lorem.word,
        task_start: nil,
        task_finish: DateTime.now + 3.hours,
        email: Faker::Internet.email
      }
    }
  end

  describe 'tasks index request' do
    it 'renders task#index' do
      get tasks_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe 'tasks show request' do
    it 'renders task#show' do
      @task = create(:task)
      get task_path(@task)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end
  end

  describe 'new task request' do
    it 'renders task#new form' do
      get new_task_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'edit task request' do
    it 'renders task#edit form' do
      @task = create(:task)
      get edit_task_path(@task)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'create task request' do
    context 'with valid params' do
      it 'creates a new task record' do
        expect { post tasks_path, params: valid_params }.to(change { Task.count }.by(1))
      end

      it 'redirect to tasks#show & show notice' do
        post tasks_path, params: valid_params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(task_path(Task.first))
        expect(flash[:notice]).to match(I18n.t('tasks.task_created'))
      end
    end

    context 'with invalid params' do
      it 'do not create a new task record' do
        expect { post tasks_path, params: invalid_params }.to_not(change { Task.count })
      end

      it 'render tasks#new & show alert' do
        post tasks_path, params: invalid_params

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to match(I18n.t('tasks.create_error'))
      end
    end
  end

  describe 'update task request' do
    let(:task) { create(:future_task) }

    context 'with valid params' do
      it 'do not create a new task record' do
        expect(Task.all).to include(task)
        expect { patch task_path(task.id), params: valid_params }.not_to(change { Task.count })
      end

      it 'redirect to tasks#show & show notice' do
        expect(task.title).not_to eq(valid_params[:task][:title])

        patch task_path(task.id), params: valid_params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(task_path(task.id))
        expect(flash[:notice]).to match(I18n.t('tasks.task_updated'))
        task.reload
        expect(task.title).to eq(valid_params[:task][:title])
      end
    end

    context 'with invalid params' do
      it 'render tasks#edit & show alert' do
        patch task_path(task.id), params: invalid_params

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to match(I18n.t('tasks.update_error'))
      end
    end
  end

  describe 'destroy task request' do
    context 'if task is missing' do
      it 'do not modify database' do
        expect { delete task_path(999999999) }.to_not(change { Task.count })
      end

      it 'redirect to tasks#index & show alert' do
        delete task_path(id: 999999999)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(tasks_path)
        expect(flash[:alert]).to eq(I18n.t('tasks.unknow_task'))
      end
    end

    context 'if task is present' do
      let(:task) { create(:task) }

      it 'delete task, redirect to tasks#index & show notice' do
        expect(Task.all).to include(task)
        expect { delete task_path(id: task.id) }.to(change { Task.count }.by(-1))
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq(I18n.t('tasks.destroyed'))
      end
    end
  end
end
