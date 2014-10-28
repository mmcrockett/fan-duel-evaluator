class WeekDatum < ActiveRecord::Base
  def self.get_week(params = {})
    week = params[:week]

    if (nil == week)
      week = WeekDatum.maximum(:week)
    end

    if (nil == week)
      raise "!ERROR: There is no week data."
    end

    return week
  end
end
