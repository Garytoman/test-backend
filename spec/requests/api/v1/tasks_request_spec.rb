require 'rails_helper'


RSpec.describe 'Tasks API', type: :request do
  before(:each) do
    @past_task = create(:past_task)
    @present_task = create(:task) 
    @future_task = create(:future_task)
    @headers = { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("admin","secret") }
  end
  
  describe 'GET /api/v1/tasks/all' do
    before(:each) do
      get all_api_v1_tasks_path, headers: @headers
    end

    it 'returns success status code' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a valid JSON response' do
      first_task = json.first      

      expect(json).to be_present
      expect(json).not_to be_empty
      expect(json.size).to eq(3)

      expect(first_task.keys).to contain_exactly("title", "task_start", "task_finish", "email", "time_status")
      expect(first_task['title']).to eq(@past_task.title)
      expect(Time.zone.parse(first_task['task_start'])).to eq(@past_task.task_start)
      expect(Time.zone.parse(first_task['task_finish'])).to eq(@past_task.task_finish)
      expect(first_task['email']).to eq(@past_task.email)
      expect(first_task['time_status']).to eq(I18n.t('tasks.past_task'))
    end
  end

  describe 'GET /api/v1/tasks/all with time_status param' do
    context 'with time_status = in_the_past' do
      before(:each) do
        get all_api_v1_tasks_path, params: { time_status: 'in_the_past' }, headers: @headers
      end

      it 'returns success status code' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a valid JSON response with only tasks in the past' do
        first_task = json.first      

        expect(json).to be_present
        expect(json).not_to be_empty
        expect(json.size).to eq(1)

        expect(first_task.keys).to contain_exactly("title", "task_start", "task_finish", "email", "time_status")
        expect(first_task['title']).to eq(@past_task.title)
        expect(Time.zone.parse(first_task['task_start'])).to eq(@past_task.task_start)
        expect(Time.zone.parse(first_task['task_finish'])).to eq(@past_task.task_finish)
        expect(first_task['email']).to eq(@past_task.email)
        expect(first_task['time_status']).to eq(I18n.t('tasks.past_task'))
      end
    end

    context 'with time_status = in_the_present' do
      before(:each) do
        get all_api_v1_tasks_path, params: { time_status: 'in_the_present' }, headers: @headers
      end

      it 'returns success status code' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a valid JSON response with only tasks in the present' do
        first_task = json.first      

        expect(json).to be_present
        expect(json).not_to be_empty
        expect(json.size).to eq(1)

        expect(first_task.keys).to contain_exactly("title", "task_start", "task_finish", "email", "time_status")
        expect(first_task['title']).to eq(@present_task.title)
        expect(Time.zone.parse(first_task['task_start'])).to eq(@present_task.task_start)
        expect(Time.zone.parse(first_task['task_finish'])).to eq(@present_task.task_finish)
        expect(first_task['email']).to eq(@present_task.email)
        expect(first_task['time_status']).to eq(I18n.t('tasks.current_task'))
      end
    end

    context 'with time_status = in_the_future' do
      before(:each) do
        get all_api_v1_tasks_path, params: { time_status: 'in_the_future' }, headers: @headers
      end

      it 'returns success status code' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a valid JSON response with only tasks in the future' do
        first_task = json.first      

        expect(json).to be_present
        expect(json).not_to be_empty
        expect(json.size).to eq(1)

        expect(first_task.keys).to contain_exactly("title", "task_start", "task_finish", "email", "time_status")
        expect(first_task['title']).to eq(@future_task.title)
        expect(Time.zone.parse(first_task['task_start'])).to eq(@future_task.task_start)
        expect(Time.zone.parse(first_task['task_finish'])).to eq(@future_task.task_finish)
        expect(first_task['email']).to eq(@future_task.email)
        expect(first_task['time_status']).to eq(I18n.t('tasks.future_task'))
      end
    end
  end
end