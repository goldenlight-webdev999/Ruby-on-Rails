class OrderProcessor
    
    require 'rest-client'
    require 'json'
    
    attr_accessor :order, :customer_data, :full_order, :clothier, :showroom
    
    def initialize(order_num)
        @order = order_num.to_s if order_num != nil
        @clothier = ""
        @showroom = ""
        @full_order = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders.json?status=any&name=#{order_num}")['orders'][0]
        if @full_order
           pull_order()
           return true
        else
            return false
        end
    end
    
    def set_fullorder(array)
        @full_order = array
    end
    
    def response
        pull_order()
        return @full_order
    end
    
    def line_items
        current_array = []
        @full_order['line_items'].each do |line|
            if line['properties'].map{|i| i['name']}.include?("Fabric ID")
                current_array.push(propCheck(line)) 
            end
        end
        return current_array
    end
    
    private
    
    def propCheck(line)
        conditions = PropertyCode.where(garment: ["Tux Jacket", "Tux Pants"]) if line["title"].downcase.include? "tux"
        conditions = PropertyCode.where(garment: ["Jacket", "Pants"]) if line["title"].downcase.include? "suit"
        conditions = PropertyCode.where(garment: ["Jacket"]) if line["title"].downcase.include? "jacket"
        conditions = PropertyCode.where(garment: ["Pants"]) if line["title"].downcase.include? "pants"
        conditions = PropertyCode.where(garment: ["Shirt"]) if line["title"].downcase.include? "shirt"
        conditions = PropertyCode.where(garment: ["Vest"]) if line["title"].downcase.include? "vest"
        
        csvs = CsvCode.where(garment: ["Tux Jacket", "Tux Pants"]) if line["title"].downcase.include? "tux"
        csvs = CsvCode.where(garment: ["Jacket", "Pants"]) if line["title"].downcase.include? "suit"
        csvs = CsvCode.where(garment: ["Jacket"]) if line["title"].downcase.include? "jacket"
        csvs = CsvCode.where(garment: ["Pants"]) if line["title"].downcase.include? "pants"
        csvs = CsvCode.where(garment: ["Shirt"]) if line["title"].downcase.include? "shirt"
        csvs = CsvCode.where(garment: ["Vest"]) if line["title"].downcase.include? "vest"
        

        conditions.each do |condition|
            met_cond = []
            code_index = nil
            JSON.parse(condition['conditions']).each do |cond|
                line["properties"].each_with_index do |prop, index|
                    rule = cond[prop["name"]]
                    if rule != nil
                        prop["codes"] = [] if prop["codes"] == nil
                
                
                        case rule["condition"]
                        
                            when "contains"
                               if prop["value"].downcase.include?(rule["value"].downcase)
                                   met_cond.push(true)
                                   code_index = index
                               else
                                   met_cond.push(false)
                               end
                               
                            when "equals"
                                if prop["value"].downcase == rule["value"].downcase
                                    met_cond.push(true)
                                    code_index = index
                                else
                                    met_cond.push(false)
                                end
                                
                            when "not"
                                if prop["value"].downcase != rule["value"].downcase
                                    met_cond.push(true)
                                    code_index = index
                                else
                                    met_cond.push(false)
                                end
                            
                        end
                        #prop["codes"].push(condition["code"])
                    
                    end
                end
            end
            line["properties"][code_index]["codes"].push(condition["code"]) unless met_cond.size < 1 or met_cond.include? false
            
        end
        line["properties"].each_with_index do |prop, index|
            csvs.each do |condition|
              cond = JSON.parse(condition['values'])
                if prop["name"].downcase == condition["property"].downcase
                  prop["codes"] = [] if prop["codes"] == nil 
                  if prop["name"] == "Fabric ID"
                   
                    prop["codes"].push(cond[prop["value"]]["mill"]) if cond[prop["value"]] != nil
                    
                  elsif prop["name"] == "Collar Felt"
                    index = cond.keys.index{|i|prop["value"].downcase.gsub(/[[:space:]]/, ' ').strip.gsub("- ", "").strip == i.downcase.gsub(/[[:space:]]/, ' ').strip}
                    if index != nil
                        prop["codes"].push("#{condition["code"]}=#{cond.values[index]["code"]}")
                    end
                  elsif prop["name"] == "Buttons"
                  
                    index = cond.keys.index{|i|prop["value"].downcase.split(' - ').last.strip == i.downcase.gsub(/[[:space:]]/, ' ').strip}
                    if index != nil
                        prop["codes"].push("#{condition["code"]}=#{cond.values[index]["code"]}")
                    end
                  else
                   
                    index = cond.keys.index{|i|prop["value"].downcase.include? i.downcase.gsub(/[[:space:]]/, ' ').strip}
                    if index != nil
                        prop["codes"].push("#{condition["code"]}=#{cond.values[index]["code"]}")
                    end
                
                  end                
                end
              
                
            end
            prop["codes"].uniq! if prop["codes"] != nil
        end
        return line
    end

    
    def pull_order
        @customer_data = {}
        
        meta_fields = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/customers/#{@full_order['customer']['id']}/metafields.json")['metafields']
        meta_fields.each do |field|
            if field['namespace'] == "enzocustom"
                @customer_data[field['key']] = parser(field['value'])
            end
        end
        
        @full_order['note_attributes'].each do |line|
            if line['name'] == "Clothier"
                @clothier = line['value']
            end
            if line['name'] == "location"
                @showroom = line['value']
            end
        end
    end
    
    def parser(data)
        return_object = {}
        data.split(';').each do |option|
            return_object[option.split(':').first] = option.split(':').last
        end
        return return_object
    end
    
end