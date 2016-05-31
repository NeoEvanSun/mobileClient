-- FileName: MainBoundGiftCtrl.lua
-- Author: zhangqi
-- Date: 2014-12-16
-- Purpose: 最游戏平台账户登陆礼包控制逻辑
--[[TODO List]]

module("MainBoundGiftCtrl", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_i18n = gi18n
local m_fnGetWidget = g_fnGetWidgetByName
local m_typeValue

local function init(...)
	m_typeValue = {}
end

function destroy(...)
	package.loaded["MainBoundGiftCtrl"] = nil
end

function moduleName()
	return "MainBoundGiftCtrl"
end

local function addAttrValue( ... )
	local tbAddValue = {
		["1"] = UserModel.addSilverNumber, ["3"] = UserModel.addGoldNumber, -- ["2"] = UserModel.addSoulNum, -- zhangqi, 2015-01-10, 去经验石
		["4"] = UserModel.addEnergyValue, ["5"] = UserModel.addStaminaNumber, ["8"] = UserModel.addSilverNumber,
		["9"] = UserModel.addExpValue, ["11"] = UserModel.addJewelNum, ["12"] = UserModel.addPrestigeNum,
	}

	for type, value in pairs(m_typeValue) do
		if (tbAddValue[type]) then
			tbAddValue[type](value)
		end
	end
end

local function getCallback( cbFlag, dictData, bRet )
	if (bRet) then
		LayerManager.removeLayout()
		local sRet = dictData.ret
		if (sRet == "ok") then -- 领取成功，加相关数值
			MainShip.removeRegistGift() -- 删除主船界面的注册礼包按钮
			ShowNotice.showShellInfo(m_i18n[4750])
			addAttrValue()
		elseif (sRet == "nobound") then
			ShowNotice.showShellInfo(m_i18n[4751])
		elseif (sRet == "got") then
			ShowNotice.showShellInfo(m_i18n[4752])
		end
	end
end

local function showBoundAlert( ... )
	local layMain = g_fnLoadUI("ui/register_gift_prompt.json")
	local labI18n = m_fnGetWidget(layMain, "tfd_txt")
	labI18n:setText(m_i18n[4753])

	local btnBind = m_fnGetWidget(layMain, "BTN_BINDING")
	UIHelper.titleShadow(btnBind, m_i18n[4708]) -- 绑定账号

	btnBind:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			LayerManager.removeLayout()
			require "script/module/login/ZyxView"

			logger:debug("ConfigMainView onBind")
			local tbBind = {}
			tbBind.account = ""
			tbBind.eventConfirm = function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					logger:debug("onBindOldRequest")
					local tbLogin = ZyxView.getAllInputText()
					-- 发送绑定账户的请求
					ZyxCtrl.onGuestBindOld(tbLogin)
				end
			end
			ZyxView.showBindOld(tbBind) -- 弹出提示绑定账户的面板
		end
	end)

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE")
	btnClose:addTouchEventListener(UIHelper.onClose)

	LayerManager.addLayout(layMain)
end

function create(...)
	init()

	require "db/DB_Normal_config"
	local cfgReward = DB_Normal_config.getDataById(1)
	local bindReward = string.strsplit(cfgReward.binding_reward, ",")

	-- 记录奖励的类型和数值，用于领奖处理
	for i, str in ipairs(bindReward) do
		local reward = string.strsplit(str, "|")
		m_typeValue[reward[1]] = reward[3]
	end

	local function callbackGet ()
		local mConfig = Platform.getConfig()
		if (mConfig.zyxUser()) then -- 是最游戏账号登陆，直接发领奖请求
			RequestCenter.getBoundingReward(getCallback)
		else
			LayerManager.removeLayout() -- 关闭奖励面板
			showBoundAlert() -- 弹绑定才可领取的提示
		end
	end

	-- 奖励图标
	local tbItems = {}
	for i, sReward in ipairs(bindReward) do
		logger:debug("sReward = %s", sReward)
		local itemInfo = {}
		itemInfo.icon, itemInfo.name = ItemUtil.createIconByRewardString(sReward)
		table.insert(tbItems, itemInfo)
	end

	return UIHelper.createRewardDlg(tbItems, callbackGet)
end
