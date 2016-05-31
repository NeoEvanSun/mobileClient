---
-- 下载监听器
-- @type DownloadListener

---
-- 下载进度
-- @function [parent=#DownloadListener] onProgress
-- @param self
-- @param #table event 事件对象

---
-- 下载结果
-- @function [parent=#DownloadListener] onFinished
-- @param self
-- @param #table event 事件对象

---
-- 一个大包下载器
-- @type Downloader
-- @extends fw.EventDispatcher#EventDispatcher

---
-- @function [parent=#Downloader] new
-- @return #Downloader
Downloader = class("Downloader", function()
	return EventDispatcher.create()
end)

---
-- 下载完成事件
local kETFinished = "Downloader.finished"

---
-- 下载进度事件
local kETProgress = "Downloader.progress"

local kRangePattern = 'Content%-Range: bytes (%d+)%-(%d+)%/(%d+)'

local kStatusPattern = "HTTP/1.1 (%d+) ([^\r]+)"

local kContentPattern = 'Content%-Length: (%d+)'

function Downloader.create()
	local downloader = Downloader.new()
	---
	-- 响应头信息
	-- @field [parent=#Downloader] #string mHeader
	downloader.mHeader = ""

	---
	-- 断点续传的起始位置
	-- @field [parent=#Downloader] #number mRangeStart
	downloader.mRangeStart = 0

	---
	-- 断点续传的结束位置
	-- @field [parent=#Downloader] #number mRangeEnd
	downloader.mRangeEnd = 0

	---
	-- 总共需要传输的大小
	-- @field [parent=#Downloader] #number mRangeSize
	downloader.mRangeSize = 0

	---
	-- 目前已经下载的字符数
	-- @field [parent=#Downloader] #number mNowBytes
	downloader.mNowBytes = 0

	---
	-- 响应头信息的处理情况
	-- @field [parent=#Downloader] #mixed mHeaderOk
	downloader.mHeaderOk = nil

	---
	-- 保存的路径
	-- @field [parent=#Downloader] #string mSavePath
	downloader.mSavePath = ""

	---
	-- 已保存的大小
	-- @field [parent=#Downloader] #number mSavedBytes
	downloader.mSavedBytes = 0

	---
	-- 用于保存文件的句柄
	-- @field [parent=#Downloader] #file mFile
	downloader.mFile = nil

	---
	-- 当前完成进度
	-- @field [parent=#Downloader] #number mPercent
	downloader.mPercent = 0

	return downloader
end



---
-- 处理头信息
-- @function [parent=#Downloader] doHeader
-- @param self
function Downloader:doHeader()
	if self.mHeader == "" then
		Logger.trace("header is empty")
		return
	end

	Logger.trace("header:%s", self.mHeader)
	---
	-- 首先看一下http协议返回状态
	local status, message = self.mHeader:match(kStatusPattern)
	if status == nil then
		self:dispatch({
			type=kETFinished,
			err="Bad Http Response " .. self.mHeader
		})
		self.mHeaderOk = false
		return
	end

	---
	-- 状态码大于299就是有问题的，直接发送错误信息
	if tonumber(status) > 299 then
		self:dispatch({
			type=kETFinished,
			err=message
		})
		self.mHeaderOk = false
		return
	end

	---
	-- 获取断点续传的信息
	self.mRangeStart, self.mRangeEnd, self.mRangeSize = self.mHeader:match(kRangePattern)
	-- Logger.debug("self.mHeader = " .. self.mHeader)

	---
	-- 如果没有断点续传的头信息，则认为不支持，直接取包体大小作为大小
	if self.mRangeStart == nil then
		self.mRangeStart = 0
		local contentLength = self.mHeader:match(kContentPattern)
		if contentLength == nil then
			self:dispatch({
				type=kETFinished,
				err="Bad Http Response" .. self.mHeader
			})
			self.mHeaderOk = false
			return
		end
		self.mRangeSize = tonumber(contentLength)
		self.mRangeEnd = self.mRangeSize - 1
	else -- 否则表示支持断点续传
		self.mRangeStart = tonumber(self.mRangeStart)
		self.mRangeEnd = tonumber(self.mRangeEnd)
		self.mRangeSize = self.mRangeEnd + 1
	end

	---
	-- 开始断点续传，设置正确的文件输入点
	if self.mRangeStart <= self.mSavedBytes then
		self.mFile:seek("set", self.mRangeStart)
		self.mNowBytes = self.mRangeStart
	else
		self:dispatch({
			type=kETFinished,
			err="Bad Http Response" .. self.mHeader
		})
		self.mHeaderOk = false
		return
	end

	self.mHeaderOk = true
end

---
-- 处理接收到的响应体数据
-- @function [parent=#Downloader] onBodyData
-- @param self
-- @param #string data 接收到的数据
function Downloader:onBodyData(data)
	--Logger.trace("recieved body data %d bytes", data:len())
	---
	-- 如果还没处理头信息，则开始处理头信息
	if self.mHeaderOk == nil then
		self:doHeader()
	end

	if self.mHeaderOk then
		self.mFile:write(data)
		self.mNowBytes = self.mNowBytes + data:len()
		local percent = math.ceil(self.mNowBytes * 100 / self.mRangeSize)
		if percent ~= self.mPercent then
			self.mPercent = percent
			self:dispatch({type = kETProgress, percent=self.mPercent})
			Logger.trace("download:%d", percent)
		end

		---
		-- 下载完成，则需要关闭文件句柄，重全名文件等操作
		-- 这个不能在onFinished里完成，因为onFinished可能会比onProgress事件更新早完成
		if self.mNowBytes == self.mRangeSize then
			self.mFile:flush()
			self.mFile:close()
			local ret = GameUtil:rename(self.mSavePath .. ".dl", self.mSavePath)
			local event = {
				type=kETFinished
			}
			if ret == 0 then
				event.err = "ok"
			else
				event.err = "rename failed"
			end
			self:dispatch(event)
		end
	end
end

---
-- 接收到响应头信息
-- @function [parent=#Downloader] onHeaderData
-- @param self
-- @param #string data 接收到的数据
function Downloader:onHeaderData(data)
	self.mHeader = self.mHeader .. data
end

---
-- 当下载完成之后的处理结果
-- @function [parent=#Downloader] onFinished
-- @param self
-- @param CCHttpClient#CCHttpClient client
-- @param LuaHttpResponse#LuaHttpResponse response
function Downloader:onFinished(client, response)
	Logger.trace("download finished")
	if self.mHeaderOk == nil then
		Logger.trace("header not handled")
		self:doHeader()
	end

	if self.mHeaderOk == false then
		Logger.trace("header is not ok, finish now")
		return
	end

	---
	-- 当出错时才在这里关闭文件句柄
	if response:getResponseCode() > 299 or response:getResponseCode() < 0 then
		Logger.fatal("download failed:%s", response:getErrorBuffer())
		self.mFile:flush()
		self.mFile:close()
		self.mHeaderOk = false
		self:dispatch({
			type=kETFinished,
			err=response:getErrorBuffer()
		})
	end
end

---
-- 开启一个新的下载
-- @function [parent=#Downloader] start
-- @param self
-- @param #string url 下载的链接地址
-- @param #number downloadTime 根据更新的大小预算的下载时间
function Downloader:start(url, savePath, downloadTime)
	Logger.trace("save file to:%s", savePath)
	----
	-- 步骤1：得到已下载包的大小
	--
	self.mFile = io.open(savePath .. '.dl','a+')
	if self.mFile == nil then
		self:dispatch({type=kETFinished, err=string.format("open file:%s failed", savePath .. '.dl')})
		return
	end

	local savedBytes, message = self.mFile:seek('cur', 0)
	if savedBytes == nil then
		self:dispatch({type=kETFinished, err=message})
		return
	end

	---
	-- 步骤2：开始下载，设置断点续传头
	--
	local request = LuaHttpRequest:newRequest()
	request:setTimeoutForRead(downloadTime) -- zhangqi, 2014-09-27, 给每次下载设置读取超时
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setUrl(url)
	request:addHeader(string.format("Range: bytes=%d-", savedBytes))
	Logger.debug("savedBytes:%d", savedBytes)

	---
	-- 步骤3：根据返回头信息来确认是否支持断点续传
	--
	self.mRangeStart = 0
	self.mSavedBytes = savedBytes
	self.mRangeEnd = 0
	self.mRangeSize = 0
	self.mNowBytes = 0
	self.mHeader = ""
	self.mHeaderOk = nil
	self.mSavePath = savePath

	request:setBodyDataScriptFunc(function(...)
		self:onBodyData(...)
	end, false)
	request:setHeaderDataScriptFunc(function(...)
		self:onHeaderData(...)
	end, false)
	request:setResponseScriptFunc(function(...)
		self:onFinished(...)
	end)

	CCHttpClient:getInstance():send(request)
	request:release()
end

---
-- 分发事件
-- @function [parent=#Downloader] dispatchEvent
-- @param self
-- @param #DownloadListener listener
-- @param #table event
function Downloader:dispatchEvent(listener, event)
	if event.type == kETFinished then
		listener:onFinished(event)
	elseif event.type == kETProgress then
		listener:onProgress(event)
	else
		Logger.fatal("unkonw event type:%s", event.type)
	end
end

return Downloader
