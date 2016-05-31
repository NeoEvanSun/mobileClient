-- FileName: SwitchCtrl.lua
-- Author: huxiaozhou
-- Date: 2014-06-04
-- Purpose: function description of module
--[[TODO List]]
-- 功能节点开启控制器模块

module("SwitchCtrl", package.seeall)
require "script/module/switch/SwitchView"
require "script/module/main/LayerManager"
require "script/module/public/BTRichText"
-- 模块全局变量 --
m_sCallBackKey = "CALLBACKKEY"


isForthFormation = false -- 第四个上阵伙伴栏位
isInBattle = false -- 是不是在战斗状态
isInExplore = false -- 是不是在探索状态

isHaveNotification = false --当前是否可以开启推送功能

-- 模块局部变量 --
local m_nSwitchEnum

function reset(  )
	isInExplore = false 
	isForthFormation = false -- 第四个上阵伙伴栏位
	isInBattle = false -- 是不是在战斗状态
	isHaveNotification = false --当前是否可以开启推送功能
end

local function init(...)

end

function destroy(...)
	package.loaded["SwitchCtrl"] = nil
end

function moduleName()
    return "SwitchCtrl"
end

-- zhangqi, 2015-01-24, 用新添加的 MainScene.homeCallback 代替之前的MainShip.create
function changeToMainShip( ... )
	require "script/module/main/MainScene"
 	MainScene.homeCallback()
end

--  点击按钮 触发的事件 前往XXX 功能
function callBackFunc( sender,eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playCommonEffect()
		
		LayerManager.removeSwitchDlg()

		if(m_nSwitchEnum == ksSwitchFormation) then
			-- 提示阵容开启
		elseif(m_nSwitchEnum == ksSwitchEliteCopy) then
			-- 精英副本
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideEliteCopy)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createEliteGuide(1)
    		changeToMainShip()
    		
		elseif(m_nSwitchEnum == ksSwitchActivity) then
			-- 活动开启
		elseif(m_nSwitchEnum == ksSwitchGreatSoldier) then
			-- 名将
		elseif (m_nSwitchEnum == ksSwitchContest) then
			-- 比武
		elseif (m_nSwitchEnum == ksSwitchArena) then
			-- 竞技场
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideArena)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createArenaGuide(1)
    		GuideCtrl.setPersistenceGuide("arena","2")
    		changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchActivityCopy) then
			-- 活动副本
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideAcopy)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createAcopyGuide(1)
    		changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchPet) then
			-- 宠物开启
		elseif(m_nSwitchEnum == ksSwitchResource) then
			-- 资源框
		elseif(m_nSwitchEnum == ksSwitchStar) then
			-- 占星
			
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideAstrology)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createAstrologyGuide(1)
    		GuideCtrl.setPersistenceGuide("astrology","4")
    		changeToMainShip()

		elseif(m_nSwitchEnum == ksSwitchSignIn) then
			-- 签到
			
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideSignIn)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createSignGuide(1)
    		changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchShop) then
			-- 等级礼包
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideFiveLevelGift)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createkFiveLevelGiftGuide(1)
    		changeToMainShip()
		elseif (m_nSwitchEnum == ksSwitchWeaponForge) then
			-- 提示装备强化
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideSmithy)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createEquipGuide(1)
    		changeToMainShip()

		elseif (m_nSwitchEnum == ksSwitchGeneralForge) then
			-- 武将强化

			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideFormation)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createFormationGuide(1)
    		changeToMainShip()

		elseif(m_nSwitchEnum == ksSwitchGeneralTransform) then 
			-- 武将进阶
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideGeneralTransform)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createPartnerAdvGuide(1)
    		changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchTreasureForge) then
			-- 宝物强化
		elseif(m_nSwitchEnum == ksSwitchRobTreasure) then
			-- 夺宝
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideRobTreasure)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createRobGuide(1)
    		changeToMainShip()
		elseif (m_nSwitchEnum == ksSwitchResolve) then
			-- 炼化炉
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideResolve)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createDecomGuide(1)
    		changeToMainShip()

		elseif (m_nSwitchEnum == ksSwitchDestiny) then
			-- 天命
			-- 如果是在 
			-- require "script/module/copy/MainCopy"
			-- MainCopy.extraToCopyScene(1,1)
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideDestiny)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createTrainGuide(1)
    		GuideCtrl.setPersistenceGuide("destiny","2")
    		changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchGuild) then
			-- 联盟
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideSmithy)
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createGuildGuide(1)
			changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchEquipFixed) then
			-- 装备洗炼
		elseif(m_nSwitchEnum == ksSwitchTreasureFixed) then
			-- 宝物精炼
		elseif(m_nSwitchEnum == ksSwitchTower) then
			--爬塔
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideSkypiea)
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createSkyPieaGuide(1)
			changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchWorldBoss) then
			-- 世界boss
		elseif(m_nSwitchEnum == ksSwitchDress) then
			-- 主角时装
		elseif(m_nSwitchEnum == ksSwitchBattleSoul) then
			-- 战魂
		elseif(m_nSwitchEnum == ksSwitchEveryDayTask) then
			-- 每日任务
		elseif(m_nSwitchEnum == ksSwitchDressStrengthen) then
			-- 时装强化
		elseif(m_nSwitchEnum == ksHeroBiography) then
			-- 武将列传
		elseif(m_nSwitchEnum == ksSwitchExplore) then
			-- 探索
			require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideExplore)
			require "script/module/guide/GuideCtrl"
    		GuideCtrl.createExploreGuide(1)
    		changeToMainShip()
    	elseif(m_nSwitchEnum == ksSwitchTreasure) then
   --  		-- 宝物
   --  		require "script/module/guide/GuideModel"
			-- GuideModel.setGuideClass(ksGuideTreasure)
			-- require "script/module/guide/GuideCtrl"
			-- GuideCtrl.createTreasGuide(1)
			-- changeToMainShip()
		elseif(m_nSwitchEnum == ksSwitchReborn) then
			-- 重生
    		require "script/module/guide/GuideModel"
			GuideModel.setGuideClass(ksGuideReborn)
			require "script/module/guide/GuideCtrl"
			GuideCtrl.createRebornGuide(1)
			changeToMainShip()
		elseif (m_nSwitchEnum == ksSwitchLitFmt) then
			-- 小伙伴引导
			-- require "script/module/guide/GuideModel"
			-- GuideModel.setGuideClass(ksGuideLitFmt)
			-- require "script/module/guide/GuideCtrl"
			-- GuideCtrl.createLitFmtGuide(1)
			-- changeToMainShip()
		end
	end
