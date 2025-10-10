#include <lua.h>
#include <lauxlib.h>

#ifdef _WIN32

#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>
#include <stdint.h>

static int l_clock(lua_State *L) {
    static const uint64_t EPOCH = 116444736000000000ULL;
    SYSTEMTIME  systemtime;
    FILETIME filetime;
    uint64_t time;
    GetSystemTime(&systemtime);
    GetSystemTimeAsFileTime(&filetime);
    time = (((uint64_t)filetime.dwHighDateTime) << 32) + ((uint64_t)filetime.dwLowDateTime);
    double precise_time = (time - EPOCH) / 10000000.0;
    lua_pushnumber(L, precise_time);
    return 1;
}

static int l_usleep(lua_State *L) {
  int time = 1;
  if (lua_isnumber(L, 1)) time = lua_tonumber(L, 1);
  Sleep(time / 1000);
  return 1;
}

#else

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <sys/time.h>
#include <unistd.h>
#include <time.h>
#include <sys/resource.h>
#include <sys/sysinfo.h>

static int l_clock(lua_State *L) {
  struct timeval tv;
  struct timezone tz;
  struct tm *tm;
  gettimeofday(&tv, &tz);
  tm=localtime(&tv.tv_sec);
  double precise_time = tv.tv_sec + tv.tv_usec / 1e6;
  lua_pushnumber(L,precise_time);
  return 1;
}

static int l_usleep(lua_State *L) {
  int time = 1;
  if (lua_isnumber(L, 1)) time = lua_tonumber(L, 1);
  usleep(time);
  return 1;
}

static int l_memory_usage(lua_State *L) {
  struct rusage usage;
  if (getrusage(RUSAGE_SELF, &usage) == 0) {
    // Create a table with memory statistics
    lua_newtable(L);
    
    lua_pushstring(L, "rss_kb");
    lua_pushnumber(L, usage.ru_maxrss); // RSS in KB on Linux
    lua_settable(L, -3);
    
    lua_pushstring(L, "major_page_faults");
    lua_pushnumber(L, usage.ru_majflt);
    lua_settable(L, -3);
    
    lua_pushstring(L, "minor_page_faults");
    lua_pushnumber(L, usage.ru_minflt);
    lua_settable(L, -3);
    
    return 1;
  } else {
    lua_pushnil(L);
    return 1;
  }
}

static int l_system_memory(lua_State *L) {
  struct sysinfo si;
  if (sysinfo(&si) == 0) {
    // Create a table with system memory statistics
    lua_newtable(L);
    
    lua_pushstring(L, "total_ram");
    lua_pushnumber(L, si.totalram * si.mem_unit);
    lua_settable(L, -3);
    
    lua_pushstring(L, "free_ram");
    lua_pushnumber(L, si.freeram * si.mem_unit);
    lua_settable(L, -3);
    
    lua_pushstring(L, "used_ram");
    lua_pushnumber(L, (si.totalram - si.freeram) * si.mem_unit);
    lua_settable(L, -3);
    
    lua_pushstring(L, "total_swap");
    lua_pushnumber(L, si.totalswap * si.mem_unit);
    lua_settable(L, -3);
    
    lua_pushstring(L, "free_swap");
    lua_pushnumber(L, si.freeswap * si.mem_unit);
    lua_settable(L, -3);
    
    return 1;
  } else {
    lua_pushnil(L);
    return 1;
  }
}

static int l_gc_collect(lua_State *L) {
  // Force full garbage collection cycle
  lua_gc(L, LUA_GCCOLLECT, 0);
  
  // Return memory usage after collection
  int kb_used = lua_gc(L, LUA_GCCOUNT, 0);
  lua_pushnumber(L, kb_used);
  return 1;
}

static int l_process_info(lua_State *L) {
  struct rusage usage;
  if (getrusage(RUSAGE_SELF, &usage) == 0) {
    // Create a table with process statistics
    lua_newtable(L);
    
    lua_pushstring(L, "user_time");
    lua_pushnumber(L, usage.ru_utime.tv_sec + usage.ru_utime.tv_usec / 1e6);
    lua_settable(L, -3);
    
    lua_pushstring(L, "system_time");
    lua_pushnumber(L, usage.ru_stime.tv_sec + usage.ru_stime.tv_usec / 1e6);
    lua_settable(L, -3);
    
    lua_pushstring(L, "max_rss_kb");
    lua_pushnumber(L, usage.ru_maxrss);
    lua_settable(L, -3);
    
    lua_pushstring(L, "voluntary_context_switches");
    lua_pushnumber(L, usage.ru_nvcsw);
    lua_settable(L, -3);
    
    lua_pushstring(L, "involuntary_context_switches");
    lua_pushnumber(L, usage.ru_nivcsw);
    lua_settable(L, -3);
    
    return 1;
  } else {
    lua_pushnil(L);
    return 1;
  }
}

static int l_get_pid(lua_State *L) {
  lua_pushnumber(L, getpid());
  return 1;
}

static int l_set_priority(lua_State *L) {
  int priority = 0;
  if (lua_isnumber(L, 1)) {
    priority = (int)lua_tonumber(L, 1);
  }
  
  int result = setpriority(PRIO_PROCESS, 0, priority);
  lua_pushboolean(L, result == 0);
  return 1;
}

#endif

static const struct luaL_Reg routines [] = {
  {"clock", l_clock},
  {"usleep", l_usleep},
  {"memory_usage", l_memory_usage},
  {"system_memory", l_system_memory},
  {"gc_collect", l_gc_collect},
  {"process_info", l_process_info},
  {"get_pid", l_get_pid},
  {"set_priority", l_set_priority},
  {NULL, NULL}
};

#if defined(_WIN32)
    #define SYS_DLLEXPORT __declspec(dllexport) __cdecl
#else
    #define SYS_DLLEXPORT 
#endif
int SYS_DLLEXPORT luaopen_libsys(lua_State *L)
{
  lua_newtable(L);
#if LUA_VERSION_NUM == 501
  luaL_register(L, NULL, routines);
#else
  luaL_setfuncs(L, routines, 0);
#endif
  return 1;
}
