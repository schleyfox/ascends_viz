require 'zip/zip'
desc "Draws all emitters (currently just powerplants) to KML"
task :plot_emitters do
  get_db_conn(GTRON_ENV)
  MODEL_DIR = ENV['models_dir'] || "input/models/"
  kmz_files = Dir[MODEL_DIR+"*.kmz"]
  doc = KML::Document.new(:name => "CO2 Emitters")
  Emitter.find(:all).each do |e|
    # TODO: add typecheck to judge what type of emitter it is and render appropriate model
    # TODO: scale emitter size based on emissions?
    scale = [10, 10, 10]
    href = kmz_files[rand(kmz_files.size)]
    href = href.to_s[6..href.to_s.size-4]+"dae"
    link = KML::Link.new(:href => href)
    model = KML::Model.new(:location => e.pos_to_tuple, :scale => scale, :link => link)
    placemark = KML::Placemark.new(:name => "emitter_#{e.pos_to_tuple.join("_")}")
    placemark.features << model
    doc.features << placemark
  end
  kml = KMLFile.new
  kml.objects << doc
  FileUtils.rm("output/emitters.kmz") if File.exists?("output/emitters.kmz")
  Zip::ZipFile.open("output/emitters.kmz", "w+") do |z|
    z.get_output_stream("doc.kml") do |f|
      f.write kml.render
    end
    kmz_files.each do |k|
      Zip::ZipFile.open(k, 'r') do |f|
        f.each do |ff|
          next if ff.name.index("kml")
          f.read(ff.name)
          z.get_output_stream(ff.name) do |fff| # i'm only using these names because "k" was too funny and i hate you
            fff.write(f.read(ff.name)) # yep hate you a whole lot
          end # and myself
        end
      end
    end
  end
end
