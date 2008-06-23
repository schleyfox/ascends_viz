
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

