class Co2ColorCode
  def self.colorify(value)
    v = value.to_f
    if v == -9999.99
      return abgr(0,0,0,0)
    else
      v = normalize(v, 370, 450)
      c = hsv(v*360, 0.75, 0.75)
      return abgr(255 ,255*c[2], 255*c[1], 255*c[0])
    end
  end

  def self.abgr(a,b,g,r)
    "%02X%02X%02X%02X" % [a,b,g,r]
  end

  def self.hsv(h, s, v)
    h_i = (h/60).floor.to_i % 6
    f = (h/60) - (h/60).floor
    p = v*(1-s)
    q = v*(1-(f*s))
    t = v*(1-(1-f)*s)

    case h_i
    when 0
      [v,t,p]
    when 1
      [q,v,p]
    when 2
      [p,v,t]
    when 3
      [p,q,v]
    when 4
      [t,p,v]
    when 5
      [v,p,q]
    end
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

