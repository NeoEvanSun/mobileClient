---
-- 一个基础类，用于完成事件模型
-- @type EventDispatcher
EventDispatcher = class("EventDispatcher")

local mSchedulerId = nil

---
-- #list< #EventDispatcher > mManaged
local mManaged = {}
---
-- @function [parent=#EventDispatcher] create
-- @return #EventDispatcher
function EventDispatcher.create()
	local ed = EventDispatcher.new()

	---
	-- 所有的监听者
	-- @field [parent=#EventDispatcher] #table mListeners
	ed.mListeners = {}

	---
	-- 当前聚集的事件
	-- @field [parent=#EventDispatcher] #table mEvents
	ed.mEvents = {}

	---
	-- 是否已经加入定时器
	-- @field [parent=#EventDispatcher] #bool mScheduled
	ed.mScheduled = false

	return ed
end

---
-- 添加一个监听器，当事件发生时会进行通知
-- @function [parent=#EventDispatcher] addListener
-- @param #string eventType 事件类型，允许支持多个事件
-- @param listener 要添加的监听者
function EventDispatcher:addListener(listener)
	if listener == nil then
		Logger.fatal("nil listener found")
		return
	end
	self.mListeners[#self.mListeners + 1] = listener
end


---
-- 删除一个事件监听者
-- @function [parent=#EventDispatcher] removeListener
-- @param listener 事件监听者
function EventDispatcher:removeListener(listener)
	for i = 1, #self.mListeners do
		if self.mListeners[i] == listener then
			self.mListeners[i] = nil
		end
	end
end

---
-- 发送一个事件出来
-- @function [parent=#EventDispatcher] dispatch
-- @param self
-- @param event 事件对象
function EventDispatcher:dispatch(event)
	self.mEvents[#self.mEvents + 1] = event

	if not self.mScheduled then
		mManaged[#mManaged + 1] = self
		self.mScheduled = true
	end

	if mSchedulerId == nil then
		mSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mSchedulerId)
			mSchedulerId = nil
			local managed = mManaged -- #list< #EventDispathcer >
			mManaged = {}
			for i = 1, #managed do
				managed[i]:doDispatch()
			end
		end, 0, false)
	end
end

---
-- 实际处理函数
-- @function [parent=#EventDispatcher] doDispatch
-- @param self
function EventDispatcher:doDispatch()
	for i = 1, #self.mEvents do
		local event = self.mEvents[i]
		for j = 1, #self.mListeners do
			self:dispatchEvent(self.mListeners[j], event)
		end
	end
	self.mEvents = {}
	self.mScheduled = false
end

---
-- 虚函数，由子类来实现
-- @function [parent=#EventDispatcher] dispatchEvent
-- @param self
-- @param listener
-- @param event
function EventDispatcher:dispatchEvent(listener, event)
	Logger.fatal("dispatchEvent not implemented for class:%s", EventDispatcher.__cname)
end

return EventDispatcher
