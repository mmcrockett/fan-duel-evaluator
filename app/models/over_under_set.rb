class OverUnderSet
  attr_reader :scores

  def initialize(import)
    @expectations = {}
    @scores = []
    @import = import

    overunders = OverUnder.where({:import => import})

    if (nil == overunders)
      raise "!ERROR: Couldn't find any over unders for '#{import}'."
    end

    overunders.each do |overunder|
      home    = OverUnder.translate(import.league, overunder.home)
      visitor = OverUnder.translate(import.league, overunder.visitor)

      if (overunder.overunder > overunder.home_spread.abs)
        h_score = (overunder.overunder - overunder.home_spread)/2
      else
        p_win   = OverUnder.moneyline_to_decimal(overunder.home_spread)
        h_score = (overunder.overunder*p_win).round(2)
      end

      v_score = (overunder.overunder - h_score)
      @expectations[home]    = {:opp => visitor, :score => h_score}
      @expectations[visitor] = {:opp => home,    :score => v_score}

      @scores << h_score
      @scores << v_score
    end
  end

  def import_id
    return @import.id
  end

  def get_exp_score(team)
    if (false == @expectations.include?(team))
      raise "!ERROR: Can't find '#{team}'."
    end

    return @expectations[team][:score] || 0
  end

  def get_opponent(team)
    if (false == @expectations.include?(team))
      raise "!ERROR: Can't find '#{team}'."
    end

    return @expectations[team][:opp] || '?'
  end

  def multiplier(team, params={})
    params = {:output => :raw, :defensive => false}.merge(params)

    if (true == params[:defensive])
      exp_score = self.get_exp_score(self.get_opponent(team))
    else
      exp_score = self.get_exp_score(team)
    end

    mult = ((exp_score - self.scores.mean)/self.scores.mean)

    if (:raw == params[:output])
      return mult
    elsif (:percentage == params[:output])
      return (mult*100).round()
    elsif (:adjustment == params[:output])
      return (1 + mult).round(3)
    else
      raise "!ERROR: Unknown type '#{type}'."
    end
  end
end
