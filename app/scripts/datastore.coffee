class DataStore
  @get: (key) -> JSON.parse localStorage.getItem JSON.stringify key
  @set: (key, value) -> localStorage.setItem JSON.stringify(key), JSON.stringify value
  @delete: (key) -> localStorage.removeItem JSON.stringify key
  @count: -> localStorage.length
  @clear: -> do localStorage.clear