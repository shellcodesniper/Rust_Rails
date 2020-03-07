require 'net/http'
require 'json'

class Steamutil
	def initialize()
		@api_key = "C0AF75CF76A2A495FE7099C02D623DA9"

	end


	def request(url)
		url = URI.parse(url)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		res.body
	end


	def getvacban(steamid)
		url = "http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=#{@api_key}&steamids=#{steamid}";
		ret = request(url);
		JSON.parse(ret);
	
		# $players = $data->{"players"}[0];
	end

	def getfamilyshare(steamid)
		url = "http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=#{@api_key}&steamid=#{steamid}&appid_playing=252490&format=json";
		ret = request(url)
		data = JSON.parse(ret)
		data["response"]["lender_steamid"]
	end


	def getsteamplaytime(steamid)
		url="http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=#{@api_key}&steamid=#{steamid}&format=json"
		# puts url
		ret = request(url)
		data = JSON.parse(ret)
		playtime = -1
		
		if(data["response"]["games"].nil?)
			return playtime
		end
		
		data["response"]["games"].each do |game|
			# puts game
			if game["appid"] == 252490 then playtime = game["playtime_forever"] end	
		end
		return playtime
	end
end