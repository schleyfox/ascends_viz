
# The radius of the earth according to Bob Dole and possibly scientists
# in meters
EARTH_RADIUS = 6378137.0


# This class contains routines to draw simple shapes and make geography
# calculations in Google Earth. I have been playing with Processing lately,
# so hopefully I can take away things from that and make GE a bit more fun.
#
# Methods with *_coords return ordered pairs of [lon,lat,altitude] while
# the ones without that suffix return KML::Polygon
class KmlTools
  #Get class methods and constants
  include Math
  extend Math

  # Creates an extruded circle centered on (@lat@, @lon@) at altitude @alt@
  # with a radius of @radius@ (in meters)
  #
  # Google Earth is extremely weird about making real cylinders (I would love
  # a triangle strip primitive) so cylinders are faked by extruding towards
  # the center of the earth.  Luckily this meets the needs of the ASCENDS
  # visualization
  def self.cylinder(lon, lat, alt, radius)
    cylinder = circle(lon, lat, alt, radius)
    cylinder.extrude = true
    cylinder
  end

  # Creates a Google Earth polygon that is a circle centered on (@lat@, @lon@)
  # at an altitude of @alt@ with a radius of @radius@ (in meters).
  def self.circle(lon, lat, alt, radius)
    bounds = circle_coords(lon, lat, alt, radius)
    KML::Polygon.new(
      :outer_boundary_is => format_bounds(bounds + [bounds.first]),
      :altitude_mode => 'absolute'
    )
  end

  # generates coordinates in the form [[lon, lat, alt],...] for a circle
  # centered on (@lon@, @lat@) at altitude @alt@ with a radius of @radius@
  # (in meters)
  #
  # This code uses the haversine formula and was ported from a PHP
  # Google Earth circle generator:
  # http://dev.bt23.org/keyhole/circlegen/output.phps
  def self.circle_coords(lon, lat, alt, radius)
    bounds = []
    for i in (0...36)
      bounds << haversine(lon, lat, radius, i*10) + [alt]
    end
    bounds
  end

  # Creates a square extruded to the ground in a columnar fashion
  def self.square_column(lon, lat, alt, heading, side_length)
    square = square(lon, lat, alt, heading, side_length)
    square.extrude = true
    square
  end

  # Creates square polygon for Google Earth centered at [@lon@,@lat@,@alt@]
  # oriented at the angle @heading@ with the side length @side_length@
  def self.square(lon, lat, alt, heading, side_length)
    bounds = square_coords(lon, lat, alt, heading, side_length)
    KML::Polygon.new(
      :outer_boundary_is => format_bounds(bounds + [bounds.first]),
      :altitude_mode => 'absolute'
    )
  end

  # Generates coordinates of form [lon, lat, alt] to make the perimeter of a
  # square centered on [@lon@, @lat@] at altitude @alt@ oriented at the 
  # angle (in degrees) @heading@ with a side length of @side_length@ meters
  def self.square_coords(lon, lat, alt, heading, side_length)
    radius = side_length/(sqrt(2))

    angles = [45, 135, 225, 315].map{|a| (heading + a) % 360.0}

    bounds = angles.map do |angle|
      haversine(lon, lat, radius, angle) + [alt]
    end
  end

  # Calculates the [lon, lat] of a point at great circle @distance@ meters
  # from [@lon@, @lat@] at heading @angle@ (degrees).
  def self.haversine(lon, lat, distance, angle)
    # d is the great circle distance in radians
    d = distance/EARTH_RADIUS

    # convert everything to radians
    lat = deg2rad(lat)
    lon = deg2rad(lon)

    radial = deg2rad(angle)

    # latitude of the point on the circle
    lat_rad = asin(sin(lat)*cos(d) + cos(lat)*sin(d)*cos(radial))
    
    # change in longitude from the provided center to the circle perimeter
    dlon_rad = atan2(sin(radial)*sin(d)*cos(lat),
                     cos(d) - (sin(lat)*sin(lat_rad)))

    # get longitude of the point on the circle
    lon_rad = ((lon + dlon_rad + PI) % (2*PI)) - PI

    [rad2deg(lon_rad), rad2deg(lat_rad)]
  end

  # Calculates the heading angle between two points. Useful for pirates.
  #
  # @start@ and @finish@ are coordinate pairs in [lon, lat] format
  def self.heading(start, finish)
    start_lat = start[1]
    start_lon = start[0]
    finish_lat = finish[1]
    finish_lon = finish[0]

    #longtide difference
    a_big = deg2rad(start_lon-finish_lon)
    
    #polar distance of end point
    c = deg2rad(90.0-finish_lat)
    
    #polar distance of start point
    b = deg2rad(90.0-start_lat)
    
    #cosine rule
    a = acos((cos(b) * cos(c)) + ((sin(b) * sin(c)) * cos(a_big)))
    
    #sine rule
    c_big = 0.0
    begin
      c_big = asin(sin(a_big) * sin(c) / sin(a)) 
    rescue
      c_big = 1.0
    end
    
    b_big = deg2rad(180.0 - (rad2deg(a_big) + rad2deg(c_big)))
    
    #Normalize to North heading
    if (start_lat > finish_lat) && (rad2deg(c_big) > 0.0) && 
      (rad2deg(b_big) > 90.0)

      c_big = deg2rad(180.0-(rad2deg(c_big)))
    end
    
    #we actually find heading counterclockwise from the meridian
    #Correct this by subtracting from 360 
    c_big_deg = 360.0 - rad2deg(c_big)
    
    #this should make everything happy, but check
    return c_big_deg
  end

  private

  # converts degrees to radians
  def self.deg2rad(degree)
    degree.to_f*(PI/180.0)
  end

  # converts radians to degrees
  def self.rad2deg(radian)
    radian.to_f*(180.0/PI)
  end
  
  # returns LinearRing object with correct bounds
  def self.format_bounds(bounds)
    KML::LinearRing.new(:coordinates => bounds)
  end

end

