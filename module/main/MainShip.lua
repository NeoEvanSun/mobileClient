-- FileName: MainShip.lua
-- Author: zhangqi
-- Date: 2014-03-25
-- Purpose: 主页显示的主船模块，包括二级菜单按钮和各种活动按钮

module("MainShip", package.seeall)

require "script/GlobalVars"
require "script/utils/LuaUtil"
require "script/module/public/ShowNotice"

-- UI控件引用变量 --
local widgetRoot = nil -- 主背景UI的根层容器
local widgetMenu -- 二级菜单UI的根层容器

--二级菜单
local layMask  -- "LAY_MASK", 屏蔽下层触摸的层容器
local btnEnter -- "BTN_ENTER", 二级菜单激活按钮
local imgCircle -- "IMG_CIRCLE", 所有二级按钮的父级图片
-- local btnMenu -- "BTN_MENU", 菜单按钮
-- local btnZhanBu -- "BTN_ZHANBU", 占卜按钮
-- local btnRestaurant -- "BTN_RESTAURANT", 宴会厅按钮
-- local btnResolve -- "BTN_RESOLVE", 分解室按钮
-- local btnFriend -- "BTN_FRIEND", 好友按钮

--主背景
-- local layBottomMenu -- "LAY_BTN_BOTTOM", 底部按钮容器
-- local btnHero -- "BTN_HERO", 伙伴按钮
-- local btnEquip -- "BTN_EQUIP", 装备按钮
-- local btnPirate -- "BTN_HAIZEITUAN", 海贼团按钮
-- local btnChat -- "BTN_CHAT", 聊天按钮

-- local btnMail -- 邮件按钮
local btnWondAct --精彩活动按钮
local IMG_TIP_ACT -- 精彩活动按钮上红点
local m_imgTipPartner -- 伙伴按钮上的红点
local m_ArmTipPartner --伙伴按钮上的动画
local m_imgTipEquip -- 装备按钮上的红点
-- local m_imgTipSign -- 签到按钮上的红点
local m_IMG_TIP_UNION -- 联盟按钮上的红点
local BTN_REWARD_CENTER -- 奖励中心按钮
-- local IMG_TIP_SERVER 	-- 开服礼包上的红点
local m_btnNewSvr --开服礼包按钮
local m_BtnTask --  每日任务按钮
local m_btnRegist -- 绑定礼包按钮


-- local IMG_TIP_ASTROLOGY --占卜屋上的红点
local btnLevelReward 	-- 等级礼包按钮
local btnSigns -- 签到按钮
local tbLayHolder = {"LAY_BTN_TOP_1", "LAY_BTN_TOP_2", "LAY_BTN_TOP_3"} -- 活动按钮占位容器

local m_layBoatTip -- 主船叹号提示的占位层容器
local m_layBoatTouch -- 触摸可弹出二级菜单的层容器


-- 模块局部变量 --
local jsonMain = "ui/home_main.json"
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n
local m_i18nString = gi18nString
local m_config = Platform.getConfig()

local m_updateTimeScheduler 		-- menghao 更新背景图片位置线程
local m_updateOnlineTimeScheduler 	-- menghao 更新在线奖励时间线程

-- zhangqi, 2014-12-30, 记录是否显示船头上的叹号提示
--（占卜屋和好友有红点提示时各做一次处理，zb = true, fd = true, 反之为false）
local m_boatTipFlag

local tbRedPoint = {} -- 存放有红点动画的 红点动画


local tbSecondButton = nil  --用于二级菜单
local tbSecondPos = nil --用于二级菜单


-- 模块局部函数 --




--二级菜单按钮事件
local function onSecondEnter(sender, eventType)
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()
		local wgBtn = tolua.cast(sender, "Widget")
		logger:debug(wgBtn:getName() .. " on touched2")
	end
end
--统一给二级菜单按钮添加事件的方法
local fnAddEventToCircleBtn = function ()
	if (imgCircle) then
		local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
		for btn in array_iter(imgCloud:getChildren()) do
			local wgBtn = tolua.cast(btn, "Button")
			logger:debug("btn.name : " .. wgBtn:getName())
			if(wgBtn:getName() == "BTN_RESOLVE")then
				wgBtn:addTouchEventListener(onResolve)
			elseif(wgBtn:getName() == "BTN_FRIEND")then
				wgBtn:addTouchEventListener(onToFriends)
			elseif(wgBtn:getName() == "BTN_RESTAURANT")then
				wgBtn:addTouchEventListener(onRestarant)
			elseif(wgBtn:getName() == "BTN_ZHANBU")then
				wgBtn:addTouchEventListener(onAstrology)
			elseif(wgBtn:getName() == "BTN_MAIL")then
				wgBtn:addTouchEventListener(onMail)
			elseif(wgBtn:getName() == "BTN_MENU")then
				wgBtn:addTouchEventListener(onConfig)
			else
				wgBtn:addTouchEventListener(onSecondEnter)
			end

			wgBtn:setTouchEnabled(true) -- 初始时禁用二级按钮
		end
	end
end
--激活二级菜单按钮事件
local function onMainEnter(sender, eventType)

	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playBtnEffect("zhuchuan.mp3")

		--------------------------- new guide begin ---------------------------
		require "script/module/guide/GuideModel"
		require "script/module/guide/GuideDecomView"
		if (GuideModel.getGuideClass() == ksGuideResolve and GuideDecomView.guideStep == 1) then
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createDecomGuide(2)
		end

		require "script/module/guide/GuideAstrologyView"
		if (GuideModel.getGuideClass() == ksGuideAstrology and GuideAstrologyView.guideStep == 1) then
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createAstrologyGuide(2)
		end

		require "script/module/guide/GuideRebornView"
		if (GuideModel.getGuideClass() == ksGuideReborn  and GuideRebornView.guideStep == 1) then
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createRebornGuide(2)
		end

		--------------------------- new guide end ---------------------------------
		logger:debug("onMainEnter trigger 1")
		logger:debug("imgCircle type " .. type(imgCircle))

		if (imgCircle) then
			logger:debug("circle found")
			local bEnable = not imgCircle:isEnabled()
			-- imgCircle:setEnabled(bEnable)

			if(bEnable)then
				secondMenuLayerOpen()
			else
				secondMenuLayerClose()
			end

			layMask:setTouchEnabled(bEnable)
			-- zhangqi, 2014-08-28, 打开二级菜单后，点击除信息面板和主菜单之外区域都会关闭二级菜单
			local ship = m_fnGetWidget(widgetRoot, "LAY_SHIP")
			ship:setTouchEnabled(bEnable)
			if (bEnable) then
				ship:addTouchEventListener(function ( sender, eventType )
					if (eventType == TOUCH_EVENT_ENDED) then
						AudioHelper.playCloseEffect()
						secondMenuLayerClose()
						-- imgCircle:setEnabled(false)
						layMask:setTouchEnabled(false)
						ship:setTouchEnabled(false)
					end
				end)
			end
		end
	end
end

