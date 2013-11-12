class HomeController < ApplicationController
  before_filter :login_required, :only => :help

  def index
  end

  def contacts
  end

  def help
  end

  before_filter :login_required,:only => :download_admin_manual
  before_filter :admin_authorization_required,:only => :download_admin_manual
  def download_admin_manual
    send_file "#{RAILS_ROOT}/file privati app/manuali/Manuale Admin.pdf"
  end

  before_filter :login_required,:only => :download_rilevatore_manual
  before_filter :rilevatore_authorization_required,:only => :download_rilevatore_manual
  def download_rilevatore_manual
    send_file "#{RAILS_ROOT}/file privati app/manuali/Manuale Rilevatore.pdf"
  end

end
