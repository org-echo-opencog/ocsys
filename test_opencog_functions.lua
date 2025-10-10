#!/usr/bin/env lua5.4

-- Test script for OpenCog system functions

-- Add current directory to package path
package.cpath = package.cpath .. ";./?.so"
package.path = package.path .. ";./?.lua"

-- Load the sys module
local sys = require('init')

print("=== OpenCog System Functions Test ===")
print()

-- Test basic functionality
print("1. Basic system info:")
print("   OS:", sys.OS)
print("   PID:", sys.get_pid())
print()

-- Test memory monitoring
print("2. Memory monitoring:")
local memory = sys.monitor_memory()
if memory then
   print("   Process RSS:", memory.process_rss_mb, "MB")
   print("   System free:", memory.system_free_mb, "MB")
   print("   Memory pressure:", string.format("%.1f%%", memory.memory_pressure))
else
   print("   Memory monitoring not available")
end
print()

-- Test process info
print("3. Process information:")
local process = sys.process_info()
if process then
   print("   User time:", string.format("%.3fs", process.user_time))
   print("   System time:", string.format("%.3fs", process.system_time))
   print("   Max RSS:", process.max_rss_kb, "KB")
else
   print("   Process info not available")
end
print()

-- Test cognitive stats
print("4. Cognitive statistics:")
local stats = sys.cognitive_stats()
if stats then
   print("   Total CPU time:", string.format("%.3fs", stats.cpu_time_total))
   print("   CPU efficiency:", string.format("%.2f", stats.cpu_efficiency))
   print("   Memory usage:", stats.memory_mb, "MB")
   print("   System memory pressure:", string.format("%.1f%%", stats.system_memory_pressure))
else
   print("   Cognitive stats not available")
end
print()

-- Test configuration
print("5. Configuration management:")
sys.set_opencog_param("test_param", "hello_world")
sys.set_opencog_param("max_atoms", 1000000)
print("   test_param:", sys.get_opencog_param("test_param", "default"))
print("   max_atoms:", sys.get_opencog_param("max_atoms", 0))
print("   unknown_param:", sys.get_opencog_param("unknown_param", "default_value"))
print()

-- Test AtomSpace GC
print("6. AtomSpace garbage collection:")
local gc_result = sys.atomspace_gc()
if gc_result then
   print("   RSS freed:", gc_result.rss_freed_kb, "KB")
   print("   Lua memory:", gc_result.lua_memory_kb, "KB")
   print("   Page faults during GC:", gc_result.page_faults_during_gc)
else
   print("   GC stats not available")
end
print()

-- Test network info
print("7. Network information:")
local network = sys.get_network_info()
print("   Hostname:", network.hostname)
print("   IP:", network.ip)
print("   Node ID:", sys.create_node_id())
print()

-- Test benchmarking
print("8. Operation benchmarking:")
local function test_operation(n)
   local sum = 0
   for i = 1, n do
      sum = sum + math.sqrt(i)
   end
   return sum
end

local benchmark = sys.benchmark_operation("sqrt_loop", test_operation, 10000)
print("   Operation:", benchmark.operation)
print("   Duration:", string.format("%.4fs", benchmark.duration))
if benchmark.memory_delta_mb then
   print("   Memory delta:", benchmark.memory_delta_mb, "MB")
end
if benchmark.cpu_time_delta then
   print("   CPU time delta:", string.format("%.4fs", benchmark.cpu_time_delta))
end
print()

-- Test resource limits
print("9. Resource limits check:")
local limits = sys.check_resource_limits()
print("   Memory OK:", limits.memory_ok)
print("   CPU OK:", limits.cpu_ok)
print("   Overall OK:", limits.overall_ok)
if limits.memory_pressure then
   print("   Memory pressure:", string.format("%.1f%%", limits.memory_pressure))
end
if limits.context_switch_rate then
   print("   Context switch rate:", string.format("%.1f/s", limits.context_switch_rate))
end
print()

-- Test atomic file operations
print("10. Atomic file operations:")
local test_content = "OpenCog test data: " .. os.date() .. "\n"
local success, err = sys.atomic_write_file("/tmp/opencog_test.txt", test_content)
print("   Atomic write success:", success)
if not success then
   print("   Error:", err)
else
   -- Verify the file was written
   local file = io.open("/tmp/opencog_test.txt", "r")
   if file then
      local content = file:read("*all")
      file:close()
      print("   File content verified:", content:gsub("\n", ""))
      os.remove("/tmp/opencog_test.txt")
   end
end
print()

print("=== All OpenCog system functions tested ===")