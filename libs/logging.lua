-------------------------------------------------------------------------------
-- includes a new tostring function that handles tables recursively
--
-- @author Danilo Tuler (tuler@ideais.com.br)
-- @author Andre Carregal (info@keplerproject.org)
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
-------------------------------------------------------------------------------

local type, table, string, _tostring, tonumber = type, table, string, tostring, tonumber
local select = select
local error = error
local format = string.format
local pairs = pairs
local ipairs = ipairs

local logging = {

-- Meta information
_COPYRIGHT = "Copyright (C) 2004-2013 Kepler Project",
_DESCRIPTION = "A simple API to use logging features in Lua",
_VERSION = "LuaLogging 1.3.0",

-- The DEBUG Level designates fine-grained instring.formational events that are most
-- useful to debug an application
DEBUG = "DEBUG",

TRACE = "TRACE",
-- The INFO level designates instring.formational messages that highlight the
-- progress of the application at coarse-grained level
INFO = "INFO",

-- The WARN level designates potentially harmful situations
WARN = "WARN",

-- The ERROR level designates error events that might still allow the
-- application to continue running
ERROR = "ERROR",

-- The FATAL level designates very severe error events that will presumably
-- lead the application to abort
FATAL = "FATAL",
}

local LEVEL = {"DEBUG", "TRACE","INFO", "WARN", "ERROR", "FATAL"}
local MAX_LEVELS = #LEVEL
-- make level names to order
for i=1,MAX_LEVELS do
	LEVEL[LEVEL[i]] = i
end

-- private log function, with support for formating a complex log message.
local function LOG_MSG(self, level, fmt, ...)
	local args = {...}
	
	for i = 1, select('#', ...) do
		local arg = select(i, ...)
		if arg == nil then
			args[i] = math.huge   ----nil 在 %d %s下统一用这个玩意  会打印出一个-9223372036854775808 或者 inf
		elseif type(arg) == 'table' then
			args[i] = logging.tostring(arg)
		else
			args[i] = _tostring(arg)
		end
	end

	local f_type = type(fmt)
	if f_type == 'string' then
		if #args > 0 then
			return self:append(level, format(fmt, unpack(args)))
		else
			-- only a single string, no formating needed.
			return self:append(level, fmt)
		end
	elseif f_type == 'function' then
		-- fmt should be a callable function which returns the message to log
		return self:append(level, fmt(...))
	end
	-- fmt is not a string and not a function, just call tostring() on it.
	return self:append(level, logging.tostring(fmt))
end

-- create the proxy functions for each log level.
local LEVEL_FUNCS = {}
for i=1,MAX_LEVELS do
	local level = LEVEL[i]
	LEVEL_FUNCS[i] = function(self, ...)
		-- no level checking needed here, this function will only be called if it's level is active.
		return LOG_MSG(self, level, ...)
	end
end

-- do nothing function for disabled levels.
local function disable_level() end

-- improved assertion function.
local function assert(exp, ...)
	-- if exp is true, we are finished so don't do any processing of the parameters
	if exp then return exp, ... end
	-- assertion failed, raise error
	error(format(...), 2)
end

-------------------------------------------------------------------------------
-- Creates a new logger object
-- @param append Function used by the logger to append a message with a
--	log-level to the log stream.
-- @return Table representing the new logger object.
-------------------------------------------------------------------------------
function logging.new(append)
	if type(append) ~= "function" then
		return nil, "Appender must be a function."
	end

	local logger = {}
	logger.append = append

	logger.setLevel = function (self, level)
		local order = LEVEL[level]
		assert(order, "undefined level `%s'", _tostring(level))
		if self.level then
			-- self:log(logging.DEBUG, "Logger: changing loglevel from %s to %s", self.level, level)
			print(string.format( "Logger: changing loglevel from %s to %s", self.level, level))
		end
		self.level = level
		self.level_order = order
		-- enable/disable levels
		for i=1,MAX_LEVELS do
			local name = LEVEL[i]:lower()
			if i >= order then
				self[name] = LEVEL_FUNCS[i]
			else
				self[name] = disable_level
			end
		end
	end

	-- generic log function.
	logger.log = function (self, level, ...)
		local order = LEVEL[level]
		assert(order, "undefined level `%s'", _tostring(level))
		if order < self.level_order then
			return
		end
		return LOG_MSG(self, level, ...)
	end

	-- initialize log level.
	logger:setLevel(logging.DEBUG)
	return logger
end

local startTime  = os.clock()
function getmsecond()
	return string.format("%.2f",os.clock() - startTime)	
end

-------------------------------------------------------------------------------
-- Prepares the log message

--[[
    The fields currentline discription
	see 《Lua 5.1 Reference Manual》  3.8 – The Debug Interface -lua_Debug
	
-—]]
-------------------------------------------------------------------------------
function logging.prepareLogMsg(pattern, dt, level, message)
	local info = debug.getinfo(3, "Sl")
	local lineNum = tostring(info.currentline);
	local file   = tostring(info.source)
	local logMsg = pattern or "Lua:[%date][%msTime][%level][%file:%lineNum]%message   \n"
	local curr_time = string.format("%02d:%02d:%02d",tonumber(dt.hour) , tonumber(dt.min) , tonumber(dt.sec))
	message = string.gsub(message, "%%", "%%%%")
	logMsg = string.gsub(logMsg, "%%date", curr_time)
	logMsg = string.gsub(logMsg, "%%msTime", getmsecond())
	logMsg = string.gsub(logMsg, "%%level", level)
	logMsg = string.gsub(logMsg, "%%file", file)
	logMsg = string.gsub(logMsg, "%%lineNum", lineNum)
	logMsg = string.gsub(logMsg, "%%message", message)	

	return logMsg
end

--[[
    desc:完成tostring时的缩进量
    arg1: 当前层数 层次每深一层 缩进增加一个\t
    return: string  
-—]]
local function  echoEnd( num )
	local str = "\n"
	for  i=1,num do
		str = str .. "\t"
	end
	return str
end
-------------------------------------------------------------------------------
-- Converts a Lua value to a string
--
-- Converts Table fields in alphabetical order
-------------------------------------------------------------------------------
local num = 0
local function tostring(value)
	local str = ''
	num = num+1
	if (type(value) ~= 'table') then
		if (type(value) == 'string') then
			str = string.format("%q", value)
		else
			str = _tostring(value)
		end
	else
		local auxTable = {}
		for key in pairs(value) do
			-- if (tonumber(key) ~= key) then
			-- 	table.insert(auxTable, key)
			-- else
			-- 	table.insert(auxTable, tostring(key))
			-- end
			table.insert(auxTable, key)
		end
		-- table.sort(auxTable)
	
		str = str..'{' .. echoEnd(num)
		local separator = ""
		local entry = ""
		for _, fieldName in ipairs(auxTable) do
			-- if ((tonumber(fieldName)) and (tonumber(fieldName) > 0) and (type(fieldName) == "number") ) then
			-- 	entry = tostring(value[tonumber(fieldName)]) 
			-- 	entry = entry .. "," .. echoEnd(num)
			-- else
				entry = fieldName.." = "..tostring(value[fieldName])
				entry = entry .. echoEnd(num)
			-- end

			str = str..entry
		end
		str = str..'}' .. echoEnd(num)
	end
	num  = num - 1
	return str
end
logging.tostring = tostring

if _VERSION ~= 'Lua 5.2' then
	-- still create 'logging' global for Lua versions < 5.2
	_G.logging = logging
end

return logging
