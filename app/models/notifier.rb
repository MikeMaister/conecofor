class Notifier < ActionMailer::Base
  def activation_instructions(user)
    @user = user
    @url = "www.conecofor.com"
    @from = "admin@gmail.com"
    @subject = "Validazione E-mail"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #user.email
    @account_activation_url = validate_user_url(@user.perishable_token)
    @content_type = "text/html"
  end

  def psw_reset_instructions(user)
    @user = user
    @url = "www.conecofor.com"
    @from = "admin-web@gmail.net"
    @subject = "Password Reset Instruction"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #user.email
    @psw_reset_url = reset_psw_url(@user.psw_per_token)
    @content_type = "text/html"
  end

  def user_active(user)
    @user = user
    @url = "www.conecofor.net"
    @from = "admin@gmail.com"
    @subject = "Attivazione account"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com"  #user.email
    @content_type = "text/html"
  end

  def user_disactivate(user)
    @user = user
    @url = "www.conecofor.net"
    @from = "admin@gmail.com"
    @subject = "Disattivazione account"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #user.email
    @content_type = "text/html"
  end

  def user_survey_sheet(user,surveysheet)
    @user = user
    @surveysheet = surveysheet
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def user_import_complete(user,import)
    @user = user
    @import = import
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def add_import_permits(user,import)
    @user = user
    @import = import
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Permessi d'import"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def remove_import_permits(user,import)
    @user = user
    @import = import
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Permessi d'import"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def deleted_survey_sheet(user,import)
    @user = user
    @import = import
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "michele.balestrini@gmail.com" #sostituire con email admin
    @content_type = "text/html"
  end

end
