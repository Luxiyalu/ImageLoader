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
  
Emg.init = (options) ->
  # console.log 'init'
  Emg.arr = []
  Emg.currentNum = 0
  Emg.targetNum = 0
  Emg.elems = $('.emg')
  Emg.mediaElems = []
  Emg.length = Emg.elems.length
  
  for obj of options
    Emg[obj] = options[obj]
    
  if Emg.divide && Emg.naming
    Emg.bindWindowResize()
    
Emg.start = () ->
  Emg.trigger('start')
  Emg.elems.each (i, e) =>
    Emg.load($(e))
  Emg.processing = true
  Emg.processTimer = Date.now()
  Emg.update()
  
Emg.end = () ->
  Emg.trigger('complete')
  Emg.processing = false
   
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
    
  if Emg.currentNum >= 100
    Emg.end()
    return
  
  delta = (Emg.targetNum - Emg.currentNum) / 2
  absDelta = Math.abs(delta)
  
  if absDelta < 0.01
    Emg.currentNum = Emg.targetNum
  else
    Emg.currentNum += delta
      
Emg.mediaP = (src) ->
  # if the src include a {media}
  src.match(/{media}/)
  
Emg.getSrc = (src) ->
  Emg.media = Emg.media || Emg.getMedia() # if first time, get Media
  src.replace(/{media}/, Emg.media)
  
Emg.load = ($e) ->
  alt = $e.data('alt')
  src = $e.data('src')
  type = $e.data('type')
  
  if Emg.mediaP(src)
    Emg.mediaElems.push($e)
    src = Emg.getSrc(src)
    
  d = $.Deferred ->
    $img = $('<img>').attr
      src: src
      alt: alt
      
    $img.on 'load', (event) =>
      this.resolve()
    $img.on 'error', (event) =>
      console.log "image doesn't exist"
      this.resolve()
      
    ## type is canvas
    if type is 'cvs'
      console.log 'load with canvas'
      
    ## type is background
    if type is 'bg'
      $e.css('backgroundImage', 'url('+src+')')
      
    ## type is image tag
    else
      $e.append($img)
      
  Emg.add(d)

Emg.bindWindowResize = ->
  $(window).on 'resize', ->
    t = Date.now()
    setTimeout ->
        return if t - Emg.resizeTimer < 100 # interval of getMedia()
        
        media = Emg.getMedia()
        return if Emg.media is media
        
        # console.log 'change to', media
        Emg.media = media
        for $e in Emg.mediaElems
          Emg.load($e)
            
        Emg.resizeTimer = t
      , 200 # delay from stop resizing to change src
      # must be larger than the first interval, or it wouldn't make sense to exist
      
Emg.getMedia = ->
  if Emg.divide && Emg.naming
    i = 0
    for num in [0...Emg.divide.length]
      i++ if $(window).width() > Emg.divide[num]
    Emg.naming[i]
  else
    console.log 'Please provide options "divide" and "naming" for mediaquery to work'
    
Emg.add = (def) ->
  Emg.arr.push(def)
    
# initiate
Emg.init()

if typeof define is 'function' and define.amd
  # AMD
  define -> Emg
else if typeof exports is 'object'
  # CommonJS
  module.exports = Emg
else
  # Global
  Emg.start()
