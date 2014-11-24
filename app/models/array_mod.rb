class Array
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

    if (0 != self.size)
      mean = self.mean()
      var  = Float(0)

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
        return (sorted[i] + sorted[j])/2
      else
        return sorted[(sorted.size-1)/2]
      end
    else
      return 0
    end
  end
end
