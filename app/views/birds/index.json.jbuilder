# frozen_string_literal: true

json.array! @birds, partial: 'birds/bird', as: :bird
