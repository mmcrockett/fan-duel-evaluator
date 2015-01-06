class Array
  def tolerance(tolerance = 80)
    tolerance_to_n = {
      80 => 1.28155,
      90 => 1.64485,
      95 => 1.95996,
      98 => 2.32635,
      99 => 2.57583
    }
    n = tolerance_to_n[tolerance]

    if (nil == n)
      raise "!ERROR: Invalid tolerance '#{tolerance}', add to table."
    else
      return (self.mean - (self.stddev * n))
    end
  end

  def stddev
    return Math.sqrt(self.variance())
  end

  def variance
    mean = self.mean()
    var  = Float(0)

    if (0 != self.size)
      self.each do |val|
        dev = Float(val) - mean
        var += dev*dev
      end

      var = (var/Float(self.size))
    end

    return var
  end

  def mean
    mean = nil
    sum  = Float(0)

    if (0 != self.size)
      self.each do |val|
        sum += Float(val)
      end

      mean = (sum/Float(self.size))
    else
      mean = 0
    end

    return mean
  end

  def median
    if ((0 != self.size) && (true == self.first.is_a?(Numeric)))
      sorted = self.sort

      if (true == sorted.size.even?())
        i = sorted.size/2
        j = i - 1
        return (sorted[i] + sorted[j])/2.0
      else
        return sorted[(sorted.size-1)/2]
      end
    else
      return 0
    end
  end
end
