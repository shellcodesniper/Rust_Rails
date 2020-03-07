class ConsoleController < ApplicationController
  def index
	if user_signed_in?
		if current_user.admin != true 
			raise ActionController::RoutingError.new('Not Found')
		end
	else
		raise ActionController::RoutingError.new('Not Found')
	end

	@jails = Jail.all
	@messages = Messagelog.all
	@servers = Server.all


  end
end
