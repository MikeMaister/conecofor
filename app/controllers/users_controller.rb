class UsersController < ApplicationController

  def new_rilevatore
    @user = User.new
  end

  def new_admin
    @user = User.new
  end

  def create_rilevatore
    @user = User.new(params[:user])
    @user.user_kind_id = UserKind.find_by_kind("Rilevatore").id
    @user.approved = false

    if @user.save
      #session[:user_id] = @user.id
      #session[:user_kind] = UserKind.find(@user.user_kind_id).identifier
      flash[:notice] = "Thank you for signing up! You have to log in now"
      redirect_to login_path
    else
      render :action => 'new_rilevatore'
    end
  end

  def create_admin
    @user = User.new(params[:user])
    @user.user_kind_id = UserKind.find_by_kind("Admin").id

    if @user.save
      #session[:user_id] = @user.id
      #session[:user_kind] = UserKind.find(@user.user_kind_id).identifier
      flash[:notice] = "Thank you for signing up! You have to log in now."
      redirect_to login_path
    else
      render :action => 'new_admin'
    end
  end

end
