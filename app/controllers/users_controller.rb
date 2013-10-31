class UsersController < ApplicationController
  before_filter :logout_required

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
    @user.invisible = false

    if @user.save
      @user.generate_perishable_token
      Notifier.deliver_activation_instructions(@user)
      @user = User.new
      @message_notice = "Ti è stata spedita una mail. Controlla la tua casella di posta e segui le istruzioni per portare a termine la richiesta di registrazione."
      render :update do |page|
        page.replace_html "form", :partial => "reg_form", :object => @user
        page.show "error"
        page.replace_html "error", :partial => "layouts/remote_flash_message", :object => @message_notice
      end
    else
      render :update do |page|
        page.show "error"
        page.replace_html "error", :partial => "input_errors", :object => @user
      end
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

  def validate_user
    @user = User.find_by_perishable_token(params[:activation_code])
    if @user != nil && @user.token_expired? == false
      @user.update_attributes(:validate => 1)
      @user.reset_perishable_token
      flash[:notice] = "La tua e-mail è stata validata."
      redirect_to root_path
    else
      flash[:error] = "Qualcosa è andato storto. Per risolvere il problema, contattare il webmaster."
      redirect_to root_path
    end
  end

end
