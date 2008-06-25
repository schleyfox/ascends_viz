
# The radius of the earth according to Bob Dole and possibly scientists
# in meters
EARTH_RADIUS = 6378137.0

include Math

# This class contains routines to draw simple shapes in Google Earth.
# I have been playing with Processing lately, so hopefully I can take away 
# things from that and make GE a bit more fun.
#
# Methods with *_coords return ordered pairs of [lon,lat,altitude] while
# the ones without that suffix return KML::Polygon
class KmlShapes

  def self.cylinder(lon, lat, alt, radius)
    cylinder = circle(lon, lat, alt, radius)
    cylinder.extrude = true
    cylinder
  end

  def self.circle(lon, lat, alt, radius)
    bounds = circle_coords(lon, lat, alt, radius)
    KML::Polygon.new(:outer_boundary_is => format_bounds(bounds + [bounds.first]),
                    :altitude_mode => 'absolute')
  end

  def self.circle_coords(lon, lat, alt, radius)
    lat = deg2rad(lat)
    lon = deg2rad(lon)

    d = radius/EARTH_RADIUS

    bounds = []
    for i in (0...36)
      radial = deg2rad(i*10)
      lat_rad = asin(sin(lat)*cos(d) + cos(lat)*sin(d)*cos(radial))
      dlon_rad = atan2(sin(radial)*sin(d)*cos(lat),
                       cos(d) - (sin(lat)*sin(lat_rad)));
      lon_rad = ((lon + dlon_rad + PI) % (2*PI)) - PI

      bounds << [rad2deg(lon_rad), rad2deg(lat_rad), alt]
    end
    bounds
  end

  def heading(start, finish)
    #longtide difference
    a_big = deg2rad(start[1]-finish[1])
    
    #polar distance of end point
    c = deg2rad(90.0-finish[0])
    
    #polar distance of start point
    b = deg2rad(90.0-start[0])
    
    #cosine rule
    a = acos(cos(b)*cos(c) + sin(b) * sin(c) * cos(a_big))
    
    #sine rule
    c_big = asin(sin(a_big) * sin(c) / sin(a))
    
    b_big = deg2rad(180.0 - rad2deg(a_big) + rad2deg(c_big))
    
    #Normalize to North heading
    if (start[0] > finish[0]) && (rad2deg(c_big) > 0.0) && (rad2deg(b_big) > 90.0)
    
      c_big = 180-(rad2deg(c_big))
    end
    
    #we actually find heading counterclockwise from the meridian
    #Correct this by negating
    c_big = deg2rad(c_big)*-1.0
    
    return c_big
  end

  private
  def self.deg2rad(degree)
    degree.to_f*(PI/180.0)
  end

  def self.rad2deg(radian)
    radian.to_f*(180.0/PI)
  end
  
  def self.format_bounds(bounds)
    KML::LinearRing.new(:coordinates => bounds)
  end

end

