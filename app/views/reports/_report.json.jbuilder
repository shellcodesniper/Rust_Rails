json.extract! report, :id, :title, :reason, :content, :server_id, :player_id, :user_id, :memo, :created_at, :updated_at
json.url report_url(report, format: :json)
