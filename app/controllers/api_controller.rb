class ApiController < ApplicationController
    
    before_action :verify_admin
    skip_before_action :verify_admin, only: [:receive_webhook]
    protect_from_forgery except: :receive_webhook
    
    
    def index
        require 'rest-client'
        require 'json'
        
        

=begin
        #SAMPLE CODE TO PULL A TEST ORDER FOR DATA AND THEN PULL THE METAFIELDS FOR THE ORDER'S CUSTOMER

        orderNumber = '1003'
        order = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/orders.json?name=#{orderNumber}")
        customer_id = order['orders'][0]['customer']['id']
        order_meta = JSON.parse(RestClient.get "https://#{ENV['SHOPIFY_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@enzo-custom.myshopify.com/admin/customers/#{customer_id}/metafields.json")['metafields']
        
        @fullOrder = order['orders'][0]
        @data = []
        order_meta.each do |x|
            @data.push(x) if x['namespace'] == "enzocustom"
        end
=end
        
    end
    
    def line_codes
        @garment_list = JSON.parse(PropertyCode.garment_list)
    end
    
    def new_code
        @garment = params[:garment]
        
        @code_list = PropertyCode.list(@garment).html_safe
        
    end
    
    def csv_codes
        @garment_list = JSON.parse(CsvCode.garment_list)
    end
    
    def new_csv
        @garment = params[:garment]
        @code_list = CsvCode.list(@garment).html_safe 
    end
    
    def csv_upload
        require 'csv'
        require 'json'
        if params.has_key? :file and params.has_key? :garment and params.has_key? :code and params.has_key? :property
            c = CsvCode.where(garment: params[:garment], property: params[:property]).first
            c = CsvCode.new if c == nil or c.property == "Button Threading" or c.property == "Buttonhole Thread"
            c.garment = params[:garment]
            c.property = params[:property]
            c.code = params[:code]
            codes = {}
            uploaded_io = File.read params[:file].path
            csv = CSV.parse(uploaded_io, :headers => true)
            csv.each do |prop|
                if c.property == "Fabric ID"
                  codes[prop['code']] = {"mill" => prop['mill'], "name" => prop[0]}
                else
                  codes[prop[0]] = {"code" => prop['code']}  
                end
                 
            end
            
            c.values = codes.to_json
            
            begin
                 c.save
                 @data = c.list_item
 
            rescue => e
               @data = '{"message": "' + e.message + '"}'
            end
            
        else
            @data = '{"message": "Testing"}'
        end

        respond_to do |format|
            format.json { render json: @data.to_json}
        end 
    end
    
    def add_code
        if params.has_key? :code and params.has_key? :conditions and params.has_key? :garment
            code = PropertyCode.new
            code.code = params[:code]
            code.garment = params[:garment]
            code.conditions = params[:conditions]
            
            begin

                 code.save
                 @data = code.list_item
 
            rescue => e
               @data = '{"message": "' + e.message + '"}'
            end
            respond_to do |format|
                format.json { render json: @data.to_json}
            end 
        end
    end
    
    def update_code
        if params.has_key? :code and params.has_key? :conditions and params.has_key? :id and params.has_key? :garment
            code = PropertyCode.find(params[:id])
            code.code = params[:code]
            code.garment = params[:garment]
            code.conditions = params[:conditions]
            
            begin

                 code.save
                 @data = code.list_item
 
            rescue => e
               @data = '{"message": "' + e.message + '"}'
            end
            respond_to do |format|
                format.json { render json: @data.to_json}
            end 
        end
    end
    
    def remove_code
        if params.has_key? :id and params.has_key? :garment
            c = CsvCode.find(params[:id])
            c.delete
            redirect_to "/api/csv/#{params[:garment]}"
            return
        end
        redirect_to "/api/csv"
        return
    end
    
    def generate_excel
        
      @order = OrderProcessor.new(params[:order])
      @customer = @order.customer_data if @order.full_order
      if @order.full_order == nil
        redirect_to '/api/test' and return
      else
        
          respond_to do |format|
            format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="Order' + @order.full_order['name'] + '.xlsx"'}
          end
      end
      
    end
    
    def test_it
        
      order = OrderProcessor.new(1008)
      customer = order.customer_data if order.full_order
      
      data = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "clothiers/generate_excel", :locals => {:current_order => order, :current_customer => customer}
      file_path = Rails.root.join('public', "Order1009.xls")
      File.open(file_path, "w"){|f| f << data }   
      @xls = "test" 
      
      render "test_it"
        
    end
    
  def download_csv

    send_data CsvCode.to_csv,
              filename: "uploadcodes.csv",
              type: "text/csv"
  end
  
  def receive_webhook
      
      
    data = JSON.parse(request.body.read)
    hook = Webhook.first
    list = JSON.parse(hook.list)
      
    unless list.include?(data["id"].to_i)
    
      list.push(data["id"].to_i)
      
      if list.length > 750
        hook.list = list.drop(300).as_json
      else
        hook.list = list.as_json
      end
      
      hook.save
      
      
      order = OrderProcessor.new(data["order_number"])
      customer = order.customer_data if order.full_order
      
      file = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "clothiers/generate_excel", :locals => {:current_order => order, :current_customer => customer}
      
      file_path = Rails.root.join('public', "#{data["order_number"]}.xls")
      File.open(file_path, "w"){|f| f << file }  

      RestClient.post("https://hooks.zapier.com/hooks/catch/3318491/ewam7z/", {:file => File.new(Rails.root.join("public", "#{data["order_number"]}.xls"), 'rb'), :subject => "#{data["order_number"]}", :multipart => true})
      
    end
     
    render nothing: true 
      
  end
    
end
