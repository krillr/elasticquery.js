utils = require './utils'

@default = (field, value) ->
  return utils.makeTermFilter field, value

@gte = (field, value) ->
  return utils.makeRangeFilter field, 'gte', value

@gt = (field, value) ->
  return utils.makeRangeFilter field, 'gt', value

@lte = (field, value) ->
  return utils.makeRangeFilter field, 'lte', value

@lt = (field, value) ->
  return utils.makeRangeFilter field, 'lt', value

@in = (field, value) ->
  obj = {
    terms: {
    }
  }

  obj.terms[field] = value

  return obj
