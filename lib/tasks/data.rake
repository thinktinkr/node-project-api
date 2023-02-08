# frozen_string_literal: true

require 'csv'

def db_execute(sql, data)
  ActiveRecord::Base.connection.execute(sql, data)
end

def load_csv_file(filename)
  raise "Could not fine file '#{filename}'" unless File.exist? filename

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

namespace :db do
  desc 'Add Nodes and Birds from test/fixtures/sample_nodes.csv'
  task add_sample_data: [:environment] do
    load_csv_file('test/fixtures/sample_nodes.csv')
  end

  desc 'Add Nodes and Birds from test/fixtures/test_nodes.csv'
  task add_test_data: [:environment] do
    load_csv_file('test/fixtures/test_nodes.csv')
  end

  desc 'Remove ALL Nodes and Birds'
  task clear: [:environment] do
    warn 'Removing ALL Nodes and Birds'
    ActiveRecord::Base.connection.execute('delete from birds;')
    ActiveRecord::Base.connection.execute('delete from nodes;')
  end
end
