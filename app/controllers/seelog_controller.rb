class SeelogController < ApplicationController
  def index
	@jails = Jail.all
	@messages = Messagelog.all
	@servers = Server.all
  end
end
