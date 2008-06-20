class Co2ColorCode
  def self.colorify(value)
    value = value.dup
    if value == -9999
      return rgba(0,0,0,0)
    else
      value = normalize(value, 370, 450)
      return rgba(value*255,value*255,value*255,0)
    end
  end

  def self.rgba(r,g,b,a)
    "%02X%02X%02X%02X" % [a,r,g,b]
  end

  def self.normalize(value, min, max)
    if value > max
      return max
    elsif value < min
      return min
    else
      return (value-min)/(max-min)
    end
  end
end

