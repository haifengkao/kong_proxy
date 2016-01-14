local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.kong-proxy.access"

local KongProxyHandler = BasePlugin:extend()

function KongProxyHandler:new()
  KongProxyHandler.super.new(self, "kong-proxy")
end

function KongProxyHandler:access(conf)
  KongProxyHandler.super.access(self)
  access.execute(conf)
end

--should executed as last as possible
--we don't want it to interfere with existing plugins
KongProxyHandler.PRIORITY = 5

return KongProxyHandler
