# frozen_string_literal: true

module ActionController
  module Flash
    def render(*args)
      options = args.last.is_a?(Hash) ? args.last : {}

      if alert = options.delete(:alert)
        flash[:alert] = alert
      end

      if notice = options.delete(:notice)
        flash[:notice] = notice
      end

      if other = options.delete(:flash)
        flash.update(other)
      end

      super(*args)
    end
  end
end
