class DataFile < ActiveRecord::Base
  def self.save(upload)
    name = upload['datafile'].original_filename
    #CAMBIARE LA DIRECTORY CON QUELLA DEL SERVER(non nella cartella public)
    directory = "public/file_importati"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end
end
