#requestAnimationFrame
window.requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
window.cancelAnimationFrame = window.cancelAnimationFrame or window.mozCancelAnimationFrame
if not requestAnimationFrame?
  requestAnimationFrame = (fn) ->
    setTimeout fn, 50
  cancelAnimationFrame = (id) ->
    clearTimeout id
    
#Array.filter
if !Array.prototype.filter
  Array.prototype.filter = (fn, context) ->
    result = []
    if !this || typeof fn isnt 'function' || fn instanceof RegExp
      throw new TypeError()
    for i in [0...this.length]
      if this.hasOwnProperty(i)
        value = this[i]
        if fn.call(context, value, i, this)
          result.push(value)
    result
    
extend = (out, sources...) ->
  for source in sources when source
    for own key, val of source
      if out[key]? and typeof out[key] is 'object' and val? and typeof val is 'object'
        extend(out[key], val)
      else
        out[key] = val
  out

class Evented
  on: (event, handler, ctx, once=false) ->
    @bindings ?= {}
    @bindings[event] ?= []
    @bindings[event].push {handler, ctx, once}

  once: (event, handler, ctx) ->
    @on(event, handler, ctx, true)

  off: (event, handler) ->
    return unless @bindings?[event]?
    
    if not handler?
      delete @bindings[event]
    else
      i = 0
      while i < @bindings[event].length
        if @bindings[event][i].handler is handler
          @bindings[event].splice i, 1
        else
          i++

  trigger: (event, args...) ->
    if @bindings?[event]
      i = 0
      while i < @bindings[event].length
        {handler, ctx, once} = @bindings[event][i]
        handler.apply(ctx ? @, args)
        if once
          @bindings[event].splice i, 1
        else
          i++
  
window.Emg ?= {}
extend Emg, Evented::
  
Emg.init = ->
  Emg.arr = []
  Emg.currentNum = 0
  Emg.targetNum = 0
  Emg.elems = $('.emg')
  Emg.length = Emg.elems.length
  
  Emg.elems.each (i, e) =>
    $e = $(e)
    alt = $e.data('alt')
    src = $e.data('src')
    type = $e.data('type')
    
    Emg.load($e, type, src, alt)
    
  do Emg.startProcess
      
Emg.startProcess = () ->
  console.log 'startProcess'
  Emg.processing = true
  Emg.processTimer = Date.now()
  Emg.update()
  
Emg.endProcess = () ->
  Emg.trigger('complete')
  Emg.processing = false
  clearTimeout ->
    Emg.displayTimeout()
   
Emg.update = ->
  if Emg.processing
    do Emg.processHandler
    requestAnimationFrame =>
      Emg.trigger('update')
      Emg.update()
      
Emg.processHandler = ->
  t = Date.now()
  if (t - Emg.processTimer >= 100)
    Emg.processTimer = t
    filtered = Emg.arr.filter (e) ->
      e.state() == 'resolved'
    Emg.targetNum = 0 + filtered.length / Emg.length * 100
    
  console.log Emg.currentNum, Emg.targetNum
  if Emg.currentNum >= 100
    Emg.endProcess()
    return
  
  # delta = Emg.targetNum - Emg.currentNum / (3.2 + 15 * (100 - Emg.targetNum))
  delta = (Emg.targetNum - Emg.currentNum) / 20
  # console.log 'delta', delta
  absDelta = Math.abs(delta)
  
  if absDelta < 0.01
    Emg.currentNum = Emg.targetNum
  else
    Emg.currentNum += delta
      
      
Emg.load = ($e, type, src, alt) ->
  if type is 'cvs'
    console.log 'load with canvas'
    
  if type is 'bg'
    console.log 'load with background'
    
  else # type is 'img' or type is undefined
    console.log 'load with img'
    d = $.Deferred ->
      $img = $('<img src="' + src + '" alt="' + alt + '">')
      
      $img.on 'load', (event) =>
        this.resolve()
      $img.on 'error', (event) =>
        console.log "image doesn't exist"
        this.resolve()
        
      $e.append($img)
      
    Emg.add(d)
      
Emg.add = (def) ->
  Emg.arr.push(def)
    
if typeof define is 'function' and define.amd
  # AMD
  define -> Emg
else if typeof exports is 'object'
  # CommonJS
  module.exports = Emg
else
  # Global
  Emg.init()
