module.exports = patchMochaSuite = (Mocha) ->
  Suite = Mocha.Suite
  RetryHook = require './retryHook'

  Suite::beforeAllWithRetry = (times, title, fn) ->
    return @ if @pending
    unless title?
      fn = times
      title = fn.name
      times = undefined
    else unless fn?
      if typeof times is 'number'
        [title, fn] = [undefined, title]
      else
        [title, fn, times] = [times, title, undefined]
      if typeof title is 'function'
        fn = title
        title = fn.name
    if !times? and @times? then times = @times
    title = "\"before all\" hook" + ((if title then ": " + title else ""))
    hook = new RetryHook times, title, fn
    hook.parent = @
    hook.timeout @timeout()
    hook.slow @slow()
    hook.ctx = @ctx
    @_beforeAll.push hook
    @emit "beforeAll", hook
    @

  Suite::beforeEachWithRetry = (times, title, fn) ->
    return @ if @pending
    unless title?
      fn = times
      title = fn.name
      times = undefined
    else unless fn?
      if typeof times is 'number'
        [title, fn] = [undefined, title]
      else
        [title, fn, times] = [times, title, undefined]
      if typeof title is 'function'
        fn = title
        title = fn.name
    if !times? and @times? then times = @times
    title = "\"before each\" hook" + ((if title then ": " + title else ""))
    hook = new RetryHook times, title, fn
    hook.parent = @
    hook.timeout @timeout()
    hook.slow @slow()
    hook.ctx = @ctx
    @_beforeEach.push hook
    @emit "beforeEach", hook
    @

  Suite::afterAllWithRetry = (times, title, fn) ->
    return @ if @pending
    unless title?
      fn = times
      title = fn.name
      times = undefined
    else unless fn?
      if typeof times is 'number'
        [title, fn] = [undefined, title]
      else
        [title, fn, times] = [times, title, undefined]
      if typeof title is 'function'
        fn = title
        title = fn.name
    if !times? and @times? then times = @times
    title = "\"after all\" hook" + ((if title then ": " + title else ""))
    hook = new RetryHook times, title, fn
    hook.parent = @
    hook.timeout @timeout()
    hook.slow @slow()
    hook.ctx = @ctx
    @_afterAll.push hook
    @emit "afterAll", hook
    @

  Suite::afterEachWithRetry = (times, title, fn) ->
    return @ if @pending
    unless title?
      fn = times
      title = fn.name
      times = undefined
    else unless fn?
      if typeof times is 'number'
        [title, fn] = [undefined, title]
      else
        [title, fn, times] = [times, title, undefined]
      if typeof title is 'function'
        fn = title
        title = fn.name
    if "function" is typeof title
      fn = title
      title = fn.name
    if !times? and @times? then times = @times
    title = "\"after each\" hook" + ((if title then ": " + title else ""))
    hook = new RetryHook times, title, fn
    hook.parent = @
    hook.timeout @timeout()
    hook.slow @slow()
    hook.ctx = @ctx
    @_afterEach.push hook
    @emit "afterEach", hook
    @
