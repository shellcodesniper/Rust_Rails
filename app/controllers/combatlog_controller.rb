class CombatlogController < ApplicationController

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

		myid = ''
		attackerid= ''
		weapon= ''
		damage= ''
		distance= ''

		message = params["message"]

		if message.include? "were attacked by" and message.include? "with a"
			# 공격이면서 무기가 있을때.

			begin
				myid = message.split('(',2)[1].split(')', 2)[0]
				attackerid = message.split('were attacked by')[1].split('(', 2)[1].split(')', 2)[0]
				weapon = message.split('with a \'')[1].split('\'')[0]
				damage = message.split('for ')[1].split(' damage')[0]
				distance = message.split('damage from ')[1].split(' meters')[0]
				puts "MYID", myid
				puts "ATTACKER", attackerid
				puts "WEAPON", weapon
				puts "DAMAGE", damage
				puts "DISTANCE", distance

			
				player = Player.where(steamid: myid)
				if(player.exists?)
					player = player.first
					puts "Try to Insert CombatLog!"

					attacker = Player.where(steamid: attackerid)
					if(attacker.exists?)
						attacker = attacker.first
						CombatLog.create(:player => player, :attacker_id => attacker.id, :weapon => weapon, :distance => distance, :damage => damage, :server_id => @server.id )
					end
				else
					puts "Player Not Found.. Can't insert CombatLog"
				end

			rescue
				puts "Error While Decoding Attacked Log"
			end
			

			
		end

		if message.include? "were killed by" and message.include? "with a"
			# 공격이면서 무기가 있을때.
			begin
				myid = message.split('(',2)[1].split(')', 2)[0]
				attackerid = message.split('were killed by')[1].split('(', 2)[1].split(')', 2)[0]
				weapon = message.split('with a \'')[1].split('\'')[0]
				damage = 0
				distance = message.split(' from ')[1].split(' meters')[0]
				puts "MYID", myid
				puts "ATTACKER", attackerid
				puts "WEAPON", weapon
				puts "DAMAGE", damage
				puts "DISTANCE", distance

				player = Player.where(steamid: myid)
				if(player.exists?)
					player = player.first
					puts "Try to Insert CombatLog!"

					attacker = Player.where(steamid: attackerid)
					if(attacker.exists?)
						attacker = attacker.first
						CombatLog.create(:player => player, :attacker_id => attacker.id, :weapon => weapon, :distance => distance, :damage => damage, :server_id => @server.id )
					end
				else
					puts "Player Not Found.. Can't insert CombatLog"
				end

			rescue
				puts "Error While Decoding Killed Log"
			end

			
		end



	end
end


# 'azidahaka80(76561198104607254)' has respawned
# '나야나성준이(76561198359829838)' were attacked by 'Micro-UZIU(76561198395432636)' with a 'Rock' for 10 damage from 1 meters
# '6687963(6687963)' were attacked by 'sentry.scientist.static' for 16.06118 damage from 86 meters
# '2711541(2711541)fart' were killed by 'Leekyu(76561198950321910)' with a 'Thompson' from 30 meters
# 'Leekyu(76561198950321910)' were attacked by '2711541(2711541)' with a 'M92 Pistol' for 11.64375 damage from 31 meters