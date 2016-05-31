local kSavePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "dltmp/"

---
-- 更新器，负责下载，解压，拷贝，修改版本信息
-- @type Updater
-- @extends fw.EventDispatcher#EventDispatcher
Updater=class("Updater", function()
	return EventDispatcher.create()
end)

---
-- 创建一个新的下载器出来
function Updater.create()
	local updater = Updater.new()
	---
	-- 下载监听器，用于显示UI
	-- @field [parent=#Updater] fw.Downloader#DownloadListener mListener
	updater.mListener = nil

	---
	-- 下载器对象
	-- @field [parent=#Updater] fw.Downloader#Downloader mDownloader
	updater.mDownloader = nil

	---
	-- 下载的文件名
	-- @field [parent=#Updater] #string mName
	updater.mName = ""

	return updater
end

---
-- @function [parent=#Updater] onProgress
-- @param self
-- @param #table event
function Updater:onProgress(event)
	if self.mListener ~= nil then
		self.mListener:onProgress(event)
	end
end

---
-- 开始更新，如果有更新则会发出一个更新的事件
-- @function [parent=#Updater] start
-- @param self
-- @param #string url 用于下载更新的url
-- @param #number downloadTime 根据更新的大小预算的下载时间
function Updater:start(url, name, checkCode, downloadTime)
	logger:debug("Updater:start: url:%s, fileName:%s", url, name)
	if not GameUtil:isDir(kSavePath) then
		if 0 ~= GameUtil:mkdir(kSavePath, Util.octal2Decimal("0700")) then
			if self.mListener == nil then
				Logger.warning("create dir:%s failed", kSavePath)
			else
				self.mListener:onFinished({err="create tmp dir failed"})
			end
			return
		end
	end
	self.mMd5 = checkCode
	self.mDownloader = Downloader.create()
	self.mDownloader:addListener(self)
	self.mName = name
	self.mDownloader:start(url, kSavePath .. name, downloadTime)
end

---
-- 设置显示UI的监听器
-- @function [parent=#Updater] addListener
-- @param self
-- @param fw.Downloader#DownloadListener listener
function Updater:addListener(listener)
	self.mListener = listener
end

---
-- 完成事件响应
-- @function [parent=#Updater] onFinished
-- @param self
-- @param event
function Updater:onFinished(event)
	if event.err == "ok" then
		local tmpFile = kSavePath .. self.mName
		-- MD5校验
		if (self.mMd5) then
			local tmpMd5 = Util.digestFile(tmpFile, CCCrypto.EDigestMD5, false)
			Logger.debug("tmpMd5: %s", tmpMd5)

			Logger.debug("self.mMd5: %s", self.mMd5)
			if (self.mMd5 ~= tmpMd5) then
				event.err = "md5 check error"
				Logger.warning(event.err)
			else
				-- 解压
				local ret = GameUtil:unzip(tmpFile, kSavePath)
				if ret == GameUtil.EUnzipOk then
					-- 重命名
					local resPath = string.format("%s%s/%s", g_ResPath, g_ProjName, g_ResRoot) -- ../fknpirate/, zhangqi, 20140615
					local ret = Util.copyDir(kSavePath .. "Resources", resPath, true)
					if not ret then
						Logger.warning("copy file failed")
						event.err = "copy file failed"
					end
				else
					Logger.warning("upzip failed:%d", ret)
					event.err = "unzip failed"
				end

				-- 删除空文件夹
				Util.removeDir(kSavePath)
			end
		end
	else
		Logger.warning("download failed:%s", event.err)
	end

	if self.mListener ~= nil then
		self.mListener:onFinished(event)
	end
end
