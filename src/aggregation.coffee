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
      obj.aggs = {}
      for aggregation in @aggregations
        obj.aggs[aggregation.name] = aggregation.toObject()
    return obj

  aggregate: (aggregation) ->
    clone = @_clone()
    clone.aggregations.push aggregation._clone()
    return clone

module.exports = Aggregation
