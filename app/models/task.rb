class Task < ApplicationRecord
  # Callbacks
  before_save :normalize_time

  # Validations
  validates :title, :task_start, :task_finish, presence: true 
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}, unless: Proc.new { |tl| tl.email.blank? }
  validate :check_overlapping_tasks

  # Scopes
  scope :in_the_past,     -> { where("task_finish < ?", DateTime.now.utc).order(:task_start) }
  scope :in_the_present,  -> { where("task_start <= ? AND task_finish >= ?", DateTime.now.utc, DateTime.now.utc).order(:task_start) }
  scope :in_the_future,   -> { where("task_start > ?", DateTime.now.utc).order(:task_start) }

  # Custom validations
  def check_overlapping_tasks
    tasks_overlapped = Task.where('task_start < ? AND task_finish > ?', self.task_finish.try(:utc), self.task_start.try(:utc)).where.not(id: self.id).limit(1)

    errors.add(:overlap_error, I18n.t('activerecord.errors.overlap_error')) if tasks_overlapped.present?
  end

  #JBuilder
  def to_builder
    Jbuilder.new do |task|
      task.title title
      task.task_start task_start
      task.task_finish task_finish
      task.email email.present? ? email : I18n.t('tasks.unregistered')
      task.time_status time_status
    end
  end

  private
  def time_status
    if Task.in_the_past.include? self
      I18n.t('tasks.past_task')
    elsif Task.in_the_present.include? self
      I18n.t('tasks.current_task')
    else
      I18n.t('tasks.future_task')
    end
  end

  def normalize_time
    self.task_start = self.task_start.to_datetime.change(sec: 0)
    self.task_finish = self.task_finish.to_datetime.change(sec: 0)
  end
end
