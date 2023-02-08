# frozen_string_literal: true

json.extract! node, :id, :parent_id, :created_at, :updated_at
json.url node_url(node, format: :json)
