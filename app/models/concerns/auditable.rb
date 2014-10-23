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

    def set_week_data(week, source)
      puts "#{source}"
      ws = WeekDatum.find_by({:week => week})

      if (Dvoa == source)
        ws.dvoa = true
      elsif (FanDuelPlayer == source)
        ws.fan_duel = true
      elsif (Yahoo == source)
        ws.yahoo = true
      elsif (FfTodayPrediction == source)
        ws.fftoday = true
      else
        raise "!ERROR: Unknown source '#{source}'."
      end

      ws.save
    end
  end
end
