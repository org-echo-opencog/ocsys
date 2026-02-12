#!/usr/bin/env lua5.4

-- Test script for OpenCog system functions

-- Add current directory to package path
package.cpath = package.cpath .. ";./?.so"
package.path = package.path .. ";./?.lua"

-- Test counter
local tests_passed = 0
local tests_failed = 0

-- Helper function to run tests with error handling
local function test_section(name, func)
    io.write(name)
    local success, err = pcall(func)
    if success then
        print(" ✓")
        tests_passed = tests_passed + 1
    else
        print(" ✗")
        print("   Error:", err)
        tests_failed = tests_failed + 1
    end
    print()
end

-- Load the sys module
local sys
test_section("0. Loading sys module:", function()
    sys = require('init')
    assert(sys, "Failed to load sys module")
end)

if not sys then
    print("Cannot continue without sys module")
    os.exit(1)
end

print("=== OpenCog System Functions Test ===")
print()

-- Test basic functionality
test_section("1. Basic system info:", function()
    assert(sys.OS, "OS not detected")
    assert(sys.get_pid, "get_pid function not available")
    local pid = sys.get_pid()
    assert(pid and pid > 0, "Invalid PID")
    print("   OS:", sys.OS)
    print("   PID:", pid)
end)

-- Test memory monitoring
test_section("2. Memory monitoring:", function()
    assert(sys.monitor_memory, "monitor_memory function not available")
    local memory = sys.monitor_memory()
    if memory then
        assert(memory.process_rss_mb >= 0, "Invalid RSS value")
        assert(memory.system_free_mb >= 0, "Invalid free memory value")
        assert(memory.memory_pressure >= 0 and memory.memory_pressure <= 100, "Invalid memory pressure")
        print("   Process RSS:", string.format("%.2f MB", memory.process_rss_mb))
        print("   System free:", string.format("%.2f MB", memory.system_free_mb))
        print("   Memory pressure:", string.format("%.1f%%", memory.memory_pressure))
    else
        print("   Memory monitoring not available")
    end
end)

-- Test process info
test_section("3. Process information:", function()
    assert(sys.process_info, "process_info function not available")
    local process = sys.process_info()
    if process then
        assert(process.user_time >= 0, "Invalid user time")
        assert(process.system_time >= 0, "Invalid system time")
        assert(process.max_rss_kb >= 0, "Invalid max RSS")
        print("   User time:", string.format("%.3fs", process.user_time))
        print("   System time:", string.format("%.3fs", process.system_time))
        print("   Max RSS:", process.max_rss_kb, "KB")
    else
        print("   Process info not available")
    end
end)

-- Test cognitive stats
test_section("4. Cognitive statistics:", function()
    assert(sys.cognitive_stats, "cognitive_stats function not available")
    local stats = sys.cognitive_stats()
    if stats then
        assert(stats.cpu_time_total >= 0, "Invalid CPU time")
        assert(stats.cpu_efficiency >= 0 and stats.cpu_efficiency <= 1, "Invalid CPU efficiency")
        assert(stats.memory_mb >= 0, "Invalid memory usage")
        print("   Total CPU time:", string.format("%.3fs", stats.cpu_time_total))
        print("   CPU efficiency:", string.format("%.2f", stats.cpu_efficiency))
        print("   Memory usage:", string.format("%.2f MB", stats.memory_mb))
        print("   System memory pressure:", string.format("%.1f%%", stats.system_memory_pressure))
    else
        print("   Cognitive stats not available")
    end
end)

-- Test configuration
test_section("5. Configuration management:", function()
    assert(sys.set_opencog_param, "set_opencog_param function not available")
    assert(sys.get_opencog_param, "get_opencog_param function not available")
    
    sys.set_opencog_param("test_param", "hello_world")
    sys.set_opencog_param("max_atoms", 1000000)
    
    local test_param = sys.get_opencog_param("test_param", "default")
    local max_atoms = sys.get_opencog_param("max_atoms", 0)
    local unknown_param = sys.get_opencog_param("unknown_param", "default_value")
    
    assert(test_param == "hello_world", "test_param value mismatch")
    assert(max_atoms == 1000000, "max_atoms value mismatch")
    assert(unknown_param == "default_value", "unknown_param should return default")
    
    print("   test_param:", test_param)
    print("   max_atoms:", max_atoms)
    print("   unknown_param:", unknown_param)
end)

-- Test AtomSpace GC
test_section("6. AtomSpace garbage collection:", function()
    assert(sys.atomspace_gc, "atomspace_gc function not available")
    local gc_result = sys.atomspace_gc()
    if gc_result then
        assert(type(gc_result.rss_freed_kb) == "number", "Invalid RSS freed value")
        assert(gc_result.lua_memory_kb >= 0, "Invalid Lua memory value")
        print("   RSS freed:", string.format("%.2f KB", gc_result.rss_freed_kb))
        print("   Lua memory:", string.format("%.2f KB", gc_result.lua_memory_kb))
        print("   Page faults during GC:", gc_result.page_faults_during_gc)
    else
        print("   GC stats not available")
    end
end)

