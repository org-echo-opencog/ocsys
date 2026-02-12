#!/usr/bin/env lua5.4

--[[
  Example script demonstrating OpenCog system functions
  
  This script shows basic usage of the ocsys package for
  monitoring and managing cognitive processes.
--]]

-- Add current directory to package path
package.cpath = package.cpath .. ";./?.so"
package.path = package.path .. ";./?.lua"

-- Load the sys module
local sys = require('init')

print("=== OpenCog System Functions Example ===\n")

-- 1. Basic System Information
print("1. System Information:")
print(string.format("   Running on: %s", sys.OS))
print(string.format("   Process ID: %d\n", sys.get_pid()))

-- 2. Memory Monitoring
print("2. Memory Monitoring:")
local mem = sys.monitor_memory()
if mem then
    print(string.format("   Process Memory: %.2f MB", mem.process_rss_mb))
    print(string.format("   System Free: %.2f MB", mem.system_free_mb))
    print(string.format("   Memory Pressure: %.1f%%\n", mem.memory_pressure))
end

-- 3. Configuration Management
print("3. Configuration Management:")
sys.set_opencog_param("learning_rate", 0.01)
sys.set_opencog_param("max_atoms", 1000000)
print(string.format("   learning_rate = %s", sys.get_opencog_param("learning_rate", "not set")))
print(string.format("   max_atoms = %s\n", sys.get_opencog_param("max_atoms", "not set")))

-- 4. Benchmarking Operations
print("4. Benchmarking Operations:")
local function fibonacci(n)
    if n <= 1 then return n end
    return fibonacci(n-1) + fibonacci(n-2)
end

local result = sys.benchmark_operation("fibonacci", fibonacci, 20)
print(string.format("   Operation: %s", result.operation))
print(string.format("   Duration: %.4f seconds", result.duration))
print(string.format("   Result: %s\n", result.results[1]))

-- 5. Cognitive Statistics
print("5. Cognitive Statistics:")
local stats = sys.cognitive_stats()
if stats then
    print(string.format("   Total CPU Time: %.3f seconds", stats.cpu_time_total))
    print(string.format("   CPU Efficiency: %.2f", stats.cpu_efficiency))
    print(string.format("   Memory Usage: %.2f MB", stats.memory_mb))
    print(string.format("   Context Switches: %d\n", stats.context_switches_total))
end

-- 6. Network Information for Distributed Processing
print("6. Network Information:")
local network = sys.get_network_info()
print(string.format("   Hostname: %s", network.hostname))
print(string.format("   IP: %s", network.ip))
print(string.format("   Unique Node ID: %s\n", sys.create_node_id()))

-- 7. Resource Limits Check
print("7. Resource Limits:")
local limits = sys.check_resource_limits()
print(string.format("   Memory OK: %s", limits.memory_ok and "✓" or "✗"))
print(string.format("   CPU OK: %s", limits.cpu_ok and "✓" or "✗"))
print(string.format("   Overall OK: %s\n", limits.overall_ok and "✓" or "✗"))

-- 8. Custom Logging
print("8. Cognitive Event Logging:")
sys.log_cognitive_event("INFO", "EXAMPLE", "Demonstration completed successfully")

print("\n=== Example Complete ===")
