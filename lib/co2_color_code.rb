require 'lib/ruby-processing'

$co2_low_bound = 370
$co2_high_bound = 450

class Co2ColorCode
  def self.colorify(value)
    v = value.to_f
    if v == -9999.99
      return abgr(0,0,0,0)
    else
      c = normalized_colorify(normalize(v, $co2_low_bound, $co2_high_bound))
      abgr(255 ,255*c[2], 255*c[1], 255*c[0])
    end
  end

  def self.normalized_colorify(norm_value)
    hsv((norm_value*300) +60, 0.75, 0.75)
  end

  def self.make_color_bar
    Co2ColorCodeBar.new :title => "Color Bar", :height => 400, :width => 60 
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

  def self.lerp(min, max, value)
    (max-min)*value + min
  end
end

class Co2ColorCodeBar < Processing::App
  def setup
    background(255)
    font = load_font("#{GTRON_ROOT}/lib/Electron-12.vlw")
    text_font(font)
    fill(0)
    last_line_number = nil
    for i in (0...height)
      value = (1.0/height)*i
      colors = Co2ColorCode.normalized_colorify(value).map{|v| (255*v).to_i } 
      stroke(colors[0], colors[1], colors[2])
      line(25,i,width,i)

      orig_val = Co2ColorCode.lerp($co2_low_bound, $co2_high_bound, value).to_i
      
      if (orig_val % 10 == 0) && orig_val != last_line_number
        last_line_number = orig_val
        text("#{orig_val}", 2, i+12)
        #stroke(0)
        #line(23,i,height,i)
      end
    end
    save "#{GTRON_ROOT}/output/co2_color_bar.png"
    exit
  end
end

