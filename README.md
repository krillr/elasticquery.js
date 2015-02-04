Simple aggregation-centric library for querying ElasticSearch

[![Circle CI](https://circleci.com/gh/krillr/elasticquery.js.png?style=badge)](https://circleci.com/gh/krillr/elasticquery.js)

CoffeeScript
------
ElasticQuery.js is written in CoffeeScript, and as such its API is geared towards usage in CoffeeScript. Where possible, helper utilities are provided to make it easier for pure JavaScript usage -- but keep in mind that pure JavaScript is treated as a second-class citizen.

Aggregations and Queries
------
Aggregations and Queries are both cloned every time you perform and operation on or with them. This is avantageous where you may want to define multiple different aggregations and mix them at query time, or if you want to predefine a base query then expand on it later in code.

Promises
------
The core elasticsearch client uses promises, so we do too!

Example
======
```CoffeeScript
client = new ElasticQuery.Client

# Aggregations are defined outside of queries, so they can be reused
aggregation = new ElasticQuery.Aggregation 'myAggregation', 'stats', { field: 'number' }

# Queries are created on a specific index, for now
query = client.query 'my-index'
              .aggregate aggregation

query.execute()
    .then (response) ->
      console.log response
```
