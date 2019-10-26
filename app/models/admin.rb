class Admin < ApplicationRecord
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  before_save { self.email = self.email.downcase }
  has_secure_password #required for bcrypt
  
  validates :first, presence: true, length: { maximum: 50 }
  validates :last, presence: true, length: { maximum: 50 }  
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: create

  def init
    self.level ||= 5 if self.has_attribute? :level
  end
  
  def recover
      require 'securerandom'
      require 'rest-client'
      self.reset_hash = SecureRandom.urlsafe_base64
      self.save
      url = ENV['master_url'] + '/login/reset?type=admin&check=' + self.reset_hash + '&key=' + self.id.to_s

      
      RestClient.post( "https://hooks.zapier.com/hooks/catch/1841721/wpttgo/",
        {
          "name": "#{self.first} #{self.last}",
          "email": self.email,
          "hash_url": url
        })
  end
  
  def toggle
    
    self.active = true if self.active == nil
    
    if self.active
      self.active = false
    else
      self.active = true
    end
    
    self.save
    
  end
  
  def list_item
    data = {"id" => self.id, "first" => self.first, "last" => self.last, "email" => self.email, "level" => self.level}
    return data.to_json
  end
  
  def self.list
    data = []
    all.each do |log|
      data.push({"id" => log.id, "first" => log.first, "last" => log.last, "email" => log.email, "level" => log.level})
    end
    return data.to_json
  end
  
  after_initialize :init
  
end
