# frozen_string_literal: true

class NodesBirds
  def self.collect_descendant_bird_ids(node)
    return [] if @nodes_seen.find_index(node.id)

    @nodes_seen << node.id
    bird_ids = [node.birds.map(&:id)]

    node.children.each do |child|
      bird_ids << NodesBirds.collect_descendant_bird_ids(child)
    end

    bird_ids.flatten
  end

  # Implementation using ActiveRecord Associations recursively (quite slow)
  def self.collect_birds1(node_ids)
    @nodes_seen = []
    bird_ids = []
    Node.where(id: node_ids).each do |node|
      bird_ids << NodesBirds.collect_descendant_bird_ids(node)
    end

    { bird_ids: bird_ids.flatten.sort }
  end

  # Implementation using individual Model lookups (decent option)
  def self.collect_birds2(node_ids)
    i = 0
    while i < node_ids.count
      Node.where(parent_id: node_ids[i]).each do |row|
        node_ids << row.id unless node_ids.find_index(row.id)
      end
      i += 1
    end

    { bird_ids: Bird.where(node_id: node_ids).map(&:id).sort }
  end

  # Implementation using individual raw sql queries (decent option)
  def self.collect_birds3(node_ids)
    i = 0
    sql = 'SELECT id FROM nodes WHERE parent_id=?'
    while i < node_ids.count
      ActiveRecord::Base.connection.exec_query(sql, 'q', [node_ids[i]]).each do |row|
        node_ids << row['id'] unless node_ids.find_index(row['id'])
      end
      i += 1
    end

    sql = "SELECT id FROM birds WHERE node_id in (#{node_ids.join(',')})"
    bird_ids = ActiveRecord::Base.connection.exec_query(sql, 'q2', []).pluck('id')
    { bird_ids: bird_ids.sort }
  end

  # Implementation using recursive query facility in SQLite (pretty quick)
  def self.collect_birds4(node_ids)
    return [] unless node_ids

    list = node_ids.map(&:to_i).compact.join(',')
    sql = <<-SQL
    WITH RECURSIVE cte_nodes (id, parent_id, depth) AS (
      SELECT id, parent_id, 1
      FROM nodes
      WHERE id IN (#{list})
      UNION ALL
      SELECT c.id, c.parent_id, r.depth + 1
      FROM nodes AS c
      INNER JOIN cte_nodes AS r ON (c.parent_id = r.id AND r.depth < 20)
    )
    SELECT DISTINCT birds.id
    FROM cte_nodes JOIN birds ON cte_nodes.id=birds.node_id;
    SQL

    { bird_ids: ActiveRecord::Base.connection.exec_query(sql).pluck('id') }
  end

  def self.find(node_ids, method = 3)
    start_time = Time.now

    case method.to_i
    when 1
      data = NodesBirds.collect_birds1(node_ids)
    when 2
      data = NodesBirds.collect_birds2(node_ids)
    when 3
      data = NodesBirds.collect_birds3(node_ids)
    else
      data = NodesBirds.collect_birds4(node_ids)
      method = 4
    end

    { data:, meta: { method:, elapsed: format('%.3f sec', Time.now - start_time) } }
  end
end
