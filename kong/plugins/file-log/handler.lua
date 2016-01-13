-- Copyright (C) Mashape, Inc.
local ffi = require "ffi"
local cjson = require "cjson"
local system_constants = require "lua_system_constants"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local BasePlugin = require "kong.plugins.base_plugin"

local FileLogHandler = BasePlugin:extend()

FileLogHandler.PRIORITY = 1

ffi.cdef[[
int open(char * filename, int flags, int mode);
int write(int fd, void * ptr, int numbytes);

char *strerror(int errnum);
]]

local function string_to_char(str)
  return ffi.cast("uint8_t*", str)
end

-- fd tracking utility functions
local fd = {}

local function get_fd(conf_path)
  return fd[conf_path]
end

local function set_fd(conf_path, file_descriptor)
  fd[conf_path] = file_descriptor
end

-- Log to a file. Function used as callback from an nginx timer.
-- @param `premature` see OpenResty `ngx.timer.at()`
-- @param `conf`     Configuration table, holds http endpoint details
-- @param `message`  Message to be logged
local function log(premature, conf, message)
  message = cjson.encode(message).."\n"

  local fd = get_fd(conf.path)
  if not fd then
    fd = ffi.C.open(string_to_char(conf.path), 
                    bit.bor(system_constants.O_WRONLY(), system_constants.O_CREAT(), system_constants.O_APPEND()), 
                    bit.bor(system_constants.S_IWUSR(), system_constants.S_IRUSR(), system_constants.S_IXUSR()))
    if fd < 0 then
      local errno = ffi.errno()
      ngx.log(ngx.ERR, "[file-log] failed to open the file: ", ffi.string(ffi.C.strerror(errno)))
    else
      set_fd(conf.path, fd)
    end
  end

  ffi.C.write(fd, string_to_char(message), string.len(message))
end

function FileLogHandler:new()
  FileLogHandler.super.new(self, "file-log")
end

function FileLogHandler:log(conf)
  FileLogHandler.super.log(self)
  local message = basic_serializer.serialize(ngx)

  local ok, err = ngx.timer.at(0, log, conf, message)
  if not ok then
    ngx.log(ngx.ERR, "[file-log] failed to create timer: ", err)
  end

end

return FileLogHandler
