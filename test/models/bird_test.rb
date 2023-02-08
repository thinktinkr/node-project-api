# frozen_string_literal: true

require 'test_helper'

class BirdTest < ActiveSupport::TestCase
  def setup
    Node.create(id: 50)
  end

  def teardown
    Node.delete(50)
  end

  test 'valid Bird with node_id' do
    assert Bird.new(id: 500, node_id: 50).valid?
  end

  test 'invalid Bird with id only' do
    assert_not Bird.new(id: 500).valid?
  end

  test 'invalid Bird with node_id only' do
    assert_not Bird.new(node_id: 50).valid?
  end
end
