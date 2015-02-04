elasticsearch = require 'elasticsearch'

_rangeFilter = (field, type, value) ->
  obj = {
    range: {}
  }

  obj['range'][field] = {}
  obj['range'][field][type] = value

  return obj

_termFilter = (field, value) ->
  obj = {
    term: {}
  }

  obj['term'][field] = value

  return obj

FILTER_TYPES = {
  default: (field, value) ->
    return _termFilter(field, value)
  gte: (field, value) ->
    return _rangeFilter(field, 'gte', value)
  ,
  lte: (field, value) ->
    return _rangeFilter(field, 'lte', value)
  ,
  gt: (field, value) ->
    return _rangeFilter(field, 'gt', value)
  ,
  lt: (field, value) ->
    return _rangeFilter(field, 'lt', value)
  ,
  in: (field, value) ->
    obj = {
      terms: {
      }
    }

    obj['terms'][field] = value

    return obj
}

class Aggregation
  constructor: (@name, @type, @options) ->
    @aggregations = []
  
  _clone: ->
    clone = new Aggregation @name, @type, @options
    clone.aggregations = @aggregations
    return clone

  toObject: ->
    obj = {}
    obj[@type] = @options
    if @aggregations.length
      obj['aggs'] = {}
      for aggregation in @aggregations
        obj['aggs'][aggregation.name] = aggregation.toObject()
    return obj

  aggregate: (aggregation) ->
    clone = @_clone()
    clone.aggregations.push(aggregation)
    return clone

class Query
  constructor: (@index) ->
    @aggregations = []
    @query = { 'must': [], 'must_not': [] }

  _clone: ->
    clone = new Query @index
    clone.aggregations = @aggregations
    clone.query = @query
    return clone

  _parseFilter: (filter) ->
    filter = filter.split("__")
    if filter[filter.length-1] in FILTER_TYPES
      key = filter.splice(0,filter.length-1).join("__").replace("__",".")
      filter = FILTER_TYPES[filter[0]]
    else
      key = filter.join("__")
      filter = FILTER_TYPES['default']

    return { key:key, filter:filter }

  _parseFilters: (filters) ->
    _filters = []
    for filter, value of filters
      parsed = @_parseFilter(filter)
      _filters.push(parsed.filter(parsed.key, value))
    return _filters

  execute: ->
    return @index.client.es.search @toObject()

  toObject: ->
    obj = {
      aggs: {
        filtered: {
          filter: {
            bool: @query
          },
          aggs: {}
        }
      }
    }

    for aggregation in @aggregations
      obj['aggs']['filtered']['aggs'][aggregation.name] = aggregation.toObject()

    return obj

  filter: (filters) ->
    clone = @_clone()
    filters = @_parseFilters filters
    for filter in filters
      clone.query.must.push filter
    return clone

  exclude: (filters) ->
    clone = @_clone()
    filters = @_parseFilters filters
    for filter in filters
      clone.query.must_not.push filter
    return clone

  aggregate: (aggregation) ->
    clone = @_clone()
    clone.aggregations.push(aggregation)
    return clone

class Index
  constructor: (@client, @name) ->

  index: (id, type, doc, cb) ->
    @client.es.index({
      index: @name,
      id: id,
      type: type,
      body: doc
    }).then(cb)

  query: ->
    return new Query @

class Client
  constructor: (@options) ->
    @es = new elasticsearch.Client options

  index: (name) ->
    return new Index @, name

client = new Client {}
index = client.index('myindex')
query = index.query()
query = query.filter({ event: "cnbeuajftf" })
agg = new Aggregation 'rofl', 'terms', { "field": "user.id" }
agg = agg.aggregate(new Aggregation 'meh', 'stats', { field: 'timestamp' })
query = query.aggregate(agg)
query.execute().then (response) ->
  console.log response
