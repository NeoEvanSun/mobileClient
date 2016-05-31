-- FileName: LayerManager.lua
-- Author: zhangqi
-- Date: 2014-05-29
-- Purpose: 所有层的管理器
--[[TODO List]]

module("LayerManager", package.seeall)

require "script/GlobalVars"
require "script/module/public/UIHelper"
require "script/module/public/GlobalNotify"
require "script/utils/LuaUtil"
require "script/module/public/GlobalScheduler"
require "script/model/user/UserModel"


-- UI控件引用变量 --
local uiLayer -- OneTouchGroup 对象，添加根容器，并add到runningScene
local layRoot -- 最底层容器，满足适配，放置所有UI, Z-order 0
local layModule -- 当前显示的功能模块，默认是主船，Z-order 0-0-1
local topLayer -- 全局触屏特效接受层, 点击屏幕任意处播放粒子特效

-- 模块局部变量 --
local nZPlayer = 2 -- 玩家信息面板zorder
local nZModule = 0 -- 功能模块Z-order
local nZGuide = 30000 -- 新手引导层
local nZSwitch = 30050 -- 新功能开启面板
local nZTalk = 30100 -- 对话层
local nZLoading = 35000 -- 网络请求 loading bar 在runningScene上的层级
local nZLogin = 35001 -- 登录时的loading 层级和tag
local nZNetworkFailed = 40000 -- 网络断开时的层级，最高
local nZPop = 10000 -- 弹出窗口的初始Zorder
local nPopLayoutTag = 666666 -- popLayer 要附加的layout的tag
local nShieldLayoutTag = 666669 -- ShieldLayout 的 tag，用于检测是否存在, zhangqi, 2015-03-19
local tbTags = {1, 2, 3}
local m_strCurName = "" -- 当前功能模块的名称
local m_tbLayerStack = {} -- 添加其他模块的容器栈，添加新的入栈，模块remove时出栈
local m_tbLayoutStack = {} -- 附加到parent上的Layout的容器栈
local m_tbTypeStack = {} -- 记录当前addLayout的类型，1, OneTouchGroup; 2, Layout
local m_fnGetWidget = g_fnGetWidgetByName
local m_touchPriority = g_tbTouchPriority
local m_fnRemoveLayout -- removeLayout 后调用的callback

local visibleViews={} -- table中每个值都是一个CCArray 每个CCArray都记录当前界面要隐藏的scene上所有显示的节点

-- loading 动画
local m_layLoading = nil
local m_animat = nil
local m_szAni = nil

local m_scheduler = CCDirector:sharedDirector():getScheduler()
local m_fnLoginTimeout = nil
local m_fnLoadingTimeout = nil

-- 模块局部方法 --
local m_tbPubModule = {"PaoMaDeng", "PlayerPanel", "MainMenu"} -- 公共模块对应模块名

local function createLoading()
	local frameWidth = 110
	local frameHeight = 110

	-- create dog animate
	local path = "images/effect/load/"
	local loading1 = CCTextureCache:sharedTextureCache():addImage(path .. "loading_0001.png")
	local loading2 = CCTextureCache:sharedTextureCache():addImage(path .. "loading_0002.png")

	local rect = CCRectMake(0, 0, frameWidth, frameHeight)
	local frame0 = CCSpriteFrame:createWithTexture(loading1, rect)
	local frame1 = CCSpriteFrame:createWithTexture(loading2, rect)

	local spriteLoading = CCSprite:createWithSpriteFrame(frame0)
	spriteLoading.isPaused = false
	-- spriteLoading:setPosition(origin.x, origin.y + visibleSize.height / 4 * 3)

	local animFrames = CCArray:create()
	animFrames:addObject(frame0)
	animFrames:addObject(frame1)

	local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.2)
	local animate = CCAnimate:create(animation);
	spriteLoading:runAction(CCRepeatForever:create(animate))

	return spriteLoading
end

-- zhagnqi, 2014-04-01, 在一个全集的table上取另一个table的补集
-- tbFull: 表示全集的table; tbChild: 求补集的table; return: 表示补集的table
local complement = function (tbFull, tbChild)
	local tbRet = {}

	local setChild = {}
	for k, v in pairs(tbChild) do
		setChild[v] = true
	end

	for k,v in pairs(tbFull) do
		if (not setChild[k]) then
			table.insert(tbRet,k)
		end
	end

	return tbRet
end
--zhangqi, 2014-11-25, 战斗时候会隐藏所有ui，这里的功能是在未退出战斗时提前显示据点界面
function showItemHolder( )
	for i, layer in ipairs(m_tbLayerStack) do
		if (layer:getWidgetByName(g_HolderLayout)~=nil) then
			layer:setVisible(true)
			return
		end
	end
end

