class CsvCode < ApplicationRecord
    
    
    def self.garment_list
        return ['Jacket', 'Pants', 'Vest', 'Shirt', 'Tux Jacket', 'Tux Pants'].to_json
    end
    
    def self.list(current_garment)
        data = []
        CsvCode.where(garment: current_garment).each do |log|
          errors = false
          values = JSON.parse(log.values)
          errors = true if values.size == 1
          if log.property == "Fabric ID" and values.values[0]["mill"] == nil
            errors = true
          end
          data.push({"id" => log.id, "code" => log.code, "name" => log.property, "errors" => errors})
        end

        return data.to_json
    end
    
    def list_item
        data = {"id" => self.id, "code" => self.code, "name" => self.property}
        return data.to_json
    end
    
    def self.to_csv
        attributes = %w{garment code property values} #customize columns here
    
        CSV.generate(headers: true) do |csv|
          csv << attributes
    
          CsvCode.all.each do |prop|
            csv << attributes.map{ |attr| prop.send(attr) }
          end
        end
    end
end
