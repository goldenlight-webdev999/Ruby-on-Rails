class Shopifier

    require 'rest-client'
    require 'json'

    def self.change_password(customer_id, new_pass)
    
        r = RestClient.put("https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/customers/#{customer_id}.json", 
        {
           "customer": {
              "id": customer_id,
              "password": "#{new_pass}",
              "password_confirmation": "#{new_pass}",
            } 
        })
        return JSON.parse(r) if r
        return false
    end

end