----------------------------------------------------------------------
-- sys - a package that provides simple system (unix) tools
----------------------------------------------------------------------

local os = require 'os'
local io = require 'io'
local paths = require 'paths'

sys = {}

--------------------------------------------------------------------------------
-- load all functions from lib
--------------------------------------------------------------------------------
local _lib = require 'libsys'
for k,v in pairs(_lib) do
   sys[k] = v
end

--------------------------------------------------------------------------------
-- tic/toc (matlab-like) timers
--------------------------------------------------------------------------------
local __t__
function sys.tic()
   __t__ = sys.clock()
end
function sys.toc(verbose)
   local __dt__ = sys.clock() - __t__
   if verbose then print(__dt__) end
   return __dt__
end

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
--------------------------------------------------------------------------------
local function execute(cmd)
   local cmd = cmd .. ' 2>&1'
   local f = io.popen(cmd)
   local s = f:read('*all')
   f:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   return s
end
sys.execute = execute

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
-- side effect: file in /tmp
-- this call is typically more robust than the one above (on some systems)
--------------------------------------------------------------------------------
function sys.fexecute(cmd, readwhat)
   readwhat = readwhat or '*all'
   local tmpfile = os.tmpname()
   local cmd = cmd .. ' >'.. tmpfile..' 2>&1'
   os.execute(cmd)
   local file = _G.assert(io.open(tmpfile))
   local s= file:read(readwhat)
   file:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   os.remove(tmpfile)
   return s
end

--------------------------------------------------------------------------------
-- returns the name of the OS in use
-- warning, this method is extremely dumb, and should be replaced by something
-- more reliable
--------------------------------------------------------------------------------
function sys.uname()
   if paths.dirp('C:\\') then
      return 'windows'
   else
      -- Use uname command to detect OS
      local uname_result = sys.execute('uname -s 2>/dev/null')
      if uname_result:find('Linux') then
         return 'linux'
      elseif uname_result:find('Darwin') then
         return 'macos'
      elseif uname_result:find('MINGW') or uname_result:find('CYGWIN') then
         return 'windows'
      else
         return '?'
      end
   end
end
sys.OS = sys.uname()

--------------------------------------------------------------------------------
-- ls (list dir)
--------------------------------------------------------------------------------
sys.ls  = function(d) d = d or ' ' return execute('ls '    ..d) end
sys.ll  = function(d) d = d or ' ' return execute('ls -l ' ..d) end
sys.la  = function(d) d = d or ' ' return execute('ls -a ' ..d) end
sys.lla = function(d) d = d or ' ' return execute('ls -la '..d) end

--------------------------------------------------------------------------------
-- prefix
--------------------------------------------------------------------------------
local function find_prefix()
   if arg then
      for i, v in pairs(arg) do
	 if type(i) == "number" and type(v) == "string" and i <= 0 then
	    local lua_path = paths.basename(v)
	    if lua_path == "luajit" or lua_path == "lua" then
	       local bin_dir = paths.dirname(v)
	       if paths.basename(bin_dir) == "bin" then
		  return paths.dirname(bin_dir)
	       else
		  return bin_dir
	       end
	    end
	 end
      end
   end
   return ""
end
sys.prefix = find_prefix()

--------------------------------------------------------------------------------
-- always returns the path of the file running
--------------------------------------------------------------------------------
sys.fpath = require 'fpath'

--------------------------------------------------------------------------------
-- split string based on pattern pat
--------------------------------------------------------------------------------
function sys.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, last_end)
   while s do
      if s ~= 1 or cap ~= "" then
         _G.table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      _G.table.insert(t, cap)
   end
   return t
end

--------------------------------------------------------------------------------
-- check if a number is NaN
--------------------------------------------------------------------------------
function sys.isNaN(number)
   -- We rely on the property that NaN is the only value that doesn't equal itself.
   return (number ~= number)
end

--------------------------------------------------------------------------------
-- sleep
--------------------------------------------------------------------------------
function sys.sleep(seconds)
   sys.usleep(seconds*1000000)
end

--------------------------------------------------------------------------------
-- OpenCog-specific system functions
--------------------------------------------------------------------------------

-- Memory monitoring for AtomSpace operations
function sys.monitor_memory()
   local usage = sys.memory_usage()
   local system = sys.system_memory()
   if usage and system then
      return {
         process_rss_kb = usage.rss_kb,
         process_rss_mb = usage.rss_kb / 1024,
         system_free_mb = system.free_ram / (1024 * 1024),
         system_used_mb = system.used_ram / (1024 * 1024),
         memory_pressure = (system.used_ram / system.total_ram) * 100
      }
   end
   return nil
end

-- Cognitive load balancer - adjust process priority based on system load
function sys.adjust_cognitive_priority(target_memory_pressure)
   target_memory_pressure = target_memory_pressure or 80 -- default 80%
   local memory_info = sys.monitor_memory()
   if memory_info then
      if memory_info.memory_pressure > target_memory_pressure then
         -- System under pressure, lower priority
         sys.set_priority(10)
         return "lowered"
      elseif memory_info.memory_pressure < target_memory_pressure - 20 then
         -- System has capacity, normal priority
         sys.set_priority(0)
         return "normal"
      end
   end
   return "unchanged"
end

