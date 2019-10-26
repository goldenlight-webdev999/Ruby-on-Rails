class LoginController < ApplicationController
    
    layout "login", only: [:clothier_login, :admin_login]
    
    def clothier_login
        
        @message = ""
      
        if(params.has_key?('user') and params['user'].has_key?(:password) and params['user'].has_key?(:email))
          if(Clothier.find_by(email: params['user'][:email]).try(:authenticate, params['user'][:password]))
            @user = Clothier.where(email: params['user'][:email]).first
            session[:name] = @user.first
            session[:level] = 0
            session[:id] = @user.id
            redirect_to '/'
          else
            @message = "Your email and password is not in the system"
          end
        end 
        
    end
    
    def admin_login
      @message = ""
      
        if(params.has_key?('user') and params['user'].has_key?(:password) and params['user'].has_key?(:email))
          if(Admin.find_by(email: params['user'][:email]).try(:authenticate, params['user'][:password]))
            @user = Admin.where(email: params['user'][:email]).first
            session[:name] = @user.first
            session[:level] = @user.level
            session[:id] = @user.id
            redirect_to '/'
          else
            @message = "Your email and password is not in the system"
          end
        end   
        
    end
    
    def recovery
        @key = nil
        @message = ""
        @reset = false
        
            if params.has_key? 'type'
                @type = params['type']
            end
            if params.has_key? 'user'
                @type = params['user']['type']
                user = Clothier.where(email: params['user']['email']).first if @type == "clothier"
                user = Admin.where(email: params['user']['email']).first if @type == "admin"
                unless user == nil
                    user.recover
                    @message = "A password reset email has been sent to #{user.email}"
                else
                    @message = "#{params['user']['email']} couldn't be found"
                end
            end
    end
    
    def reset
        require 'securerandom'
        @expired = true
        @type = nil
        @user = nil
        
        if params.has_key?('key') and params.has_key?('check') and params.has_key?('type')
            @user = Clothier.find(params['key'].to_i) if params['type'] == 'clothier'
            @user = Admin.find(params['key'].to_i) if params['type'] == 'admin'
            if @user != nil
                if @user.reset_hash == params['check'].to_s and @user.reset_hash != nil
                    @expired = false
                    @type = params['type']
                    if params.has_key?('password') and params.has_key?('password2')
                        if params['password'] === params['password2']
                          @user.password = params['password']
                          @user.reset_hash = SecureRandom.urlsafe_base64
                          @user.save              
                          redirect_to "/login/#{params['type']}"
                        end
                          @message = "Passwords need to match"
                    end
                end
            end
        end
    end
    
    def logout
    
        if session[:level] == 0
            session.clear
            redirect_to '/login/clothier'
        else
            session.clear
            redirect_to '/login/admin'
        end

    end
    
end
