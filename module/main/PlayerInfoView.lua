-- FileName: PlayerInfoView.lua
-- Author: zhangqi
-- Date: 2014-12-25
-- Purpose: 角色信息详情的UI, 从PlayerPanel模块中单独分离出来
--[[TODO List]]

-- module("PlayerInfoView", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_i18n = gi18n
local m_i18nString 	= gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

local dirScheduler = CCDirector:sharedDirector():getScheduler()


PlayerInfoView = class("PlayerInfoView")

function PlayerInfoView:ctor(fnCloseCallback)
	self.layMain = g_fnLoadUI("ui/home_info_frame.json")
	self.m_strInitTime = "00:00:00" -- 默认时间串
	self.m_nPowerSchedule = 0 -- 体力恢复定时器id
	self.m_nStaminaSchedule = 0 -- 耐力恢复定时器id
	self.onClose = fnCloseCallback
end

function PlayerInfoView:stopSchedulerById( nSid )
	if (nSid ~= 0) then
		dirScheduler:unscheduleScriptEntry(nSid)
	end
end

function PlayerInfoView:create( ... )
	self.tbUserInfo = UserModel.getUserInfo()
	local tbUserInfo = self.tbUserInfo

	local layRoot = self.layMain

	-- local i18nTitle = m_fnGetWidget(layRoot, "tfd_info")
	-- i18nTitle:setText(m_i18n[3207])
	-- UIHelper.labelNewStroke( i18nTitle, ccc3(0x4f, 0x14, 0x00))
	-- UIHelper.labelShadow(i18nTitle)

	-- 给关闭和确定按钮添加事件
	local function addEventToBtn( strBtnName )
		local btnClose = m_fnGetWidget(layRoot, strBtnName)
		if (btnClose) then
			btnClose:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					AudioHelper.playCloseEffect()

					self:stopSchedulerById(self.m_nPowerSchedule)
					self:stopSchedulerById(self.m_nStaminaSchedule)
					LayerManager.removeLayout()
				end
			end)
		end
	end
	addEventToBtn("BTN_CLOSE")
	addEventToBtn("BTN_CONFIRM")
	local btnOk = m_fnGetWidget(layRoot, "BTN_CONFIRM")
	UIHelper.titleShadow(btnOk, m_i18n[1029])

	-- 更名按钮事件
	local btnChgName = m_fnGetWidget(layRoot, "BTN_CHANGE_NAME")
	UIHelper.titleShadow(btnChgName, m_i18n[3223])
	btnChgName:setVisible(true) -- 2014-12-25, 临时处理
	if (btnChgName) then
		btnChgName:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playCommonEffect()

				local fnUpdateName = function ( ... )
					return self:updateName()
				end
				require "script/module/main/ChangeNameView"
				local ChangeName = ChangeNameView:new(fnUpdateName)
				ChangeName:create()
			end
		end)
	end

	local function eventChangeAvatar( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			local tbArgs = {}
			tbArgs.updateCallback = function ( ... )
				self:updateHeader() -- 更换头像后的回调刷新详情面板上的头像
			end
			require "script/module/main/MainChangeAvatar"
			MainChangeAvatar.create(tbArgs)
		end
	end

	-- 玩家头像和更换头像按钮
	local btnChange = m_fnGetWidget(layRoot, "BTN_CHANGE_PHOTO")
	UIHelper.titleShadow(btnChange, m_i18n[3222])
	btnChange:addTouchEventListener(eventChangeAvatar)

	-- 玩家头像
	self.m_imgHeader = m_fnGetWidget(layRoot, "IMG_HEAD_FRAME")
	self:loadHeader(self.m_imgHeader)
	local btnPhoto = m_fnGetWidget(layRoot, "BTN_PHOTO_FRAME")
	btnPhoto:addTouchEventListener(eventChangeAvatar)

	-- vip 等级
	local labnVip = m_fnGetWidget(layRoot, "LABN_VIP")
	labnVip:setStringValue(tbUserInfo.vip)

	-- 角色名称
	self.labName = m_fnGetWidget(layRoot, "TFD_NAME")
	self.labName:setText(tbUserInfo.uname)
	UIHelper.labelNewStroke(self.labName, ccc3(0x36, 0x01, 0x63))

	-- 战斗力
	local labnFight = m_fnGetWidget(layRoot, "LABN_ZHANDOULI")
	labnFight:setStringValue(tostring(UserModel.getFightForceValue()))

	-- 提升战斗力按钮
	local btnFight = m_fnGetWidget(layRoot, "BTN_FIGHT_FORCE")
	UIHelper.titleShadow(btnFight, m_i18n[3224])
	btnFight:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			require "script/module/main/MainRaiseFightCtrl"
			MainRaiseFightCtrl.create()
		end
	end)

	-- 角色等级
	local labnLevel = m_fnGetWidget(layRoot, "LABN_LVNUM")
	labnLevel:setStringValue(tbUserInfo.level)

	-- 经验条
	local barExp = m_fnGetWidget(layRoot, "LOAD_EXP")
	local labExp = m_fnGetWidget(barExp, "LABN_EXP_NUM")
	--UIHelper.labelStroke(labExp)
	local labExpDom = m_fnGetWidget(barExp, "LABN_EXP_NUM3")
	--UIHelper.labelStroke(labExpDom)

	self.img_slant  = m_fnGetWidget(layRoot,"img_slant")
	self.img_max = m_fnGetWidget(layRoot,"IMG_MAX")
	self.img_max:setEnabled(false)
	self:setExp(barExp, labExp, labExpDom)

	local szShadow = CCSizeMake(3, -3)
	-- 上阵伙伴
	local i18nHero = m_fnGetWidget(layRoot, "tfd_partner")
	i18nHero:setText(m_i18n[3201])
	-- UIHelper.labelShadowWithText(i18nHero, m_i18n[3201], szShadow)

	local labPartner = m_fnGetWidget(layRoot, "TFD_PARTNER_NUM")
	require "script/module/formation/FormationUtil"
	local hero, allHeros = FormationUtil.getOnFormationAndLimited()
	labPartner:setText(hero .. "/" .. allHeros)
	-- UIHelper.labelShadowWithText(labPartner, hero .. "/" .. allHeros, szShadow)

	-- 金币
	local i18nGold = m_fnGetWidget(layRoot, "tfd_gold")
	i18nGold:setText(m_i18n[2069])
	-- UIHelper.labelShadowWithText(i18nGold, m_i18n[2069], szShadow)
	self.labGold = m_fnGetWidget(layRoot, "TFD_GOLD_NUM")
	self.labGold:setText(tbUserInfo.gold_num)
	-- UIHelper.labelShadowWithText(self.labGold, tbUserInfo.gold_num, szShadow)

	-- 贝里
	local i18nSilver = m_fnGetWidget(layRoot, "tfd_money")
	i18nSilver:setText(m_i18n[1521])
	-- UIHelper.labelShadowWithText(i18nSilver, m_i18n[1521], szShadow)
	local labSilver = m_fnGetWidget(layRoot, "TFD_MONEY_NUM")
	labSilver:setText(UserModel.getSilverNumber() or 0)
	-- UIHelper.labelShadowWithText(labSilver, UserModel.getSilverNumber() or 0, szShadow)

	-- 海魂
	local i18nHunyu = m_fnGetWidget(layRoot, "tfd_hunyu")
	i18nHunyu:setText(m_i18n[2068])
	-- UIHelper.labelShadowWithText(i18nHunyu, m_i18n[2068], szShadow)
	local labJewel = m_fnGetWidget(layRoot, "TFD_HUNYU_NUM")
	labJewel:setText(UserModel.getJewelNum() or 0)
	-- UIHelper.labelShadowWithText(labJewel, UserModel.getJewelNum() or 0, szShadow)

	-- 体力
	self.labDescPowNum = m_fnGetWidget(layRoot, "TFD_POWER_NUM")
	-- UIHelper.labelShadow(self.labDescPowNum, szShadow)
	-- 体力恢复时间
	local i18nPower = m_fnGetWidget(layRoot, "tfd_power_recover")
	i18nPower:setText(m_i18n[3203])
	-- UIHelper.labelShadowWithText(i18nPower, m_i18n[3203], szShadow)
	self.labDescPowTime = m_fnGetWidget(layRoot, "TFD_POWER_RECOVER_NUM")
	-- UIHelper.labelShadow(self.labDescPowTime, szShadow)
	-- 体力全部回满
	local i18nPowerFull = m_fnGetWidget(layRoot, "tfd_power_recover1")
	i18nPowerFull:setText(m_i18n[3204])
	-- UIHelper.labelShadowWithText(i18nPowerFull, m_i18n[3204], szShadow)
	self.labDescPowFull = m_fnGetWidget(layRoot, "TFD_POWER_RECOVER1_NUM")
	-- UIHelper.labelShadow(self.labDescPowFull, szShadow)
	local fnUpdatePower = self:updateTimeFunc(true)
	if (not fnUpdatePower()) then
		self.m_nPowerSchedule = dirScheduler:scheduleScriptFunc(fnUpdatePower, 1, false)
	end

	-- 耐力
	self.labDescStamNum = m_fnGetWidget(layRoot, "TFD_STAMINA_NUM")
	-- UIHelper.labelShadow(self.labDescStamNum, szShadow)
	-- 耐力恢复时间
	local i18nStamina = m_fnGetWidget(layRoot, "tfd_stamina_recover")
	i18nStamina:setText(m_i18n[3205])
	-- UIHelper.labelShadowWithText(i18nStamina, m_i18n[3205], szShadow)
	self.labDescStamTime = m_fnGetWidget(layRoot, "TFD_STAMINA_RECOVER_NUM")
	-- UIHelper.labelShadow(self.labDescStamTime, szShadow)
	-- 耐力全部回满
	local i18nStaminaFull = m_fnGetWidget(layRoot, "tfd_stamina_recover1")
	i18nStaminaFull:setText(m_i18n[3206])
	-- UIHelper.labelShadowWithText(i18nStaminaFull, m_i18n[3206], szShadow)
	self.labDescStamFull = m_fnGetWidget(layRoot, "TFD_STAMINA_RECOVER1_NUM")
	-- UIHelper.labelShadow(self.labDescStamFull, szShadow)
	local fnUpdateStamia = self:updateTimeFunc(false)
	if (not fnUpdateStamia()) then
		self.m_nStaminaSchedule = dirScheduler:scheduleScriptFunc(fnUpdateStamia, 1, false)
	end
	-- zhangqi, 2014-12-23, 优化需求：如果探索功能未开启则隐藏耐力显示
	local layStamina = m_fnGetWidget(layRoot, "LAY_STAMINA")
	layStamina:setEnabled(SwitchModel.getSwitchOpenState(ksSwitchExplore))

	-- + 号按钮，各种金币，贝里获取方式的引导
	-- BTN_GET_GOLD, BTN_GET_BELLY, BTN_GET_SOUL, BTN_GET_POWER, BTN_GET_STAMINA, 
	local plusBtns = { 	{name = "BTN_GET_GOLD", call = function ( ... )
							logger:debug("need recharge gold")
						end},

						{name = "BTN_GET_BELLY", call = function ( ... )
							if(not SwitchModel.getSwitchOpenState(ksSwitchBuyBox,true)) then
								return
							end
							require "script/module/wonderfulActivity/MainWonderfulActCtrl"
							local buyUI = MainWonderfulActCtrl.create(WonderfulActModel.tbShowType.kShowBuyMoney)
							LayerManager.changeModule(buyUI, MainWonderfulActCtrl.moduleName(), {1, 3}, true)
						end},

						{name = "BTN_GET_SOUL", call = function ( ... )
							if (not SwitchModel.getSwitchOpenState( ksSwitchResolve ,true)) then
								return
							end

							require "script/module/resolve/MainResolveCtrl"
							local layResolve = MainResolveCtrl.create()
							if (layResolve) then
								LayerManager.changeModule(layResolve, MainResolveCtrl.moduleName(), {1,3}, true)
								PlayerPanel.addForPublic()
							end
						end},

						{name = "BTN_GET_POWER", call = function ( ... )
							if (not SwitchModel.getSwitchOpenState( ksSwitchBuyBox, true)) then
								return
							end
							
							require "script/module/copy/copyUsePills"
							local dlg = copyUsePills.create()
							copyUsePills.setUpdateCallback(function ( ... )
								self:updateValueFunc(true)
							end, function ( ... )
								self:updateGold()
							end)
							LayerManager.addLayout(dlg)
							copyUsePills.showLackTips(false) -- 隐藏不足提示
						end},

						{name = "BTN_GET_STAMINA", call = function ( ... )
							require "script/module/arena/ArenaBuyCtrl"
							local dlg = ArenaBuyCtrl.createForArena()
							ArenaBuyCtrl.setUpdateCallback(function ( ... )
								self:updateValueFunc(false)
							end, function ( ... )
								self:updateGold()
							end)
							LayerManager.addLayoutNoScale(dlg)
							require "script/module/arena/ArenaBuyView"
							ArenaBuyView.showLackTips(false) -- 隐藏不足提示
						end} 
					  }

	for i, btnItem in ipairs(plusBtns) do
		local btn = m_fnGetWidget(layRoot, btnItem.name)
		btn:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playCommonEffect()
				btnItem.call()
			end
		end)
	end

	-- 关闭UI后执行创建者指定的回调
	UIHelper.registExitAndEnterCall(tolua.cast(layRoot, "CCNode"), function ( ... )
		-- 关闭定时器
		self:stopSchedulerById(self.m_nPowerSchedule)
		self:stopSchedulerById(self.m_nStaminaSchedule)

		if (self.onClose) then
			self.onClose()
		end
	end)

	return layRoot
