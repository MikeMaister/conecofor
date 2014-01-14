class Notifier < ActionMailer::Base
  def activation_instructions(user)
    @user = user
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Validazione E-mail"
    @sent_on = Time.now
    @recipients = user.email
    @account_activation_url = validate_user_url(@user.perishable_token)
    @content_type = "text/html"
  end

  def psw_reset_instructions(user)
    @user = user
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Instruzioni Password Help"
    @sent_on = Time.now
    @recipients = user.email
    @psw_reset_url = reset_psw_url(@user.psw_per_token)
    @content_type = "text/html"
  end

  def user_active(user)
    @user = user
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Attivazione account"
    @sent_on = Time.now
    @recipients = user.email  #user.email
    @content_type = "text/html"
  end

  def user_disactivate(user)
    @user = user
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Disattivazione account"
    @sent_on = Time.now
    @recipients = user.email #user.email
    @content_type = "text/html"
  end

  def user_survey_sheet(user,surveysheet)
    @user = user
    @surveysheet = surveysheet
    @url = "www.groundvegetationdb-web.com"
    @from = user.email
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = "admin@groundvegetationdb-web.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def user_import_complete(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = user.email
    @subject = "Rilevamento completato"
    @sent_on = Time.now
    @recipients = "admin@groundvegetationdb-web.com" #sostituire con email admin
    @content_type = "text/html"
  end

  def add_import_permits(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Permessi d'import"
    @sent_on = Time.now
    @recipients = user.email #sostituire con email utente
    @content_type = "text/html"
  end

  def remove_import_permits(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Permessi d'import"
    @sent_on = Time.now
    @recipients = user.email #sostituire con email utente
    @content_type = "text/html"
  end

  def deleted_survey_sheet(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Scheda di rilevamento"
    @sent_on = Time.now
    @recipients = user.email #sostituire con email utente
    @content_type = "text/html"
  end

  def approve_import(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Dati Approvati"
    @sent_on = Time.now
    @recipients = user.email #sostituire con email rilevatore
    @content_type = "text/html"
  end

  def deleted_import(user,import)
    @user = user
    @import = import
    @url = "www.groundvegetationdb-web.com"
    @from = "info@groundvegetationdb-web.com"
    @subject = "Dati non approvati"
    @sent_on = Time.now
    @recipients = user.email #sostituire con email utente
    @content_type = "text/html"
  end

end
