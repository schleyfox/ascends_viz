require 'lib/ruby-processing'

# global variables for the benefit of Processing
# lower and upper bounds for recorded CO2 
$itt_low_bound = 0.0
$itt_high_bound = 5.5 

$ins_low_bound = 380
$ins_high_bound = 450

# Co2ColorCode implements the color scale used to render columns of
# CO2 in Google Earth.  
#
# == Usage
#
#   Co2ColorCode.colorify(co2_ppm) #=> appropriate color in hex format
#   Co2ColorCode.make_color_bar #=> outputs an image of the color scale
class Co2ColorCode

  # Returns the color associated with @value@ of CO2
  #
  # Return format is #AABBGGRR in hexadecimal notation
  def self.itt_colorify(value)
    v = value.to_f
    if v == -9999.99 # -9999.99 is the fill value for the dataset
      return abgr(0,0,0,0)
    else
      c = normalized_colorify(
        normalize($itt_low_bound, $itt_high_bound, v)
      )
      
      abgr(255 ,c[2], c[1], c[0])
    end
  end

  def self.insitu_colorify(value)
    v = value.to_f
    c = normalized_colorify(
      normalize($ins_low_bound, $ins_high_bound, v)
    )

    abgr(255, c[2], c[1], c[0])
  end

  # Returns the color for the associated normalized value
  # 
  # Return format is [red, green, blue] where all components are in range
  # [0, 255]
  def self.normalized_colorify(v)
    case v
    when (0...(1.0/27.0))
      [255,255,255]
    when ((1.0/27.0)...(6.0/27.0))
      [-918.0*v + 289, -783*v + 169, 255]
    when ((6.0/27.0)...(11.0/27.0))
      [-1215.0*v + 448, -1377.0*v + 561 ,255]
    when ((11.0/27.0)...(16.0/27.0))
      [-1296.0*v + 719, 255, -1296.0*v + 719]
    when ((16.0/27.0)...(22.0/27.0))
      [255, -1296.0*v + 1023, 0]
    when ((22.0/27.0)...(26.0/27.0))
      [-1026.0*v + 1052, 0, 432.0*v - 337]
    else
      [0,0,0]
    end
  end

  # Writes a PNG of the color scale to disk using Processing.  This image can
  # be used as a ScreenOverlay in Google Earth
  def self.make_color_bar
    Co2ColorCodeBar.new :title => "Color Bar", :height => 400, :width => 90 
  end

  # Convenience method to format integer color components into abgr hex format
  def self.abgr(a,b,g,r)
    "%02X%02X%02X%02X" % [a,b,g,r]
  end

  # Converts a value expressed in HSV colormode to RGB
  # 
  # @h@ is on range [0, 360]
  # @s@ and @v@ are on range [0.0, 1.0]
  #
  # Returns [red, green, blue] where all components are on range [0.0, 1.0]
  # Math stolen from 
  # http://en.wikipedia.org/wiki/HSL_and_HSV#Conversion_from_HSV_to_RGB
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

  # Constrains values on range [min, max] to between 0.0 and 1.0
  def self.normalize(min, max, value)
    if value > max
      return max
    elsif value < min
      return min
    else
      return (value-min)/(max-min)
    end
  end

  # Linear Interpolation: transforms @value@ on range [0.0, 1.0] to equivalent
  # value on range [min, max]
  def self.lerp(min, max, value)
    (max-min)*value + min
  end
end

# Processing class to create color bar for Co2ColorCode
class Co2ColorCodeBar < Processing::App
  def setup
    background(255)
    font = load_font("#{GTRON_ROOT}/lib/Electron-12.vlw")
    text_font(font)
    fill(0)

    text("ITT", 2, 12)
    text("ppm", width - text_width("ppm"), 12)


    for i in (0...height)
      value = (1.0/height)*i

      colors = Co2ColorCode.normalized_colorify(value)

      stroke(colors[0], colors[1], colors[2])
      line(width/3.0,(height-i),(2*width)/3.0,(height-i))

      # find co2 measurement associated with generated normalized value
      itt_val = Co2ColorCode.lerp($itt_low_bound, $itt_high_bound, value)
      ins_val = Co2ColorCode.lerp($ins_low_bound, $ins_high_bound, value)

      # label points on the bar with values
      if i % (height/6.0).floor == 0 
        text("%2.1f" % itt_val, 2, (height-i)-6)
        text("%3d" % ins_val, width-(text_width("%3d" % ins_val))-2, 
             (height-i)-6)
      end
    end

    save $co2_color_bar_file
    
    # close window and quit the method
    # There might be a cleaner way
    exit
  end
end

