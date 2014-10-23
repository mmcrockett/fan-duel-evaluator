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
