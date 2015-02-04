@makeRangeFilter = (field, type, value) ->
  obj = {
    range: {}
  }

  obj.range[field]
  obj.range[field][type] = value

  return obj

@makeTermFilter = (field, value) ->
  obj = {
    term: {}
  }

  obj.term[field] = value

  return obj
