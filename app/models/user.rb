class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :email, :password, :password_confirmation,:nome,:cognome,:codice_fiscale,:user_kind_id,:approved,:remember_token

  attr_accessor :password
  before_save :prepare_password

  #validates_presence_of :email
  #validates_uniqueness_of :username, :email, :allow_blank => true
  #validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  #validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  #validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  #validates_length_of :password, :minimum => 4, :allow_blank => true

  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_email(login)
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  def generate_remember_token
    #cancello il token precedente
    reset_remember_token
    #genero un nuovo token
    self.remember_token = Digest::SHA1.hexdigest([Time.now, self.email].join)
    save
  end

  def full_name
    self.nome + " " + self.cognome
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end

  def reset_remember_token
    self.remember_token = nil
    save
  end

end