end

function PlayerInfoView:updateName( ... )
	if (self.labName) then
		self.labName:setText(UserModel.getUserName())
	end
	if (package.loaded["PlayerPanel"]) then
		updateInfoBar() -- 新信息条统一更新方法
	end
end

function PlayerInfoView:updateGold( ... )
	if (self.labGold) then
		self.labGold:setText(UserModel.getGoldNumber())
	end
end

function PlayerInfoView:updateValueFunc( bExec )
	local nCurVal = bExec and tonumber(self.tbUserInfo.execution) or tonumber(self.tbUserInfo.stamina)
	local nMax = bExec and g_maxEnergyNum or UserModel.getMaxStaminaNumber()
	local labNum = bExec and self.labDescPowNum or self.labDescStamNum
	labNum:setText((nCurVal or 0) .. "/" .. nMax) -- 设置比值
end

--[[desc: 返回刷新体力或耐力恢复时间的函数
    bExec: true, 刷新体力；false, 刷新耐力
    return: 一个function  
—]]
function PlayerInfoView:updateTimeFunc( bExec )
	return function ( ... )
		local nNow = BTUtil:getSvrTimeInterval() -- 当前服务器时间戳

		local nCurVal = bExec and tonumber(self.tbUserInfo.execution) or tonumber(self.tbUserInfo.stamina)
		logger:debug("PlayerInfoView-updateTimeFunc-nCurVal = " .. nCurVal)
		local nLastTime = bExec and self.tbUserInfo.execution_time or self.tbUserInfo.stamina_time -- 服务器端上次恢复的时间
		local nSPP = bExec and g_energyTime or g_stainTime -- 恢复 1 点的秒数, seconds per point
		local nMax = bExec and g_maxEnergyNum or UserModel.getMaxStaminaNumber()
		local nFullRemain = (nMax - nCurVal) * nSPP -- 恢复满的剩余时间

		local labTime = bExec and self.labDescPowTime or self.labDescStamTime
		local labFull = bExec and self.labDescPowFull or self.labDescStamFull
		local labNum = bExec and self.labDescPowNum or self.labDescStamNum

		local function stopPower( ... )
			self:stopSchedulerById(self.m_nPowerSchedule)
		end
		local function stopStamina( ... )
			self:stopSchedulerById(self.m_nStaminaSchedule)
		end
		local fnStop = bExec and stopPower or stopStamina

		local strFullRemain, bExpire = TimeUtil.expireTimeString(nLastTime, nFullRemain)
		labFull:setText(strFullRemain) -- 设置恢复满时间
		labNum:setText((nCurVal or 0) .. "/" .. nMax) -- 设置比值

		local function updateValue( ... )
			local passTime = nNow - nLastTime
			local addVal = math.floor(passTime/nSPP)
			logger:debug("PlayerInfoView:updateTimeFunc:updateValue: nCurVal = " .. nCurVal .. " addVal = " .. addVal)
			if (nCurVal < nMax) then
				labNum:setText((nCurVal or 0) + addVal .. "/" .. nMax) -- 设置比值
			end
		end
		updateValue()

		if (bExpire) then -- 到期取消定时器
			labTime:setText(self.m_strInitTime)
			fnStop()
			return bExpire
		else
			local nLeftTime = (nNow - nLastTime)%nSPP
			local strTime = TimeUtil.expireTimeString(nSPP - nLeftTime + nNow)
			labTime:setText(strTime)
		end

		return bExpire
	end
