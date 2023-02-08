# frozen_string_literal: true

class Bird < ApplicationRecord
  belongs_to :node
  validates :id, presence: true, uniqueness: true
  validates :node_id, presence: true
end