-- zhangqi, 2014-07-25, 禁用 uiLayer 和 底层的其他 popLayer 的触摸
function disabledTouchOfOtherLayer(bBattle)
	if (uiLayer:isTouchEnabled()) then
		uiLayer:setTouchEnabled(false)
	end
	if (bBattle) then
		uiLayer:setVisible(false)
	end

	for i, layer in ipairs(m_tbLayerStack) do
		if (layer:isTouchEnabled()) then
			layer:setTouchEnabled(false)
		end
		if (bBattle) then
			layer:setVisible(false)
		end
	end
end

--[[desc:判断某个界面是否在不显示列表 liweidong
    arg1: layer
    return: true 在则不能显示，false不在，则显示  
—]]
function layerIsInHideList(layer)
	for _,val in pairs(visibleViews) do
		for i=1,val:count() do
			local childNode = tolua.cast(val:objectAtIndex(i-1),"CCNode")
			if (layer==childNode) then
				return true
			end
		end
	end
	return false
end

local function visibleAllOther(...)
	if (not uiLayer:isVisible()) then
		if (not layerIsInHideList(uiLayer)) then --liweidong 增加判断是否要显示
			uiLayer:setVisible(true)
		end
	end
	for i, layer in ipairs(m_tbLayerStack) do
		if (not layer:isVisible()) then
			if (not layerIsInHideList(layer)) then --liweidong 增加判断是否要显示
				layer:setVisible(true)
			end
		end
	end
