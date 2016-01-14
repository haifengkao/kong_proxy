local url = require "socket.url"
local stringy = require "stringy"
local responses = require "kong.tools.responses"


local _M = {}

--package.path = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?/?.lua;/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?.lua;" .. package.path
--package.cpath = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs/?.dylib;/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs/?/?.dylib;" .. package.cpath

local function get_host_from_url(val)
  local parsed_url = url.parse(val)

  local port
  if parsed_url.port then
    port = parsed_url.port
  elseif parsed_url.scheme == "https" then
    port = 443
  end

  return parsed_url.host..(port and ":"..port or "")
end

function _M.execute(conf)
    
    require('mobdebug').start("127.0.0.1")
    local uri = stringy.split(ngx.var.request_uri, "?")[1]
    local hostName = nil
    if conf.HostTag then
        hostName = ngx.req.get_headers()[conf.HostTag]
    end

    if hostName then
        ngx.var.backend_url = hostName..uri
        ngx.var.backend_host = get_host_from_url(ngx.var.backend_url)
        
    else 
        return responses.send_HTTP_NOT_FOUND()
    end
end

return _M
