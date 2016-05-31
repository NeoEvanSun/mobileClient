-- FileName: AnnounceCtrl.lua
-- Author: menghao
-- Date: 2014-06-19
-- Purpose: 公告ctrl


module("AnnounceCtrl", package.seeall)


require "script/module/config/AnnounceView"


-- UI控件引用变量 --


-- 模块局部变量 --
local m_ExpCollect = ExceptionCollect:getInstance()

local m_bShowLoading
local m_strNotice


local addNoticeToLay = function ( strAll )
	strAll = string.gsub(strAll, "\r\n", " \n")
	local tbAllOld = string.split(strAll, "======")

	for k,v in pairs(tbAllOld) do
		local tbOneOld = string.split(v, "|")

		local tbInfo = {}
		tbInfo.colorT = string.split(tbOneOld[1], ",")
		tbInfo.colorW = string.split(tbOneOld[3], ",")
		tbInfo.title = tbOneOld[2]
		tbInfo.word = tbOneOld[4]

		if (#tbAllOld == 1) then
			AnnounceView.addAnnounce(tbInfo, 1)
			return
		end
		AnnounceView.addAnnounce(tbInfo)
	end
end


local function getAnnounceCallBack( sender, res )
	if m_bShowLoading then
		LayerManager.removeLoading()
		m_bShowLoading = false
	end

	if(res:getResponseCode()==200)then
		m_ExpCollect:finish("fetchNotice02FromServer")

		m_strNotice = res:getResponseData()

		if (m_strNotice and m_strNotice ~= "") then
			local layAnnounce = AnnounceView.create()
			LayerManager.addLayout(layAnnounce)
			addNoticeToLay(m_strNotice)
			MainScene.addNoticeTime()
		end
	else
		m_ExpCollect:info("fetchNotice02FromServer", "responseCode = " .. tostring(res:getResponseCode()))
		LayerManager.addLayout(UIHelper.createCommonDlg(gi18n[2829], nil, nil, 1))
	end
end


-- 通过服务器标识serverKey拉取第二类通知
function fetchNotice02FromServer(serverKey)
	require "platform/Platform"
	local url = Platform.getNoticeBeforeGameUrl()
	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setUrl(url)
	request:setResponseScriptFunc(getAnnounceCallBack)
	if (not m_bShowLoading) then
		LayerManager.addLoading()
		m_bShowLoading = true
	end

	m_ExpCollect:start("fetchNotice02FromServer", "url = " .. url)
	CCHttpClient:getInstance():send(request)
	request:release()
end


local function init(...)

end


function destroy(...)
	package.loaded["AnnounceCtrl"] = nil
end


function moduleName()
	return "AnnounceCtrl"
end


function create(...)
	if (UserModel.getAvatarLevel() < 6) then
		return
	end

	fetchNotice02FromServer()
end

