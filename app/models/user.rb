class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :email, :password, :password_confirmation,:nome,:cognome,:codice_fiscale,:user_kind_id,:approved,:remember_token,:invisible

  attr_accessor :password
  before_save :prepare_password

  validates_presence_of :email,:nome,:cognome,:codice_fiscale,:password,:password_confirmation ,:message => "non può essere vuoto.", :on => :create
  validates_uniqueness_of :email, :on => :create ,:message => "già in uso.",:allow_blank => true
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i ,:message => "formato non valido.", :on => :create, :allow_blank => true
  validates_format_of :nome,:cognome ,:with => /^[A-Za-z\s]+$/,:message => "formato non valido.", :allow_blank => true
  validates_format_of :codice_fiscale, :with => /^[-a-z0-9]+$/i,:allow_blank => true,:on => :create, :message => "formato non valido."
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :minimum => 6, :allow_blank => true ,:message => "deve contenere minimo 6 caratteri.",:on => :create
  validates_length_of :codice_fiscale, :is => 16 ,:allow_blank => true,:message => "non valido.",:on => :create

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
