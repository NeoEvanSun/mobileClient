---
-- 打印日志的类
-- @module Logger
Logger = {}

local mLevel = 0

---
-- 日志级别:debug，用于打印所有调试信息
Logger.kDebug = 0

---
-- 日志级别:trace，原则上所有的代码分支都有一行这条日志
Logger.kTrace = 1

---
-- 日志级别:info，一般来说线上可能是这种日志级别，打印一些标志性信息
Logger.kInfo = 2

---
-- 日志级别:warning，一般来跟预期不一致的异常都应该打印这个结果
Logger.kWarning = 3

---
-- 日志级别:fatal，一般来说错误都应该打印这个级别的日志，注意这个级别的日志会把调用栈信息也打印出来
Logger.kFatal = 4

local mFilter = ""

local kLevelDesc = {
	[0] = "DEBUG",
	[1] = "TRACE",
	[2] = "INFO",
	[3] = "WARNING",
	[4] = "FATAL",
}

---
-- 设置日志级别
-- @function [parent=#Logger] setLevel
-- @param level 日志级别，低于这个级别的日志将不被打印
function Logger.setLevel(level)
	mLevel = level
end

---
-- 日志的实际输出函数
local function log(level, ...)
	if level < mLevel then
		return
	end

	local argLength = select('#', ...)
	local args = {}
	for i = 1, argLength do
		local arg = select(i, ...)
		if type(arg) == 'table' then
			arg = Util.tableToString(arg)
		end
		args[i] = arg
	end

	local message = ""
	if #args == 1 then
		message = args[1]
	else
		message = string.format(unpack(args))
	end

	if mFilter ~= "" and nil == message:find(mFilter) then
		return
	end

	local info = debug.getinfo(3, "Sl")
	local source = info.source
	local start, endi = string.find(source,"/?scripts/")
	if endi ~= nil then
		source = source:sub(endi + 1)
	else
		source = ""
	end

	local ts = os.date("%Y%m%d %H:%M:%S")
	if GameUtil ~= nil then
		ts = string.format("%s %06d", ts, GameUtil:getMicroSeconds())
	end

	message = string.format("[%s][%s][%s:%d] %s", ts, kLevelDesc[level], source, info.currentline, message)
	print(message)

	if level == Logger.kFatal then
		print(debug.traceback())
	end
end

---
-- 打印debug级别的日志
-- @function [parent=#Logger] debug
-- @param ...
function Logger.debug(...)
	log(Logger.kDebug, ...)
end

---
-- 设置过滤器，含有该标识的日志才被输出
-- @function [parent=#Logger] setFilter
-- @param #string filter 空字符串表示关闭
function Logger.setFilter(filter)
	if Util.isEmpty(filter) then
		filter = ""
	end
	mFilter = filter
end

function Logger.trace(...)
	log(Logger.kTrace, ...)
end

function Logger.info(...)
	log(Logger.kInfo, ...)
end

function Logger.warning(...)
	log(Logger.kWarning, ...)
end

function Logger.fatal(...)
	log(Logger.kFatal, ...)
end
