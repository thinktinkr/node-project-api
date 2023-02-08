# frozen_string_literal: true

json.array! @nodes, partial: 'nodes/node', as: :node
