# frozen_string_literal: true

json.extract! bird, :id, :node_id, :created_at, :updated_at
json.url bird_url(bird, format: :json)
