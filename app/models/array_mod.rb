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
    if (0 != self.size)
      i = (self.size/2).to_i
      return self.sort[i]
    else
      return 0
    end
  end
end
