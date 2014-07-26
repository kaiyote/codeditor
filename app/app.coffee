'use strict'
document.addEventListener 'DOMContentLoaded', ->
  # make this global, this will be the conduit for all cross-controller communication
  window.Emitter = require('events')
  window.Emitter = new window.Emitter.EventEmitter
  m.module document.body, ApplicationController