desc "Tests out my shape drawing code by drawing simple shapes"
task :draw_simple_shapes do
  kml = KMLFile.new
  doc = KML::Document.new(:name => "Simple Shapes")
  circle_p = KML::Placemark.new(:name => "Circle")
  circle = KmlShapes.circle(40,37,9000,100000)
  circle_p.features << circle

  cylinder_p = KML::Placemark.new(:name => 'Cylinder')
  cy_sty = KML::Style.new(:id => "doit",
                          :line_style => KML::LineStyle.new(:color => "4cff5555"),
                          :poly_style => KML::PolyStyle.new(:color => "4cff5555", :outline => false))
  cylinder = KmlShapes.cylinder(50, 37, 10000,1000)
  cylinder_p.features << cy_sty << cylinder

  doc.features << circle_p << cylinder_p
  kml.objects << doc
  puts kml
  File.open("output/simple_shapes.kml", "w") {|f| f.write kml.render }
end