-- 主背景按钮事件 --
-- 伙伴
local function onHero( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()
		logger:debug("btn.name : " .. sender:getName())
		-- LayerManager.addLoading()
		require "script/module/partner/MainPartner"
		local layPartner = MainPartner.create()
		if (layPartner) then
			logger:debug("layPartner not nil")
			LayerManager.changeModule(layPartner, MainPartner.moduleName(), {1, 3}, true)
			PlayerPanel.addForPublic()
		end
	end
end
-- 装备
local function onEquip( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()

		logger:debug("btn.name : " .. sender:getName())
		-- LayerManager.addLoading()
		require "script/module/equipment/MainEquipmentCtrl"
		local layEquipment = MainEquipmentCtrl.create()
		if layEquipment then
			LayerManager.changeModule(layEquipment, MainEquipmentCtrl.moduleName(), {1, 3}, true)
			PlayerPanel.addForPublic()
		end
	end
end
-- 联盟按钮事件
local function onPirate( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then

		-- ShowNotice.showShellInfo(m_i18n[1366])
		AudioHelper.playMainUIEffect()
		if (not SwitchModel.getSwitchOpenState(ksSwitchGuild,true)) then
			return
		end
		require "script/module/guild/GuildDataModel"
		require "script/module/guild/MainGuildCtrl"
		MainGuildCtrl.create()
	end
end
-- 聊天
local function onChat( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()

		logger:debug("btn.name : " .. sender:getName())
		require "script/module/chat/ChatCtrl"
		local layChat = ChatCtrl.create()
	end
end
--签到
-- function onSign( sender, eventType )
-- 	if (eventType == TOUCH_EVENT_ENDED) then
-- 		AudioHelper.playMainUIEffect()

-- 		if (not SwitchModel.getSwitchOpenState(ksSwitchSignIn,true)) then
-- 			return
-- 		end
-- 		require "script/module/registration/MainRegistrationCtrl"
-- 		local laySign = MainRegistrationCtrl.resetView()
-- 	end
-- end
--每日任务
function onDailyTask(sender,eventType)
	if(eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()
		if (not SwitchModel.getSwitchOpenState(ksSwitchEveryDayTask,true)) then
			return
		end
		require "script/module/achieve/MainAchieveCtrl"
		MainAchieveCtrl.create()
	end
end
--邮件
function onMail( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()

		logger:debug("btn.name : " .. sender:getName())
		require "script/module/mail/MainMailCtrl"
		local layMail = MainMailCtrl.create()
		LayerManager.changeModule(layMail, MainMailCtrl.moduleName(), {1, 3},true)

		--点击邮件后则取消红点
		g_redPoint.newMail.visible = false
	end
end
--开服礼包 zhangjunwu 2014-11-25
-- function onAccReward(sender,eventType)
-- 	if(eventType == TOUCH_EVENT_ENDED) then
-- 		AudioHelper.playMainUIEffect()
-- 		require "script/module/accSignReward/MainAccSignCtrl"
-- 		--MainAccSignCtrl.create()
-- 		MainAccSignCtrl.create()
-- 	end
-- end

--分解屋
function onResolve( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()
		logger:debug(sender)
		require "script/module/resolve/MainResolveCtrl"
		local canEnter = SwitchModel.getSwitchOpenState( ksSwitchResolve ,true)
		logger:debug(canEnter)
		if (canEnter )then
			local layResolve = MainResolveCtrl.create()
			if (layResolve) then
				LayerManager.changeModule(layResolve, MainResolveCtrl.moduleName(), {1,3}, true)
				PlayerPanel.addForPublic()
			end
		end
	end
end
-- 宴会大厅
function onRestarant( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()
		ShowNotice.showShellInfo(m_i18n[1366])
	end
end
--占卜屋
function onAstrology( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()

		logger:debug(sender)
		require "script/module/astrology/MainAstrologyModel"

		local canEnter = SwitchModel.getSwitchOpenState( ksSwitchStar ,true)
		logger:debug(canEnter)
		if( canEnter ) then
			--从后端读取数据然后初始化界面
			MainAstrologyModel.createViewByGetAstrologyInfo()
		end
	end
end

function onLevelReward( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()
		require "script/module/levelReward/LevelRewardCtrl"
		LevelRewardCtrl.create()
	end
end

function onConfig( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()

		require "script/module/config/ConfigMainCtrl"
		local layConfig = ConfigMainCtrl.create()
		LayerManager.addLayout(layConfig)
	end
end

-- menghao 领取等级礼包后
function fnSetBtnLevel( ... )
	require "script/module/levelReward/LevelRewardCtrl"
	local btnLevel = m_fnGetWidget(widgetRoot, "BTN_LEVEL_REWARD")
	btnLevel:setEnabled(false)
	-- 等级礼包功能已开启且没有领取完
	if (SwitchModel.getSwitchOpenState(ksSwitchLevelGift, false)) then
		local rewardInfo = LevelRewardCtrl.getCurRewardInfo()
		if (rewardInfo) then
			btnLevel:setEnabled(true)

			local imgTipLevel = m_fnGetWidget(widgetRoot, "IMG_TIP_LEVEL")
			imgTipLevel:removeAllNodes()
			if (rewardInfo.status == 1) then
				imgTipLevel:addNode(UIHelper.createRedTipAnimination())
			end
		end
	end
end


-- zhangqi, 2014-08-08, 刷新伙伴和装备按钮的红点
function updateBagPoint( sBtnName ) -- "BTN_HERO", "BTN_EQUIP"
	if (widgetRoot) then
		if (sBtnName == "BTN_HERO") then
			local partner = g_redPoint.partner.getvisible()

			if (m_ArmTipPartner==nil and partner==1) then
				m_ArmTipPartner = UIHelper.createArmatureNode({
					filePath = "images/effect/newhero/new.ExportJson",
					animationName = "new",
				})
				m_ArmTipPartner:setAnchorPoint(ccp(0.2,-0.3))
				local btn=m_fnGetWidget(widgetRoot,"BTN_HERO")
				btn:addNode(m_ArmTipPartner)
			else
				if m_ArmTipPartner then
					m_ArmTipPartner:removeFromParentAndCleanup(true)
					m_ArmTipPartner=nil
				end
			end

			require "script/module/partner/HeroSortUtil"
			if (partner~=1 and HeroSortUtil.getFuseSoulNum() > 0) then
				m_imgTipPartner:removeAllNodes()
				m_imgTipPartner:addNode(UIHelper.createRedTipAnimination())
			else
				m_imgTipPartner:removeAllNodes()
			end

		else
			require "script/model/utils/EquipFragmentHelper"
			--m_imgTipEquip:setVisible(g_redPoint.equip.visible or EquipFragmentHelper.getCanFuseNum() > 0)
			if (g_redPoint.equip.visible or EquipFragmentHelper.getCanFuseNum() > 0) then
				m_imgTipEquip:removeAllNodes()
				m_imgTipEquip:addNode(UIHelper.createRedTipAnimination())
			else
				m_imgTipEquip:removeAllNodes()
			end
			logger:debug("g_redPoint.equip.visible = %s", tostring(g_redPoint.equip.visible))
			logger:debug("EquipFragmentHelper.getCanFuseNum() = %d", EquipFragmentHelper.getCanFuseNum())
		end
end
end

--加入波纹效果
local function buttonRippleAnimation( )
	local rewardCenter = UIHelper.createArmatureNode({
		filePath =  "images/main/bowen/bowen.ExportJson",
		animationName = "bowen",
		loop = 1,
		fnMovementCall = nil,
	})
	return rewardCenter
end
--统一添加主背景按钮事件的方法
local fnAddEventToButtons = function ( ... )
	local tbBtnName = {"BTN_MAIL", "BTN_HERO", "BTN_EQUIP","BTN_HAIZEITUAN", "BTN_CHAT",
		"BTN_JINGCAI_ACT","BTN_REWARD_CENTER","BTN_DAYTASK","BTN_TRAIN",
	}
	local tbEvents = {onMail, onHero, onEquip, onPirate, onChat,
		onWonderfulActivity,onRewardCenter,onDailyTask,onDestiny
	}

	for i, v in ipairs(tbBtnName) do

		local btn = m_fnGetWidget(widgetRoot, v)

		if (btn) then
			btn:addTouchEventListener(tbEvents[i])
		end
	end

	btnWondAct = m_fnGetWidget(widgetRoot, "BTN_JINGCAI_ACT")
	IMG_TIP_ACT = m_fnGetWidget(btnWondAct, "IMG_TIP_ACT") --取到红圈
	BTN_REWARD_CENTER = m_fnGetWidget(widgetRoot, "BTN_REWARD_CENTER")

	m_BtnTask = m_fnGetWidget(widgetRoot, "BTN_DAYTASK")
	m_imgTipPartner     = m_fnGetWidget(widgetRoot,"IMG_TIP_PARTNER")
	m_imgTipEquip 	  = m_fnGetWidget(widgetRoot,"IMG_TIP_EQUIP")
	-- m_imgTipSign        = m_fnGetWidget(widgetRoot,"IMG_SIGN_TIP")
	m_IMG_TIP_UNION    = m_fnGetWidget(widgetRoot, "IMG_TIP_UNION")
	-- m_IMG_TIP_SERVER   = m_fnGetWidget(widgetRoot,"IMG_TIP_SERVER")   --开服礼包红点
	-- m_btnNewSvr   = m_fnGetWidget(widgetRoot,"BTN_SERVER_REWARD")


	-- zhangqi, 2014-12-17, 最游戏账号绑定礼包按钮
	if (Platform.isPlatform()) then
		m_btnRegist = m_fnGetWidget(widgetRoot, "BTN_REGIST_REWARD")
		local mConfig = Platform.getConfig()
		if (mConfig.getFlag() == "zyxphone" and not mConfig.gotBindReward()) then -- 如果是最游戏平台且没有领取过绑定领礼包
			local refPoint = m_fnGetWidget(m_btnRegist, "IMG_TIP_REGIST")
			refPoint:addNode(UIHelper.createRedTipAnimination())
			m_btnRegist:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					require "script/module/login/MainBoundGiftCtrl"
					LayerManager.addLayout(MainBoundGiftCtrl.create())
				end
			end)
		else
			if (Platform.isDebug()) then
				m_btnRegist:addTouchEventListener(function ( sender, eventType )
					if (eventType == TOUCH_EVENT_ENDED) then
						AudioHelper.playCommonEffect()
						-- zhangqi, 2015-03-02, 弹出接渠道SDK测试用的充值面板
						require "script/module/shop/RechargeView"
						local dlg = RechargeView:new()
						dlg:create()
					end
				end)
			else
				m_btnRegist:removeFromParentAndCleanup(true)
			end
		end
	end
end

--addBy wangming 20150122
--[[desc:判断是否有签到的红点
    arg1: 参数说明
    return: 是否有返回值，返回值说明  
—]]
local function fnCheckRegistrationTip( ... )
	require "script/model/DataCache"
	local signInfo = DataCache.getNorSignCurInfo()
	if(not signInfo) then
		return false
	end
	if(tonumber(signInfo.sign_num) > tonumber(signInfo.reward_num)) then
		return true
	end
	require "script/module/registration/MainRegistrationCtrl"
	local pReward = MainRegistrationCtrl.fnGetTodayReward()
	if(not pReward ) then
		return false
	end
	local pBei = tonumber(pReward[4]) or 0
	if(pBei <= 0) then
		return false
	end
	local pLast = tonumber(signInfo.last_vip) or 0
	local pL = tonumber(pReward[3]) or 0
	local mVip =  tonumber(UserModel.getVipLevel()) or 0
	local isGetVip = pL <= pLast and pL <= mVip
	if(not isGetVip) then
		return true
	end
	return false
end

function checkTipOnBtn(  )
	if (widgetRoot and LayerManager.curModuleName() == moduleName()) then
		-- local function updateSignRedPoint(  ) --每日签到
		-- 	if(fnCheckRegistrationTip()) then
		-- 		if tbRedPoint.sign == nil then
		-- 			tbRedPoint.sign = UIHelper.createRedTipAnimination()
		-- 			m_imgTipSign:addNode(tbRedPoint.sign)
		-- 		end
		-- 	else
		-- 		if tbRedPoint.sign ~= nil then
		-- 			tbRedPoint.sign:removeFromParentAndCleanup(true)
		-- 			tbRedPoint.sign = nil
		-- 		end
		-- 	end
		-- end

		local function updateGuildRedPoint( ) -- 联盟
			require "script/module/guild/GuildUtil"
			if (GuildUtil.isShowTip()==true) then
				if tbRedPoint.guild == nil then
					tbRedPoint.guild = UIHelper.createRedTipAnimination()
					m_IMG_TIP_UNION:addNode(tbRedPoint.guild)
				end
			else
				if tbRedPoint.guild ~= nil then
					tbRedPoint.guild:removeFromParentAndCleanup(true)
					tbRedPoint.guild = nil
				end
			end
		end

		local function updateWonderfulActRedPoint(  ) -- 精彩活动
			require "script/module/wonderfulActivity/WonderfulActModel"
			local bVis = WonderfulActModel.hasTipInActive()
			if tbRedPoint.wonderful == nil then
				if bVis then
					tbRedPoint.wonderful = UIHelper.createRedTipAnimination()
					IMG_TIP_ACT:addNode(tbRedPoint.wonderful)
				end
			else
				if not bVis then
					tbRedPoint.wonderful:removeFromParentAndCleanup(true)
					tbRedPoint.wonderful = nil
				end
			end
		end

		-- updateSignRedPoint()
		updateGuildRedPoint()
		updateWonderfulActRedPoint()

		require "script/module/rewardCenter/RewardCenterModel" --奖励中心
		if DataCache.getRewardCenterStatus() and BTN_REWARD_CENTER then
			BTN_REWARD_CENTER:setEnabled(true)
			if tbRedPoint.rewardCenter == nil then
				tbRedPoint.rewardCenter = buttonRippleAnimation()
				BTN_REWARD_CENTER:addNode(tbRedPoint.rewardCenter)
			end
		elseif(RewardCenterModel.getRewardCount()<=0 and BTN_REWARD_CENTER) then --奖励中心
			BTN_REWARD_CENTER:setEnabled(false)
		else
			if BTN_REWARD_CENTER then
				BTN_REWARD_CENTER:setEnabled(true)
				if tbRedPoint.rewardCenter == nil then
					tbRedPoint.rewardCenter = buttonRippleAnimation()
					BTN_REWARD_CENTER:addNode(tbRedPoint.rewardCenter)
				end
			end
		end

		local function updateAchieveTaskRedPonit(  ) --  检测 每日任务 上的小红点
			require "script/module/achieve/AchieveModel"
			require "script/module/dailyTask/MainDailyTaskData"
			if tbRedPoint.taskPoint == nil then
				if AchieveModel.getTotalUnRewardNum() ~= 0
					or tonumber(MainDailyTaskData.getRewardAbleNum()) ~= 0 then
					local IMG_TIP_LEVEL = m_fnGetWidget(m_BtnTask, "IMG_TIP_LEVEL") --
					tbRedPoint.taskPoint = UIHelper.createRedTipAnimination()
					IMG_TIP_LEVEL:addNode(tbRedPoint.taskPoint)
				end
			else
				if AchieveModel.getTotalUnRewardNum() == 0
					and tonumber(MainDailyTaskData.getRewardAbleNum()) == 0 then
					tbRedPoint.taskPoint:removeFromParentAndCleanup(true)
					tbRedPoint.taskPoint = nil
				end
			end
		end
		updateAchieveTaskRedPonit()
	end
end

--奖励中心
function onRewardCenter(sender,eventType)
	if(eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()
		require "script/module/rewardCenter/MainRewardCenterCtrl"
		MainRewardCenterCtrl.create()
	end
end


--好友
function onToFriends(sender,eventType)
	if(eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainMenuBtn()
		require "script/module/friends/MainFdsCtrl"
		LayerManager.changeModule(MainFdsCtrl.create(), MainFdsCtrl.moduleName(), {1, 3}, true)
		PlayerPanel.addForActivity()
	end
end

-- 精彩活动
function onWonderfulActivity( sender,eventType )
	if(eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()
		require "script/module/wonderfulActivity/MainWonderfulActCtrl"
		local act = MainWonderfulActCtrl.create()
		LayerManager.changeModule(act, MainWonderfulActCtrl.moduleName(), {1,3},true)
	end
end

--线上活动按钮事件
local function onActivity( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playMainUIEffect()

		local wgBtn = tolua.cast(sender, "Widget")
		logger:debug(wgBtn:getName() .. " on touched")
	end
end
--统一给活动按钮添加事件的方法
local fnAddEventToActivityBtn = function ()
	for _, v in ipairs(tbLayHolder) do
		logger:debug("layHolder: " .. v)
	end
end

-- 控制台
local function createCmdBtn( parent )
	local btn = Button:create()
	btn:loadTextureNormal("images/common/new_four.png")

	local ship = m_fnGetWidget(widgetRoot, "LAY_SHIP")
	local shipSize = ship:getSize()

	btn:setPosition(ccp(shipSize.width - btn:getSize().width/2, shipSize.height/2 - 70))

	btn:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			local totalMem = collectgarbage("count")
			logger:debug("totalMem = " .. totalMem/1024 .. " MB")

			local cmdBtn = ship:getChildByTag(99999)
			local cmdEdit = ship:getNodeByTag(99998)
			if (cmdBtn and cmdEdit) then
				logger:debug(" cmdEdit exist, remove")
				ship:removeChildByTag(99999, true)
				ship:removeNodeByTag(99998)
			else
				logger:debug("create cmdEdit")
				require "script/consoleExe/ConsolePirate"
				ConsolePirate.create(ship)
			end
		end
	end)
	logger:debug("create cmdBtn end")
	ship:addChild(btn)
end

-- menghao 背景图片滚动
local function createBackground( ... )
	local layRoot = m_fnGetWidget(widgetRoot, "LAY_ROOT")

	local imgWave1 = m_fnGetWidget(widgetRoot, "IMG_WAVE1")
	local imgWave2 = m_fnGetWidget(widgetRoot, "IMG_WAVE2")
	local imgCloud1 = m_fnGetWidget(widgetRoot, "IMG_CLOUD1")
	local imgCloud2 = m_fnGetWidget(widgetRoot, "IMG_CLOUD2")
	local imgIsland = m_fnGetWidget(widgetRoot, "IMG_ISLAND")

	---[[
	local imgWaveCopy2 = imgWave1:clone()
	layRoot:addChild(imgWaveCopy2)

	local imgWaveCopy = imgWave2:clone()
	layRoot:addChild(imgWaveCopy)

	local imgCloud1Copy = imgCloud1:clone()
	layRoot:addChild(imgCloud1Copy)

	local imgCloud2Copy = imgCloud2:clone()
	layRoot:addChild(imgCloud2Copy)

	local imgIslandCopy = imgIsland:clone()
	layRoot:addChild(imgIslandCopy)
	--]]
	local posXWave = imgWave2:getPositionX()
	local posXWave2 = imgWave1:getPositionX()
	local posXCloud1 = imgCloud1:getPositionX()
	local posXCloud2 = imgCloud2:getPositionX()
	local posXIsland = imgIsland:getPositionX()
	local function updateUI( ... )
		imgWave2:setPositionX(imgWave2:getPositionX() - 0.6)
		imgWaveCopy:setPositionX(imgWave2:getPositionX() + imgWave2:getSize().width - 2)

		imgWave1:setPositionX(imgWave1:getPositionX() + 0.7)
		imgWaveCopy2:setPositionX(imgWave1:getPositionX() - imgWave1:getSize().width + 2)

		imgCloud1:setPositionX(imgCloud1:getPositionX() + 0.4)
		imgCloud1Copy:setPositionX(imgCloud1:getPositionX() - imgCloud1:getSize().width + 2)

		imgCloud2:setPositionX(imgCloud2:getPositionX() + 0.2)
		imgCloud2Copy:setPositionX(imgCloud2:getPositionX() - imgCloud2:getSize().width + 2)

		imgIsland:setPositionX(imgIsland:getPositionX() + 0.55)
		imgIslandCopy:setPositionX(imgIsland:getPositionX() - imgIsland:getSize().width + 2)

		if imgWave2:getPositionX() < posXWave - imgWave2:getSize().width then
			imgWave2:setPositionX(posXWave)
			imgWaveCopy:setPositionX(posXWave + imgWave2:getSize().width - 2)
		end
		if imgWave1:getPositionX() > posXWave + imgWave1:getSize().width then
			imgWave1:setPositionX(posXWave2)
			imgWaveCopy2:setPositionX(posXWave2 - imgWave1:getSize().width + 2)
		end
		if imgCloud1:getPositionX() > posXCloud1 + imgCloud1:getSize().width then
			imgCloud1:setPositionX(posXCloud1)
			imgCloud1Copy:setPositionX(posXCloud1 - imgCloud1:getSize().width + 2)
		end
		if imgCloud2:getPositionX() > posXCloud2 + imgCloud2:getSize().width then
			imgCloud2:setPositionX(posXCloud2)
			imgCloud2Copy:setPositionX(posXCloud2 - imgCloud2:getSize().width + 2)
		end
		if imgIsland:getPositionX() > posXIsland + imgIsland:getSize().width then
			imgIsland:setPositionX(posXIsland)
			imgIslandCopy:setPositionX(posXIsland - imgIsland:getSize().width + 2)
		end
	end

	-- 启动scheduler
	local function startScheduler()
		if(m_updateTimeScheduler == nil) then
			m_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateUI, 0, false)
		end
	end

	-- 停止scheduler
	local function stopScheduler()
		if(m_updateTimeScheduler)then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_updateTimeScheduler)
			m_updateTimeScheduler = nil
		end
	end

	UIHelper.registExitAndEnterCall(layRoot, stopScheduler, startScheduler)

	--[[
	local function runRepeatAction( node, duration)
		local pos = ccp(node:getPositionX(), node:getPositionY())
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(
			CCMoveBy:create(duration, ccp(node:getSize().width, 0)),
			CCPlace:create(pos)
		))
		node:runAction(action)
	end

	runRepeatAction(imgWave2, 30)
	runRepeatAction(imgCloud1, 30)
	runRepeatAction(imgCloud2, 20)

	runRepeatAction(imgWaveCopy, 30)
	runRepeatAction(imgCloud1Copy, 30)
	runRepeatAction(imgCloud2Copy, 20)
	--]]
end

-- 初始函数，加载UI资源文件
function init( ... )
	IMG_TIP_ACT = nil
	m_imgTipPartner = nil
	m_ArmTipPartner =nil
	m_imgTipEquip = nil
	-- m_imgTipSign = nil
	m_IMG_TIP_UNION = nil
	BTN_REWARD_CENTER = nil
	widgetRoot = nil
	tbRedPoint = {}
	m_boatTipFlag = {zb = false, fd = false}

	tbSecondButton = nil
	tbSecondPos = nil
end

-- 析构函数，释放纹理资源
function destroy( ... )
	GlobalScheduler.removeCallback("checkTipOnBtn")
	init()
	package.loaded["MainShip"] = nil
	logger:debug("MainShip destroy")
end


function updateOnlineTime( ... )
	require "script/module/onlineReward/OnlineRewardCtrl"
	if (OnlineRewardCtrl.getFutureTime() == 0) then -- 全部领取完了
		stopOnlineScheduler()
		return
	end

	local btnOnline = m_fnGetWidget(widgetRoot, "BTN_ONLINE_REWARD")
	local imgRecieve = m_fnGetWidget(widgetRoot, "IMG_CAN_RECIEVE")
	local tfdOnlineTime = m_fnGetWidget(widgetRoot, "TFD_ONLINE_TIME")

	local layTop = m_fnGetWidget(widgetRoot, "LAY_BTN_TOP")


	local leftTime = OnlineRewardCtrl.getFutureTime() - BTUtil:getSvrTimeInterval()
	if (leftTime < 0) then
		if (layTop:getNodeByTag(333)) then

		else
			local armatureClock = UIHelper.createArmatureNode({
				filePath = "images/effect/onlineReward/clock.ExportJson",
				animationName = "clock",
			})
			local posX, posY = btnOnline:getPosition()
			armatureClock:setPosition(ccp(posX, posY))
			layTop:addNode(armatureClock, 3, 333)

			logger:debug("armatureClock")

			btnOnline:setVisible(false)
			imgRecieve:setEnabled(true)

			local armatureRecieve = UIHelper.createArmatureNode({
				filePath = "images/effect/onlineReward/recieve.ExportJson",
				animationName = "recieve",
			})
			imgRecieve:addNode(armatureRecieve)
		end
	else
		if (layTop:getNodeByTag(333)) then
			layTop:removeNodeByTag(333)
		end
		imgRecieve:removeAllNodes()

		btnOnline:setVisible(true)
		imgRecieve:setEnabled(false)

		tfdOnlineTime:setText(TimeUtil.getTimeString(leftTime))
	end
end


-- 启动scheduler
function startOnlineScheduler()
	if(m_updateOnlineTimeScheduler == nil and widgetRoot) then
		m_updateOnlineTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateOnlineTime, 1, false)
	end
end


-- 停止scheduler
function stopOnlineScheduler()
	if(m_updateOnlineTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_updateOnlineTimeScheduler)
		m_updateOnlineTimeScheduler = nil
	end
end

-- menghao 0829 处理在线礼包按钮
function fnSetBtnOnline()
	require "script/module/onlineReward/OnlineRewardCtrl"
	OnlineRewardCtrl.addNotice()

	local tfdOnlineTime = m_fnGetWidget(widgetRoot, "TFD_ONLINE_TIME")
	UIHelper.labelNewStroke(tfdOnlineTime, ccc3( 0x04, 0x1f, 0x41 ))


	local btnOnline = m_fnGetWidget(widgetRoot, "BTN_ONLINE_REWARD")
	local imgRecieve = m_fnGetWidget(widgetRoot, "IMG_CAN_RECIEVE")
	if (OnlineRewardCtrl.getFutureTime() == 0) then -- 全部领取完后
		btnOnline:removeFromParent()
		imgRecieve:removeFromParent()

		local layTop = m_fnGetWidget(widgetRoot, "LAY_BTN_TOP")
		layTop:removeNodeByTag(333)	-- 动画没有加在按钮上，需要手动移除
		return
	end

	UIHelper.registExitAndEnterCall(btnOnline, stopOnlineScheduler, startOnlineScheduler)
	updateOnlineTime()

	btnOnline:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playMainUIEffect()
			logger:debug("btnOnline")
			OnlineRewardCtrl.create()
		end
	end)
end

-- zhangqi, 2014-12-30, 创建船头叹号提示动画
local function createBoatSign()
	local anim = UIHelper.createArmatureNode({
		filePath = "images/effect/sign_boat/sign_boat.ExportJson",
		animationName = "sign_boat",
		loop = -1,
	})
	if (anim) then
		anim:setTag(100)
	end
	return anim
end
-- zhangqi, 2014-12-30, 根据占卜屋和好友是否有红点提示来控制船头的提示显示
function showBoatTip()
	logger:debug("showBoatTip: m_boatTipFlag")
	logger:debug(m_boatTipFlag)
	if (m_boatTipFlag.zb or m_boatTipFlag.fd) then -- 显示
		if (not m_layBoatTip:getNodeByTag(100)) then
			logger:debug("m_layBoatTip:addNode")
			m_layBoatTip:addNode(createBoatSign()) -- zhangqi, 2014-12-30, 给二级菜单入口按钮添加提示
	end
	else
		if (m_layBoatTip:getNodeByTag(100)) then
			logger:debug("m_layBoatTip:removeAllNodes")
			m_layBoatTip:removeAllNodes()
		end
	end
end

function create( ... )
	init()
	--主背景UI
	widgetRoot = g_fnLoadUI(jsonMain)

	local imgSky = m_fnGetWidget(widgetRoot, "IMG_SKY")

	local layTest = m_fnGetWidget(widgetRoot,"LAY_TEST")
	local laysize = layTest:getSize()
	layTest:setSize(CCSizeMake(laysize.width*g_fScaleX, laysize.height*g_fScaleX))


	local layShip = m_fnGetWidget(widgetRoot, "LAY_SHIP")
	local imgShip = m_fnGetWidget(widgetRoot, "IMG_SHIP")
	local tbShipPos = ccp(imgShip:getPositionX(),imgShip:getPositionY())
	local tbShipAnchor = ccp(imgShip:getAnchorPoint().x,imgShip:getAnchorPoint().y)

	local home_graph = UIHelper.getHomeShipID()
	local aniShip = UIHelper.addShipAnimation(layShip,home_graph,tbShipPos,tbShipAnchor,1.0,10086,10087 )

	-- zhangqi, 2014-12-30, 重新设置zorder在船的动画之上，用于显示主船上的感叹号提示
	-- tolua.cast(imgShip, "CCNode"):setZOrder(110)
	imgShip:setZOrder(aniShip:getZOrder() + 10)

	m_layBoatTip = m_fnGetWidget(imgShip, "LAY_SHIP_TIP")
	-- m_layBoatTip:addNode(createBoatSign()) -- zhangqi, 2014-12-30, 给二级菜单入口按钮添加提示

	m_layBoatTouch = m_fnGetWidget(imgShip, "LAY_ENTER")

	m_layBoatTouch:setTouchEnabled(true)
	m_layBoatTouch:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			onMainEnter(sender, eventType)
		end
	end)
	--探索
	local explorBtn = m_fnGetWidget(widgetRoot, "BTN_EXPLORE")
	explorBtn:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			require "script/module/copy/MainCopy"
			MainCopy.extraToExploreScene()

			-- require "script/module/adventure/MagicalQuestionCtrl"
			-- LayerManager.addLayout(MagicalQuestionCtrl.create())



		end
	end)
	--探索红点
	require "script/module/copy/ExplorMainCtrl"
	ExplorMainCtrl.setExplorRedByBtn(explorBtn)
	-- menghao 鸟的动画
	local aniBird = UIHelper.createArmatureNode({
		filePath = "images/effect/home/zhujiemian_niao.ExportJson",
		animationName = "zhujiemian_niao",
	})
	aniBird:setPosition(ccp(g_winSize.width / 2, g_winSize.height / 2))
	widgetRoot:addNode(aniBird, 3)

	createBackground()

	fnAddEventToButtons()
	-- menghao 等级礼包按钮处理
	--fnSetBtnLevel()

	-- menghao 0829 在线礼包按钮
	fnSetBtnOnline()

	imgCircle = m_fnGetWidget(widgetRoot, "IMG_CIRCLE")
	imgCircle:setVisible(true)
	imgCircle:setEnabled(false)
	if (imgCircle) then
		fnAddEventToCircleBtn() -- 给二级circle菜单按钮添加回调方法

		btnEnter = m_fnGetWidget(widgetRoot, "BTN_ENTER")
		if (btnEnter) then
			logger:debug("enterBtn found")
			btnEnter:addTouchEventListener(onMainEnter)
			btnEnter:setZOrder(2)  --修正BTN_ENTER层级，防止被船上的浪花特效遮住
		end
	end

	layMask = m_fnGetWidget(widgetRoot, "LAY_MASK")

	--显示好友数量
	updateFriendRedPoint()

	--占卜中心
	require "script/module/astrology/MainAstrologyModel"
	local IMG_TIP_ASTROLOGY = m_fnGetWidget(widgetRoot,"IMG_TIP_ASTROLOGY")
	local canEnterAstro = SwitchModel.getSwitchOpenState( ksSwitchStar , false)
	logger:debug(canEnterAstro)

	if( canEnterAstro == true ) then
		MainAstrologyModel.hasRedPoint()
	end
	logger:debug("占卜需要红点么？")
	logger:debug(g_redPoint.diviStar.visible)

	if (g_redPoint.diviStar.visible) then
		IMG_TIP_ASTROLOGY:removeAllNodes()
		IMG_TIP_ASTROLOGY:addNode(UIHelper.createRedTipAnimination())
		m_boatTipFlag.zb = true
	else
		IMG_TIP_ASTROLOGY:removeAllNodes()
		m_boatTipFlag.zb = false
	end

	showBoatTip() -- 2014-12-30


	-- IMG_TIP_ASTROLOGY:setVisible(g_redPoint.diviStar.visible)

	--显示邮件红点
	updateMailRedPoint()
	-- updateAccRewardRedPoint()
	-- 聊天小红点
	upChatRedPoint()

	updateBagPoint("BTN_HERO") -- zhangqi, 2014-08-08, 根据是否招到新伙伴刷新红点状态
	updateBagPoint("BTN_EQUIP") -- zhangqi, 2014-08-08, 刷新装备按钮红点状态

	updateDestinyRedPoint()  --yangna 2015.1.19 刷新主船入口红点状态

	checkTipOnBtn() -- 每次创建主船场景时先即时刷新一下所有红点状态，避免定时刷新造成时间延迟

	GlobalScheduler.addCallback("checkTipOnBtn", checkTipOnBtn) -- 注册自动恢复体力耐力定时器

	-- 控制台
	if (g_debug_mode) then
		logger:debug("add cmdBtn")
		createCmdBtn()
	end

	require "script/module/guide/GuideCtrl"
	GuideCtrl.test()
	require "script/module/guide/GuideTreasView"
	if (GuideModel.getGuideClass() == ksGuideTreasure and GuideTreasView.guideStep == 5) then
		require "script/module/guide/GuideCtrl"
		GuideCtrl.createTreasGuide(6)
	end
	return widgetRoot
end

-- menghao 更新聊天红点状态
function upChatRedPoint( ... )
	if (widgetRoot) then
		local imgTipChat = m_fnGetWidget(widgetRoot, "IMG_TIP_CHAT")
		if (imgTipChat) then
			logger:debug("chat red var ==")
			logger:debug(g_redPoint.chat.visible)
			if (g_redPoint.chat.visible) then
				imgTipChat:removeAllNodes()
				imgTipChat:addNode(UIHelper.createRedTipAnimination())
			else
				imgTipChat:removeAllNodes()
			end
		end
	end
end


--显示开服礼包红点
-- function updateAccRewardRedPoint( ... )
-- 	if(widgetRoot) then

-- 		-- local BTN_SERVER_REWARD = m_fnGetWidget(widgetRoot,"BTN_SERVER_REWARD")
-- 		if(m_btnNewSvr) then
-- 			--开服礼包
-- 			require "script/module/accSignReward/AccSignModel"


-- 			local needShow = AccSignModel.accIconNeedShow()
-- 			logger:debug("是否需要显示开服礼包：")
-- 			logger:debug(needShow)

-- 			--是否需要显示开服礼包的按钮
-- 			if(needShow) then
-- 				local rewardNum = AccSignModel.getCanGotRewardNum()
-- 				logger:debug("当前可以领取的奖励数量为:")
-- 				logger:debug(rewardNum)
-- 				if( tonumber(rewardNum) <= 0) then --开服礼包
-- 					logger:debug("rewardNum <= 0")

-- 					--不需要红点

-- 					m_IMG_TIP_SERVER:removeAllNodes()
-- 					--m_IMG_TIP_SERVER:removeAllChildrenWithCleanup(true)
-- 					--m_IMG_TIP_SERVER:addNode(UIHelper.createRedTipAnimination())
-- 				else
-- 					--需要红点
-- 					--m_IMG_TIP_SERVER:removeAllChildrenWithCleanup(true)
-- 					logger:debug("rewardNum > 0")
-- 					m_IMG_TIP_SERVER:removeAllNodes()
-- 					m_IMG_TIP_SERVER:addNode(UIHelper.createRedTipAnimination())

-- 					--m_IMG_TIP_SERVER:setEnabled(true)
-- 					-- local LABN_TIP_SERVER = m_fnGetWidget(m_IMG_TIP_SERVER,"LABN_TIP_SERVER")
-- 					-- LABN_TIP_SERVER:setStringValue(tonumber(rewardNum))
-- 				end

-- 			else
-- 				m_btnNewSvr:setEnabled(false)
-- 			end

-- 		end

-- 	end
-- end

local T_BIRD_BTN_TAG = 111111
local T_BIRD_ANI_TAG = 111112
--显示邮件红点
function updateMailRedPoint( ... )
	if(widgetRoot) then
		logger:debug("removeNodeByTag(123123)")

		local layShip = m_fnGetWidget(widgetRoot, "LAY_SHIP")
		local IMG_SHIP = m_fnGetWidget(widgetRoot, "IMG_SHIP")

		layShip:removeNodeByTag(T_BIRD_ANI_TAG)
		layShip:removeChildByTag(T_BIRD_BTN_TAG,true)

		if(g_redPoint.newMail.visible) then
			local binder = CCBattleBoneBinder:create()
			-- binder:setAnchorPoint(ccp(0.5,0.5))
			binder:setCascadeOpacityEnabled(true)

			local aniShip = layShip:getNodeByTag(10086)

			local aniBird = UIHelper.createArmatureNode({
				filePath = "images/effect/home/youxiang.ExportJson",
				animationName =  "fly",
				fnMovementCall = function ( sender, MovementEventType , frameEventName)
					if (MovementEventType == 1) then
						sender:getAnimation():play("stand", -1, -1, -1)

						local layout  = Layout:create()
						layout:setSize(CCSizeMake(120,130))
						layout:setTouchEnabled(true)
						layout:setPositionY(binder:getPositionY() )
						layout:setPositionX(binder:getPositionX() - 62)
						layShip:addChild(layout,10000,T_BIRD_BTN_TAG)

						-- layout:setBackGroundColorType(LAYOUT_COLOR_SOLID) -- 设置单色模式
						-- layout:setBackGroundColor(ccc3(0x00, 0x00, 0x00))
						-- layout:setBackGroundColorOpacity(100)

						layout:addTouchEventListener(function ( sender, eventType )
							if (eventType == TOUCH_EVENT_ENDED) then
								logger:debug("点击信鸽，进入邮件")
								onMail(sender,TOUCH_EVENT_ENDED)
							end
						end)
					end
				end
			})

			local animationBone = aniShip:getBone("xingge")
			binder:bindBone(animationBone)
			layShip:addNode(binder,123123,T_BIRD_ANI_TAG)
			--美术给的信鸽特效 和主船的船杆骨骼节点有错位，所以美术给量出了位移差，代码中手动设置位置
			aniBird:setPositionY(- 90)
			aniBird:setPositionX(-132)
			binder:addChild(aniBird)

		else

		end
	end
end
--更新好友可领取耐力红点
function updateFriendRedPoint( ... )
	if(widgetRoot) then
		--显示好友数量
		require "script/module/friends/staminaFdsCtrl"
		logger:debug("updateFriendRedPoint: getStaminaNum = " .. staminaFdsCtrl.getStaminaNum())
		local imgFriendTip = m_fnGetWidget(widgetRoot, "IMG_FRIEND_TIP")

		local num=0
		imgFriendTip:setVisible(false)
		m_boatTipFlag.fd = false

		-- 耐力
		if(staminaFdsCtrl.getStaminaNum()>0 and staminaFdsCtrl.getTodayReceiveTimes()>0) then
			num = num + staminaFdsCtrl.getStaminaNum()
			m_boatTipFlag.fd = true
			logger:debug("可领取的耐力")
			logger:debug({num=num})
		end
		-- 好友申请
		require "script/module/friends/FriendsApplyModel"
		if(FriendsApplyModel.getApplyNum()>0)then
			m_boatTipFlag.fd = true
			num = num + FriendsApplyModel.getApplyNum()
			logger:debug("好友申请")
			logger:debug({num=num})
		end

		if(m_boatTipFlag.fd )then
			local tfdFriendTip = m_fnGetWidget(imgFriendTip, "LABN_FRIEND_TIP")
			tfdFriendTip:setStringValue(num)
			imgFriendTip:setVisible(true)
		end

		showBoatTip() -- zhangqi, 2014-12-30
	end
end

function setRewardCenterBtnEnabled(bEnable)
	require "script/model/DataCache"
	DataCache.setRewardCenterStatus(false)
	BTN_REWARD_CENTER:setEnabled(bEnable)
end

function removeRegistGift( ... )
	if (m_btnRegist) then
		m_btnRegist:removeFromParentAndCleanup(true)
	end
end

function moduleName( ... )
	return "MainShip"
end

--------------主船系统入口-----------
function  onDestiny( sender,eventType )

	if(eventType == TOUCH_EVENT_ENDED) then
		require "script/module/destiny/MainDestinyCtrl"
		require "script/module/switch/SwitchModel"
		AudioHelper.playMainUIEffect()
		if (not SwitchModel.getSwitchOpenState(ksSwitchDestiny,true)) then
			--ShowNotice.showShellInfo("天命系统功能节点未开启")
			return
		else
			MainDestinyCtrl.create()
		end
	end
end

--------加入天命入口按钮上的红色标志的控制------------
function updateDestinyRedPoint( )
	local function getDestinyInfo_callback(  cbFlag, dictData, bRet  )
		logger:debug(dictData)
		local error = dictData.err
		if (error == "ok") then
			require "script/model/DataCache"
			local  destinyCurInfo = dictData.ret

			DataCache.setDestinyCurInfo(destinyCurInfo)

			local  hasTip = false
			if(destinyCurInfo ~= nil) then
				local  ownStar 			= destinyCurInfo.left_score
				local  destinyNextId 	= destinyCurInfo.cur_break + 1
				require "db/DB_Destiny"
				local pNum = table.count(DB_Destiny.Destiny)
				if(destinyNextId > pNum) then
					hasTip = false
				else
					local  destinyNextInfo	= DB_Destiny.getDataById(destinyNextId)
					local  needStar 		= destinyNextInfo.costCopystar
					logger:debug(ownStar.."    "..needStar)

					if (tonumber(ownStar) >= tonumber(needStar)) then
						hasTip = true
					else
						hasTip = false
					end
				end
			else
				hasTip = false
			end

			local imgTipDestiny = m_fnGetWidget(widgetRoot,"IMG_TRAIN_TIP")  --主船系统红点 --主船入口红点
			if ( LayerManager.curModuleName() == "MainShip" and hasTip) then
				imgTipDestiny:removeAllNodes()
				imgTipDestiny:addNode(UIHelper.createRedTipAnimination())
			else
				imgTipDestiny:removeAllNodes()
			end
		else

		end
	end

	require "script/module/switch/SwitchModel"
	if (not SwitchModel.getSwitchOpenState(ksSwitchDestiny,false)) then
		return
	else
		RequestCenter.ship_getShipInfo(getDestinyInfo_callback)
	end

end


-- 纪录二级菜单上各个按钮的原始位置
function getSendButtonPos( ... )
	tbSecondButton = {}
	tbSecondPos = {}

	local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
	tbSecondButton[1] = m_fnGetWidget(imgCircle, "BTN_MENU")
	tbSecondButton[2] = m_fnGetWidget(imgCircle, "BTN_ZHANBU")
	tbSecondButton[3] = m_fnGetWidget(imgCircle, "BTN_RESOLVE")
	tbSecondButton[4] = m_fnGetWidget(imgCircle, "BTN_FRIEND")
	tbSecondButton[5] = m_fnGetWidget(imgCircle, "BTN_MAIL")

	for i=1,5 do
		tbSecondPos[i] = {tbSecondButton[i]:getPositionX(),tbSecondButton[i]:getPositionY()}
	end
	tbSecondPos[6] = { imgCloud:getPositionX(),imgCloud:getPositionY() }
end


local FRAME_TIME = 1/60

function secondMenuLayerOpen( ... )
	LayerManager.addUILayer()  --动画播放开始添加屏蔽层

	if (not tbSecondButton)then
		getSendButtonPos()
	end
	--云动画
	-- 第1帧        位置（0，-141）     比例70%        透明度 0%
	-- 第14帧       位置（0，0）        比例100%       透明度 100%
	-- 第18帧       位置（0，0）        比例104%       透明度 100%
	-- 第22帧       位置（0，0）        比例100%       透明度 100%
	imgCircle:setEnabled(true)

	local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
	imgCloud:setOpacity(50)
	local pos = tbSecondPos[6]

	local imgRender = imgCloud:getVirtualRenderer()

	imgRender:setPosition(ccp( 0,-141))
	local array1 = CCArray:create()
	array1:addObject(CCScaleTo:create(13*FRAME_TIME,1.0*g_fScaleX,1.0*g_fScaleY))
	array1:addObject(CCMoveTo:create(13*FRAME_TIME,ccp(0,0)))
	array1:addObject( CCFadeTo:create(13*FRAME_TIME,255))
	local spawn1 = CCSpawn:create(array1)
	local array2 = CCArray:create()
	array2:addObject( CCScaleTo:create(1*FRAME_TIME,0.7*g_fScaleX,0.7*g_fScaleY) )   	--1桢
	array2:addObject(spawn1) 		      							--2-14 帧
	array2:addObject(CCScaleTo:create(4*FRAME_TIME,1.04*g_fScaleX,1.04*g_fScaleY))       --15-18
	array2:addObject(CCScaleTo:create(4*FRAME_TIME,1.0*g_fScaleX,1.0*g_fScaleY))		--19-22
	array2:addObject(CCCallFuncN:create(function ( sender )
		local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
		imgCloud:setOpacity(255)
	end ) )
	local seq1 = CCSequence:create(array2)
	imgRender:runAction(seq1)

	-- 黑幕
	-- 第10帧       透明度 0%
	-- 第20帧       透明度 100%
	imgCircle:setOpacity(0)
	local imgRender = imgCircle:getVirtualRenderer()
	local array1 = CCArray:create()
	array1:addObject( CCDelayTime:create(10*FRAME_TIME) )    --1-10 帧
	array1:addObject( CCFadeTo:create(10*FRAME_TIME,255))    --11-20帧
	array1:addObject( CCCallFuncN:create(function ( ... )
		imgCircle:setOpacity(255)
	end)  )
	local seq = CCSequence:create(array1)
	local imgCircleRender = imgCircle:getVirtualRenderer()
	imgCircleRender:runAction(seq)

	-- 	设置     【以最后停止位置为坐标原点（0，0）】
	-- 第1帧        位置（157，-185）     透明度 0%
	-- 第10帧       位置（21，-22）       透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第20帧       位置（-10，11）       透明度 100%
	-- 第28帧       位置（0，0）          透明度 100%
	local button = tbSecondButton[1]
	local pos = tbSecondPos[1]
	button:setOpacity(0)
	local imgRender = button:getVirtualRenderer()
	imgRender:setPosition(ccp(157,-185))
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(1*FRAME_TIME))   --1帧
	array:addObject(CCSpawn:createWithTwoActions( CCMoveTo:create( 9*FRAME_TIME, ccp(21,-22 )) ,
		CCFadeTo:create( 9*FRAME_TIME,255 )  ))  --2-10 位置  +透明度
	array:addObject( CCMoveTo:create(2*FRAME_TIME,ccp(0,0)))  --11-12
	array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(-10,11)))  --13-20
	array:addObject( CCMoveTo:create(8*FRAME_TIME,ccp(0,0)))   --21-38
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq1 = CCSequence:create(array)
	imgRender:runAction(seq1)


  

	-- 	占卜屋    【以最后停止位置为坐标原点（0，0）】
	-- 第3帧        位置（72，-216）      透明度 0%
	-- 第12帧       位置（10，-26）       透明度 100%
	-- 第14帧       位置（0，0）          透明度 100%
	-- 第22帧       位置（-5，12）        透明度 100%
	-- 第30帧       位置（0，0）          透明度 100%
	local button = tbSecondButton[3]     -- 占不屋 位置换成 分解屋 ，其他按钮保持
	local pos = tbSecondPos[3]
	button:setOpacity(0)
	local imgRender = button:getVirtualRenderer()
	button:setPosition(ccp(pos[1]+72,pos[2]-216))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(3*FRAME_TIME))  						 --1-3
	array:addObject( CCMoveTo:create(9*FRAME_TIME,ccp(pos[1]+10,pos[2]-26)))  --4-12
	array:addObject(CCMoveTo:create(2*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))   --13-14
	array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]-5,pos[2]+12)))  --15-22
	array:addObject( CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))  --23-30
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	-- widget节点
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,3*FRAME_TIME,14*FRAME_TIME,0,255)

	-- CCNode节点
	local tbNode = UIHelper.getTbNodes(button)
	UIHelper.nodeFadeTo(tbNode,2,3*FRAME_TIME,9*FRAME_TIME,0,255)

	-- 	分解屋    【以最后停止位置为坐标原点（0，0）】
	-- 第5帧        位置（0，-124）       透明度 0%
	-- 第14帧       位置（0，-28）        透明度 100%
	-- 第16帧       位置（0，0）          透明度 100%
	-- 第24帧       位置（0，15）         透明度 100%
	-- 第32帧       位置（0，0）          透明度 100%
	-- local button = tbSecondButton[3]
	-- local pos = tbSecondPos[3]
	-- button:setOpacity(0)
	-- local imgRender = button:getVirtualRenderer()
	-- button:setPosition(ccp(pos[1]+0,pos[2]-124))
	-- local array = CCArray:create()
	-- array:addObject(CCDelayTime:create(5*FRAME_TIME))  --1-5
	-- array:addObject(CCMoveTo:create(9*FRAME_TIME,ccp(pos[1]+0,pos[2]-28)))   --6-14
	-- array:addObject(CCMoveTo:create(2*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))  --15-16
	-- array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+0,pos[2]+15)))   --17-24
	-- array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))  --25-32
	-- array:addObject(CCCallFuncN:create(function ( ... )
	-- 	button:setOpacity(255)
	-- end))
	-- local seq = CCSequence:create(array)
	-- button:runAction(seq)

	-- --widget节点
	-- local tbNode = UIHelper.getTbChildren(button)
	-- table.insert(tbNode,button)
	-- UIHelper.nodeFadeTo(tbNode,1,5*FRAME_TIME,9*FRAME_TIME,0,255)

	-- 好友     【以最后停止位置为坐标原点（0，0）】
	-- 第7帧        位置（-86，-219）       透明度 0%
	-- 第16帧       位置（-11.5，-27）      透明度 100%
	-- 第18帧       位置（0，0）            透明度 100%
	-- 第26帧       位置（6，14）           透明度 100%
	-- 第34帧       位置（0，0）            透明度 100%
	local button = tbSecondButton[4]
	local pos = tbSecondPos[4]
	button:setOpacity(0)
	button:setPosition(ccp(pos[1]-86,pos[2]-219))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(7*FRAME_TIME))   --1-7
	array:addObject(  CCMoveTo:create(9*FRAME_TIME,ccp(pos[1]-11.5,pos[2]-27)))   --8-16
	array:addObject(CCMoveTo:create(2*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))   --17-18
	array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+6,pos[2]+14)))   --19-26
	array:addObject( CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)) )  --27-34
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	-- widget节点
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,7*FRAME_TIME,9*FRAME_TIME,0,255)

	-- 邮箱     【以最后停止位置为坐标原点（0，0）】
	-- 第9帧        位置（-125，-190）       透明度 0%
	-- 第18帧       位置（-17.5，-22.5）     透明度 100%
	-- 第20帧       位置（0，0）             透明度 100%
	-- 第28帧       位置（9，12）            透明度 100%
	-- 第36帧       位置（0，0）             透明度 100%
	local button = tbSecondButton[5]
	button:setOpacity(0)
	local pos = tbSecondPos[5]
	local imgRender = button:getVirtualRenderer()
	button:setPosition(ccp(pos[1]-125,pos[2]-190))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(9*FRAME_TIME))    --1-9
	array:addObject(CCMoveTo:create(9*FRAME_TIME,ccp(pos[1]-17.5,pos[2]-22.5) ))   --10-18
	array:addObject(CCMoveTo:create(2*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))   --19-20
	array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+9,pos[2]+12)) )    --21-28
	array:addObject(CCMoveTo:create(8*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))	  --19-36
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
		LayerManager.removeUILayer()  --移除动画播放过程中的屏蔽层
	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	-- widget节点
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,9*FRAME_TIME,9*FRAME_TIME,0,255)

	-- CCNode节点
	local tbNode = UIHelper.getTbNodes(button)
	UIHelper.nodeFadeTo(tbNode,2,9*FRAME_TIME,9*FRAME_TIME,0,255)

