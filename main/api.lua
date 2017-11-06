local websocket = require('defnet.websocket.client_async')
local rxijson = require('libs.rxijson')

--local host = 'ws://127.0.0.1:8080/game'
local host = 'ws://37.143.9.232'

local _M = {}

_M.players = {}

function _M.connect()
	local is_html5 = sys.get_sys_info().system_name == 'HTML5'
	local self = _M
	if not self.ws then
		self.ws = websocket(is_html5)
	
		self.ws:on_message(function(message)
			print('on_message', message)
			local player = json.decode(message)
			table.insert(self.players, player)
		end)
		
		self.ws:on_connected(function(ok, err)
			print('on_connected', ok, err)
			if err then
				self.is_connected = false
				self.ws:close()
				self.ws = nil
			else
				self.is_connected = true
			end
		end)
		
		self.ws:connect(host)
	end
end

function _M.send(t)
	local self = _M
	if self.ws and self.is_connected then
		self.ws:send(rxijson.encode(t))
	end
end

function _M.update()
	local self = _M
	if self.ws then
		self.ws.step()
	end
end

function _M.disconnect()
	local self = _M
	if self.ws then
		self.ws:close()
		self.is_connected = false
		self.ws.step()
		self.ws = nil
	end
end

return _M