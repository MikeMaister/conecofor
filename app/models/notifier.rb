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

  def q_nuvst(user,data)
    @user = user
    @url = "www.stock-signals-db.net"
    @from = "admin@stock-signals-db.net"
    @subject = "SSDB - Unusual Volume Simple Trend"
    @sent_on = Time.now
    @recipients = user.email
    @query_result = data
    @content_type = "text/html"
  end

  def q_nuvct(user,data)
    @user = user
    @url = "www.stock-signals-db.net"
    @from = "admin@stock-signals-db.net"
    @subject = "SSDB - Unusual Volume Complex Trend"
    @sent_on = Time.now
    @recipients = user.email
    @query_result = data
    @content_type = "text/html"
  end

  def q_fint(user,data)
    @user = user
    @url = "www.stock-signals-db.net"
    @from = "admin@stock-signals-db.net"
    @subject = "SSDB - Finviz Trend"
    @sent_on = Time.now
    @recipients = user.email
    @query_result = data
    @content_type = "text/html"
  end

end
