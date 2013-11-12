class Admin::FileManagerController < ApplicationController
  before_filter :login_required,:admin_authorization_required

  def index
  end

  def result
    @import_file = ImportFile.find(:all,:conditions => ["deleted = false"], :order => "file_name")
  end

end
