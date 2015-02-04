Query = require './query'

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

module.exports = Index
