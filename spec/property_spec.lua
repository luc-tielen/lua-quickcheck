p = require "src.property"


describe("property helper function", function()
  it("should add function to array of other properties", function()
    local descr1 = "test property"
    local descr2 = descr1 .. " 2"
    p.property(descr1, function() 
      return 9001
    end)
    assert.is.equal(1, #p.all)

    p.property(descr2, function() 
      return 1337
    end)
    assert.is.equal(2, #p.all)
    assert.same(p.all[1](), 9001)
    assert.same(p.all[2](), 1337)
  end)
end)

