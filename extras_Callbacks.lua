require('middleclass')
require('middleclass-extras')

context( 'Callbacks', function()
  local A
  
  local function redefineA()
    A = class('A')
    function A:initialize()
      super.initialize(self)
      self.calls = {}
    end
    function A:__tostring()
      result = {}
      for _,call in ipairs(self.calls) do table.insert(result, call) end
      return self.class.name ..'(' .. table.concat(result, ', ') .. ')'
    end
  end
  
  local function defineRegularMethods(theClass)
    function theClass:foo() table.insert(self.calls, 'foo') end
    function theClass:bar() table.insert(self.calls, 'bar') end
    function theClass:baz() table.insert(self.calls, 'baz') end
  end
  
  local function addCallbacks(theClass)
    theClass:include(Callbacks)
    theClass:before('bar', 'foo')
    theClass:after('bar', function(myself) myself:baz() end )
  end
  
  local function testInstance(theClass)
    local obj = theClass:new()
    
    obj:bar()
    obj:barWithoutCallbacks()

    assert_equal(obj.calls[1], 'foo')
    assert_equal(obj.calls[2], 'bar')
    assert_equal(obj.calls[3], 'baz')
    assert_equal(obj.calls[4], 'bar')
  end

  before(redefineA)

  test('fooWithoutCallbacks should call foo if no callbacks are defined', function()
    defineRegularMethods(A)
    addCallbacks(A)
    local obj = A:new()
    obj:fooWithoutCallbacks()
    assert_equal(obj.calls[1], 'foo')
  end)

  test('Should work when declared before the methods', function()
    addCallbacks(A)
    defineRegularMethods(A)
    testInstance(A)
  end)
  
  test('Should work when declared after the methods', function()
    defineRegularMethods(A)
    addCallbacks(A)
    testInstance(A)
  end)
  
  test('Throws error if theClass:new has been modified when including', function()
    defineRegularMethods(A)
    A.new = function() end -- replace new with an empty function
    assert_error(function() addCallbacks(A) end)
  end)

  context('When subclassing', function()
    local B

    before(redefineA)
    
    test('callbacks declared before inherited methods should work', function()
      A:include(Callbacks)
      B = class('B', A)
      addCallbacks(B)
      defineRegularMethods(A)
      testInstance(B)
    end)
    
    test('callbacks declared after inherited methods should work', function()
      defineRegularMethods(A)
      B = class('B', A)
      addCallbacks(B)
      testInstance(B)
    end)

    test('callbacks should be conserved in subclasses', function()
      addCallbacks(A)
      defineRegularMethods(A)
      B = class('B', A)
      testInstance(B)
    end)

    test('callbacks in subclasses can be used as well as in superclasses', function()
      addCallbacks(A)
      defineRegularMethods(A)
      addCallbacks(B)
      local obj = B:new()
      obj:bar()

      assert_equal(obj.calls[1], 'foo')
      assert_equal(obj.calls[2], 'foo')
      assert_equal(obj.calls[3], 'bar')
      assert_equal(obj.calls[4], 'baz')
      assert_equal(obj.calls[5], 'baz')
    end)

    -- https://github.com/kikito/middleclass-extras/issues/#issue/3
    test('initialize should be respected', function()
      A:include(Callbacks)
      defineRegularMethods(A)
      A:after('initialize', 'foo')
      B = class('B', A)
      function B:initialize()
        super.initialize(self)
        self.x = 'x'
      end
      
      local obj = B:new()
      
      assert_equal(#obj.calls, 1)
      assert_equal(obj.x, 'x')
    end)

  end)


  context('Destroy and Initialize', function()
    test('Should have working callbacks too', function()
      redefineA()
      defineRegularMethods(A)
      A:include(Callbacks)

      local x = 0
      -- before initialize is only valid for methods that don't rely on self.calls
      A:before('initialize', function() x = 1 end)
      A:after( 'initialize', 'foo')

      A:before('destroy', 'foo')
      A:after( 'destroy', 'bar')

      local obj = A:new()
      assert_equal(x, 1)
      assert_equal(obj.calls[1], 'foo')

      obj:destroy()
      assert_equal(obj.calls[2], 'foo')
      assert_equal(obj.calls[3], 'bar')

    end)
  end)

end)