end
-- 关闭一个popLayer时启用下层的 popLayer 的触摸
function enabledTouchOfOtherLayer(bInBattle)
	logger:debug("enabledTouchOfOtherLayer: bInBattle = %s", tostring(bInBattle))
	if (#m_tbLayerStack == 0) then
		uiLayer:clearTouchStat()
		if (not uiLayer:isTouchEnabled()) then
			uiLayer:setTouchEnabled(true)
		end
		if ((not bInBattle) and (not uiLayer:isVisible())) then
			uiLayer:setVisible(true)
		end
	elseif (#m_tbLayerStack >= 1) then
		logger:debug("enabledTouchOfOtherLayer: m_tbLayerStack.count = %d", #m_tbLayerStack)
		local popLayer = m_tbLayerStack[#m_tbLayerStack]
		-- addLayout时，之前的OneTouchGroup可能刚响应了began事件，记录了被触摸的状态
		-- 如果此时弹出了，当关闭刚add的OneTouchGroup时，之前的那个就不能再响应触摸了，需要清除一下触摸状态
		popLayer:clearTouchStat()  -- zhangqi, 2014-08-22
		popLayer:setTouchEnabled(true)

		local widget = popLayer:getWidgetByTag(nPopLayoutTag)
		if (widget) then
			logger:debug("widget.name = %s", widget:getName())
			widget:setTouchEnabled(false) -- zhangqi, 2014-07-30, 画布的root layout要关闭交互才能不屏蔽popLayer上其他控件的事件传递
		end
		-- end

		if (not bInBattle) then
			visibleAllOther()
		end
		-- logger:debug("bShow = %s", tostring(bShow))
	else
		uiLayer:clearTouchStat()
		uiLayer:setTouchEnabled(true)
		visibleAllOther()
	end
end

--[[desc:用 wigModule 替换当前模块，当前模块会被remove掉
    wigModule: widget对象，需要显示的模块根容器
	strName: 切换模块的名称，每个主模块会提供moduleName()方法, 这个参数通常例如：MainShip.moduleName()
	tbKeep: 存放需要保留的公共模块的Tag（对应 nZPmd, nZPlayer, nZMenu)
			例如 副本模块 只需要保留主菜单，需要传入(copyWidget, MainCopy.moduleName(), {3})
    bClean: 是否强制清理不需要的公共模块局部变量, 默认不清理
    return:  
—]]
function changeModule( wigModule, strName, tbKeep, bClean)
	if (wigModule) then
		logger:debug("changeModule: curName = %s, newName = %s", m_strCurName, strName)

		local oldModuleName = m_strCurName -- 2015-04-15, zhangqi

		if (strName ~= m_strCurName) then
			-- 2013-03-11, 平台统计需求，离开游戏主界面, 主要用于判断在主界面才显示平台的悬浮图标，每次进入离开都要统计
			if (Platform.isPlatform()) then
				if (strName == "MainShip") then -- 进入主界面
					Platform.sendInformationToPlatform(Platform.kEnterTheGameHall)
				end

				if (m_strCurName == "MainShip") then -- 离开主界面
					Platform.sendInformationToPlatform(Platform.kLeaveTheGameHall)
				end
			end

			local tempKeep = tbKeep or {1, 2, 3}

			-- 删除添加到mainscene的已存在的layout
			for i = 1, #m_tbTypeStack do
				removeLayout()
			end

			local curLayout = layRoot:getChildByTag(nZModule)
			if (curLayout) then
				curLayout:removeFromParentAndCleanup(true) -- 删除当前模块

				local curModule = _G[m_strCurName] -- package.loaded[m_strCurName]
				if (curModule) then
					curModule.destroy() -- 调用被删除模块的析构函数，自定义的清扫工作
					curModule = nil -- 完全的释放模块
				end
			end

			layModule = wigModule -- 20140505, 保存当前模块的主画布，方便在模块上添加弹出的UI
			layRoot:addChild(layModule, nZModule, nZModule) -- 添加新模块
			m_strCurName = strName

			-- layModule:setTouchEnabled(true)


			--删除不需要保留的公用模块
			local tbExcept = complement(tbTags, tempKeep)
			logger:debug(tbExcept)
			logger:debug(tempKeep)
			for i, v in ipairs(tbExcept) do
				local widget = layRoot:getChildByTag(v)
				if (widget) then
					widget:removeFromParentAndCleanup(true)
				end
				if (bClean) then --  , 不需要重新创建定制信息面板时指定true把以前的清理一下，避免更新人物属性导致找不到对象的问题
					local mod = package.loaded[m_tbPubModule[v]]
					if (mod) then
						mod.destroy()
					end
				end
			end

			--创建需要显示的公用模块
			for _, v in ipairs(tempKeep) do
				--if (tbTags[v]) then -- 检查 tag 有效性，只能是公共模块的tag Game_tip
				local widget = layRoot:getChildByTag(v)
				if (not widget) then -- 如果不存在则创建
					logger:debug("MainScene.CreatePublic: v = %d", v)
					require "script/module/main/MainScene"
					MainScene.CreatePublic(v)
				else
					-- 2015-04-15, zhangqi, 增加如果是进出主界面的模块切换就创建新的跑马灯
					local cond1 = (m_strCurName == "MainShip" and oldModuleName ~= "MainShip")
					local cond2 = (m_strCurName ~= "MainShip" and oldModuleName == "MainShip")
					if (v == tbTags[1] and (cond1 or cond2)) then -- 是跑马灯, 删除重建
						widget:removeFromParentAndCleanup(true)
						logger:debug("LayerManager create PaoMaDeng: v = %d", v)
						require "script/module/main/MainScene"
						MainScene.CreatePublic(v)
					end
				end
				--end
			end
			uiLayer:clearTouchStat() -- zhangqi, 2014-08-22, 清除切换前可能保存的已触摸状态，避免不再响应触摸的问题
		end

	end

	--zhangjunwu 2014-09-12 切换模块之后删除添加的触摸屏蔽层
	begainRemoveUILoading()
	addShieldLayout()

end

function addPlayerPanel( panel )
	if (layRoot) then
		layRoot:addChild(panel, nZPlayer, nZPlayer)
	end
end


-- 添加一个层到runningScene的指定Zorder
local function addToRunningScene(layer, Zorder)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, Zorder, Zorder)
end

local function removeFromRunningScene( tag )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(tag)) then
		runningScene:removeChildByTag(tag, true)
	end
end

-- 弹出对话层
function addTalkLayer( widget )
	local layout = tolua.cast(widget, "Layout")
	layout:setTouchEnabled(true)
	layout:setBackGroundColorType(LAYOUT_COLOR_SOLID) -- 设置单色模式
	layout:setBackGroundColor(ccc3(0x00, 0x00, 0x00))
	layout:setBackGroundColorOpacity(100)

	local layer = OneTouchGroup:create()
	layer:setTouchPriority(m_touchPriority.talk)
	layer:addWidget(layout)
	addToRunningScene(layer, nZTalk)
end

function removeTalkLayer( ... )
	removeFromRunningScene(nZTalk)
end

function getTalkLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local layer = runningScene:getChildByTag(nZTalk)
	return layer
end

-- 弹出新功能开启面板
function addSwitchDlg( widget )
	local layout = tolua.cast(widget, "Layout")
	layout:setTouchEnabled(true)
	local layer = OneTouchGroup:create()
	layer:setTouchPriority(m_touchPriority.switch)
	layer:addWidget(layout)
	addToRunningScene(layer, nZSwitch)
end

function removeSwitchDlg( ... )
	removeFromRunningScene(nZSwitch)
end

function getSwitchDlg(  )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local layer = runningScene:getChildByTag(nZSwitch)
	return layer
end

-- 弹出新手引导层
function addGuideLayer( ccLayer )
	ccLayer:setTouchPriority(m_touchPriority.guide)
	addToRunningScene(ccLayer, nZGuide)

	-- local layer = OneTouchGroup:create()
	-- layer:setTouchPriority(m_touchPriority.guide + 1)
	-- layer:addChild(ccLayer)
	-- addToRunningScene(layer, nZGuide)
end

function removeGuideLayer( ... )
	removeFromRunningScene(nZGuide)
end

function getGuideLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local layer = runningScene:getChildByTag(nZGuide)
	return layer
end

-- 弹出网络错误的面板, zhangqi, 2104-09-04
function addNetworkDlg( dlg )
	local popLayer = OneTouchGroup:create()
	popLayer:setTouchPriority(g_tbTouchPriority.network)
	popLayer:addWidget(dlg)
	addToRunningScene(popLayer, nZNetworkFailed)
end

function removeNetworkDlg( ... )
	removeFromRunningScene(nZNetworkFailed)
end

function networkDlgIsShow( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	return runningScene:getChildByTag(nZNetworkFailed)
end


function isInBattle( ... )
	local widget
	for i, layer in ipairs(m_tbLayerStack) do
		widget = layer:getWidgetByTag(nPopLayoutTag)
		if (widget) then
			logger:debug("In Battle wigLayout:getName() = %s", widget:getName())
			if (widget:getName() == g_battleLayout) then
				return true
			end
		end
	end
	return false
end

local function isBattleLayer( layout )
	if (layout) then
		return layout:getName() == g_battleLayout
	end
	return false
end
--[[desc:addLayout弹框调用 不显示放大效果
    arg1: layout
    return: nil
—]]
function addLayoutNoScale(wigLayout, parent, nPriority, customZorder)
	return addLayout(wigLayout,parent,nPriority,customZorder,true)
end
--[[desc:添加一个新的层容器
    wigLayout: 层容器对象
    parent: 要附加到的父容器，如果为nil则默认加到TouchGroup的最高层
    nPriority: 指定特殊的触摸优先级
    customZorder: 指定特殊的Zorder
    scale: nil或false时显示放大效果，true时不显示放大效果
    return:   
—]]


-- menghao 让一个UI在addLayout到屏幕时不会改变颜色,addLayout前调用
local bLockOpacity
function lockOpacity()
	bLockOpacity = true
end


function addLayout( wigLayout, parent, nPriority, customZorder ,scale)
	if (wigLayout) then

		local tbExcept = {"partner_information", "treasure_fetter", "equip_taozhuang_info", "layForShield","copy_result_layout","Explor_mask_layout","Enter_Explor_layout","Activity_Select_Hard_Layout"}
		local lay = tolua.cast(wigLayout, "Layout")
		logger:debug("lay:getName() = %s", lay:getName())
		local bOpacity = not table.include(tbExcept, {lay:getName()})

		logger:debug(bOpacity)
		logger:debug(lay)

		if not scale then
			--liweidong 放大提示框scale==nil或false显示放大效果
			local oriagelayout = wigLayout

			local scalelayout=Layout:create()
			scalelayout:setSize(g_winSize)
			scalelayout:setAnchorPoint(ccp(0.5,0.5))
			scalelayout:setPositionType(POSITION_ABSOLUTE)
			scalelayout:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
			scalelayout:setScale(0.5)
			scalelayout:addChild(oriagelayout)

			local array = CCArray:create()
			local wait1=CCDelayTime:create(0.01)
			local scale1 = CCScaleTo:create(0.08,1.2)
			local fade = CCFadeIn:create(0.06)
			local spawn = CCSpawn:createWithTwoActions(scale1,fade)
			local scale2 = CCScaleTo:create(0.07,0.9)
			local scale3 = CCScaleTo:create(0.07,1)
			array:addObject(wait1)
			array:addObject(scale1)
			array:addObject(scale2)
			array:addObject(scale3)
			local seq = CCSequence:create(array)
			scalelayout:runAction(seq)

			-- local sequence1 = CCSequence:createWithTwoActions(CCDelayTime:create(0.01),CCScaleTo:create(0.1, 1.1))
			-- scalelayout:runAction(CCSequence:createWithTwoActions(sequence1, CCScaleTo:create(0.04, 1.0)))

			wigLayout=Layout:create()
			wigLayout:setSize(g_winSize)
			wigLayout:addChild(scalelayout)
		end

		wigLayout:setTouchEnabled(true)

		if (lay and (bOpacity and not bLockOpacity)) then -- 如果画布名称不在 tbExcept 中才设置半透明
			logger:debug("set background")
			wigLayout:setBackGroundColorType(LAYOUT_COLOR_SOLID) -- 设置单色模式
			wigLayout:setBackGroundColor(ccc3(0x00, 0x00, 0x00))
			wigLayout:setBackGroundColorOpacity(100)
		end
		bLockOpacity = nil

		if (parent) then
			wigLayout.isLayout = true
			parent:addChild(wigLayout)
			-- table.insert(m_tbLayerStack, wigLayout)
			table.insert(m_tbLayoutStack, wigLayout)
			table.insert(m_tbTypeStack, 2)
		else
			-- modified by zhangqi， 为了使CCTableView列表里物品按钮弹出的面板具有屏蔽效果，需要添加一层TouchGroup来吃掉触摸事件
			local popLayer = OneTouchGroup:create() -- TouchGroup:create()
			popLayer:addWidget(wigLayout)
			wigLayout:setTag(nPopLayoutTag)

			local popZ = nZPop + #m_tbLayerStack + 1

			if (customZorder) then -- 如果有给定的Zorder
				popZ = customZorder
			end

			if (nPriority) then
				popLayer:setTouchPriority(nPriority)
			else
				popLayer:setTouchPriority(- #m_tbLayerStack - 1)
			end
			logger:debug("zorder = %d, priority = %d", popZ, popLayer:getTouchPriority())

			local runningScene = CCDirector:sharedDirector():getRunningScene()
			if (not runningScene) then
				runningScene = CCScene:create()
				CCDirector:sharedDirector():runWithScene(runningScene)
			end
			runningScene:addChild(popLayer, popZ, popZ)



			disabledTouchOfOtherLayer(isBattleLayer(wigLayout)) -- 禁用 uiLayer 和 底层的其他 popLayer 的触摸

			table.insert(m_tbLayerStack, popLayer)
			table.insert(m_tbTypeStack, 1)
		end


	end

	addShieldLayout()
	--zhangjunwu 2014-09-12 切换模块之后删除添加的触摸屏蔽层
	begainRemoveUILoading()
end


--[[desc:屏蔽旧界面往新界面传递触摸 添加屏蔽层
    arg1: nil
    return: nil
—]]
function addShieldLayout()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene == nil) then
		return
	end
	local touchLayer = OneTouchGroup:create()
	touchLayer:setTag(nShieldLayoutTag) -- 2015-03-19
	touchLayer:setTouchPriority(g_tbTouchPriority.ShieldLayout)
	local  t_layou = Layout:create()
	t_layou:setTouchEnabled(true)
	touchLayer:addWidget(t_layou)
	runningScene:addChild(touchLayer)

	performWithDelay(runningScene,function()
		local shield = runningScene:getChildByTag(nShieldLayoutTag)
		if (shield) then
			shield:removeFromParentAndCleanup(true)
		end
	end, 0.01)
end

--[[desc:隐藏场景上的所有节点 调用之后必须在退出界面时调用remuseAllLayoutVisible
    arg1: key 标识某个界面 传入moduleName()即可
    return: nil 
—]]
function hideAllLayout(key)
	local scene = CCDirector:sharedDirector():getRunningScene()
	---[[
	visibleViews[key] = CCArray:create()

	visibleViews[key]:retain()

	local sceneChildArray = scene:getChildren()
	for idx=1,sceneChildArray:count() do
		----print("childNode:",idx,sceneChildArray:count() )
		local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx-1),"CCNode")
		if(childNode~=nil and childNode:isVisible()==true and childNode~=topLayer)then
			childNode:setVisible(false)
			visibleViews[key]:addObject(childNode)
		end
	end
end

--[[desc:恢复场景上的所有隐藏节点的显示
    arg1:  key 标识某个界面 传入moduleName即可
    return: nil  
—]]
function remuseAllLayoutVisible(key)
	--CCLuaLog("enter remuseAllLayoutVisible")
	if(visibleViews[key]~=nil)then
		for idx=1,visibleViews[key]:count() do
			local childNode = tolua.cast(visibleViews[key]:objectAtIndex(idx-1),"CCNode")
			if(childNode~=nil)then
				childNode:setVisible(true)
			end
		end
		visibleViews[key]:removeAllObjects()
		visibleViews[key]:release()
		visibleViews[key] = nil
	end
end

function addRemoveLayoutCallback( fnCallback )
	m_fnRemoveLayout = fnCallback
end

-- 删除根容器上最近添加的 其他层容器
function removeLayout( ... )
	if (m_tbTypeStack and (#m_tbTypeStack > 0)) then
		local popType = table.remove(m_tbTypeStack)
		if (popType == 1) then
			if (m_tbLayerStack and (#m_tbLayerStack > 0)) then
				local popLayer = tolua.cast(table.remove(m_tbLayerStack), "CCNode")

				if (popLayer) then
					popLayer:removeFromParentAndCleanup(true)
					enabledTouchOfOtherLayer(isInBattle())
				end
			end
		else
			if (m_tbLayoutStack and (#m_tbLayoutStack > 0)) then
				local layout = table.remove(m_tbLayoutStack)
				if (layout) then
					layout:removeFromParentAndCleanup(true)
				end
			end
		end

		if (m_fnRemoveLayout and type(m_fnRemoveLayout) == "function") then
			m_fnRemoveLayout()
		end
	end
	addShieldLayout()
end

-- 2014-12-04, 指定了popLayer或Layout名称，先查找，如果没有则不做任何操作
function removeLayoutByName( sName )
	if (sName and m_tbTypeStack and (#m_tbTypeStack > 0)) then
		local popType = m_tbTypeStack[#m_tbTypeStack]
		if ( popType == 1 ) then
			if (m_tbLayerStack and (#m_tbLayerStack > 0)) then
				local layout = m_tbLayerStack[#m_tbLayerStack]:getWidgetByName(sName)
				if (layout) then
					removeLayout()
				end
			end
		else
			if (m_tbLayoutStack and (#m_tbLayoutStack > 0)) then
				local layout = m_tbLayoutStack[#m_tbLayoutStack]
				if (layout and layout:getName() == sName ) then
					removeLayout()
				end
			end
		end
	end
end

-- 点击登录按钮后显示的loading面板, 进入主页后自动消失
function addLoginLoading( sPrompt, bNoTimeout )
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	-- if (m_animat:getParent()) then
	-- 	m_animat:removeFromParentAndCleanup(true)
	-- end

	local oldLogin = runningScene:getChildByTag(nZLogin)
	if (oldLogin) then
		return
		-- oldLogin:removeFromParentAndCleanup(true)
	end

	local loginLoading = m_layLoading:clone()

	local labText = m_fnGetWidget(loginLoading, "tfd_wait")
	labText:setText(sPrompt or gi18n[4746])

	local laym_animat = m_fnGetWidget(loginLoading, "LAY_ANIMATION")
	local szAnimat = laym_animat:getSize()
	m_animat = createLoading()
	m_animat:setPosition(ccp(szAnimat.width/2, szAnimat.height/2))
	laym_animat:addNode(m_animat, 100)

	local layer = OneTouchGroup:create()
	layer:setTouchPriority(g_tbTouchPriority.talk)
	layer:addWidget(loginLoading)

	logger:debug("addLoginLoading")

	if (not bNoTimeout) then
		-- 超时 30 秒后自动删除login loading面板，玩家可以继续操作
		m_fnLoginTimeout = GlobalScheduler.scheduleFunc(function ( ... )
			removeLoginLoading()
		end, 60)
	end

	runningScene:addChild(layer, nZLogin, nZLogin)
end

function removeLoginLoading( ... )
	if (m_fnLoginTimeout) then
		m_fnLoginTimeout()
		m_fnLoginTimeout = nil
	end

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nZLogin)) then
		runningScene:removeChildByTag(nZLogin, true)
		logger:debug("removeLoginLoading")
	end
end

-- 发送网络请求显示的loading 面板, removeTimeout: remove自己的超时时间，单位秒，默认10秒
function addLoading(  text)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nZLogin)) then
		logger:debug("Loading exist")
		return
	end

	-- if(not m_layLoading:getParent()) then
	-- 	local popLayer = OneTouchGroup:create()
	-- 	popLayer:setTouchPriority(g_tbTouchPriority.talk)
	-- 	popLayer:addWidget(m_layLoading)
	-- 	local popZ = #m_tbLayerStack + 1 + nZLoading
	-- 	local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- 	runningScene:addChild(popLayer, popZ, nZLoading)
	-- 	logger:debug("addLoading")
	-- else
	-- 	logger:debug("m_layLoading:getParent() = true")
	-- 	return
	-- end

	local layLoading = m_layLoading:clone()
	local popLayer = OneTouchGroup:create()
	popLayer:setTouchPriority(g_tbTouchPriority.talk)
	popLayer:addWidget(layLoading)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(popLayer, nZLoading, nZLoading)
	logger:debug("addLoading")

	local labText = m_fnGetWidget(layLoading, "tfd_wait")
	if text ~= nil then
		labText:setText(text)
	else
		labText:setText("加载中...")
	end
	labText:setText("加载中...")
	layMain = m_fnGetWidget(layLoading, "LAY_MAIN")
	layMain:setVisible(false)

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(0.5))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		if (layMain) then
			local laym_animat = m_fnGetWidget(layLoading, "LAY_ANIMATION")
			local szAnimat = laym_animat:getSize()
			m_animat = createLoading()
			m_animat:setPosition(ccp(szAnimat.width/2+60, szAnimat.height/2))
			laym_animat:addNode(m_animat, 100)
			layMain:setVisible(true)
		end
	end))
	layLoading:runAction(CCSequence:create(actionArray))

	-- 超时 10 秒后自动删除loading面板，玩家可以继续操作
	m_fnLoadingTimeout = GlobalScheduler.scheduleFunc(function ( ... )
		removeLoading()
	end,   20)
end
-- 发送网络请求显示的loading 面板, removeTimeout: remove自己的超时时间，单位秒，默认10秒
function addLoadingByWait( cdfun,removeTimeout )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nZLogin)) then
		logger:debug("Loading exist")
		return
	end
 
	local layLoading = m_layLoading:clone()
	local popLayer = OneTouchGroup:create()
	popLayer:setTouchPriority(g_tbTouchPriority.talk)
	popLayer:addWidget(layLoading)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(popLayer, nZLoading, nZLoading)
	logger:debug("addLoading")

	local labText = m_fnGetWidget(layLoading, "tfd_wait")
	 
	labText:setText("等待其他玩家加入")
	layMain = m_fnGetWidget(layLoading, "LAY_MAIN")
	layMain:setVisible(false)

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(0.5))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		if (layMain) then
			local laym_animat = m_fnGetWidget(layLoading, "LAY_ANIMATION")
			local szAnimat = laym_animat:getSize()
			m_animat = createLoading()
			m_animat:setPosition(ccp(szAnimat.width/2+60, szAnimat.height/2))
			laym_animat:addNode(m_animat, 100)
			layMain:setVisible(true)
		end
	end))
	layLoading:runAction(CCSequence:create(actionArray))

	-- 超时 10 秒后自动删除loading面板，玩家可以继续操作
	m_fnLoadingTimeout = GlobalScheduler.scheduleFunc(function ( ... )
		
		removeLoading()
		cdfun()
	end, removeTimeout or 10)
end

function removeLoading( ... )
	if (m_fnLoadingTimeout) then
		m_fnLoadingTimeout()
		m_fnLoadingTimeout = nil
	end

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nZLoading)) then
		logger:debug("removeLoading: %d", nZLoading)
		runningScene:removeChildByTag(nZLoading, true)
	end
end
-- 模块切换显示的loading 面板，屏蔽按钮
local nZUILogin = 60000
function addUILoading()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nZUILogin)) then
		logger:debug("UILoading  exist")
		return
	end
	local popLayer = OneTouchGroup:create()
	popLayer:setTouchPriority(g_tbTouchPriority.talk)
	--popLayer:addWidget(m_layLoading)
	local popZ = #m_tbLayerStack + 1 + nZUILogin
	runningScene:addChild(popLayer, popZ + 2000000, nZUILogin)
	logger:debug("addUILoading——————————————")
	performWithDelay(runningScene,function()
		begainRemoveUILoading()
	end,10)
end

function begainRemoveUILoading( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if(runningScene and runningScene:getChildByTag(nZUILogin))then
		local actionArray = CCArray:create()
		actionArray:addObject(CCDelayTime:create(0.1))

		actionArray:addObject(CCCallFuncN:create(function ( ... )
			logger:debug("removeUILoading: %d", nZUILogin)
			runningScene:removeChildByTag(nZUILogin, true)
		end))

		runningScene:runAction(CCSequence:create(actionArray))
	end
end


-- add by yangna 2015.4.16 添加需要手动删除的屏蔽层 
local nUILayerTag = 600101
function addUILayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene:getChildByTag(nUILayerTag)) then
		logger:debug("addUILayer  exist")
		return
	end
	local popLayer = OneTouchGroup:create()
	popLayer:setTouchPriority(g_tbTouchPriority.talk)
	runningScene:addChild(popLayer, 2000000, nUILayerTag)
end

--add by yangna 2015.4.16 删除屏蔽层
function removeUILayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if(runningScene and runningScene:getChildByTag(nUILayerTag))then
		local actionArray = CCArray:create()
		actionArray:addObject(CCDelayTime:create(0.1))
		actionArray:addObject(CCCallFuncN:create(function ( ... )
			logger:debug("removeUILoading: %d", nUILayerTag)
			runningScene:removeChildByTag(nUILayerTag, true)
		end))
		runningScene:runAction(CCSequence:create(actionArray))
	end
end


-- 返回当前模块的画布容器对象
function getModuleRootLayout( ... )
	return layModule
end

function getUIGroup( ... )
	return uiLayer
end

function getRootLayout( ... )
	return layRoot
end

function curModuleName( ... )
	return m_strCurName or ""
end

function setCurModuleName( sName )
	m_strCurName = sName
end

function getCurrentPopLayer( ... )
	if (m_tbLayerStack and #m_tbLayerStack > 0) then
		return m_tbLayerStack[#m_tbLayerStack]
	else
		return uiLayer
	end
end


local tbPMDParents = {}
local tbPMDZOrders = {}
function setPaomadeng( curParent, zOrder )
	local PMDParent
	if (table.isEmpty(tbPMDParents)) then
		PMDParent = layRoot
		tbPMDParents = {layRoot}
		tbPMDZOrders = {1}
	else
		PMDParent = tbPMDParents[#tbPMDParents]
	end

	local PMD = PMDParent:getChildByName("PaoMaDeng")
	if (PMD) then
		logger:debug("转移topbar")
		local barType = PMD.tttopBarType
		if (barType == "yellowTB") then
			PMD:removeFromParentAndCleanup(true)
			PMDParent.fngfvbnvbnvbnvn = true
			require "script/module/main/TopBar"
			PMD = TopBar.create(true)
			PMD:setName("PaoMaDeng")
			curParent:addChild(PMD, zOrder or 0, 1)
		else
			PMD:retain()
			PMDParent:removeChild(PMD, false)
			curParent:addChild(PMD, zOrder or 0, 1)
			PMD:release()
		end
	else
		logger:debug("新创建一个topbar")
		require "script/module/main/TopBar"
		PMD = TopBar.create()
		PMD:setName("PaoMaDeng")
		curParent:addChild(PMD, zOrder or 0, 1)

		tbPMDParents = {}
		tbPMDZOrders = {}
	end
	table.insert(tbPMDParents, curParent)
	table.insert(tbPMDZOrders, zOrder or 0)
end

function resetPaomadeng()
	local PMDParent = tbPMDParents[#tbPMDParents]
	table.remove(tbPMDParents)
	table.remove(tbPMDZOrders)
	if (table.isEmpty(tbPMDParents)) then
		logger:debug("移除topbar")
	else
		logger:debug("重置topbar")
		local PMD = PMDParent:getChildByName("PaoMaDeng")
		if (PMD) then
			PMD:retain()
			PMDParent:removeChild(PMD, false)
			PMDParent = tbPMDParents[#tbPMDParents]
			local zOrder = tbPMDZOrders[#tbPMDZOrders]
			if (PMDParent == layRoot) then
				local yellowBar = PMDParent:getChildByName("PaoMaDeng")
				if (PMDParent.fngfvbnvbnvbnvn) then
					-- yellowBar:setEnabled(true)
					-- yellowBar:setVisible(true)
					require "script/module/main/TopBar"
					local PMDNew = TopBar.create()
					PMDNew:setName("PaoMaDeng")
					PMDParent:addChild(PMDNew, zOrder or 0, 1)
				else
					PMDParent:addChild(PMD, zOrder or 1, 1)
				end
			else
				PMDParent:addChild(PMD, zOrder or 0, 1)
			end
			PMD:release()
		end
	end
end
local isDirect  = 11  -- 1 向上滑动，2 向下滑动，3 向左滑动，4 向右滑动
function getIsDirect( ... )
	return isDirect
end
local mainY
function init(...)
	if (not uiLayer) then
		m_strCurName = ""
		uiLayer = OneTouchGroup:create() --
		uiLayer:setTag(55555)
		-- uiLayer:setTouchPriority(-1)

		layRoot = Layout:create()

		layRoot:setSize(g_winSize)
		uiLayer:addWidget(layRoot)

		m_layLoading = g_fnLoadUI("ui/loading.json")
		m_layLoading:setTouchEnabled(true)
		m_layLoading:retain() -- loading 面板始终存在，只控制是否显示，避免频繁重复创建
		-- m_animat = UIHelper.createArmatureNode({
		-- 	filePath = "images/base/effect/load/loading.ExportJson",
		-- 	animationName = "loading-1",
		-- })
		-- m_animat = createLoading()
		-- m_animat:retain()
		-- m_szAni = m_animat:getContentSize()
		-- m_animat:setPosition(m_szAni.width/2, m_szAni.height/2)
	end

	if (not topLayer) then
		topLayer = CCLayer:create()
		topLayer:setTouchEnabled(true)
		local firstx,firsty=0,0
		topLayer:registerScriptTouchHandler(function ( eventType, x, y )
			if (eventType == "began") then
				logger:debug("topLayer on began: x = %f, y = %f", x, y)
				-- print("1")
				firstx,firsty=x,y
				-- 播放例子特效
				local waveNode = CCParticleSystemQuad:create("images/effect/zhu_dianji/zhu_dianji.plist")
				waveNode:setAutoRemoveOnFinish(true)
				waveNode:setPosition(ccp(x, y))
				topLayer:addChild(waveNode)
				return true
			elseif eventType == "moved" then
				-- print("2")
        	elseif eventType=="ended" then
	        	if (firsty-y>20) then
		            isDirect=2
		        elseif(firsty-y<-20) then
		        	isDirect=1
		        else
		        	isDirect=0
		        end
		        print("firstx--"..firstx)
		        print("x--"..x)
		        print("firsty--"..firsty)
		        print("y--"..y)
		        logger:debug("here is lizy: isDirect = %f ", isDirect )
			end
		end,
		false, g_tbTouchPriority.touchEffect)
	end


	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if (runningScene) then
		runningScene:removeAllChildrenWithCleanup(true)
		runningScene:addChild(uiLayer)
		runningScene:addChild(topLayer, 9999999, 9999999)
	else
		local sceneGame = CCScene:create()
		sceneGame:addChild(uiLayer)
		sceneGame:addChild(topLayer, 9999999, 9999999)
		CCDirector:sharedDirector():runWithScene(sceneGame)
	end
end

function destroy(...)
	if (m_layLoading) then
		m_layLoading:release()
	end

	m_layLoading = nil
	m_animat = nil

	m_strCurName = ""
	m_tbLayerStack = nil
	uiLayer = nil
	layRoot = nil

	package.loaded["LayerManager"] = nil
end

function moduleName()
	return "LayerManager"
end

function create(...)

end
