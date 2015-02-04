elasticsearch = require 'elasticsearch'
Query = require './query'

class Client
  constructor: (@options) ->
    @es = new elasticsearch.Client @options

  query: (indexName) ->
    return new Query @, indexName

module.exports = Client
