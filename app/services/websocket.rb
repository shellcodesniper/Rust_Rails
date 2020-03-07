# require 'steam-condenser'
require 'websocket-eventmachine-client'
require 'json'

class Websocket
	def initialize(host,port,passwd)
		@host = host
		@port = port
		@passwd = passwd
	end


	def sendquery(command)
		@rmsg = ""
		EM.run do

				ws = WebSocket::EventMachine::Client.connect(:uri => "ws://#{@host}:#{@port}/#{@passwd}")

				ws.onopen do
					# puts "Connected"
					command_string = {
						'Identifier': 0,
						'Message': command,
						'Type': 3,
						'Name': 'WebRcon'
					}
					command_js = command_string.to_json
					# ws.send('playerlist')
					ws.send(command_js)
				end

				ws.onmessage do |msg, type|
					@rmsg = msg
					# puts "Received message: #{msg}"
					ws.close
					# puts "CLOSE!"
					EM.stop
				end

				ws.onclose do |code, reason|
					# puts "Disconnected with status code: #{code}"
					ws = nil
					EM.stop
				end

		end

		JSON.parse(@rmsg)
	end

	def execute_command(command)
		r = sendquery(command)
		JSON.parse(r["Message"])
	end


	def getConsoleLog(length=200)
		r = sendquery("console.tail #{length}")
		# JSON.parse(r)
		r
	end

	def getCombatLog(steamid)
		# r = sendquery("combatlog #{steamid}")
		r = sendquery('console.tail 100')
		JSON.parse(r["Message"])
	end

	def sendNotification(message)
		sendquery("say #{message}")
	end

	def sendPM(username, message)
		sendquery("pm #{username} #{message}")
	end

	def kick(username, resason)
		sendquery("kick #{username} \"#{resason}\"")
	end

	def ban(username, resason)
		sendquery("ban #{username} \"#{resason}\"")
	end

end