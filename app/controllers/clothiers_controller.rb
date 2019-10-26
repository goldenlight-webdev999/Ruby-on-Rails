class ClothiersController < ApplicationController
    before_filter :verify_login
    skip_before_filter :verify_login, only: [:checkShopify]
    protect_from_forgery except: :checkShopify

    def list
        redirect_to '/' if session[:level] == 0
        @list = Clothier.list.html_safe
        @showrooms = JSON.parse Settings.first.showrooms
    end
    
    def modify
        redirect_to '/' if session[:level] == 0
        @list = Clothier.list.html_safe
        @showrooms = JSON.parse Settings.first.showrooms
    end
    
    def toggle
        if params.has_key? :id
            clothier = Clothier.find(params[:id].to_i)
            unless clothier == nil
              clothier.toggle
              @data = clothier.list_item
              respond_to do |format|
                format.json { render json: @data.to_json}
              end 
            end
        end
    end
    
    def add
        if params.has_key? :first and params.has_key? :email and params.has_key? :showroom
            clothier = Clothier.new
            clothier.first = params[:first]
            clothier.last = params[:last]
            clothier.email = params[:email]
            clothier.showroom = params[:showroom]
            clothier.password = "#{params[:first]}1234"
            clothier.active = true
            begin
               clothier.save
               @data = clothier.list_item 
            rescue => e
               @data = '{"message": ' + e + '"}'
            end
            respond_to do |format|
                format.json { render json: @data.to_json}
            end 
        end
    end
    
    def orderAdd
        @message = ""
        @actionurl = ""
        @clothier = Clothier.where(:id => params[:id]).first
        if @clothier == nil
            redirect_to '/clothier/list' 
        else
            @actionurl = "orderAdd/#{@clothier.id}"
            if params.has_key? :order and @clothier != nil
                success = @clothier.addToOrder(params[:order][:number])
                if success
                    @message = "#{@clothier.first} is now the Clothier attributed to Order ##{params[:order][:number]}"
                else
                    @message = "Order ##{params[:order][:number]} Couldn't Be Found."
                end
            end
        end
    end
    
    def orderRemove
        success = false
        if params.has_key? "id"
            success = Clothier.removeClothier(params[:id])
        end
        
        if success
            @data = {"success": true}
        else
            @data = {"success": false}
        end
        respond_to do |format|
          format.json { render json: @data.to_json}
        end 
    end
    
    def generate_excel
      @order = OrderProcessor.new(params[:order])
      @customer = @order.customer_data if @order.full_order
      if @order.full_order == nil
        redirect_to controller: 'clothiers', action: 'orders', order: params[:order], message: "Order Does Not Exist"
        return
      else
        
          respond_to do |format|
            format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="Order' + @order.full_order['name'] + '.xlsx"'}
          end
      end
    end
    
    def checkShopify
        
        @data = '{"success": false, "message": "Clothier Could Not Be Verified!"}'
        if params.has_key? "credentials"
          begin
              if(Clothier.find_by(email: params['credentials']['email']).try(:authenticate, params['credentials']['password']))
               clothier = Clothier.where(email: params['credentials']['email']).first
               if clothier.active
                   @data = {"success": true, "message": "Clothier Verified!", "name": "#{clothier.first} #{clothier.last}", "id": "#{clothier.id}", "showroom": "#{clothier.showroom}"}
                   @data = @data.to_json.to_s
               end
              end
          rescue => e
          end
        end
        respond_to do |format|
            format.json { render json: @data.to_json.html_safe, :callback => params['callback']}
        end
    end
    
    def orders
        @order = params[:order]
        
    end
    
    def test_it
        
      order = OrderProcessor.new(1008)
      customer = order.customer_data if order.full_order
      
      data = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "clothiers/generate_excel", :locals => {:current_order => order, :current_customer => customer}
      file_path = Rails.root.join('public', "Order1008.xls")
      File.open(file_path, "w"){|f| f << data }   
      @xls = "test" 
      
      render "test_it"
    end
    
    def commissions
        if params.has_key? "id"
            redirect_to '/' if session[:level] == 0 and session[:id] != params[:id].to_i
            clothier = Clothier.find(params["id"])
            @timeframe = ""
            if params.has_key? "time"
                min = nil
                max = nil
                if params['time'] == "1M"
                    min = Time.now.months_since(-1).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-1).at_end_of_month.utc.iso8601
                end
                if params['time'] == "2M"
                    min = Time.now.months_since(-2).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-2).at_end_of_month.utc.iso8601
                end
                if params['time'] == "3M"
                    min = Time.now.months_since(-3).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-3).at_end_of_month.utc.iso8601
                end
                @orders = []
                @timeframe = params['time']
                @orders = clothier.credited(min,max) if min
            else
                @orders = clothier.credited
            end
            
            
            @name = "#{clothier.first} #{clothier.last}"
            @id = clothier.id
        end
    end
    
    def generate_commissions

        if params.has_key? "id"
            redirect_to '/' if session[:level] == 0 and session[:id] != params[:id].to_i
            clothier = Clothier.find(params["id"])
            @timeframe = ""
            if params.has_key? "time" and params["time"] != ""
                min = nil
                max = nil
                if params['time'] == "1M"
                    min = Time.now.months_since(-1).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-1).at_end_of_month.utc.iso8601
                end
                if params['time'] == "2M"
                    min = Time.now.months_since(-2).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-2).at_end_of_month.utc.iso8601
                end
                if params['time'] == "3M"
                    min = Time.now.months_since(-3).at_beginning_of_month.utc.iso8601
                    max = Time.now.months_since(-3).at_end_of_month.utc.iso8601
                end
                @orders = []
                @timeframe = params['time']
                @orders = clothier.credited(min,max) if min
            else
                @orders = clothier.credited
            end
            
            @orders = JSON.parse(@orders)
            @gift_rush_orders = 0
            @total_units = 0
            @total_dollars = 0.00
            
            @orders.each do |order|
                
                @gift_rush_orders = @gift_rush_orders + 1 if order['item_count'] == 0
                @total_units = @total_units + order['item_count']
                @total_dollars = @total_dollars + order["subtotal_price"].to_f
                
            end
            
            @name = "#{clothier.first} #{clothier.last}"
            @id = clothier.id
        
        
        
        
        
        
        
        
          
        respond_to do |format|
          format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="ClothierReport_' + "#{clothier.first}_#{clothier.last}" + '.xlsx"'}
        end        
        
        
        end
          
          
          


    end
end
