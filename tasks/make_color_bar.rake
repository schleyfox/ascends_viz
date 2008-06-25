desc "Creates Color Bar for Google Earth"
task :make_color_bar do
  Co2ColorCode.make_color_bar
  image_path = File.expand_path("#{GTRON_ROOT}/output/co2_color_bar.png")
  kml = KMLFile.new
  doc = KML::Document.new(:name => "ASCENDS CO2 Color Bar")
  overlay = KML::ScreenOverlay.new(:name => 'CO2 Color Bar',
                                   :overlay_xy => {:x => 0.98, :y => 0.2},
                                   :screen_xy => {:x => 0.98, :y => 0.2},
                                   :icon => KML::Icon.new( 
                                      :href => "file:/#{image_path}"))
  doc.features << overlay
  kml.objects << doc
  File.open("output/co2_color_bar.kml", "w") {|f| f.write kml.render }
end
