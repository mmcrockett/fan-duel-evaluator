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

  def median
    i = (self.size/2).to_i
    return self.sort[i]
  end
end
