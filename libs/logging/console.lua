-------------------------------------------------------------------------------
-- Prints logging information to console
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local logging = require "script/libs/logging"

function logging.console(logPattern)
	return logging.new( function(self, level, message)
		local msg = logging.prepareLogMsg(logPattern, os.date("*t"), level, message)
		io.stdout:write(msg)
		if (level == "fatal") then
			CCMessageBox(msg, "FATAL")
		end
		return true
	end)
end

return logging.console
