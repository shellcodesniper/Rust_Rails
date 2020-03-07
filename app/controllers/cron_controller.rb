require 'time'

class CronController < ApplicationController
	def cron_job
	self.UpdateSequence()
	end

	def UpdateSequence
		@cron = Cron.all

		@servers = Server.all

		@cron.each do |job|
			current_t = Time.parse(DateTime.now.to_s)
			next_t = Time.parse(job.next.to_s)
			last_executed = (current_t - next_t)
			# 마지막 실행시간, 반복시간과 비교
			
			if(last_executed > job.duration)
				if(job.job == "update_player")
					puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<플레이어 정보 업데이트 시작>"
					@servers.each do |server|
						self.UpdateServerPlayers(server, last_executed)
					end
					job.next = DateTime.parse((current_t).to_s)
					job.save
				elsif (job.job == "check_notice")
					puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<공지사항 정보 뿌리기 시작>"
					self.SendNotice
					job.next = DateTime.parse((current_t).to_s)
					job.save
				elsif (job.job == "check_jail")
					puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<감옥 관리 시작>"
					job.next = DateTime.parse((current_t).to_s)
					self.ManageJail

				end


			end
		end

	end

	def UpdateServerPlayers(server, last_executed)
		ru = Rustutil.new(server.rcon_host, server.rcon_port, server.rcon_pass)
		
		ru.Get_Player().each do |player|
			searchedplayer = Player.where(steamid: player["SteamID"], server_id: server.id)
			if(searchedplayer.exists?)
				# 플레이어가 있음 > 업데이트
				p = searchedplayer.first
				# 데이터베이스에서 검색된 플레이어정보

				steamplaytime = ru.Get_SteamPlaytime(player["SteamID"])

				if p.serverplaytime == nil then p.serverplaytime=0 end
				if p.steamplaytime == nil then p.steamplaytime=-1 end
				if p.steamplaytime < steamplaytime then p.steamplaytime=steamplaytime end
				
				p.serverplaytime += last_executed

				
				p.update_columns(name: player["DisplayName"], serverplaytime: p.serverplaytime, steamplaytime: p.steamplaytime, connectip:player["Address"], updated_at:DateTime.now.to_s)

				# Update CombatLog
				# self.UpdateCombatLog(ru,player)

				if(server.title == "Playrust.co.kr#뉴비")
					self.DK_Ban(ru, server, p)
				end

				
				
				
			else
				# 플레이어가 없음 > 등록해야됨
				data = ru.Get_Van(player["SteamID"])
				# 플레이어 정보 가져오기
				
				vacban = data["players"][0]["VACBanned"]
				gameban = if data["players"][0]["NumberOfGameBans"] > 0 then true else false end
				# 벤 정보 저장

				data = ru.Get_FamilyShare(player["SteamID"])
				if data != "0" then familyshare = true else familyshare = false end
				# 가족공유정보 저장

				Player.create(:name => player["DisplayName"], :steamid => player["SteamID"], vacban: vacban, gameban: gameban,familyshare: familyshare, serverplaytime: 0, steamplaytime: -1, seasonplaytime: 0,:server_id => server.id, :connectip => player["Address"] )
			end

		end
	end
	def UpdateCombatLog(ru, player)
		steamid = player["SteamID"]
		ru.Get_ConsoleLog()
		# data = ru.Get_CombatLog(steamid)
		# data.each do |row|
		# 	puts "NEW ROW : "
		# 	puts row
		# 	puts ""
		# end
		
	end

	def SendNotice()
		current_t = Time.parse(DateTime.now.to_s)
		Broadcast.all.each do |broadcast|
			next_t = Time.parse(broadcast.next.to_s)
			last_executed = (current_t - next_t)
			# 마지막 실행시간, 반복시간과 비교
			
			if(last_executed > broadcast.duration)
				
				puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\tSend Notification"

				puts "제목 : ", broadcast.title
				puts "내용 : ", broadcast.content
				
				server = broadcast.server
				ru = Rustutil.new(server.rcon_host, server.rcon_port, server.rcon_pass)
				broadcast.content.split('\n').each do |content|
					puts "잘려진 내용 : ", content
					ru.Send_Notification("#{broadcast.title} : #{content}")
				end
				
				broadcast.next = DateTime.parse((current_t).to_s)
				puts "다음 실행시간 : ", broadcast.next
				broadcast.save
			end


		end
	end

	def DK_Ban(ru, server, player)
		if(player.steamplaytime == -1)
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<스팀 플레이타임 비공개 유저 발견!>"
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", player.name
			puts ""
			ru.PM(player.name, "디케 : 이 서버는 뉴비를 위한 서버이며 플레이타임으로 관리되고 있습니다.")
			ru.PM(player.name, "귀하는 플레이타임 공개 설정을 1회이상 진행하지 않았으므로")
			ru.PM(player.name, "쾌적한 게임을 위하여 프로필 전체공개후 접속하여 5분이상 플레이 해주시기 바랍니다.")
			ru.PM(player.name, "프로필 전체공개 방법은 홈페이지 공지사항에 나와있습니다.")
			ru.PM(player.name, "홈페이지는 rust.kuuwang.com 입니다.")
			ru.PM(player.name, "20초후 자동 킥 진행됩니다.")
			jailtype = "kick_playtime"
			title = "D.K - 플레이타임 비공개"
			reason = "플레이타임 비공개입니다. 홈페이지를 확인하여 플레이타임을 전체공개 해주시기 바랍니다."
			judger = "D.K"

			j = Jail.create(:player => player, :server => server.title, :jailtype => jailtype, :title => title, :reason => reason, :start_date => DateTime.now.to_s, :end_date => DateTime.now.to_s, :judger => judger, :executed => true)
			if(!j.valid?)
				puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", j.errors.messages
			end
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t감옥 생성완료!"

		end

		if(player.steamplaytime / 60 > 500)
			# 고인물
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<스팀 플레이타임 500시간 이상 고인물 발견!>"
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] PLAYER NAME : ", player.name
			puts ""
			ru.PM(player.name, "디케 : 이 서버는 뉴비를 위한 서버이며 플레이타임으로 관리되고 있습니다.")
			ru.PM(player.name, "귀하는 스팀 플레이타임 500시간 이상인 유저로")
			ru.PM(player.name, "뉴비서버를 이용하실 수 없습니다.")
			ru.PM(player.name, "Playrust.co.kr 본서버를 이용해주시기 바랍니다.")
			ru.PM(player.name, "문의사항은 홈페이지 rust.kuuwang.com 를 이용해주시기 바랍니다.")
			ru.PM(player.name, "20초후 자동 밴 진행됩니다.")

			jailtype = "ban_playtime"
			title = "D.K - 500시간 이상유저"
			reason = "500시간 이상 고인물 유저는 이용하실 수 없습니다."
			judger = "D.K"

			j = Jail.create(:player => player, :server => server.title, :jailtype => jailtype, :title => title, :reason => reason, :start_date => DateTime.now.to_s, :end_date => (Time.zone.now + 100.year), :judger => judger, :executed => true)
			if(!j.valid?)
				puts j.errors.messages
			end
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", "\t\t<감옥 생성완료!>"

		end
	end

	def ManageJail
		predefined_jailtype= ["kick_playtime", "ban_playtime","kick"]
		@jail = Jail.where("end_date <= ?", DateTime.now.to_s).where.not(jailtype: predefined_jailtype).where(executed: false)

		@jail.each do |jail|
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", jail.title
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", jail.jailtype
			puts "\t# ["+DateTime.now.strftime("%Y-%m-%d %H:%M:%S") +"] ", jail.end_date
			# 여기서 밴 / 킥 처리해주기
		end

	end
end
