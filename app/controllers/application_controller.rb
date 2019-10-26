class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  
  def verify_login
   
   unless(session[:id])
    redirect_to controller: 'login', action: 'clothier_login', order: params[:order]
   end
   
  end
  
  def verify_admin
   unless(session[:id])
    redirect_to '/login/clothier'
    return
   end
   if(session[:level] < 2)
    redirect_to '/'
    return
   end
  end
  
end