end



function secondMenuLayerClose( ... )
	-- 	云朵   （以云朵的 时间帧数为基准）
	-- 第1帧        位置（0，0）        比例100%       透明度 100%
	-- 第9帧       位置（0，0）        比例100%       透明度 100%
	-- 第12帧       位置（0，0）        比例105%       透明度 100%
	-- 第17帧       位置（0，0）        比例100%       透明度 100%
	-- 第24帧       位置（0，-141）     比例70%        透明度 0%
	LayerManager.addUILayer()  --屏蔽层

	if (not tbSecondButton)then
		getSendButtonPos()
	end

	local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
	local imgRender = imgCloud:getVirtualRenderer()
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(9*FRAME_TIME))   --1-9
	array:addObject(CCScaleTo:create(3*FRAME_TIME,1.05*g_fScaleX,1.05*g_fScaleY))  --10-12
	array:addObject(CCScaleTo:create(5*FRAME_TIME,1.0*g_fScaleX,1.0*g_fScaleY))  --13-17

	local array1 = CCArray:create()
	array1:addObject( CCMoveTo:create(7*FRAME_TIME,ccp(0,-141)))
	array1:addObject( CCScaleTo:create(7*FRAME_TIME,0.7*g_fScaleX,0.7*g_fScaleY))
	array1:addObject( CCFadeTo:create(7*FRAME_TIME,0))
	array:addObject(CCSpawn:create(array1))    --18-24

	array:addObject(CCCallFuncN:create(function ( sender )
		local imgCloud = m_fnGetWidget(imgCircle, "img_main_cloud")
		sender:setScaleX(1.0*g_fScaleX)
		sender:setScaleY(1.0*g_fScaleY)
		sender:setPosition(ccp(0,0))
		imgCircle:setEnabled(false)
	end ) )
	local seq1 = CCSequence:create(array)
	imgRender:runAction(seq1)

	-- 黑幕
	-- 第12帧       透明度 100%
	-- 第22帧       透明度 0%
	local imgRender = imgCircle:getVirtualRenderer()
	local array1 = CCArray:create()
	array1:addObject( CCDelayTime:create(12*FRAME_TIME) )    --1-12 帧
	array1:addObject( CCFadeTo:create(10*FRAME_TIME,0))    --13-22帧
	array1:addObject( CCCallFuncN:create(function ( ... )
		-- imgCircle:setOpacity(255)
		end)  )
	local seq = CCSequence:create(array1)
	local imgCircleRender = imgCircle:getVirtualRenderer()
	imgCircleRender:runAction(seq)

	-- 	设置     【以开始的位置为坐标原点（0，0）】
	-- 第1帧        位置（0，0）          透明度 100%
	-- 第7帧        位置（-10，11）       透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第17帧       位置（68，-79）       透明度 100%
	-- 第24帧       位置（157，-185）     透明度 0%
	local button = tbSecondButton[1]
	local pos = tbSecondPos[1]
	local imgRender = button:getVirtualRenderer()
	imgRender:setPosition(ccp(0,0))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1*FRAME_TIME))  --1
	array:addObject(CCMoveTo:create(6*FRAME_TIME,ccp(-10,11)))    --2-7
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(0,0)))   --8-12
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(68,-79)))   --13-17
	array:addObject(CCSpawn:createWithTwoActions( CCMoveTo:create(7*FRAME_TIME,ccp(157,-185)),CCFadeTo:create(7*FRAME_TIME,0)))   --18-24
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq1 = CCSequence:create(array)
	imgRender:runAction(seq1)

	-- 占卜屋    【以开始的位置为坐标原点（0，0）】
	-- 第1帧        位置（0，0）          透明度 100%
	-- 第7帧        位置（-5，12）        透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第17帧       位置（31，-92）       透明度 100%
	-- 第24帧       位置（72，-216）      透明度 0%
	local button = tbSecondButton[3]     --占卜屋 替换成 分解屋  其他保持
	local pos = tbSecondPos[3]
	button:setPosition(ccp(pos[1],pos[2]))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1*FRAME_TIME))   --1
	array:addObject(CCMoveTo:create(6*FRAME_TIME,ccp(pos[1]-5,pos[2]+12)))   --2-7
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))   --8-12
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+31,pos[2]-92)))   --13-17
	array:addObject(CCMoveTo:create(7*FRAME_TIME,ccp(pos[1]+72,pos[2]-216)))  --18-24
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	-- widget节点
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,17*FRAME_TIME,7*FRAME_TIME,255,0)

	-- CCNode节点
	local tbNode = UIHelper.getTbNodes(button)
	UIHelper.nodeFadeTo(tbNode,2,17*FRAME_TIME,7*FRAME_TIME,255,0)

	-- 	分解屋    【以开始的位置为坐标原点（0，0）】
	-- 第1帧        位置（0，0）          透明度 100%
	-- 第7帧        位置（0，15）         透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第17帧       位置（0，-121）       透明度 100%
	-- 第24帧       位置（0，-184）       透明度 0%
	-- local button = tbSecondButton[3]
	-- local pos = tbSecondPos[3]
	-- button:setPosition(ccp(pos[1]+0,pos[2]+0))
	-- local array = CCArray:create()
	-- array:addObject(CCDelayTime:create(1*FRAME_TIME))  --1
	-- array:addObject(CCMoveTo:create(6*FRAME_TIME,ccp(pos[1]+0,pos[2]+15) ))      --2-7
	-- array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+0,pos[2]+0) ))      --8-12
	-- array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+0,pos[2]-121) ))      --13-17
	-- array:addObject(CCMoveTo:create(7*FRAME_TIME,ccp(pos[1]+0,pos[2]-184) ) )  --18-24
	-- array:addObject(CCCallFuncN:create(function ( ... )
	-- 	button:setOpacity(255)
	-- end))
	-- local seq = CCSequence:create(array)
	-- button:runAction(seq)

	-- -- widget节点
	-- local tbNode = UIHelper.getTbChildren(button)
	-- table.insert(tbNode,button)
	-- UIHelper.nodeFadeTo(tbNode,1,17*FRAME_TIME,7*FRAME_TIME,255,0)

	-- 好友     【以开始的位置为坐标原点（0，0）】
	-- 第1帧        位置（0，0）          透明度 100%
	-- 第7帧        位置（6，14）         透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第17帧       位置（-37，-94）      透明度 100%
	-- 第24帧       位置（-86，-219）     透明度 0%
	local button = tbSecondButton[4]
	local pos = tbSecondPos[4]
	button:setPosition(ccp(pos[1]+0,pos[2]+0))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1*FRAME_TIME))  --1
	array:addObject(CCMoveTo:create(6*FRAME_TIME,ccp(pos[1]+6,pos[2]+14)))   --2-7
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)))   --8-12
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]-37,pos[2]-94)))   --13-17
	array:addObject(CCMoveTo:create(7*FRAME_TIME,ccp(pos[1]-86,pos[2]-219) )  )   --18-24
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	-- ui控件
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,17*FRAME_TIME,7*FRAME_TIME,255,0)

	-- 邮箱     【以开始的位置为坐标原点（0，0）】
	-- 第1帧        位置（0，0）          透明度 100%
	-- 第7帧        位置（9，12）         透明度 100%
	-- 第12帧       位置（0，0）          透明度 100%
	-- 第17帧       位置（-55，-81）      透明度 100%
	-- 第24帧       位置（-125，-190）    透明度 0%
	local button = tbSecondButton[5]
	local pos = tbSecondPos[5]
	button:setPosition(ccp(pos[1]+0,pos[2]+0))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1*FRAME_TIME))  --1
	array:addObject(CCMoveTo:create(6*FRAME_TIME,ccp(pos[1]+9,pos[2]+12)) )   --2-7
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]+0,pos[2]+0)) )   --8-12
	array:addObject(CCMoveTo:create(5*FRAME_TIME,ccp(pos[1]-55,pos[2]-81)) )   --13-17
	array:addObject( CCMoveTo:create(7*FRAME_TIME,ccp(pos[1]-125,pos[2]-190) )  )   --18-24
	array:addObject(CCCallFuncN:create(function ( ... )
		button:setOpacity(255)
		LayerManager.removeUILayer()   --移除动画播放过程中的屏蔽层

	end))
	local seq = CCSequence:create(array)
	button:runAction(seq)

	--widget节点
	local tbNode = UIHelper.getTbChildren(button)
	table.insert(tbNode,button)
	UIHelper.nodeFadeTo(tbNode,1,17*FRAME_TIME,7*FRAME_TIME,255,0)

	-- CCNode节点
	local tbNode = UIHelper.getTbNodes(button)
	UIHelper.nodeFadeTo(tbNode,2,17*FRAME_TIME,7*FRAME_TIME,255,0)

end

