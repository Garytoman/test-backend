class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update]

  def index
    @past_tasks = Task.in_the_past
    @present_tasks = Task.in_the_present
    @future_tasks = Task.in_the_future
  end

  def show; end

  def new
    @task = Task.new
  end

  def edit; end

  def create
    @task = Task.new task_params
    

    respond_to do |format|
      if @task.save
        format.html { redirect_to task_path(@task), notice: I18n.t('tasks.task_created') }
      else
        format.html { render :new, alert: I18n.t('tasks.create_error') }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to task_path(@task), notice: I18n.t('tasks.task_updated') }
      else
        format.html { render :edit, alert: I18n.t('tasks.update_error') }
      end
    end
  end

  def destroy  
    begin
      @task = Task.find(params[:id])

      respond_to do |format|
        if @task.destroy
          format.html { redirect_to tasks_path, notice: I18n.t('tasks.destroyed') }
        end
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to tasks_path, alert: I18n.t('tasks.unknow_task')
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :email, :task_start, :task_finish)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end