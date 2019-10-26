class AdminController < ApplicationController
    before_filter :verify_login
    
    def modify
        @list = Admin.list.html_safe
    end
    
    def add
        if params.has_key? :first and params.has_key? :email and params.has_key? :level
            admin = Admin.new
            admin.first = params[:first]
            admin.last = params[:last]
            admin.email = params[:email]
            admin.level = params[:level].to_i
            admin.password = "#{params[:first]}1234"
            begin
               admin.save
               @data = admin.list_item 
            rescue => e
               @data = '{"message": ' + e + '"}'
            end
            respond_to do |format|
                format.json { render json: @data.to_json}
            end 
        end
    end
    
    def remove
        if session[:level] > 3 and params.has_key? :id
            admin = Admin.find(params[:id].to_i)
            admin.destroy if admin != nil
            @data = Admin.list.html_safe
        else
            @data = '{"success": false}'
        end
        respond_to do |format|
            format.json { render json: @data.to_json}
        end  
    end
    
    def customer_passwords
        @message = ""
        if params.has_key? :customer_id and params.has_key? :password and params.has_key? :confirm
            if params[:password] != params[:confirm]
                @message = "Password Fields Didn't Match"
            else
                c = Shopifier.change_password(params[:customer_id], params[:password])
                @message = "Customer ID doesn't exist"
                @message = "#{c['customer']['first_name']} #{c['customer']['last_name']} Password Reset was Sent to Shopify" if c
            end
        end
    end
end
