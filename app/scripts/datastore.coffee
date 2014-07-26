class DataStore
  @Create: (type) ->
    store = undefined
    switch type
      when 'simple' then store = new SimpleStore
      when 'relational' then store = new RelationalStore
    store
      
  class SimpleStore
    get: (key) -> JSON.parse localStorage.getItem JSON.stringify key
    set: (key, value) -> localStorage.setItem JSON.stringify(key), JSON.stringify value
    delete: (key) -> localStorage.removeItem JSON.stringify key
    count: -> localStorage.length
    clear: -> do localStorage.clear
    
  class RelationalStore
    constructor: ->
      @db = openDatabase 'nwsqldb', '1.0', 'embedded sql database', 1024 * 1024 * 256
      
    run: (query, fn) ->
      db.transaction (tx) ->
        tx.executeSql query, [], (tx, result) ->
          fn? (result.rows.item i for i in [0...result.rows.length])