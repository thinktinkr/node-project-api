# frozen_string_literal: true

class CommonAncestor
  # Implementation using ActiveRecord Associations (kinda slow)
  def self.node_tree_root1(node_id)
    tree_root = []
    begin
      node = Node.find(node_id)

      loop do
        tree_root.unshift(node.attributes.merge({ 'depth' => tree_root.count + 1 }))
        break if node.parent_id.nil? || tree_root.pluck('id').find_index(node.parent_id)

        node = node.parent
      end
    rescue ActiveRecord::RecordNotFound => e
      warn e.to_s if e.message != "Couldn't find Node with 'id'=0"
    end

    tree_root
  end

  # Implementation using individual Model lookups (worse yet)
  def self.node_tree_root2(node_id)
    tree_root = []
    begin
      node = Node.find(node_id)

      loop do
        tree_root.unshift(node.attributes.merge({ 'depth' => tree_root.count + 1 }))
        break if node.parent_id.nil? || tree_root.pluck('id').find_index(node.parent_id)

        node = Node.find node.parent_id
      end
    rescue ActiveRecord::RecordNotFound => e
      warn e.to_s if e.message != "Couldn't find Node with 'id'=0"
    end

    tree_root
  end

  # Implementation using individual raw sql queries (decent option)
  def self.node_tree_root3(node_id)
    sql = 'select id, parent_id from nodes where id=?'
    tree_root = []
    row = ActiveRecord::Base.connection.exec_query(sql, "q_#{node_id}", [node_id]).first

    if row
      loop do
        tree_root.unshift(row.merge({ 'depth' => tree_root.count + 1 }))
        break if row['parent_id'].nil? || tree_root.pluck('id').find_index(row['parent_id'])

        row = ActiveRecord::Base.connection.exec_query(sql, "q_#{row['parent_id']}", [row['parent_id']]).first
      end
    end

    tree_root
  end

  # Implementation using recursive query facility in SQLite (pretty quick)
  def self.node_tree_root4(node_id)
    sql = <<-SQL
    WITH RECURSIVE cte_nodes (id, parent_id, depth) AS (
      SELECT id, parent_id, 1
      FROM nodes
      WHERE id=?
      UNION ALL
      SELECT c.id, c.parent_id, r.depth + 1
      FROM nodes AS c
      INNER JOIN cte_nodes AS r ON (c.id = r.parent_id AND r.depth < 20)
    )
    SELECT DISTINCT id, parent_id
    FROM cte_nodes;
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "rec_#{node_id}", [node_id]).to_a.reverse
  end

  # def self.common_ancestor(a_id, b_id, method = 4)
  def self.find(a_id, b_id, method = 4)
    start_time = Time.now
    data = { root_id: nil, lowest_common_ancestor: nil, depth: nil }
    (results1, results2, method) = node_tree_root_dmux(a_id, b_id, method)

    if results1.count.positive? && results2.count.positive?
      results1.each_with_index do |_result, i|
        next unless results2[i] && results1[i]['id'] == results2[i]['id']

        data[:root_id] ||= results1[i]['id']
        data[:lowest_common_ancestor] = results1[i]['id']
        data[:depth] = i + 1
      end
    end

    { data:, meta: { method:, elapsed: format('%.3f sec', Time.now - start_time) } }
  end

  def self.node_tree_root_dmux(a_id, b_id, method)
    case method
    when 1
      [CommonAncestor.node_tree_root1(a_id), CommonAncestor.node_tree_root1(b_id), method]
    when 2
      [CommonAncestor.node_tree_root2(a_id), CommonAncestor.node_tree_root2(b_id), method]
    when 3
      [CommonAncestor.node_tree_root3(a_id), CommonAncestor.node_tree_root3(b_id), method]
    else
      method = 4
      [CommonAncestor.node_tree_root4(a_id), CommonAncestor.node_tree_root4(b_id), method]
    end
  end
end
