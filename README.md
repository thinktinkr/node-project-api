# Node Project

This is a Ruby on Rails API designed tp solve the following code challenge:

```
We have an adjacency list that creates a tree of nodes where a child's parent_id = a parent's id. I have provided some sample data in the attached csv.

Please make an api (rails, sinatra, cuba--your choice) that has two endpoints: 

1) /common_ancestor - It should take two params, a and b, and it should return the root_id, lowest_common_ancestor_id, and depth of tree of the lowest common ancestor that those two node ids share.

For example, given the data for nodes:
   id    | parent_id
---------+-----------
     125 |       130
     130 |          
 2820230 |       125
 4430546 |       125
 5497637 |   4430546

/common_ancestor?a=5497637&b=2820230 should return
{root_id: 130, lowest_common_ancestor: 125, depth: 2}

/common_ancestor?a=5497637&b=130 should return
{root_id: 130, lowest_common_ancestor: 130, depth: 1}

/common_ancestor?a=5497637&b=4430546 should return
{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}

if there is no common node match, return null for all fields

/common_ancestor?a=9&b=4430546 should return
{root_id: null, lowest_common_ancestor: null, depth: null}

if a==b, it should return itself

/common_ancestor?a=4430546&b=4430546 should return
{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}

You should be able to load the data into the database, and assume that a different process will mutate the database, so while the most efficient way to solve this problem probably involves pre-processing the data and then serving that pre-processed data, I would like you to store the data in postgres in an effort to emulate data that is dynamic and expanding.

2) /birds - The second requirement for this project involves considering a second model, birds. Nodes have_many birds and birds belong_to nodes. Our second endpoint should take an array of node ids and return the ids of the birds that belong to one of those nodes or any descendant nodes.
```

## Dependencies

   - Built using Ruby 3.2.0, Rails 7.0.4.2, Bundler 2.4.1 -- others may work too.
   - Database is stock SQLite3

## Making It Go

0. Install Docker Desktop if you don't have it already

      https://www.docker.com/products/docker-desktop/

1. Create the container from the latest ruby image
      ```
      docker run -d -it -p 8010:8010 --name node_project_api ruby /bin/bash
      docker exec -it node_project_api /bin/bash
      ```

2. Update the container, install SQLite3, review versions
      ```
      apt update
      apt install sqlite3 rails
      ruby --version ; sqlite3 --version ; rails --version
      ```

3. Clone repo, build, test, and start API
      ```
      git clone https://github.com/thinktinkr/node-project-api.git
      cd node-project-api
      bundle install
      bundle exec rake db:migrate
      bundle exec rails test
      bundle exec rake run_benchmarks  # also loads test/fixtures/sample_data.csv
      bundle exec rails s
      ```

## Notes

* I moved the route `/birds` from part #2 to `/nodes_birds` because it collided with the Rails scaffold for the Birds model.  I felt this was a better solution than to disable the Birds controller and related tests.

* The API is bound to `0.0.0.0:8010` in `config/puma.rb` and should be addressable at `localhost:8010`. 

* I made the API output more JSON-API compliant by moving the requested output under the top-level key `data:` and then adding some documentation about which implementation `method:` was used and the `elapsed:` time calculated under the top-level key `meta:`.  Example output:

    ```
    {"data":{"root_id":130,"lowest_common_ancestor":125,"depth":2},"meta":{"method":"1","elapsed":"0.044 sec"}}
    ``` 

* The challenge is posed referring to the sample data being a "tree of nodes", but the reality is that there are some circular relations in the sample data that doesn't conform to any definition of "tree" that I've used before.

* All four implementations for both challenges were adjusted to break out of the looping relationships the first time a node refers to a decendent as its parent.  This works well, but it does have a quirk -- the "root node" in a loop is defined from the perspective of the decendent we work back from.  This means it is possible for two loopingly-related nodes to come up with two different root nodes and produce the following output:

    ```
    {"data":{"root_id":null,"lowest_common_ancestor":null,"depth":null},"meta":{"method":"1","elapsed":"0.044 sec"}}
    ```

## For the Future

I had initially gone down the route of deriving data from the one-directional relationship data, including the following:

   1. a `root_node_id` attribute for each node
   2. an `altitude` or `depth` attribute for each node
   3. a bridge table to jump through the relationships more efficiently
   4. a bridge table to document the children of a given node

I had developed approaches to solving #1 and #2 using some combination of the derived data, but the reality is for the sample data we're using (max 10 level hierarchy) this concept would not improve the API performance significantly and would add considerable complexity.  Given that `a different process will mutate the database`, which is where this derived data would be best implemented -- I decided that this solution approach was also outside the scope of this project.