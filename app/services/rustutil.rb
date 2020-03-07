
class Rustutil
	def initialize(host,port,passwd)
		@host = host
		@port = port
		@passwd = passwd
		@ws = Websocket.new(host,port,passwd)
		@steam = Steamutil.new()
	end

	def Get_Player()
		@ws.execute_command("playerlist")
	end

	def Get_Van(steamid)
		@steam.getvacban(steamid)
	end

	def Get_FamilyShare(steamid)
		@steam.getfamilyshare(steamid)
	end

	def Get_SteamPlaytime(steamid)
		@steam.getsteamplaytime(steamid)
	end

	def Get_CombatLog(steamid)
		@ws.getCombatLog(steamid)
	end

	def Get_ConsoleLog()
		@ws.getConsoleLog()
	end

	def Send_Notification(message)
		@ws.sendNotification(message)
	end

	def PM(username, message)
		@ws.sendPM(username, message)
	end


	def Kick(username, reason)
		@ws.kick(username, reason)
	end

	def Ban(username, reason)
		@ws.ban(username, reason)
	end		

end