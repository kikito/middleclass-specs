require('middleclass')
require('middleclass-extras')

context( 'Indexable', function()

  local MyClass = class('MyClass'):include(Indexable)
  function MyClass:initialize()
    self.x = self.y
  end
  function MyClass:index(x)
    return self.class.name .. '-' .. tostring(x)
  end
  function MyClass:foo() return 'foo' end

  local obj = MyClass:new()

  test('Should work inside the initializer', function()
    assert_equal(obj.x, 'MyClass-y')
  end)

  test('Normal lookup should still work', function()
    assert_equal(obj:foo(), 'foo')
    assert_equal(obj:index('hello'), 'MyClass-hello')
  end)
  
  test('index should be used for lookup', function()
    assert_equal(obj.hello, 'MyClass-hello')
  end)
  
  context('When subclassing', function()
  
    local MyChildClass = class('MyChildClass', MyClass)
    local obj2 = MyChildClass:new()
    
    test('Previous lookup should still work', function()
      assert_equal(obj2:foo(), 'foo')
      assert_equal(obj2:index('hello'), 'MyChildClass-hello')
    end)
    
    test('index should be used for lookup', function()
      assert_equal(obj2.hello, 'MyChildClass-hello')
    end)
    
    context('When subclassing MORE and overriding index', function()
      
      local MyGrandChildClass = class('MyGrandChildClass', MyChildClass)
      
      function MyGrandChildClass:bar() return 'bar' end
      
      function MyGrandChildClass:index(name)
        if name == 'baz' then return self.bar end
        if name == 'hello' then return MyChildClass.index(self, name) end
      end
      
      local obj3 = MyGrandChildClass:new()
      
      test('Normal lookup should still work', function()
        assert_equal(obj3:foo(), 'foo')
        assert_equal(obj3:bar(), 'bar')
        assert_equal(obj3:index('hello'), 'MyGrandChildClass-hello')
        assert_equal(obj3:index('baz')(), 'bar')
      end)
      
      test('index should be used for lookup', function()
        assert_equal(obj3.hello, 'MyGrandChildClass-hello')
        assert_equal(obj3:baz(), 'bar')
        assert_nil(obj3.blah)
      end)
      
    end) -- subclassing more
    
  end) -- subclassing

end) -- Indexable
