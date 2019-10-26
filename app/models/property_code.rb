class PropertyCode < ApplicationRecord
    
    
    def self.garment_list
        return ['Jacket', 'Pants', 'Vest', 'Shirt', 'Tux Jacket', 'Tux Pants'].to_json
    end
    
    def self.list(current_garment)
        data = []
        PropertyCode.where(garment: current_garment).each do |log|
          data.push({"id" => log.id, "code" => log.code, "conditions" => JSON.parse(log.conditions)})
        end

        return data.to_json
    end
    
    def list_item
        data = {"id" => self.id, "code" => self.code, "conditions" => JSON.parse(self.conditions)}
        return data.to_json
    end
    
    
    def self.to_csv
        attributes = %w{code conditions garment} #customize columns here
    
        CSV.generate(headers: true) do |csv|
          csv << attributes
    
          PropertyCode.all.each do |prop|
            csv << attributes.map{ |attr| prop.send(attr) }
          end
        end
    end
    
end
