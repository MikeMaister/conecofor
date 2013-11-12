class HomeController < ApplicationController
  before_filter :login_required, :only => :help

  def index
  end

  def contacts
  end

  def help
  end

end
