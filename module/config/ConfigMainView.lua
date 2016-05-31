-- FileName: ConfigMainView.lua
-- Author: menghao
-- Date: 2014-06-18
-- Purpose: 系统设置view


module("ConfigMainView", package.seeall)


-- UI控件引用变量 --
local m_UIMain

local m_tfdTitle
local m_btnClose
local m_btnMusicOff
local m_btnMusicOn
local m_btnEffectOff
local m_btnEffectOn
local m_btnAnnounce

local m_tfdState1
local m_tfdState2



-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n
local m_config = Platform.getConfig()


function switchBtnMusicByStatus( bValue )
	m_btnMusicOn:setEnabled(not bValue)

	if (bValue) then
		m_tfdState1:setText(m_i18n[4102])
	else
		m_tfdState1:setText(m_i18n[4103])
	end

end


function switchBtnEffectByStatus( bValue )
	m_btnEffectOn:setEnabled(not bValue)

	if (bValue) then
		m_tfdState2:setText(m_i18n[4102])
	else
		m_tfdState2:setText(m_i18n[4103])
	end

end



local function init(...)

end


function destroy(...)
	package.loaded["ConfigMainView"] = nil
end


function moduleName()
	return "ConfigMainView"
end


function create(tbEvent, tbInfo)
	m_UIMain = g_fnLoadUI("ui/config_main.json")

	m_tfdTitle = m_fnGetWidget(m_UIMain, "tfd_title")
	m_btnClose = m_fnGetWidget(m_UIMain, "BTN_CLOSE")
	m_btnMusicOff = m_fnGetWidget(m_UIMain, "BTN_SWITCH_OFF1")
	m_btnMusicOn = m_fnGetWidget(m_UIMain, "BTN_SWITCH_ON1")
	m_btnEffectOff = m_fnGetWidget(m_UIMain, "BTN_SWITCH_OFF2")
	m_btnEffectOn = m_fnGetWidget(m_UIMain, "BTN_SWITCH_ON2")
	m_btnAnnounce = m_fnGetWidget(m_UIMain, "BTN_ANNOUNCE")

	m_tfdState1 = m_fnGetWidget(m_UIMain, "TFD_STATE1")
	m_tfdState2 = m_fnGetWidget(m_UIMain, "TFD_STATE2")


	-- 是否显示绑定帐号
	local lsvMain = m_fnGetWidget(m_UIMain, "LSV_MAIN")
	local cellBind = m_fnGetWidget(lsvMain, "LAY_ACCOUNT")
	lsvMain:removeChild(cellBind) -- 2015-03-19 封测包临时删除


	-- 设置初始化 音乐 特效文字提示

	local flagNusic = AudioHelper.isMusicOn()

	if (flagNusic) then
		m_tfdState1:setText(m_i18n[4102])
	else
		m_tfdState1:setText(m_i18n[4103])
	end


	local flagEffect = AudioHelper.isEffectOn()
	if (flagEffect) then
		m_tfdState2:setText(m_i18n[4102])
	else
		m_tfdState2:setText(m_i18n[4103])
	end

	-- local imgBinded = m_fnGetWidget(cellBind, "IMG_ALREADY_BINDING") -- 已绑定图片
	-- local btnBind = m_fnGetWidget(cellBind, "BTN_ACCOUNT") -- 绑定按钮
	-- local idxBind = lsvMain:getIndex(cellBind)
	-- if (Platform.isPlatform() and (Platform.getConfig().getFlag() == "zyxphone")) then -- 是最游戏平台
	-- 	if (m_config.bindUser()) then
	-- 		btnBind:removeFromParentAndCleanup(true) -- 已绑定帐号, 删除绑定按钮
	-- 	elseif (m_config.getLoginState() == m_config.kLoginsStateUDIDLogin) then -- 游客试玩，显示绑定按钮
	-- 		imgBinded:setEnabled(false) -- 隐藏已绑定

	-- 		local i18n_bind = m_fnGetWidget(cellBind, "TFD_ACCOUNT")
	-- 		i18n_bind:setText(m_i18n[4708])
	-- 		UIHelper.titleShadow(btnBind, m_i18n[4708])
	-- 		btnBind:addTouchEventListener(function ( sender, eventType )
	-- 			if (eventType == TOUCH_EVENT_ENDED) then
	-- 				LayerManager.removeLayout()
	-- 				require "script/module/login/ZyxView"

	-- 				local tbBind = {}
	-- 				tbBind.account = ""
	-- 				tbBind.eventConfirm = function ( sender, eventType )
	-- 					if (eventType == TOUCH_EVENT_ENDED) then
	-- 						local tbLogin = ZyxView.getAllInputText()
	-- 						-- 发送绑定账户的请求
	-- 						ZyxCtrl.onGuestBindOld(tbLogin)
	-- 					end
	-- 				end
	-- 				ZyxView.showBindOld(tbBind) -- 弹出提示绑定账户的面板
	-- 			end
	-- 		end)
	-- 	else -- 最游戏账号登陆，不显示绑定账号的cell
	-- 		lsvMain:removeChild(cellBind)
	-- 	end
	-- else
	-- 	lsvMain:removeChild(cellBind)
	-- end

	-- 平台社区入口
	local cellForum = m_fnGetWidget(lsvMain, "LAY_COMMUNITY") -- 社区Cell
	lsvMain:removeChild(cellForum) -- 2015-03-19 封测包临时删除
	-- if (Platform.isPlatform() and m_config.getBBSName) then
	-- 	local m_labForum = m_fnGetWidget(cellForum, "TFD_COMMUNITY")
	-- 	m_labForum:setText(m_config.getBBSName()) -- 平台社区入口名称
	-- 	local m_btnForum = m_fnGetWidget(cellForum, "BTN_COMMUNITY")
	-- 	UIHelper.titleShadow(m_btnForum, m_i18n[3104])
	-- 	m_btnForum:addTouchEventListener(function ( sender, eventType )
	-- 		if (eventType == TOUCH_EVENT_ENDED) then
	-- 			AudioHelper.playCommonEffect()
	-- 			Platform.enterUserCenter()
	-- 		end
	-- 	end)
	-- else
	-- 	lsvMain:removeChild(cellForum)
	-- end

	-- 平台帐号注销
	local cellLogout = m_fnGetWidget(lsvMain, "LAY_LOGOUT") -- 注销帐号Cell
	lsvMain:removeChild(cellLogout) -- 2015-03-19 封测包临时删除
	-- if (Platform.isPlatform() and Platform.loginOut) then
	-- 	local m_labLogout = m_fnGetWidget(cellLogout, "TFD_LOGOUT")
	-- 	m_labLogout:setText("注销帐号")
	-- 	local m_btnLogout = m_fnGetWidget(cellLogout, "BTN_LOGOUT")
	-- 	UIHelper.titleShadow(m_btnLogout, "注销")
	-- 	m_btnLogout:addTouchEventListener(function ( sender, eventType )
	-- 		if (eventType == TOUCH_EVENT_ENDED) then
	-- 			AudioHelper.playCommonEffect()

	-- 			Network.disconnect() -- 1. 断开游戏服连接
	-- 			Platform.loginOut() -- 2.调用平台注销接口
	-- 			LoginHelper.platformLogout() -- 3.返回登陆界面
	-- 		end
	-- 	end)
	-- else
	-- 	lsvMain:removeChild(cellLogout)
	-- end

	if tbInfo.musicOn then
		m_btnMusicOn:setEnabled(false)
	end
	if tbInfo.effectOn then
		m_btnEffectOn:setEnabled(false)
	end
	m_btnClose:addTouchEventListener(UIHelper.onClose)
	m_btnMusicOff:addTouchEventListener(tbEvent.onMusic)
	m_btnEffectOff:addTouchEventListener(tbEvent.onEffect)
	m_btnAnnounce:addTouchEventListener(tbEvent.onAnnounce)
	m_btnMusicOn:setTouchEnabled(false)
	m_btnEffectOn:setTouchEnabled(false)

	UIHelper.labelEffect(m_tfdTitle, m_i18n[3101])
	UIHelper.titleShadow(m_btnAnnounce, m_i18n[3102])

	return m_UIMain
end

