class UsersController < ApplicationController
  before_filter :logout_required, :except => [:show,:edit_info,:update_info]
  before_filter :valid_psw_token , :only => "reset_psw"
  before_filter :login_required, :only => [:show,:edit_info,:update_info,:new_admin,:create_admin]

  def show
    @user = current_user
  end

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

  def pass_res_edit
  end

  def send_psw_reset
    user = User.find_by_email(params[:email])
    if user.blank?
      flash[:error] = "E-mail inserita non valida."
      redirect_to pass_res_edit_path
    else
      #spedisco la mail con le istruzioni
      user.generate_psw_per_token
      Notifier.deliver_psw_reset_instructions(user)
      flash[:notice] = "Abbiamo inviato una mail con le istruzioni per reimpostare la password all'indirizzo #{params[:email]}, relative allo stesso account."
      redirect_to root_path
    end
  end

  def reset_psw
    @user = User.find_by_psw_per_token(params[:psw_reset])
  end

  def set_psw
    if params[:uid]
      @user = User.find(params[:uid])
      if @user && params[:new_psw] == params[:confirm] && !params[:confirm].blank?
        #@user.update_attributes(:password => params[:new_psw])
        @user.password = params[:new_psw]
        if @user.save
          @user.reset_psw_per_token
          flash[:notice] = "Password aggiornata. Prova ad effettuare il login per favore."
          redirect_to root_path
        else
          render :action => "reset_psw"
        end
      else
        flash.now[:error] = "Errore, prova di nuovo."
        render :action => "reset_psw"
      end
    else
      flash[:error] = "Critical Error."
      redirect_to root_path
    end
  end

  def edit_info
    @user = current_user
    case params[:attr]
      when "email"
        render :update do |page|
          page.show "editinfo"
          page.replace_html "editinfo", :partial => "edit_email", :object => @user
        end
      when "psw"
        render :update do |page|
          page.show "editinfo"
          page.replace_html "editinfo", :partial => "edit_psw", :object => @user
        end
      else
    end
  end

  def update_info
    @user = current_user
    #se la psw è corretta
    if @user.matching_password?(params[:psw])
      case params[:attr]
        when "email"
          @user.email = params[:new_email]
          status,message = custom_email_validation(@user.email,params[:conf_email])
          if status.blank?
            @user.save
            #disattivo l'account e spedisco la mail di notifica.
            deactivate_account!
            flash[:notice] = "Il tuo account è stato temporaneamente disattivato. Controlla la casella di posta e valida l'indirizzo e-mail fornitoci per riattivare l'account."
            redirect_to root_url
          else
            flash[:error] = message
            redirect_to user_path(current_user)
          end
        when "psw"
          status,message = custom_psw_validation(params[:new_psw],params[:confirm])
          if status.blank?
            @user.password = params[:new_psw]
            @user.save
            flash[:notice] = "Account aggiornato."
            redirect_to user_path(current_user)
          else
            flash[:error] = message
            redirect_to user_path(current_user)
          end
        else
          flash[:error] = "Something went wrong..."
          redirect_to root_path
      end
    #psw non corretta
    else
      flash[:error] = "Password errata."
      redirect_to user_path(current_user)
    end
  end


  private

  def valid_psw_token
    @user = User.find_by_psw_per_token(params[:psw_reset])
    if @user.blank?
      flash[:error] = "Invalid Token."
      redirect_to root_path
    end
  end

  def custom_email_validation(email,confirm)
    status = ""
    message = ""
    #se il campo è vuoto
    if email.blank?
      message << "E-mail non può essere vuoto. <br />"
      status = "stop"
    else
      #controllo se la nuova email è già inserita nel sistema
      user = User.find_by_email(email)
      if !user.blank?
        message << "E-mail già in uso. <br />"
        status = "stop"
      end
      regexp = /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
      unless email =~ regexp
        message << "E-mail formato non valido. <br />"
        status = "stop"
      end
    end
    if email != confirm
      message << "E-mail di conferma errata. <br />"
      status = "stop"
    end
    return status,message
  end

  def custom_psw_validation(psw,confirm)
    status = ""
    message = ""
    #se il campo è vuoto
    if psw.blank?
      message << "Password non può essere vuoto. <br />"
      status = "stop"
    else
      #controllo se la nuova psw è abbastanza lunga
      unless psw.size >= 6
        message << "Password deve contenere minimo 6 caratteri. <br />"
        status = "stop"
      end
    end
    if psw != confirm
      message << "Password di conferma errata. <br />"
      status = "stop"
    end
    return status,message
  end

  def deactivate_account!
    current_user.validate = 0
    current_user.save
    current_user.generate_perishable_token
    Notifier.deliver_activation_instructions(current_user)
    cookies.delete :rem_token
  end

end
