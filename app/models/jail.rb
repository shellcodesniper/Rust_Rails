class Jail < ApplicationRecord
	
	belongs_to :player

	after_commit(on: :create) do

		
		Rails.application.executor.wrap do
			th = Thread.new do
				Rails.application.executor.wrap do
					title = self.server
					name =  self.player.name
					jailtype = self.jailtype
					reason = self.reason
					puts title,name,jailtype,reason
					puts "Started At #{Time.now}"
					puts title, name, jailtype, reason
					target_server = Server.where(title: title).first
					ru = Rustutil.new(target_server.rcon_host, target_server.rcon_port, target_server.rcon_pass)

					sleep(20)
					if jailtype.include? "kick" then ru.Kick(name, reason) end
					if jailtype.include? "ban" then ru.Ban(name, reason) end
					puts "End At #{Time.now}"
				end
			end
			
			ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
				th.join # outer thread waits here, but has no lock
			end
		end
				
	end

end
