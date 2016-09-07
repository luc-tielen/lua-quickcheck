local MsgProcessor = require 'lqc.threading.msg_processor'
local map = require 'lqc.helpers.map'
local lanes = require('lanes').configure { with_timers = false }



-- Checks if x is a positive integer (excluding 0)
-- Returns true if x is a positive integer; otherwise false.
local function is_positive_integer(x)
  return type(x) == 'number' and x % 1 == 0 and x > 0
end


-- Checks if the thread pool args are valid.
-- Raises an error if invalid args are passed in.
local function check_threadpool_args(num_threads)
  if not is_positive_integer(num_threads) then 
    error 'num_threads should be an integer > 0' 
  end
end


-- Creates and starts a thread.
local function make_thread(func)
  return lanes.gen('*', func)()
end


local ThreadPool = {}
local ThreadPool_mt = { __index = ThreadPool }


-- Creates a new thread pool with a specific number of threads
function ThreadPool.new(num_threads)
  check_threadpool_args(num_threads)
  local linda = lanes.linda()
  local thread_pool = { 
    threads = {}, 
    linda = linda,
    numjobs = 0
  }
  for _ = 1, num_threads do
    table.insert(thread_pool.threads, make_thread(MsgProcessor.new(linda)))
  end
  return setmetatable(thread_pool, ThreadPool_mt)
end


-- Schedules a task to a thread in the thread pool
function ThreadPool:schedule(task)
  self.numjobs = self.numjobs + 1
  self.linda:send(nil, MsgProcessor.TASK_TAG, task)
end


-- Stops all threads in the threadpool. Blocks until all threads are finished
-- Returns a table containing all results (in no specific order)
function ThreadPool:join()
  map(self.threads, function() self:schedule(MsgProcessor.STOP_VALUE) end)
  map(self.threads, function(thread) thread:join() end)

  local results = {}
  for _ = 1, self.numjobs - #self.threads do  -- don't count stop job at end
    local _, result = self.linda:receive(nil, MsgProcessor.RESULT_TAG)
    if result ~= MsgProcessor.VOID_RESULT then table.insert(results, result) end
  end
  return results
end


return ThreadPool

