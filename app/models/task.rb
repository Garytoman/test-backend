class Task < ApplicationRecord
  # Callbacks
  before_save do
    self.task_start = self.task_start.to_datetime.change(sec: 0)
    self.task_finish = self.task_finish.to_datetime.change(sec: 0)
  end

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
end
