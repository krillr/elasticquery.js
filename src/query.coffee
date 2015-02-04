filters = require './filters'

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
    # I would kill for a decent rsplit in javascript
    split_filter = filter.split "__"

    if split_filter[filter.length-1] in filters
      # because then I wouldn't have to do this kind of crap
      key = filter.splice(0,filter.length-1).join("__").replace("__",".")
      filter = filters[filter[filter.length-1]]
    else
      key = filter
      filter = filters.default

    return { key:key, filter:filter }

  _parseFilters: (filters) ->
    _filters = []
    for filter, value of filters
      parsed = @_parseFilter(filter)
      _filters.push parsed.filter(parsed.key, value)
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
      obj.aggs.filtered.aggs[aggregation.name] = aggregation.toObject()

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
    clone.aggregations.push aggregation
    return clone

module.exports = Query