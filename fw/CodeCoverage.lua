---
-- 用于生成代码覆盖率文件
-- @type CodeCoverage
CodeCoverage = class("CodeCoverage")

---
-- 内部变量，用于存储单态对象
local mInstance = nil

---
-- @function [parent=#CodeCoverage] sharedCodeCoverage
-- @return #CodeCoverage
function CodeCoverage.sharedCodeCoverage()
	if mInstance == nil then
		mInstance = CodeCoverage.create()
	end
	return mInstance
end

function CodeCoverage.create()
	local codeCoverage = CodeCoverage.new()
	---
	-- 当前覆盖率结果
	-- @field [parent=#CodeCoverage] #table mResult
	codeCoverage.mResult = nil

	---
	-- 当前是否正在运行覆盖率检查
	-- @field [parent=#CodeCoverage] #boolean mRunning
	codeCoverage.mRunning = false

	---
	-- 当前使用的前缀
	-- @field [parent=#CodeCoverage] #string mPrefix
	codeCoverage.mPrefix = ""

	---
	-- 前缀长度
	-- @field [parent=#CodeCoverage] #number mPrefixLen
	codeCoverage.mPrefixLen = 0

	---
	-- 用于存储的地址
	-- @field [parent=#CodeCoverage] #string mSaveDirectory
	codeCoverage.mSaveDirectory = "/sdcard/"

	return codeCoverage
end



---
-- 将当前的生成记录保存一下
-- @function [parent=#CodeCoverage] save
-- @param self
-- @return 生成记录
function CodeCoverage:save()
	if self.mResult == nil then
		return nil
	end

	local name = os.time() .. '.cov'
	local file = self.mSaveDirectory .. name
	local f = io.open(file,'w')
	if f == nil then
		return nil
	end

	for source, lines in pairs(self.mResult) do
		for line, count in pairs(lines) do
			f:write(string.format("%s %d %d\n", source, line, count))
		end
	end
	f:close()
	self.mResult = nil
	return file
end

---
-- 启动覆盖率检查
-- @function [parent=#CodeCoverage] start
-- @param self
-- @param prefix 文件前缀
-- @param saveDir 保存覆盖率文件的地址
function CodeCoverage:start(prefix, saveDir)
	if self.mRunning then
		Logger.info("CodeCoverage already started")
		return
	end

	debug.sethook(function(event, line)
		if line == 0 or event ~= "line" or self.mResult == nil then
			return
		end

		local source = debug.getinfo(2, "S").source
		if self.mPrefixLen > 0 then
			local prefix = source:sub(1, self.mPrefixLen)
			if prefix ~= self.mPrefix then
				return
			end
			if self.mPrefix == "@" then
				source = source:sub(2)
			end
		end

		if self.mResult[source] == nil then
			self.mResult[source] = {
				[line] = 1
			}
		elseif self.mResult[source][line] == nil then
			self.mResult[source][line] = 1
		end
	end, 'l')
	self.mPrefix = prefix
	if self.mPrefix ~= nil then
		self.mPrefixLen = self.mPrefix:len()
	else
		self.mPrefixLen = 0
	end
	if self.mResult == nil then
		self.mResult = {}
	end

	if saveDir ~= nil then
		self.mSaveDirectory = saveDir
	end

	self.mRunning = true
	MemoryMonitor.sharedMonitor():addListener(self)
end

---
-- 内存报警监听者对象
-- @function [parent=#CodeCoverage] onLowMemory
-- @param self
function CodeCoverage:onLowMemory()
	Logger.info("memory is low, save coverage and clean")
	self:save()
	collectgarbage('collect')
end

---
-- 停止覆盖率生成
-- @function [parent=#CodeCoverage] stop
-- @param self
-- @return #string 存储的文件地址
function CodeCoverage:stop()
	debug.sethook()
	self.mRunning = false
	return self:save()
end