-- AtomSpace garbage collection with memory reporting
function sys.atomspace_gc()
   local before = sys.memory_usage()
   local lua_kb_before = sys.gc_collect()
   local after = sys.memory_usage()
   
   if before and after then
      return {
         rss_freed_kb = before.rss_kb - after.rss_kb,
         lua_memory_kb = lua_kb_before,
         page_faults_during_gc = after.major_page_faults - before.major_page_faults
      }
   end
   return nil
end

-- Cognitive process monitoring
function sys.cognitive_stats()
   local process = sys.process_info()
   local memory = sys.monitor_memory()
   
   if process and memory then
      return {
         cpu_time_total = process.user_time + process.system_time,
         cpu_efficiency = process.user_time / (process.user_time + process.system_time),
         context_switches_total = process.voluntary_context_switches + process.involuntary_context_switches,
         memory_mb = memory.process_rss_mb,
         system_memory_pressure = memory.memory_pressure,
         pid = sys.get_pid()
      }
   end
   return nil
end

-- OpenCog logging utilities
function sys.log_cognitive_event(level, component, message, data)
   level = level or "INFO"
   component = component or "SYSTEM"
   local timestamp = os.date("%Y-%m-%d %H:%M:%S")
   local pid = sys.get_pid()
   
   local log_entry = string.format("[%s] %s [PID:%s] [%s] %s", 
                                  timestamp, level, tostring(pid), component, message)
   
   if data then
      if type(data) == "table" then
         local stats = sys.cognitive_stats()
         if stats then
            log_entry = log_entry .. string.format(" [MEM:%.1fMB] [CPU:%.2fs]", 
                                                  stats.memory_mb, stats.cpu_time_total)
         end
      else
         log_entry = log_entry .. " " .. tostring(data)
      end
   end
   
   print(log_entry)
   return log_entry
end

-- Configuration management for OpenCog parameters
sys.opencog_config = sys.opencog_config or {}

function sys.set_opencog_param(key, value)
   sys.opencog_config[key] = value
   sys.log_cognitive_event("CONFIG", "PARAM", "Set " .. key .. " = " .. tostring(value))
end

function sys.get_opencog_param(key, default)
   local value = sys.opencog_config[key]
   if value == nil then
      return default
   end
   return value
end

-- Performance monitoring for AtomSpace operations
function sys.benchmark_operation(name, func, ...)
   if type(func) ~= "function" then
      error("sys.benchmark_operation expects a function as second argument")
   end
   
   local start_time = sys.clock()
   local start_stats = sys.cognitive_stats()
   
   local results = {func(...)}
   
   local end_time = sys.clock()
   local end_stats = sys.cognitive_stats()
   
   local benchmark = {
      operation = name,
      duration = end_time - start_time,
      results = results
   }
   
   if start_stats and end_stats then
      benchmark.memory_delta_mb = end_stats.memory_mb - start_stats.memory_mb
      benchmark.cpu_time_delta = end_stats.cpu_time_total - start_stats.cpu_time_total
   end
   
   sys.log_cognitive_event("PERF", "BENCHMARK", 
                          string.format("%s completed in %.4fs", name, benchmark.duration),
                          benchmark)
   
   return benchmark
end

-- Network utilities for distributed OpenCog processing
function sys.get_network_info()
   local hostname = sys.execute("hostname"):gsub('%s+', '')
   local ip = sys.execute("hostname -I 2>/dev/null || echo 'unknown'"):gsub('%s+', '')
   
   return {
      hostname = hostname,
      ip = ip,
      pid = sys.get_pid()
   }
end

-- Distributed processing helpers
function sys.create_node_id()
   local network = sys.get_network_info()
   local timestamp = math.floor(sys.clock() * 1000000) -- microsecond precision
   return string.format("%s:%d:%d", network.hostname, network.pid, timestamp)
end

-- AtomSpace synchronization utilities
function sys.atomic_write_file(filename, content)
   local temp_file = filename .. ".tmp." .. sys.get_pid()
   
   local file, err = io.open(temp_file, "w")
   if not file then
      return false, "Cannot create temporary file: " .. (err or "unknown error")
   end
   
   local success, write_err = pcall(function()
      file:write(content)
      file:close()
   end)
   
   if not success then
      os.remove(temp_file)
      return false, "Write failed: " .. (write_err or "unknown error")
   end
   
   -- Atomic rename
   local rename_success = os.rename(temp_file, filename)
   if not rename_success then
      os.remove(temp_file)
      return false, "Atomic rename failed"
   end
   
   return true
end

-- System resource limits for cognitive processing
function sys.check_resource_limits()
   local memory = sys.monitor_memory()
   local stats = sys.cognitive_stats()
   
   local limits = {
      memory_ok = true,
      cpu_ok = true,
      overall_ok = true
   }
   
   if memory then
      -- Check if system memory pressure is too high
      limits.memory_ok = memory.memory_pressure < 90
      limits.memory_pressure = memory.memory_pressure
   end
   
   if stats then
      -- Check for excessive context switching (might indicate thrashing)
      limits.context_switch_rate = stats.context_switches_total / stats.cpu_time_total
      limits.cpu_ok = limits.context_switch_rate < 1000 -- arbitrary threshold
   end
   
   limits.overall_ok = limits.memory_ok and limits.cpu_ok
   
   return limits
end

--------------------------------------------------------------------------------
-- colors, can be used to print things in color
--------------------------------------------------------------------------------
sys.COLORS = require 'colors'

--------------------------------------------------------------------------------
-- backward compat
--------------------------------------------------------------------------------
sys.dirname = paths.dirname
sys.concat = paths.concat

return sys
