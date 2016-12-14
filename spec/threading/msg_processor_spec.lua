local MsgProcessor = require 'lqc.threading.msg_processor'


local MockMsgBox = {}
local MockMsgBox_mt = { __index = MockMsgBox }


function MockMsgBox.new(...)
  local msg_box = { values = ... }
  return setmetatable(msg_box, MockMsgBox_mt)
end


function MockMsgBox:receive(_, tag)
  assert.equals(MsgProcessor.TASK_TAG, tag)
  local value = table.remove(self.values, 1)
  return nil, value
end


function MockMsgBox:send(_, tag, value)
  assert.equals(MsgProcessor.RESULT_TAG, tag)
  table.insert(self.values, value)
end


local function dummy_func() end


describe('MsgProcessor object', function()
  it('can handle incoming messages', function()
    dummy_func = spy.new(dummy_func)
    local msg_box1 = MockMsgBox.new { MsgProcessor.STOP_VALUE }
    local msg_box2 = MockMsgBox.new { dummy_func, MsgProcessor.STOP_VALUE }
    local msg_box3 = MockMsgBox.new { dummy_func, dummy_func, MsgProcessor.STOP_VALUE }
    MsgProcessor.new(msg_box1)()  -- checks also if function terminates
    assert.same({}, msg_box1.values)
    MsgProcessor.new(msg_box2)()
    assert.spy(dummy_func).was.called(1)
    assert.same({ MsgProcessor.VOID_RESULT }, msg_box2.values)

    MsgProcessor.new(msg_box3)()
    assert.spy(dummy_func).was.called(3)
    assert.same({ MsgProcessor.VOID_RESULT, MsgProcessor.VOID_RESULT }, msg_box3.values)
  end)

  it('discards malformed messages', function()
    dummy_func = spy.new(dummy_func)
    local msg_box = MockMsgBox.new { 'not callable', dummy_func, MsgProcessor.STOP_VALUE }
    MsgProcessor.new(msg_box)()
    assert.spy(dummy_func).was.not_called()
  end)
end)

