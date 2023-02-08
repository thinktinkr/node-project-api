# frozen_string_literal: true

require 'common_ancestor'
require 'nodes_birds'

class Node < ApplicationRecord
  has_one :parent, class_name: 'Node', primary_key: 'parent_id', foreign_key: 'id'
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  has_many :birds
  validates :id, presence: true, uniqueness: true

  def self.common_ancestor(a_id, b_id, method)
    CommonAncestor.find(a_id, b_id, method)
  end

  def self.nodes_birds(node_ids, method)
    NodesBirds.find(node_ids, method)
  end
end
