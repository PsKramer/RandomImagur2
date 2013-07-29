
class ImgurStore
  constructor: (@imageBufferSize = 3, @minWidth = 150)->
    @imageList = []
    @fillCounter = 0
    @autoFillInterval = 1000

  enableAutoFill: ->
    @autoFillIntervalID = setInterval( @_autoFill, @autoFillInterval )
  disableAutoFill: ->
    clearInterval @autoFillIntervalID

  getImage: ->
    if @autoFillIntervalID
      # If the buffer was empty, decrease the buffer refill time
      if @imageList.length == 0 && @autoFillInterval > 10
        @autoFillInterval /= 2
        console.log "Setting autoFillInterval to " + @autoFillInterval

      # If the buffer was full, increase the buffer refill time (slowely)
      else if @imageList.length == @imageBufferSize && @autoFillInterval < 5000
        @autoFillInterval *= 1.2
        console.log "Setting autoFillInterval to " + @autoFillInterval

    @imageList.pop()

  _autoFill: =>
    console.log( '---- Autofilling; counter = ' + @fillCounter )
    if @fillCounter == 0
      console.log "Will autofill"
      @_fillList()
    else
      console.log "Can't autofill, alread filling"

  _fillList: ->
    i = @imageList.length
    while i < @imageBufferSize
      @fillCounter++
      i++
      console.log( "Starting search (i=" + i + ")" )
      @_fetchImage()

   _makeid: ->
    text = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    for i in [1..5]
      text += possible.charAt(Math.floor(Math.random() * possible.length))

    return text

  _fetchImage: ->
    recurseUntilSuccess = =>
      @_tryToGetImage().then (
        ($img) =>
          console.log( "Succeeded" )
          @imageList.unshift $img
          @fillCounter--
      ), (
        ->
          console.log( "Failed" )
          recurseUntilSuccess()
      )
    recurseUntilSuccess()

  _tryToGetImage: (success, failure)->
    #console.log 'try to load'
    url = 'http://i.imgur.com/' + @_makeid() + '.jpg'
    $img = $ "<img class='imgurImage' src='" + url + "'>"
    $deferred = $.Deferred()

    # Hide the image but still add it to the dom so the height/width load
    $img.css('position','absolute')
    $img.css('left','-10000px')
    $img.css('top','-10000px')
    $img.css('opacity','-10000px')
    $('body').append($img)
    $img.load (e) =>
      if( ($img.width() == 161 && $img.height() == 81) || # kill non-existant images
          ($img.width() < @minWidth ) || # kill images smaller than 1 column
          ($img.width() < 25 || $img.height() < 25 ) )# kill super thin/tall images
        $deferred.reject()
        $img.remove()
      else
        $img.remove()
        $img.css('position','relative')
        $img.css('left','0')
        $img.css('top','0')
        $img.detach()
        $deferred.resolve($img)
    $deferred

# For testing right now
window.store = new ImgurStore()
