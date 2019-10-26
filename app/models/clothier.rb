class Clothier < ApplicationRecord
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  
  before_save { self.email = self.email.downcase }
  has_secure_password #required for bcrypt
  
  validates :first, presence: true, length: { maximum: 50 }
  validates :last, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: create
  
  def recover
      require 'securerandom'
      require 'rest-client'
      self.reset_hash = SecureRandom.urlsafe_base64
      self.save
      url = ENV['master_url'] + '/login/reset?type=clothier&check=' + self.reset_hash + '&key=' + self.id.to_s

      
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
    data = {"id" => self.id, "first" => self.first, "last" => self.last, "email" => self.email, "showroom" => self.showroom, "active" => self.active}
    return data.to_json
  end
  
  def self.list
    data = []
    all.each do |log|
      data.push({"id" => log.id, "first" => log.first, "last" => log.last, "email" => log.email, "showroom" => log.showroom, "active" => log.active})
    end
    data = data.sort_by(&:first)
    return data.to_json
  end
  
  def self.removeClothier(orderId)
    require 'rest-client'
    require 'json'
    RestClient.put("https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders/#{orderId}.json", 
        {
           "order": {
              "id": orderId,
              "note_attributes": []
            } 
        })
    return true
  end
  
  def addToOrder(orderNumber)
    require 'rest-client'
    require 'json'
    
    data = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders.json?name=#{orderNumber}")
    
    if data['orders'][0] == nil
      return false
    else
      id = data['orders'][0]['id'].to_i
      
      RestClient.put("https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders/#{id}.json", 
        {
           "order": {
              "id": id,
              "note_attributes": [
                {                
                  "name": "ClothierId",
                  "value": "#{self.id}"
                },
                {
                  "name": "Clothier",
                  "value": "#{self.first} #{self.last}"
                }
              ]
            } 
        }, )
      return true
    end
  end
  
  def credited(created_at_min = Time.now.at_beginning_of_month.utc.iso8601, created_at_max = nil)
    limit = 250
    all_orders = []
    clothier_orders = []
    #timestamp = 90.days.ago.utc.iso8601
    if created_at_max
      order_count = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders/count.json?status=any&created_at_min=#{created_at_min}&created_at_max=#{created_at_max}")["count"]
    else
      order_count = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders/count.json?status=any&created_at_min=#{created_at_min}")["count"]
    end
    page_count = (order_count/limit.to_f).ceil
    puts "Pages = #{page_count}"
    puts "Order Count = #{order_count}"

    (1..page_count).each do |page|
      if created_at_max
        current_orders = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders.json?status=any&page=#{page}&limit=#{limit}&created_at_min=#{created_at_min}&created_at_max=#{created_at_max}&fields=id,order_number,subtotal_price,note_attributes,created_at,line_items")['orders']
      else
        current_orders = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders.json?status=any&page=#{page}&limit=#{limit}&created_at_min=#{created_at_min}&fields=id,order_number,subtotal_price,note_attributes,created_at,line_items")['orders']
      end
      
      all_orders = all_orders.concat current_orders
    end
    
    all_orders.each do |order|
      order["note_attributes"].each do |field|
        puts field
        if field["name"] == "ClothierId" and field["value"] == self.id.to_s
          edited_orders = order
          order_value = order['subtotal_price']
          item_count = 0
          
          order['line_items'].each do |item|
            if item['vendor'] == "Giftwizard" or (item['properties'][0] and item['properties'][0]['name'] == "line_id") or item['vendor'] == 'Enzo Addon'
              order_value = order_value.to_f - item['price'].to_f if item['vendor'] == "Giftwizard"
            else
              item_count = item['quantity'] + item_count
            end
          end
          
          edited_orders['item_count'] = item_count
          if order_value.to_f > 0
            edited_orders['order_value'] = order_value
          else
            edited_orders['order_value'] = "0.00"
          end
          
          clothier_orders.push(edited_orders)
        end
      end
    end

    return clothier_orders.to_json.html_safe
    
    #total_orders['orders'].each do |x|
    #  if()
    #end
  end

  
  
  
end
