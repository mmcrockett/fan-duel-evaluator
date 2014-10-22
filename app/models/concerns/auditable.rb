module Auditable
  extend ActiveSupport::Concern

  module ClassMethods
    def get_audit(params)
      audit = Audit.find_by(params)

      if (nil == audit)
        params[:status] = 0
        audit = Audit.new(params)
      end

      return audit
    end

    def set_week_data(week, type)
      ws = WeekData.find_by({:week => week})

      if (Dvoa.class == type)
        ws.dvoa = true
      else
        raise "!ERROR: Unknown type '#{type}'."
      end

      ws.save
    end
  end
end