end

function PlayerInfoView:setExp( barWidget, labMem, labDomi )
	require "db/DB_Level_up_exp"
	local tUpExp = DB_Level_up_exp.getDataById(2)
	local nLevelUpExp = tUpExp["lv_"..(tonumber(self.tbUserInfo.level)+1)] -- 下一等级需要的经验值
	local nExpNum = tonumber(self.tbUserInfo.exp_num) -- 当前的经验值

	if(labMem) then
		labMem:setStringValue(nExpNum)
		labDomi:setStringValue(nLevelUpExp)
	end

	local nPercent = intPercent(nExpNum, nLevelUpExp)
	barWidget:setPercent((nPercent > 100) and 100 or nPercent)


	-- 如果等级达到顶级之后则  --zhangjunwu
	local userLevel = UserModel.getUserInfo().level
	local maxUserLevel = UserModel.getUserMaxLevel()

	if(tonumber(userLevel) >= maxUserLevel) then
		labMem:setEnabled(false)
		labDomi:setEnabled(false)
		self.img_slant:setEnabled(false)

		self.img_max:setEnabled(true)
		barWidget:setPercent(100)
	end
end

function PlayerInfoView:loadHeader( imgWidget )
	if (imgWidget) then
		require "db/DB_Heroes"
		require "script/model/utils/HeroUtil"
		local iconPath = HeroUtil.getHeroIconImgByHTID(UserModel.getAvatarHtid())
		local clipNode = HeroUtil.createCircleAvatar(iconPath, 1.19)
		imgWidget:addNode(clipNode)
	end
end

function PlayerInfoView:updateHeader( ... )
	self:loadHeader(self.m_imgHeader)
end