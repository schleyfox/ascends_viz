class Co2ColorCode
  def self.colorify(value)
    v = value.to_f
    if v == -9999
      return abgr(0,0,0,0)
    else
      v = normalize(v, 370, 450)
      return abgr(150 ,(1.0-v)*255,(1.0-v)*255,(1.0-v)*255)
    end
  end

  def self.abgr(a,b,g,r)
    "%02X%02X%02X%02X" % [a,b,g,r]
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

