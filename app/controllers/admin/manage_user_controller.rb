class Admin::ManageUserController < ApplicationController

  def index
    @user = User.find(:all, :conditions => "invisible = false and user_kind_id = (select id from user_kinds where kind = 'Rilevatore')", :order => :id)
  end

  def deactivate
    user = User.find(params[:user])
    user.update_attribute(:approved,"false")
    flash[:notice] = "Account rilevatore #{user.email} disattivato."
    redirect_to :action => :index
  end

  def activate
    user = User.find(params[:user])
    user.update_attribute(:approved,"true")
    flash[:notice] = "Account rilevatore #{user.email} attivato."
    redirect_to :action => :index
  end

  def archive_request
    user = User.find(params[:user])
    user.update_attribute(:invisible,"true")
    flash[:notice] = "Rilevatore #{user.email} rimosso."
    redirect_to :action => :index
  end

end
