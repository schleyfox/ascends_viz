require 'lib/ruby-processing'

# global variables for the benefit of Processing
# lower and upper bounds for recorded CO2 
$co2_low_bound = 0.0
$co2_high_bound = 1.0

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
  def self.colorify(value)
    v = value.to_f
    if v == -9999.99 # -9999.99 is the fill value for the dataset
      return abgr(0,0,0,0)
    else
      c = normalized_colorify(
        normalize($co2_low_bound, $co2_high_bound, v)
      )
      
      abgr(255 ,255*c[2], 255*c[1], 255*c[0])
    end
  end

  # Returns the color for the associated normalized value
  # 
  # Return format is [red, green, blue] where all components are in range
  # [0.0, 1.0]
  def self.normalized_colorify(norm_value)
    hsv((norm_value*300) +60, 0.75, 0.75)
  end

  # Writes a PNG of the color scale to disk using Processing.  This image can
  # be used as a ScreenOverlay in Google Earth
  def self.make_color_bar
    Co2ColorCodeBar.new :title => "Color Bar", :height => 400, :width => 60 
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

    last_line_number = nil #ensures proper spacing of labels
    for i in (0...height)
      value = (1.0/height)*i

      #transform colors on range [0.0, 1.0] to colors on range [0, 255]
      colors = Co2ColorCode.normalized_colorify(value).map{|v| (255*v).to_i }

      stroke(colors[0], colors[1], colors[2])
      line(25,i,width,i)

      # find co2 measurement associated with generated normalized value
      orig_val = Co2ColorCode.lerp($co2_low_bound, $co2_high_bound, value) #.to_i
      
      # label significant points on the bar with values
      if ((orig_val*100).to_i % 10 == 0) && (orig_val*100).to_i != last_line_number
        last_line_number = (orig_val*100).to_i
        text("#{orig_val}", 2, i+12)
      end
    end

    save $co2_color_bar_file
    
    # close window and quit the method
    # There might be a cleaner way
    exit
  end
end

