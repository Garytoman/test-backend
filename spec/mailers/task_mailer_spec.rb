require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let(:future_task) { create(:future_task) }

  describe "task start mailer" do
    let(:mail) { TaskMailer.with(task: future_task).task_start_email }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('mailers.task_mailer.subject'))
      expect(mail.to).to eq([future_task.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it "renders the body" do
      expect(mail.text_part.body.to_s.encode("UTF-8")).to include(I18n.t('mailers.task_mailer.subject'))
      expect(mail.text_part.body.to_s.encode("UTF-8")).to include("#{I18n.t('mailers.task_mailer.content')} #{future_task.task_start.strftime('%d/%m/%Y %H:%M')}h")
      expect(mail.text_part.body.to_s.encode("UTF-8")).to include(I18n.t('mailers.task_mailer.greetings'))
    end

    it 'enqueue mail' do
      expect { 
        TaskMailer.with(task: future_task).task_start_email.deliver_later(wait_until: future_task.task_start)}.
        to(have_enqueued_job.on_queue('mailers').with('TaskMailer', 'task_start_email', 'deliver_now', { :params => { :task => future_task }, :args=>[] }))
    end
  end
end