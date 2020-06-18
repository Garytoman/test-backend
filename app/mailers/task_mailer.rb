class TaskMailer < ApplicationMailer
  def task_start_email
    # @email = params[:email]
    # @task_start = params[:task_start]
    @task = params[:task]
    @link = task_url(@task)

    mail(to: @task.email, subject: I18n.t('mailers.task_mailer.subject'))
  end
end
