desc "Tests out my shape drawing code by drawing simple shapes"
task :draw_simple_shapes do
  kml = KMLFile.new
  doc = KML::Document.new(:name => "Simple Shapes")
  circle_p = KML::Placemark.new(:name => "Circle")
  circle = KmlTools.circle(40,37,9000,100000)
  circle_p.features << circle

  cylinder_p = KML::Placemark.new(:name => 'Cylinder')
  cy_sty = KML::Style.new(:id => "doit",
                          :line_style => KML::LineStyle.new(:color => "4cff5555"),
                          :poly_style => KML::PolyStyle.new(:color => "4cff5555", :outline => false))
  cylinder = KmlTools.cylinder(50, 37, 10000,1000)
  cylinder_p.features << cy_sty << cylinder

  square_p = KML::Placemark.new(:name => "Square")
  square = KmlTools.square(37,37,4000,45,100000)
  square_p.features << square

  square1_p = KML::Placemark.new(:name => "Square1")
  square1 = KmlTools.square(37,37,4000,45.1,100000)
  square1_p.features << square1

  doc.features << circle_p << cylinder_p << square_p << square1_p
  kml.objects << doc
  puts kml
  File.open("output/simple_shapes.kml", "w") {|f| f.write kml.render }
end