end


function createTipData( switchEnum )
	require "db/DB_Switch"
	local switchInfo = DB_Switch.getDataById(switchEnum)
	local tbData = {}

	local str = gi18n[4801] .. "|［%s］|" .. gi18n[2104]

	local tbRich = { str, 
						{
							{size = 24,color={r=0x8f;g=0x2d;b=0x02},font=g_FontPangWa}, 
							{color={r=0x00;g=0x93;b=0x11},size = 24,font=g_FontPangWa},
							{size = 24,color={r=0x8f;g=0x2d;b=0x02},font=g_FontPangWa},
						}
					}

	tbData.alertContent = switchInfo.alertContent

	local switchIcon 
	--添加功能节点图标
	if(tonumber(switchEnum) == ksSwitchFormation) then
		--阵容
		switchIcon = "images/common/new_formation.png"
	elseif(tonumber(switchEnum) == ksSwitchShop) then
		switchIcon = "images/common/new_bar.png"
	elseif(tonumber(switchEnum) == ksSwitchEliteCopy) then
		--精英副本
		switchIcon = "ui/btn_elite_copy_n.png"
	elseif(tonumber(switchEnum) == ksSwitchActivity) then

	elseif(tonumber(switchEnum) == ksSwitchGreatSoldier) then

	elseif(tonumber(switchEnum) == ksSwitchContest) then
		--比武
		-- switchIcon = "images/switch/contest.png"	
	elseif(tonumber(switchEnum) == ksSwitchArena) then
		--竞技场 
		switchIcon = "images/common/new_arena.png"
	elseif(tonumber(switchEnum) == ksSwitchActivityCopy) then
		--活动副本 	--error
		switchIcon = "images/common/new_acopy.png"
	elseif(tonumber(switchEnum) == ksSwitchPet) then
		--宠物 
		-- switchIcon = "images/switch/pet.png"
	elseif(tonumber(switchEnum) == ksSwitchResource) then
		--资源矿
		-- switchIcon = "images/switch/resource.png"	
 	elseif(tonumber(switchEnum) == ksSwitchStar) then
 		--占星
 		switchIcon = "ui/zhanbu_n.png"	
  	elseif(tonumber(switchEnum) == ksSwitchSignIn) then
 		--签到 		--error
 		switchIcon = "ui/sign_day_n.png"
		--数据拉取
		require "script/network/PreRequest"
		PreRequest.preGetSignInfo()
 	elseif(tonumber(switchEnum) == ksSwitchLevelGift) then
 		--等级礼包
 		switchIcon = "ui/level_reward_n.png"
  	elseif(tonumber(switchEnum) == ksSwitchSmithy) then
 		--铁匠铺 	--error
 		-- switchIcon = CCSprite:create("images/switch/star.png")
 	elseif(tonumber(switchEnum) == ksSwitchWeaponForge) then
 		--装备强化 	--error
 		switchIcon = "images/common/new_equip.png"
  	elseif(tonumber(switchEnum) == ksSwitchGeneralForge) then
 		--武将强化	
 		switchIcon = "images/common/new_partner_str.png"
 	elseif(tonumber(switchEnum) == ksSwitchGeneralTransform) then
 		--武将进阶 	
 		switchIcon = "images/common/new_advance.png"
 	elseif(tonumber(switchEnum) == ksSwitchTreasureForge) then
 		--宝物强化系统
 		-- systemName=GetLocalizeStringBy("key_1159")
 	elseif(tonumber(switchEnum) == ksSwitchRobTreasure  ) then
 		--夺宝系统
 		switchIcon = "images/common/new_rob.png"
	elseif(tonumber(switchEnum) == ksSwitchResolve) then
		--炼化炉
		switchIcon = "ui/resolve_n.png"
 	elseif(tonumber(switchEnum) == ksSwitchDestiny) then
 		--天命系统
 		switchIcon = "ui/btn_discipline_n.png"
	elseif(tonumber(switchEnum) == ksSwitchGuild) then
 		-- 军团系统
 		-- switchIcon = "images/common/new_union.png"
 		switchIcon = "ui/btn_guild_n.png"
	elseif(tonumber(switchEnum) == ksSwitchEquipFixed) then
 		-- 洗练系统
 		-- switchIcon = "images/switch/xilian.png"
 	elseif(tonumber(switchEnum) == ksSwitchTower) then
 		-- 神秘空岛
 		switchIcon = "images/common/new_air.png"
 	elseif(tonumber(switchEnum) == ksSwitchWorldBoss) then
	elseif(tonumber(switchEnum) == ksSwitchBattleSoul) then
		-- 战魂系统
	elseif(tonumber(switchEnum) == ksSwitchEveryDayTask) then
		--每日任务
	elseif(tonumber(switchEnum) == ksHeroBiography) then
		--武将列传
	elseif(tonumber(switchEnum) == ksSwitchExplore) then
		switchIcon = "images/common/new_explore.png"
	elseif(tonumber(switchEnum) == ksSwitchTreasure) then
		switchIcon = "images/common/new_treasure.png"
	elseif(tonumber(switchEnum) == ksSwitchReborn) then
		switchIcon = "ui/resolve_n.png"
	elseif (tonumber(switchEnum) == ksSwitchLitFmt) then
		switchIcon = "images/common/new_small.png"
 	end


	tbData.icon = switchIcon
	tbData.richText = BTRichText.create(tbRich,nil,nil,switchInfo.name)


	return tbData
