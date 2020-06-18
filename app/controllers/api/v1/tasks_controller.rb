# frozen_string_literal: true

module Api
  module V1
    # API module to return information from the Tasks table
    class TasksController < ApplicationController
      # Both user and password, in a real application, should be stored
      #  in environment variables or any other type of secret storage,
      #  making sure they are not uploaded to the repository. In addition you should use
      #  a secure connection since the access data is visible on the call.
      #  In this example case they are shown for simplicity API testing.
      http_basic_authenticate_with name: 'admin', password: 'secret'

      PERMITTED_PARAMS = ['in_the_past', 'in_the_present', 'in_the_future'].freeze

      # The all method of the API supports an optional parameter (time_status) to filter 
      #  the tasks it returns based on their state over time. This parameter supports the 
      #  following values: in_the_past, in_the_present, in_the_future. If it does not 
      #  receive a parameter, or the parameter received is not valid, it returns all the tasks
      def all
        resp = []

        tasks = if params[:time_status].present? && PERMITTED_PARAMS.include?(params[:time_status])
                  Task.send(params[:time_status])
                else
                  Task.all
                end

        tasks.each do |task|
          resp << JSON.parse(task.to_builder.target!)
        end

        render json: resp, status: 200
      end
    end
  end
end
