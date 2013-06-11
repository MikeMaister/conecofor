class Admin::FileManagerController < ApplicationController

  def index
    @import_file = ImportFile.find(:all,:conditions => ["deleted = false"], :order => "file_name")
  end

end
