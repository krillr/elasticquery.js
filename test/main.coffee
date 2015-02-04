ElasticQuery = require '../src/elasticquery'
Q = require 'q'
fixtures = require './fixtures'

chai = require 'chai'

should = chai.should()
expect = chai.expect

describe 'ElasticQuery', ->
  #index fixtures
  before (done) =>
    @client = new ElasticQuery.Client
    promises = []
    for id, body of fixtures
      promise = @client.es.index {
        id: id,
        index: 'test-index',
        type: 'testObject',
        body: body
      }
      promises.push promise
    Q.all promises
      .then =>
        @client.es.indices.refresh { index: "test-index" }
          .then ->
            done()

  it 'return an average correctly', (done) =>
    agg = new ElasticQuery.Aggregation 'stats', 'stats', { field: 'n' }
    query = @client.query('test-index')
                   .aggregate(agg)
    query.execute()
      .then (response) ->
        response.stats.avg.should.equal 4.5
        done()

  # delete fixtures
  after (done) =>
    promises = []
    for id, body of fixtures
      promise = @client.es.delete {
        id: id,
        index: 'test-index',
        type: 'testObject'
      }
      promises.push promise
    Q.all promises
      .then ->
        done()
