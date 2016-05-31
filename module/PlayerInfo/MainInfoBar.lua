-- FileName: MainInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-14
-- Purpose: 主界面玩家信息面板UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

MainInfoBar = class("MainInfoBar", PlayerInfoBar)

function MainInfoBar:destroy( ... )
	logger:debug("MainInfoBar:destroy")
end
function MainInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/home_information.json")

	local m_fnGetWidget = self.m_fnGetWidget
	local layMain = self.layMain

	-- 面板触摸事件，弹出详情面板
	local layInfo = m_fnGetWidget(layMain, "LAY_INFO")
	layInfo:setTouchEnabled(true)
	layInfo:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playBtnEffect("zhujiemian_top.mp3")

			require "script/module/main/PlayerInfoView"
			local PlayerInfo = PlayerInfoView:new()
			local layPlayerInfo = PlayerInfo:create()
			if (layPlayerInfo) then
				LayerManager.addLayout(layPlayerInfo)
			end
		end
	end)

	-- 战斗力按钮
	local btnFight = m_fnGetWidget(layMain, "BTN_ZHANDOULI_ADD")
	btnFight:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()

			-- UIHelper.showNetworkDlg(nil, function ( ... )
			-- 	LayerManager.removeNetworkDlg()
			-- end, true, gi18n[4210])
			require "script/module/main/MainRaiseFightCtrl"
 			MainRaiseFightCtrl.create()                    
		end
	end)

	self:update()
end

function MainInfoBar:update( ... )
	local m_fnGetWidget = self.m_fnGetWidget
	local layMain = self.layMain

	local strokeColor = ccc3(0x2c, 0x00, 0x00)

	local userInfo = self:updateInfo()

	self:updateAvatarIcon() -- 刷新头像

	local labnLevel = m_fnGetWidget(layMain, "LABN_LVNUM") -- 等级
	labnLevel:setStringValue(userInfo.level)

	local labName = m_fnGetWidget(layMain, "TFD_NAME") -- 昵称
	labName:setText(userInfo.uname)
	UIHelper.labelNewStroke(labName, strokeColor)

	local labnVip = m_fnGetWidget(layMain, "LABN_VIP_NUM") -- VIP
	labnVip:setStringValue(userInfo.vip)

	local imgMax = m_fnGetWidget(layMain, "IMG_MAX")
	local labnExpMem = m_fnGetWidget(layMain, "LABN_EXP_NUM") -- 经验值分子
	local labnExpDomi = m_fnGetWidget(layMain, "LABN_EXP_NUM3") -- 经验值分母
	local loadExp = m_fnGetWidget(layMain, "LOAD_EXP") -- 经验进度条
	self:setExp(loadExp, labnExpMem, labnExpDomi)

	local labBelly = m_fnGetWidget(layMain, "TFD_SILVER_NUM") -- 贝里
	labBelly:setText(UIHelper.getBellyStringAndUnit(userInfo.silver_num))
	UIHelper.labelNewStroke(labBelly, strokeColor)

	local labGold = m_fnGetWidget(layMain, "TFD_GOLD_NUM") -- 金币
	labGold:setText(userInfo.gold_num)
	UIHelper.labelNewStroke(labGold, strokeColor)

	local labPower = m_fnGetWidget(layMain, "TFD_POWER_NUM") -- 体力
	labPower:setText(userInfo.execution .. "/" .. self.m_nPowerMax)
	UIHelper.labelNewStroke(labPower, strokeColor)

	local labStamina = m_fnGetWidget(layMain, "TFD_STAMINA_NUM") -- 耐力
	labStamina:setText(userInfo.stamina .. "/" .. self.m_nStaminaMax)
	UIHelper.labelNewStroke(labStamina, strokeColor)

	UserModel.updateFightValue() -- 刷新战斗力
	local fightNum = UserModel.getFightForceValue()
	local labFightNum = m_fnGetWidget(layMain, "TFD_ZHANDOULI") -- 战斗力
	labFightNum:setText(fightNum)
	UIHelper.labelNewStroke(labFightNum, ccc3(0x19, 0x3b, 0x00))
end

function MainInfoBar:updateAvatarIcon( ... )
	require "db/DB_Heroes"
	require "script/model/utils/HeroUtil"
	local iconPath = HeroUtil.getHeroIconImgByHTID(UserModel.getAvatarHtid())
	local clipNode = HeroUtil.createCircleAvatar(iconPath)
	local imgAvatar = self.m_fnGetWidget(self.layMain, "IMG_PHOTO")
	imgAvatar:addNode(clipNode)
end
