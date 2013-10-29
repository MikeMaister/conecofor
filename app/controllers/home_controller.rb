class HomeController < ApplicationController
  before_filter :login_required , :only => :contacts

  def index
  end

  def contacts
  end

end
