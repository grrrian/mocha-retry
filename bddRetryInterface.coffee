module.exports = createInterface = (Mocha) ->
  RetryTest = require './retryTest'
  interfaces = Mocha.interfaces
  Suite = Mocha.Suite
  utils = Mocha.utils
  patchMochaSuite = require './retrySuite'
  patchMochaSuite Mocha

  interfaces.bddretry = (suite) ->
    suites = [suite]
    suite.on "pre-require", (context, file, mocha) ->
      
      context.before = (times, name, fn) -> suites[0].beforeAllWithRetry times, name, fn
      
      context.after = (times, name, fn) -> suites[0].afterAllWithRetry times, name, fn
      
      context.beforeEach = (times, name, fn) -> suites[0].beforeEachWithRetry times, name, fn
      
      context.afterEach = (times, name, fn) -> suites[0].afterEachWithRetry times, name, fn
      
      context.describe = context.context = (times, title, fn) ->
        unless fn?
          [title, fn] = [times, title]
          times = undefined
        if suites[0].times? and !times?
          times = suites[0].times
        if context.DEFAULT_RETRY? and !times?
          times = context.DEFAULT_RETRY
        asuite = Suite.create(suites[0], title)
        asuite.times = times
        asuite.file = file
        suites.unshift asuite
        fn.call asuite
        suites.shift()
        asuite

      context.xdescribe = context.xcontext = context.describe.skip = (times, title, fn) ->
        unless fn?
          [title, fn] = [times, title]
          times = undefined
        asuite = Suite.create(suites[0], title)
        asuite.pending = true
        suites.unshift asuite
        fn.call asuite
        suites.shift()

      context.describe.only = (times, title, fn) ->
        asuite = context.describe times, title, fn
        mocha.grep asuite.fullTitle()
        asuite

      context.it = context.itretry = (times, title, fn) ->
        asuite = suites[0]
        if !fn? and typeof times isnt 'number'
          [title, fn] = [times, title]
          times = if asuite.times? then asuite.times else 1
        fn = null if asuite.pending
        test = new RetryTest times, title, fn
        test.file = file
        asuite.addTest test
        test
      
      context.it.only = (times, title, fn) ->
        test = context.it times, title, fn
        reString = "^" + utils.escapeRegexp(test.fullTitle()) + "$"
        mocha.grep new RegExp(reString)
        test

      context.xit = context.xspecify = context.it.skip = (times, title, fn) ->
        unless title?
          return context.it times
        unless fn?
          [times, title, fn] = [1, times, title]
        context.it times, title
