require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe 'Validations' do
    context 'is valid' do
      it 'with valid attributes' do
        expect(subject).to be_valid
      end

      it 'with valid email' do
        subject.email = 'fakemail@mail.com'
        expect(subject).to be_valid
      end
    end
  
    context 'is not valid' do
      it 'without a title attribute' do
        subject.title = nil
        expect(subject).to_not be_valid
      end

      it 'without a task_start attribute' do
        subject.task_start = nil
        expect(subject).to_not be_valid
      end

      it 'without a task_finish attribute' do
        subject.task_finish = nil
        expect(subject).to_not be_valid
      end

      it 'with invalid email' do
        subject.email = 'fakemail.mail'
        expect(subject).to_not be_valid

        subject.email = 'fakemail@mail'
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'Custom validations' do
    describe 'check_overlapping_tasks validation' do
      before(:each) do
        @start = DateTime.now.utc.change(sec: 0)
        create(:task, task_start: @start)
      end

      context 'is valid' do
        it 'if new task starts before existing task & finish before existing task' do
          new_task = build(:task, task_start: @start - 3.hour, task_finish: @start - 1.hour)
          expect(new_task).to be_valid
        end

        it 'if new task starts after existing task & finish after existing task' do
          new_task = build(:task, task_start: @start + 6.hours, task_finish: @start + 7.hour)
          expect(new_task).to be_valid
        end

        it 'if new task starts before existing task & finish when starts existing task' do
          new_task = build(:task, task_start: @start - 1.hour, task_finish: @start)
          expect(new_task).to be_valid
        end

        it 'if new task starts when finish existing task & finish after existing task' do
          new_task = build(:task, task_start: @start + 5.hour, task_finish: @start + 6.hours)
          expect(new_task).to be_valid
        end
      end

      context 'is not valid' do
        it 'if new task starts before existing task & finish during existing task' do
          new_task = build(:task, task_start: @start - 1.hour, task_finish: @start + 2.minutes) 
          new_task.valid?

          expect(new_task.errors[:overlap_error]).to include(I18n.t('activerecord.errors.overlap_error'))
          expect(new_task).to_not be_valid
        end

        it 'if new task starts during existing task & finish after existing task' do
          new_task = build(:task, task_start: @start - 2.minutes, task_finish: @start + 5.minutes)
          new_task.valid?

          expect(new_task.errors[:overlap_error]).to include(I18n.t('activerecord.errors.overlap_error'))
          expect(new_task).to_not be_valid
        end

        it 'if new task starts before existing task & finish after existing task' do
          new_task = build(:task, task_start: @start - 1.hour, task_finish: @start + 6.minutes)
          new_task.valid?

          expect(new_task.errors[:overlap_error]).to include(I18n.t('activerecord.errors.overlap_error'))
          expect(new_task).to_not be_valid
        end

        it 'and therefore on create raise ActiveRecord::RecordInvalid error' do
          expect { create(:task, task_start: @start - 1.hour, task_finish: @start + 3.hours) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    describe 'check_date_range validation' do
      before(:each) do
        @task = build(:future_task)
      end

      context 'is valid' do
        it 'if task starts before task finish & all dates are defined' do
          @task.task_start = DateTime.now - 10.minutes
          @task.task_finish = DateTime.now + 10.minutes
          @task.valid?

          expect(@task).to be_valid
        end
      end

      context 'is not valid' do
        it 'if task starts after task finish' do
          @task.task_start = DateTime.now + 10.minutes
          @task.task_finish = DateTime.now - 10.minutes
          @task.valid?

          expect(@task.errors[:invalid_date_range]).to include(I18n.t('activerecord.errors.invalid_date_range'))
          expect(@task).to_not be_valid
        end

        it 'if the task starts at the same time it ends' do
          @task.task_start = DateTime.now
          @task.task_finish = DateTime.now
          @task.valid?

          expect(@task.errors[:invalid_date_range]).to include(I18n.t('activerecord.errors.invalid_date_range'))
          expect(@task).to_not be_valid
        end

        it 'if task_start is nil' do
          @task.task_start = nil
          @task.valid?

          expect(@task.errors[:invalid_date_range]).to include(I18n.t('activerecord.errors.invalid_date_range'))
          expect(@task).to_not be_valid
        end

        it 'if task_finish is nil' do
          @task.task_finish = nil
          @task.valid?

          expect(@task.errors[:invalid_date_range]).to include(I18n.t('activerecord.errors.invalid_date_range'))
          expect(@task).to_not be_valid
        end
      end
    end
  end

  describe 'Scopes' do
    before(:each) do
      @past_task = create(:past_task)
      @present_task = create(:task)
      @future_task = create(:future_task)
    end

    describe '#in_the_past' do
      it "returns a past tasks" do
        expect(Task.in_the_past.count).to eq(1)
      end
    
      it "does not return present or future tasks" do
        expect(Task.in_the_past).to_not include(@present_task)
        expect(Task.in_the_past).to_not include(@future_task)
      end
    end

    describe '#in_the_present' do
      it "returns a present task" do
        expect(Task.in_the_present.count).to eq(1)
      end
    
      it "does not return past or future tasks" do
        expect(Task.in_the_present).to_not include(@past_task)
        expect(Task.in_the_present).to_not include(@future_task)
      end
    end

    describe '#in_the_future' do
      it "returns a future task" do
        expect(Task.in_the_future.count).to eq(1)
      end
    
      it "does not return past or present tasks" do
        expect(Task.in_the_future).to_not include(@past_task)
        expect(Task.in_the_future).to_not include(@present_task)
      end
    end
  end
end