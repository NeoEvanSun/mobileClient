-------------------------------------------------------------------------------
-- Sends the logging information through a socket using luasocket
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local logging = require "script/libs/logging"
local socket = require "socket"

function logging.socket(address, port, logPattern)
	return logging.new( function(self, level, message)
		local s = logging.prepareLogMsg(logPattern, os.date("*t"), level, message)

		local socket, err = socket.connect(address, port)
		if not socket then
			return nil, err
		end

		local cond, err = socket:send(s)
		if not cond then
			return nil, err
		end
		socket:close()

		return true
	end)
end

return logging.socket

