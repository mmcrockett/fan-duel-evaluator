class Roster
  attr_reader :budget, :pts, :roster, :name, :s

  def initialize(name)
    @name   = name
    @s      = ""
    @budget = 60000
    @pts    = 0
    @roster = []
  end

  def <<(player)
    @budget -= player[:cost]
    @pts    += player[:avg]
    @s      << "#{player[:name]}-"
    @roster << player
  end

  def average_budget
    positions_remaining = 9 - @roster.size
    if (0 == positions_remaining)
      return @budget
    else
      return (@budget/positions_remaining).to_i
    end
  end

  def to_s
    return "#{@name}:#{@pts}:#{@budget}"
  end
end

class Array
  def best(budget, roster)
    self.each do |player|
      if (budget >= player[:cost])
        if (false == roster.include?(player))
          return player
        end
      end
    end
  end

  def sum_all
    sum  = Float(0)

    self.each do |val|
      sum += Float(val)
    end

    return sum
  end

  def variance
    mean = nil
    var  = nil
    size = self.size()

    if (0 != size)
      mean = self.mean()
      var  = Float(0)

      self.each do |val|
        dev = Float(val) - mean
        var += dev*dev
      end

      var = (var/Float(size))
    end

    return var
  end

  def mean
    mean = nil
    sum  = Float(0)
    size = self.size()

    if (0 != size)
      self.each do |val|
        sum += Float(val)
      end

      mean = (sum/Float(size))
    end

    return mean
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
