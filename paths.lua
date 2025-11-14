-- Minimal paths module for OpenCog system functions
-- This replaces the Torch paths dependency with basic functionality

local paths = {}

function paths.basename(path)
   if not path then return nil end
   return path:match("([^/\\]+)$") or path
end

function paths.dirname(path)
   if not path then return nil end
   local dir = path:match("^(.*)[/\\][^/\\]*$")
   return dir or "."
end

function paths.concat(...)
   local args = {...}
   if #args == 0 then return "" end
   
   local result = args[1] or ""
   for i = 2, #args do
      if args[i] then
         -- Ensure proper path separator
         if not result:match("[/\\]$") and not args[i]:match("^[/\\]") then
            result = result .. "/"
         end
         result = result .. args[i]
      end
   end
   return result
end

function paths.cwd()
   -- Use pwd command to get current working directory
   local handle = io.popen("pwd")
   if handle then
      local cwd = handle:read("*l")
      handle:close()
      return cwd or "."
   end
   return "."
end

function paths.dirp(path)
   if not path then return false end
   
   local f = io.open(path, "r")
   if f then
      f:close()
      return false  -- It's a file, not a directory
   end
   
   -- Try to open as directory (this is a simple heuristic)
   local handle = io.popen("test -d '" .. path .. "' 2>/dev/null && echo 'true' || echo 'false'")
   if handle then
      local result = handle:read("*l")
      handle:close()
      return result == "true"
   end
   
   return false
end

return paths