end

-- 创建提示面板
function createView( switchEnum)
	m_nSwitchEnum = tonumber(switchEnum)
	local tbData = createTipData(switchEnum)
	GuideModel.setGuideState(true)
	local view = SwitchView.create(tbData,callBackFunc)
	LayerManager.addSwitchDlg(view)
	setSwitchViewByTalk()
end

-- 初始化方法
function create(switchEnum )
	if(isInBattle == true or isInExplore == true) then
		logger:debug("push.switch.newSwitch" .. switchEnum)
		m_nSwitchEnum = tonumber(switchEnum)
		isHaveNotification = true
	else
		createView(switchEnum)
	end

end

---  第四个伙伴栏位开启 回调
function callBackFuncForthFormation(  )
	LayerManager.removeSwitchDlg()
	require "script/module/guide/GuideModel"
	GuideModel.setGuideClass(ksGuideForthFormation)
	require "script/module/guide/GuideCtrl"
	GuideCtrl.createForthFormationGuide(1)
	changeToMainShip()
end

-- 创建第四个伙伴栏位开启提示面板 特殊处理
function createForthFormationView(  )
	local tbData = {}

	local str = gi18n[4801] .. "|［%s］"
	local tbRich = { str, 
						{
							{size = 24,color={r=0x8f;g=0x2d;b=0x02},font=g_FontPangWa}, 
							{color={r=0x00;g=0x93;b=0x11},size = 24,font=g_FontPangWa},
						}
					}

	tbData.alertContent = "可以上阵第四个伙伴" --TODO


	tbData.icon  = "images/common/new_four.png"
	tbData.richText = BTRichText.create(tbRich,nil,nil,"第四个伙伴栏位") --TODO

	local view = SwitchView.create(tbData,callBackFuncForthFormation)
	LayerManager.addSwitchDlg(view)
