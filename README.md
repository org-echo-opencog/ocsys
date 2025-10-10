# OpenCog Lua System Package (ocsys)

A Lua system utilities package extended for OpenCog cognitive architecture needs.

Note: some functions only work on UNIX systems.

## Dependencies
- Lua 5.4 (or compatible version)
- Standard UNIX utilities (for some functions)

## Install
```bash
# Build the native library
gcc -shared -fPIC -I/usr/include/lua5.4 sys.c -o libsys.so -llua5.4

# Use in your project
require 'sys'
```

## Use

```lua
> require 'sys'
```

### Time / Clock

```lua
> t = sys.clock()  -- high precision clock (us precision)
> sys.tic()
> -- do something
> t = sys.toc()    -- high precision tic/toc
> sys.sleep(1.5)   -- sleep 1.5 seconds
```

### Paths

```lua
> path,fname = sys.fpath()
```

Always returns the path of the file in which this call is made. Useful
to access local resources (non-lua files).

### Execute

By default, Lua's `os.execute` doesn't pipe its results (stdout). This
function uses popen to pipe its results into a Lua string:

```lua
> res = sys.execute('ls -l')
> print(res)
```

Derived from this, a few commands:

```lua
> print(sys.uname())
linux
```

UNIX-only: shortcuts to run bash commands:

```lua
> ls()
> ll()
> lla()
```

### OpenCog System Functions

#### Memory Management
```lua
-- Monitor memory usage for AtomSpace operations
> memory_info = sys.monitor_memory()
> print("RSS:", memory_info.process_rss_mb, "MB")
> print("System pressure:", memory_info.memory_pressure, "%")

-- AtomSpace-aware garbage collection
> gc_stats = sys.atomspace_gc()
> print("Freed:", gc_stats.rss_freed_kb, "KB")
```

#### Process Monitoring
```lua
-- Get comprehensive process statistics
> stats = sys.cognitive_stats()
> print("CPU time:", stats.cpu_time_total, "s")
> print("Memory:", stats.memory_mb, "MB")

-- Adjust process priority based on system load
> result = sys.adjust_cognitive_priority(80)  -- 80% memory pressure threshold
> print("Priority adjustment:", result)
```

#### Performance Benchmarking
```lua
-- Benchmark OpenCog operations
> result = sys.benchmark_operation("my_operation", function(n)
    -- Your cognitive processing code here
    return compute_something(n)
  end, 1000)
> print("Duration:", result.duration, "s")
> print("Memory delta:", result.memory_delta_mb, "MB")
```

#### Distributed Processing
```lua
-- Network and node identification
> network = sys.get_network_info()
> print("Hostname:", network.hostname)
> node_id = sys.create_node_id()
> print("Unique node ID:", node_id)

-- Atomic file operations for AtomSpace synchronization
> success = sys.atomic_write_file("/path/to/atomspace.dat", data)
```

#### Configuration Management
```lua
-- OpenCog parameter management
> sys.set_opencog_param("max_atoms", 1000000)
> sys.set_opencog_param("learning_rate", 0.01)
> max_atoms = sys.get_opencog_param("max_atoms", 100000)
```

#### Resource Monitoring
```lua
-- Check system resource limits
> limits = sys.check_resource_limits()
> print("Memory OK:", limits.memory_ok)
> print("Overall OK:", limits.overall_ok)
```

#### Logging
```lua
-- Cognitive event logging with context
> sys.log_cognitive_event("INFO", "ATOMSPACE", "Created new atom", {type="ConceptNode"})
-- Output: [timestamp] INFO [PID:1234] [ATOMSPACE] Created new atom [MEM:45MB] [CPU:1.23s]
```

### sys.COLORS

If you'd like print in colours, follow the following snippets of code. Let start by listing the available colours

```lua
$ torch
> for k in pairs(sys.COLORS) do print(k) end
```

Then, we can generate a shortcut `c = sys.COLORS` and use it within a `print`

```lua
> c = sys.COLORS
> print(c.magenta .. 'This ' .. c.red .. 'is ' .. c.yellow .. 'a ' .. c.green .. 'rainbow' .. c.cyan .. '!')
```
