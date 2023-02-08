# frozen_string_literal: true

require 'csv'

def db_execute(sql, data = [])
  ActiveRecord::Base.connection.execute(sql, data)
end

def clear_database
  db_execute 'delete from birds', []
  db_execute 'delete from nodes', []
end

def load_csv_file(filename)
  raise "Could not fine file '#{filename}'" unless File.exist? filename

  warn "Loading Nodes and Birds from #{filename}"
  csv_data = []

  CSV.read(filename, headers: true).each do |row|
    csv_data << { id: row['id'], parent_id: row['parent_id'] }
  end

  Node.insert_all(csv_data)
  db_execute 'insert into birds SELECT id, id FROM nodes', []
  db_execute 'insert into birds SELECT id*10, id FROM nodes', []
  db_execute 'insert into birds SELECT id*100, id FROM nodes', []

  warn "Added #{Node.all.count} Nodes and #{Bird.all.count} Birds"
end

# Randomly choosing node_ids almost always found unrelated nodes.
def choose_node_ids(node_ids)
  a = node_ids.sample
  options = [0, a]
  options << Node.find(a)&.parent&.id
  options << Node.find(a)&.parent&.parent&.id
  options << Node.find(a)&.children&.first&.id
  options << Node.find(a)&.children&.first&.children&.first&.id
  [a, options.compact.sample]
end

def benchmark_common_ancestors(node_ids)
  times = [[], [], [], [], []]
  methods = [1, 2, 3, 4]

  100.times do |i|
    print "\r\r\r#{i + 1}"
    results = []
    (a, b) = choose_node_ids(node_ids)

    for method in methods.shuffle do
      start_time = Time.now
      results[method] = Node.common_ancestor(a, b, method)[:data]
      times[method] << Time.now - start_time
    end

    if results[1] != results[2] || results[2] != results[3] || results[3] != results[4]
      warn "\n  ERROR DETECTED: #{a} vs. #{b}"
      results.each_with_index { |result, i| warn "  #{i} #{result.inspect}" }
    end
  end

  print "\r\r\r"

  methods.sort.each do |method|
    count = times[method].count
    avg = times[method].sum / times[method].count
    warn format("  Node.nodes_birds #{method}() - runs: %d, avg: %0.4f sec", count, avg)
  end
end

def benchmark_birds(node_ids)
  times = [[], [], [], [], []]
  methods = [1, 2, 3, 4]

  100.times do |i|
    print "\r\r\r#{i + 1}"
    results = []
    a = node_ids.sample
    b = node_ids.sample
    c = node_ids.sample

    for method in methods.shuffle do
      start_time = Time.now
      results[method] = Node.nodes_birds([a, b, c], method)[:data]
      times[method] << Time.now - start_time
    end

    if results[1] != results[2] || results[2] != results[3] || results[3] != results[4]
      warn "\n  ERROR DETECTED: #{a} vs. #{b}"
      results.each_with_index { |result, i| warn "  #{i} #{result.inspect}" }
    end
  end
  print "\r\r\r"

  methods.sort.each do |method|
    count = times[method].count
    avg = times[method].sum / times[method].count
    warn format("  Node.nodes_birds #{method}() - runs: %d, avg: %0.4f sec", count, avg)
  end
end

def print_reference
  warn <<-TXT

There are four methods implemented for each challenge, here's the rundown:
  1 - Uses Model.find() with associations for all relationship navigation
  2 - Uses Model.find() for all relationship navigation
  3 - Uses multiple raw sql simple queries for all relationship navigation
  4 - Uses one raw sql recursive query
  TXT
end

desc 'Load sample data, run benchmarks on common_ancestor and nodes_birds implementations'
task run_benchmarks: [:environment] do
  warn 'Preparing database...'
  clear_database
  load_csv_file('test/fixtures/sample_nodes.csv')
  node_ids = db_execute('select id from nodes', []).map { |n| n['id'] }

  print_reference

  warn "\nBenchmarking common_ancestor implementations..."
  benchmark_common_ancestors node_ids

  warn "\nBenchmarking nodes_birds implementations..."
  benchmark_birds node_ids
end
