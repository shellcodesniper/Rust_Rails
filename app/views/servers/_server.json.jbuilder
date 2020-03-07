json.extract! server, :id, :title, :rcon_host, :rcon_port, :rcon_pass, :memo, :created_at, :updated_at
json.url server_url(server, format: :json)
