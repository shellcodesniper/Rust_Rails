class MessagelogController < ApplicationController
	def update
		if(params["secret"] != "kuuwang")
			puts "DENIED"
			return
		end

		@server = nil
		if (Server.where(title: params["server"]).exists?)
			@server = Server.where(title: params["server"]).first
		else
			return
		end

		time = DateTime.now
		data = params[:message]
		playername = data.split('**', 2)[1].split(':**')[0].strip
		message = data.split(':**', 2)[1].strip

		
		if (Player.where(server_id: @server.id, name: playername).exists?)
			@player = Player.where(server_id: @server.id, name: playername).first
		else
			puts "Player Not Exist"
			return
		end

		Messagelog.create(time: time, player: @player, message:message, server: @server)
		
		
		# [01:32] Builder: .저기 밖에분꺼도 만들죵
		# [2020-02-15 01:59:00] ehflqfl661: .G9에 계신다했던 뉴비분?
		# if (Player.where(server_id: @server.id, ))

	end
end