-- Test network info
test_section("7. Network information:", function()
    assert(sys.get_network_info, "get_network_info function not available")
    assert(sys.create_node_id, "create_node_id function not available")
    
    local network = sys.get_network_info()
    assert(network.hostname and #network.hostname > 0, "Invalid hostname")
    
    local node_id = sys.create_node_id()
    assert(node_id and #node_id > 0, "Invalid node ID")
    assert(node_id:find(network.hostname), "Node ID should contain hostname")
    
    print("   Hostname:", network.hostname)
    print("   IP:", network.ip)
    print("   Node ID:", node_id)
end)

-- Test benchmarking
test_section("8. Operation benchmarking:", function()
    assert(sys.benchmark_operation, "benchmark_operation function not available")
    
    local function test_operation(n)
        local sum = 0
        for i = 1, n do
            sum = sum + math.sqrt(i)
        end
        return sum
    end
    
    local benchmark = sys.benchmark_operation("sqrt_loop", test_operation, 10000)
    assert(benchmark.operation == "sqrt_loop", "Operation name mismatch")
    assert(benchmark.duration > 0, "Invalid duration")
    assert(benchmark.results and #benchmark.results > 0, "No results returned")
    
    print("   Operation:", benchmark.operation)
    print("   Duration:", string.format("%.4fs", benchmark.duration))
    if benchmark.memory_delta_mb then
        print("   Memory delta:", string.format("%.2f MB", benchmark.memory_delta_mb))
    end
    if benchmark.cpu_time_delta then
        print("   CPU time delta:", string.format("%.4fs", benchmark.cpu_time_delta))
    end
end)

-- Test resource limits
test_section("9. Resource limits check:", function()
    assert(sys.check_resource_limits, "check_resource_limits function not available")
    
    local limits = sys.check_resource_limits()
    assert(type(limits.memory_ok) == "boolean", "memory_ok should be boolean")
    assert(type(limits.cpu_ok) == "boolean", "cpu_ok should be boolean")
    assert(type(limits.overall_ok) == "boolean", "overall_ok should be boolean")
    
    print("   Memory OK:", limits.memory_ok)
    print("   CPU OK:", limits.cpu_ok)
    print("   Overall OK:", limits.overall_ok)
    if limits.memory_pressure then
        print("   Memory pressure:", string.format("%.1f%%", limits.memory_pressure))
    end
    if limits.context_switch_rate then
        print("   Context switch rate:", string.format("%.1f/s", limits.context_switch_rate))
    end
end)

-- Test atomic file operations
test_section("10. Atomic file operations:", function()
    assert(sys.atomic_write_file, "atomic_write_file function not available")
    
    local test_content = "OpenCog test data: " .. os.date() .. "\n"
    local test_file = "/tmp/opencog_test_" .. sys.get_pid() .. ".txt"
    
    local success, err = sys.atomic_write_file(test_file, test_content)
    assert(success, "Atomic write failed: " .. tostring(err))
    
    -- Verify the file was written
    local file = io.open(test_file, "r")
    assert(file, "Could not open test file")
    
    local content = file:read("*all")
    file:close()
    assert(content == test_content, "File content mismatch")
    
    print("   Atomic write success:", success)
    print("   File content verified")
    
    -- Clean up
    os.remove(test_file)
end)

-- Summary
print()
print("=== Test Summary ===")
print(string.format("Tests passed: %d", tests_passed))
print(string.format("Tests failed: %d", tests_failed))
print(string.format("Total tests: %d", tests_passed + tests_failed))

if tests_failed > 0 then
    print("\n❌ Some tests failed!")
    os.exit(1)
else
    print("\n✅ All tests passed!")
    os.exit(0)
end

-- Test cognitive stats
test_section("4. Cognitive statistics:", function()
    assert(sys.cognitive_stats, "cognitive_stats function not available")
    local stats = sys.cognitive_stats()
    if stats then
        assert(stats.cpu_time_total >= 0, "Invalid CPU time")
        assert(stats.cpu_efficiency >= 0 and stats.cpu_efficiency <= 1, "Invalid CPU efficiency")
        assert(stats.memory_mb >= 0, "Invalid memory usage")
        print("   Total CPU time:", string.format("%.3fs", stats.cpu_time_total))
        print("   CPU efficiency:", string.format("%.2f", stats.cpu_efficiency))
        print("   Memory usage:", string.format("%.2f MB", stats.memory_mb))
        print("   System memory pressure:", string.format("%.1f%%", stats.system_memory_pressure))
    else
        print("   Cognitive stats not available")
    end
end)

-- Test configuration
test_section("5. Configuration management:", function()
    assert(sys.set_opencog_param, "set_opencog_param function not available")
    assert(sys.get_opencog_param, "get_opencog_param function not available")
    
    sys.set_opencog_param("test_param", "hello_world")
    sys.set_opencog_param("max_atoms", 1000000)
    
    local test_param = sys.get_opencog_param("test_param", "default")
    local max_atoms = sys.get_opencog_param("max_atoms", 0)
    local unknown_param = sys.get_opencog_param("unknown_param", "default_value")
    
    assert(test_param == "hello_world", "test_param value mismatch")
    assert(max_atoms == 1000000, "max_atoms value mismatch")
    assert(unknown_param == "default_value", "unknown_param should return default")
    
    print("   test_param:", test_param)
    print("   max_atoms:", max_atoms)
    print("   unknown_param:", unknown_param)
end)

-- Test AtomSpace GC
test_section("6. AtomSpace garbage collection:", function()
    assert(sys.atomspace_gc, "atomspace_gc function not available")
    local gc_result = sys.atomspace_gc()
    if gc_result then
        assert(type(gc_result.rss_freed_kb) == "number", "Invalid RSS freed value")
        assert(gc_result.lua_memory_kb >= 0, "Invalid Lua memory value")
        print("   RSS freed:", string.format("%.2f KB", gc_result.rss_freed_kb))
        print("   Lua memory:", string.format("%.2f KB", gc_result.lua_memory_kb))
        print("   Page faults during GC:", gc_result.page_faults_during_gc)
    else
        print("   GC stats not available")
    end
end)

-- Test network info
test_section("7. Network information:", function()
    assert(sys.get_network_info, "get_network_info function not available")
    assert(sys.create_node_id, "create_node_id function not available")
    
    local network = sys.get_network_info()
    assert(network.hostname and #network.hostname > 0, "Invalid hostname")
    
    local node_id = sys.create_node_id()
    assert(node_id and #node_id > 0, "Invalid node ID")
    assert(node_id:find(network.hostname), "Node ID should contain hostname")
    
    print("   Hostname:", network.hostname)
    print("   IP:", network.ip)
    print("   Node ID:", node_id)
end)

-- Test benchmarking
test_section("8. Operation benchmarking:", function()
    assert(sys.benchmark_operation, "benchmark_operation function not available")
    
    local function test_operation(n)
        local sum = 0
        for i = 1, n do
            sum = sum + math.sqrt(i)
        end
        return sum
    end
    
    local benchmark = sys.benchmark_operation("sqrt_loop", test_operation, 10000)
    assert(benchmark.operation == "sqrt_loop", "Operation name mismatch")
    assert(benchmark.duration > 0, "Invalid duration")
    assert(benchmark.results and #benchmark.results > 0, "No results returned")
    
    print("   Operation:", benchmark.operation)
    print("   Duration:", string.format("%.4fs", benchmark.duration))
    if benchmark.memory_delta_mb then
        print("   Memory delta:", string.format("%.2f MB", benchmark.memory_delta_mb))
    end
    if benchmark.cpu_time_delta then
        print("   CPU time delta:", string.format("%.4fs", benchmark.cpu_time_delta))
    end
end)

-- Test resource limits
test_section("9. Resource limits check:", function()
    assert(sys.check_resource_limits, "check_resource_limits function not available")
    
    local limits = sys.check_resource_limits()
    assert(type(limits.memory_ok) == "boolean", "memory_ok should be boolean")
    assert(type(limits.cpu_ok) == "boolean", "cpu_ok should be boolean")
    assert(type(limits.overall_ok) == "boolean", "overall_ok should be boolean")
    
    print("   Memory OK:", limits.memory_ok)
    print("   CPU OK:", limits.cpu_ok)
    print("   Overall OK:", limits.overall_ok)
    if limits.memory_pressure then
        print("   Memory pressure:", string.format("%.1f%%", limits.memory_pressure))
    end
    if limits.context_switch_rate then
        print("   Context switch rate:", string.format("%.1f/s", limits.context_switch_rate))
    end
end)

-- Test atomic file operations
test_section("10. Atomic file operations:", function()
    assert(sys.atomic_write_file, "atomic_write_file function not available")
    
    local test_content = "OpenCog test data: " .. os.date() .. "\n"
    local test_file = "/tmp/opencog_test_" .. sys.get_pid() .. ".txt"
    
    local success, err = sys.atomic_write_file(test_file, test_content)
    assert(success, "Atomic write failed: " .. tostring(err))
    
    -- Verify the file was written
    local file = io.open(test_file, "r")
    assert(file, "Could not open test file")
    
    local content = file:read("*all")
    file:close()
    assert(content == test_content, "File content mismatch")
    
    print("   Atomic write success:", success)
    print("   File content verified")
    
    -- Clean up
    os.remove(test_file)
end)

-- Summary
print()
print("=== Test Summary ===")
print(string.format("Tests passed: %d", tests_passed))
print(string.format("Tests failed: %d", tests_failed))
print(string.format("Total tests: %d", tests_passed + tests_failed))

if tests_failed > 0 then
    print("\n❌ Some tests failed!")
    os.exit(1)
else
    print("\n✅ All tests passed!")
    os.exit(0)
end