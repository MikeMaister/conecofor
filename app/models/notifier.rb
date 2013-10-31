class Notifier < ActionMailer::Base
  def activation_instructions(user)
    @user = user
    @url = "www.conecofor.com"
    @from = "admin@conecofor.com"
    @subject = "Validazione E-mail"
    @sent_on = Time.now
    @recipients = user.email
    @account_activation_url = validate_user_url(@user.perishable_token)
    @content_type = "text/html"
  end

  def psw_reset_instructions(user)
    @user = user
    @url = "www.stock-signals-db.net"
    @from = "admin@stock-signals-db.net"
    @subject = "SSDB - Password Reset"
    @sent_on = Time.now
    @recipients = user.email
    @psw_reset_url = reset_psw_url(@user.psw_per_token)
    @content_type = "text/html"
  end

  def user_active(user)
    @user = user
    @url = "www.conecofor.net"
    @from = "admin@conecofor.net"
    @subject = "Attivazione account"
    @sent_on = Time.now
    @recipients = user.email
    @content_type = "text/html"
  end

  def user_disactivate(user)
    @user = user
    @url = "www.conecofor.net"
    @from = "admin@conecofor.net"
    @subject = "Disattivazione account"
    @sent_on = Time.now
    @recipients = user.email
    @content_type = "text/html"
  end

  def user_survey_sheet(user,surveysheet)
    @user = user
    @surveysheet = surveysheet
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "admin@conecofor.com"
    @content_type = "text/html"
  end

  def user_import_complete(user,import)
    @user = user
    @import = import
    @url = "www.conecofor.net"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "admin@conecofor.com"
    @content_type = "text/html"
  end

end
