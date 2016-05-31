---
-- 私有变量，用于存储单态对象
local mInstance = nil

---
-- 私有常量，要检查的内存文件
local mMemoryFile = "/proc/meminfo"

---
-- 表示当前模块是否激活
local mEnabled = CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid

---
-- 获取当前剩余内存
-- @return {
--  MemFree:当前可用内存
--  Buffers:硬盘缓存
--  Cached:文件缓存
-- }
local function getFreeMemory()
	local count = 0
	local result = {
		MemFree = 0,
		Buffers = 0,
		Cached = 0,
	}

	if not mEnabled then
		return result
	end

	for line in io.lines(mMemoryFile) do
		for key in string.gmatch(line, "%a+") do
			if result[key] == nil then
				break
			end

			for value in string.gmatch(line,"%d+") do
				result[key] = tonumber(value)
			end

			count = count + 1
			if count >= 3 then
				break
			end
		end
	end

	return result
end

---
-- 用于内存监控的模块，只适用于android系统
-- @type MemoryMonitor
-- @extends fw.EventDispatcher#EventDispatcher
MemoryMonitor = class("MemoryMonitor", function()
	return EventDispatcher.create()
end)

function MemoryMonitor.create()
	local memoryMonitor = MemoryMonitor.new()
	---
	-- 上次总可用内存
	-- @field [parent=#MemoryMonitor] #number mLastMemory
	memoryMonitor.mLastMemory = 0

	---
	-- 上次立即可用内存
	-- @field [parent=#MemoryMonitor] #number mLastFree
	memoryMonitor.mLastFree = 0

	---
	-- 内存清除比例
	-- @field [parent=#MemoryMonitor] #number mRatio
	memoryMonitor.mRatio = 2

	---
	-- 检查的间隔，单位为秒
	-- @field [parent=#MemoryMonitor] #number mCheckInterval
	memoryMonitor.mCheckInterval = 1

	---
	-- schedule句柄
	-- @field [parent=#MemoryMonitor] mScheduleEntry
	memoryMonitor.mScheduleEntry = nil

	memoryMonitor:init()

	return memoryMonitor
end


---
-- 单态工厂方法
-- @function [parent=#MemoryMonitor] sharedMonitor
-- @return #MemoryMonitor
function MemoryMonitor.sharedMonitor()
	if mInstance == nil then
		mInstance = MemoryMonitor.create()
	end
	return mInstance
end

---
-- 设置内存清理比例
-- @function [parent=#MemoryMonitor] setRatio
-- @param self
-- @param #number ratio 如果为2，则表示原内存是当前的2倍时，则开始清理，如果ratio小于1，则表示每次回调都清理
--              当前默认值是2
function MemoryMonitor:setRatio(ratio)
	self.mRatio = ratio
end

---
-- 设置内存检查间隔
-- @function [parent=#MemoryMonitor] setCheckInterval
-- @param self
-- @param #number interval 检查时间间隔，单位为s
function MemoryMonitor:setCheckInterval(interval)
	if self.mCheckInterval == interval then
		return
	end
	self.mCheckInterval = interval
	self:init()
end

---
-- 初始化
-- @function [parent=#MemoryMonitor] init
-- @param self
function MemoryMonitor:init()
	if not mEnabled then
		return
	end

	if self.ScheduleEntry ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptFunc(self.mScheduleEntry)
		self.ScheduleEntry = nil
	end

	self.mScheduleEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(...)
		local meminfo = getFreeMemory()
		local memory = meminfo.MemFree + meminfo.Buffers + meminfo.Cached
		local free = meminfo.MemFree

		if memory > self.mLastMemory then
			self.LastMemory = memory
		end

		if free > self.mLastFree then
			self.mLastFree = free
			return

		end

		if self.mLastFree >= free * self.mRatio or self.mLastMemory >= memory * self.mRatio then
			self:dispatch()
			self.mLastFree = 0
			self.mLastMemory = 0
		end
	end, self.mCheckInterval , false)
end

---
-- 处理事件
-- @function [parent=#MemoryMonitor] dispatch
-- @param self
-- @param listener
-- @param event
function MemoryMonitor:dispatchEvent(listener, event)
	listener:onLowMemroy(event)
end