end


-- 注册观察者通知
function registerBattleNotification(  )
	require "script/module/public/GlobalNotify"
	GlobalNotify.addObserver(m_sCallBackKey,handleBattleNotificationCallback,false)
end

function registerLevelUpNotification(  )
	require "script/model/user/UserModel"
	UserModel.addObserverForLevelUp("switchOpenTenLevel", levelUpCallback )
	require "script/module/arena/ArenaItem"
	UserModel.addObserverForLevelUp("ArenaLevelUp", ArenaItem.levelUpCallback )
end

function levelUpCallback( p_level )
	print("player level up to open forth formation or not")
	-- 12级开启第四个上阵栏位
	logger:debug("p_level " .. p_level)
	local needLvl = getFormationOpenLv()
	logger:debug("needLvl " .. needLvl)

	if(tonumber(p_level) == tonumber(getFormationOpenLv())) then
		if(isInBattle == true or isInExplore == true) then
			isForthFormation = true
		else
			createForthFormationView()
		end
	end
end

-- 获取第四个上阵伙伴开启的等级
function getFormationOpenLv(  )
	require "db/DB_Formation"
    local openFormByLv = DB_Formation.getDataById(1).openNumByLv
    local splitData_FormLv = lua_string_split(openFormByLv, ",")
	local openLv = lua_string_split(splitData_FormLv[3],"|")[1] 
	return openLv
	
end

--  发送观察者通知
-- notificationName ＝  BEGIN_BATTLE or  BEGIN_BATTLE  -- 战斗
--notificationName = BEGIN_EXPLORE -- 探索
--notificationName = END_EXPLORE

-- 战斗开始的是否发送 战斗结束了也发送
function postBattleNotification( notificationName)
	logger:debug("postBattleNotification" .. notificationName)
	require "script/module/public/GlobalNotify"
	GlobalNotify.postNotify(m_sCallBackKey,notificationName) 
end

-- 注册的notiftication 回调
function handleBattleNotificationCallback( notificationName )
	logger:debug("notificationName = %s", notificationName)
	logger:debug("isHaveNotification = %s",isHaveNotification)
	if (notificationName == "END_BATTLE" and Network.m_status == g_network_disconnected) then
		LoginHelper.netWorkFailed() -- zhangqi, 2015-01-14, 战斗结束后如果已断网就弹出断网提示
	end

---  弹出 功能节点 提示面板
	if(notificationName == "BEGIN_BATTLE") then
		--进入战斗场景
		isInBattle = true
		print("fight notification BEGIN_BATTLE")

	elseif(notificationName ==  "END_BATTLE") then
		--退出战斗场景
		isInBattle = false
		if(isHaveNotification == true) then
			logger:debug("push.switch.newSwitch" .. m_nSwitchEnum)
			createView(m_nSwitchEnum)
			isHaveNotification = false
		end
		print("fight notification END_BATTLE")
	end

--   弹出 
	if (notificationName == "END_BATTLE") then
		if(isForthFormation == true) then
			createForthFormationView()
			isForthFormation = false
		end 
	end
--  explore
   
	if (notificationName == "END_EXPLORE") then
		if(isForthFormation == true) then
			createForthFormationView()
			isForthFormation = false
		end 
	end


   if (notificationName == "BEGIN_EXPLORE") then
   	   isInExplore = true
   elseif (notificationName == "END_EXPLORE") then
   	   isInExplore = false	

   	   if(isHaveNotification == true) then
			logger:debug("push.switch.newSwitch" .. m_nSwitchEnum)
			createView(m_nSwitchEnum)
			isHaveNotification = false
		end
   end

end

function setSwitchView( )
	-- 新功能提示面板
	logger:debug("setSwitchView")
	local layer = LayerManager.getSwitchDlg()
	if (layer) then
		logger:debug("设置 新功能开启面板 显示")
		layer:setVisible(true)
	end

	--  新手引导层
	local guideLayer = LayerManager.getGuideLayer()
	if (guideLayer) then
		guideLayer:setVisible(true)
	end

end

function setSwitchViewByTalk( )
	local talkLayer = LayerManager.getTalkLayer()
	local layer = LayerManager.getSwitchDlg()

	--  新功能提示面板
	if (talkLayer and layer) then
		layer:setVisible(false)
	end
	
	--  新手引导层
	local guideLayer = LayerManager.getGuideLayer()
	if (talkLayer and guideLayer) then
		guideLayer:setVisible(false)
	end

end



