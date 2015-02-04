elasticsearch = require 'elasticsearch'
Index = require './index'

class Client
  constructor: (@options) ->
    @es = new elasticsearch.Client @options

  index: (name) ->
    return new Index @, name

module.exports = Client
