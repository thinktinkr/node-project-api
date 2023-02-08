# frozen_string_literal: true

require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  test 'valid Node with no parent_id' do
    assert Node.new(id: 20).valid?
  end

  test 'valid Node with parent_id' do
    assert Node.new(id: 20, parent_id: 10).valid?
  end

  test 'invalid Node with parent_id only' do
    assert_not Node.new(parent_id: 10).valid?
  end

  def teardown
    [100, 200, 300, 400, 500, 600].each do |bird_id|
      Bird.delete(bird_id)
    end

    [10, 20, 30, 40, 50, 60].each do |node_id|
      Node.delete(node_id)
    end
  end

  test 'model associations' do
    Node.create(id: 10)
    Node.create(id: 20, parent_id: 10)
    Node.create(id: 30, parent_id: 10)
    Node.create(id: 40, parent_id: 30)
    Bird.create(id: 400, node_id: 10)

    assert Node.find(10).parent_id.nil?
    assert Node.find(10).children.count == 2
    assert Node.find(10).birds.count == 1
    assert Node.find(10).birds.first.id == 400
    assert Node.find(10).birds.first.node.id == 10

    assert Node.find(40).parent_id == 30
    assert Node.find(40).parent.id == 30
    assert Node.find(40).parent.parent_id == 10
    assert Node.find(40).parent.parent.id == 10
    assert Node.find(40).children.count.zero?
    assert Node.find(40).birds.count.zero?
  end

  test 'Node.common_ancestor()' do
    Node.create(id: 10)
    Node.create(id: 20, parent_id: 10)
    Node.create(id: 30, parent_id: 10)
    Node.create(id: 40, parent_id: 30)
    Node.create(id: 50)
    Node.create(id: 60, parent_id: 30)

    assert Node.common_ancestor(20, 40, 1)[:data] ==
           { root_id: 10, lowest_common_ancestor: 10, depth: 1 }
    assert Node.common_ancestor(60, 40, 1)[:data] ==
           { root_id: 10, lowest_common_ancestor: 30, depth: 2 }
    assert Node.common_ancestor(50, 40, 1)[:data] ==
           { root_id: nil, lowest_common_ancestor: nil, depth: nil }

    assert Node.common_ancestor(20, 40, 2)[:data] ==
           { root_id: 10, lowest_common_ancestor: 10, depth: 1 }
    assert Node.common_ancestor(60, 40, 2)[:data] ==
           { root_id: 10, lowest_common_ancestor: 30, depth: 2 }
    assert Node.common_ancestor(50, 40, 2)[:data] ==
           { root_id: nil, lowest_common_ancestor: nil, depth: nil }

    assert Node.common_ancestor(20, 40, 3)[:data] ==
           { root_id: 10, lowest_common_ancestor: 10, depth: 1 }
    assert Node.common_ancestor(60, 40, 3)[:data] ==
           { root_id: 10, lowest_common_ancestor: 30, depth: 2 }
    assert Node.common_ancestor(50, 40, 3)[:data] ==
           { root_id: nil, lowest_common_ancestor: nil, depth: nil }

    assert Node.common_ancestor(20, 40, 4)[:data] ==
           { root_id: 10, lowest_common_ancestor: 10, depth: 1 }
    assert Node.common_ancestor(60, 40, 4)[:data] ==
           { root_id: 10, lowest_common_ancestor: 30, depth: 2 }
    assert Node.common_ancestor(50, 40, 4)[:data] ==
           { root_id: nil, lowest_common_ancestor: nil, depth: nil }
  end

  test 'Node.nodes_birds()' do
    Node.create(id: 10)
    Node.create(id: 20, parent_id: 10)
    Node.create(id: 30, parent_id: 10)
    Node.create(id: 40, parent_id: 30)
    Node.create(id: 50)
    Node.create(id: 60, parent_id: 30)

    Bird.create(id: 100, node_id: 10)
    Bird.create(id: 200, node_id: 20)
    Bird.create(id: 300, node_id: 30)
    Bird.create(id: 400, node_id: 40)
    Bird.create(id: 500, node_id: 50)
    Bird.create(id: 600, node_id: 60)

    assert Node.nodes_birds([10, 50], 1)[:data][:bird_ids] == [100, 200, 300, 400, 500, 600]
    assert Node.nodes_birds([50], 1)[:data][:bird_ids] == [500]
    assert Node.nodes_birds([20, 30, 50], 1)[:data][:bird_ids] == [200, 300, 400, 500, 600]
    assert Node.nodes_birds([70], 1)[:data][:bird_ids] == []
    assert Node.nodes_birds([], 1)[:data][:bird_ids] == []

    assert Node.nodes_birds([10, 50], 2)[:data][:bird_ids] == [100, 200, 300, 400, 500, 600]
    assert Node.nodes_birds([50], 2)[:data][:bird_ids] == [500]
    assert Node.nodes_birds([20, 30, 50], 2)[:data][:bird_ids] == [200, 300, 400, 500, 600]
    assert Node.nodes_birds([70], 2)[:data][:bird_ids] == []
    assert Node.nodes_birds([], 2)[:data][:bird_ids] == []

    assert Node.nodes_birds([10, 50], 3)[:data][:bird_ids] == [100, 200, 300, 400, 500, 600]
    assert Node.nodes_birds([50], 3)[:data][:bird_ids] == [500]
    assert Node.nodes_birds([20, 30, 50], 3)[:data][:bird_ids] == [200, 300, 400, 500, 600]
    assert Node.nodes_birds([70], 3)[:data][:bird_ids] == []
    assert Node.nodes_birds([], 3)[:data][:bird_ids] == []

    assert Node.nodes_birds([10, 50], 4)[:data][:bird_ids] == [100, 200, 300, 400, 500, 600]
    assert Node.nodes_birds([50], 4)[:data][:bird_ids] == [500]
    assert Node.nodes_birds([20, 30, 50], 4)[:data][:bird_ids] == [200, 300, 400, 500, 600]
    assert Node.nodes_birds([70], 4)[:data][:bird_ids] == []
    assert Node.nodes_birds([], 4)[:data][:bird_ids] == []
  end
end
