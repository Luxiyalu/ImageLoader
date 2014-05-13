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
  
window.ImageLoader ?= {}
extend ImageLoader, Evented::
  
ImageLoader.init = (options) ->
  # console.log 'init'
  ImageLoader.arr = []
  ImageLoader.currentNum = 0
  ImageLoader.targetNum = 0
  ImageLoader.elems = $('.emg')
  ImageLoader.mediaElems = []
  ImageLoader.length = ImageLoader.elems.length
  
  for obj of options
    ImageLoader[obj] = options[obj]
    
  if ImageLoader.divide && ImageLoader.naming
    ImageLoader.bindWindowResize()
    
  ImageLoader.start()
    
ImageLoader.start = () ->
  ImageLoader.trigger('start')
  ImageLoader.elems.each (i, e) =>
    ImageLoader.load($(e))
  ImageLoader.processing = true
  ImageLoader.processTimer = Date.now()
  ImageLoader.update()
  
ImageLoader.end = () ->
  ImageLoader.trigger('complete')
  ImageLoader.processing = false
   
ImageLoader.update = ->
  if ImageLoader.processing
    do ImageLoader.processHandler
    requestAnimationFrame =>
      ImageLoader.trigger('update')
      ImageLoader.update()
      
ImageLoader.processHandler = ->
  t = Date.now()
  if (t - ImageLoader.processTimer >= 100)
    ImageLoader.processTimer = t
    filtered = ImageLoader.arr.filter (e) ->
      e.state() == 'resolved'
    ImageLoader.targetNum = 0 + filtered.length / ImageLoader.length * 100
    
  if ImageLoader.currentNum >= 100
    ImageLoader.end()
    return
  
  delta = (ImageLoader.targetNum - ImageLoader.currentNum) / 2
  absDelta = Math.abs(delta)
  
  if absDelta < 0.01
    ImageLoader.currentNum = ImageLoader.targetNum
  else
    ImageLoader.currentNum += delta
      
ImageLoader.mediaP = (src) ->
  # if the src include a {media}
  src.match(/{media}/)
  
ImageLoader.getSrc = (src) ->
  ImageLoader.media = ImageLoader.media || ImageLoader.getMedia() # if first time, get Media
  src.replace(/{media}/, ImageLoader.media)
  
ImageLoader.load = ($e) ->
  alt = $e.data('alt')
  src = $e.data('src')
  type = $e.data('type')
  
  if ImageLoader.mediaP(src)
    ImageLoader.mediaElems.push($e)
    src = ImageLoader.getSrc(src)
    
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
      
  ImageLoader.add(d)

ImageLoader.bindWindowResize = ->
  $(window).on 'resize', ->
    t = Date.now()
    setTimeout ->
        return if t - ImageLoader.resizeTimer < 100 # interval of getMedia()
        
        media = ImageLoader.getMedia()
        return if ImageLoader.media is media
        
        # console.log 'change to', media
        ImageLoader.media = media
        for $e in ImageLoader.mediaElems
          ImageLoader.load($e)
            
        ImageLoader.resizeTimer = t
      , 200 # delay from stop resizing to change src
      # must be larger than the first interval, or it wouldn't make sense to exist
      
ImageLoader.getMedia = ->
  if ImageLoader.divide && ImageLoader.naming
    i = 0
    for num in [0...ImageLoader.divide.length]
      i++ if $(window).width() > ImageLoader.divide[num]
    ImageLoader.naming[i]
  else
    console.log 'Please provide options "divide" and "naming" for mediaquery to work'
    
ImageLoader.add = (def) ->
  ImageLoader.arr.push(def)
    
# initiate
ImageLoader.init()

if typeof define is 'function' and define.amd
  # AMD
  define -> ImageLoader
else if typeof exports is 'object'
  # CommonJS
  module.exports = ImageLoader
else
  # Global
  ImageLoader.start()
