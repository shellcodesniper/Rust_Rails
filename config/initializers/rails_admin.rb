# Custom Field

RailsAdmin.config do |config|
	config.model Jail do
		edit do
			include_all_fields
			exclude_fields :created_at
			field :start_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
			field :end_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
		list do
			include_all_fields
			exclude_fields :created_at
			field :start_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
			field :end_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
	end
	config.model Cron do
		edit do
			include_all_fields
			exclude_fields :created_at
			field :next do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
		list do
			include_all_fields
			exclude_fields :created_at
			field :next do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
	end

	config.model Server do
		edit do
			include_all_fields
			exclude_fields :created_at
			field :start_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
		list do
			include_all_fields
			exclude_fields :created_at
			field :start_date do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
	end

	config.model Broadcast do
		edit do
			include_all_fields
			exclude_fields :created_at
			field :next do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
		list do
			include_all_fields
			exclude_fields :created_at
			field :next do
				strftime_format do
					'%Y-%m-%d %H:%M:%S'
				end
			end
		end
	end

	config.model CombatLog do
		list do
			field :id do
			end
			field :player do	
			end
			field :attacker do
			end
			field :damage do
			end
			include_all_fields
			exclude_fields :created_at, :updated_at
		end
	end

	config.model Player do
		list do
			field :id do
			end
			field :server do
			end
			include_all_fields
			
			field  :steamplaytime do
				formatted_value do # used in form views
					hour = (value / 60).to_s.rjust(2, '0')
					minute = (value % 60).to_s.rjust(2, '0')
					# second = (value % 60).to_s.rjust(2, '0')
					if(value == -1) then value = "미인증유저" else value = "#{hour} 시 #{minute}분" end
				end
			end

			field  :serverplaytime do
				formatted_value do # used in form views
					hour = (value / 3600).to_s.rjust(2, '0')
					minute = ((value % 3600) / 60).to_s.rjust(2, '0')
					second = (value % 60).to_s.rjust(2, '0')
					value = "#{hour} 시 #{minute}분 #{second}초"
				end
			end
			include_all_fields
			exclude_fields :created_at, :updated_at
		end
	end


  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with do
    redirect_to main_app.root_path unless current_user.try(:admin?)
  end

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end

