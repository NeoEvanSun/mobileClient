-- FileName: NewGuyHelper.lua
-- Author: menghao
-- Date: 2014-10-24
-- Purpose: 创建新角色相关

module("NewGuyHelper", package.seeall)


-- UI控件引用变量 --


-- 模块局部变量 --
local isPlaying
local m_ExpCollect = ExceptionCollect:getInstance()


function createBtnSkip( layout, callback )
	local btnSkip = Button:create()
	btnSkip:loadTextureNormal("images/effect/kaichangmanhu/skip_n.png")
	btnSkip:loadTexturePressed("images/effect/kaichangmanhu/skip_p.png")
	btnSkip:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			callback()
		end
	end)
	btnSkip:setPosition(ccp(560, g_winSize.height - 170))
	btnSkip:setZOrder(99)
	layout:addChild(btnSkip)
end


-- 开场 罗杰相关
function showLuojie( callback )
	-- 黑屏和漫画
	if (isPlaying) then
		return
	end

	isPlaying = true

	local layout = Layout:create()
	layout:setSize(g_winSize)
	LayerManager.changeModule(layout, "kaichang", {})

	createBtnSkip(layout, function ( ... )
		AudioHelper.stopMusic()
		callback()
	end)

	local function newAndAddArmature( ... )
		for k, v in pairs({...}) do
			local armature = UIHelper.createArmatureNode({
				filePath = "images/effect/kaichangmanhu/kaichang" .. v .. ".ExportJson",
				animationName = "kaichang" .. v,
				loop = (v == "_1") and 1 or 0,
				fnMovementCall = function ( sender, MovementEventType , frameEventName)
					if (MovementEventType == 1) then
						logger:debug("动画结束" .. v)
						performWithDelay(layout, function ( ... )
							sender:removeFromParentAndCleanup(true)
							if (v == "_2") then
								isPlaying = false
								callback()
							end
						end, 0.33)
					end
				end,

				fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
					if (frameEventName == "1") then
						logger:debug("移除黑线")
						layout:removeNodeByTag(666)
					end
				end
			})

			if (v == "") then
				-- AudioHelper.setMusicVolume(0)
				-- AudioHelper.playSpecialEffect("AT_luojie.mp3")
				AudioHelper.playMusic("audio/effect/AT_luojie.mp3", false)
			end

			if (v == "_1") then
				armature:setTag(666)
			end

			local fScale = g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY
			armature:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
			armature:setScale(g_fScaleX)
			layout:addNode(armature)
		end
	end

	newAndAddArmature("", "_2", "_1")
	m_ExpCollect:info("NewGuyHelper", "showLuojie ok")
end


-- 创建漫画层
local function showManhua( layout )
	local index = 1
	local layoutManhua = Layout:create()
	layoutManhua:setSize(g_winSize)
	layout:addChild(layoutManhua)

	local function addArmatureFinger( ... )
		local armature = UIHelper.createArmatureNode({
			filePath = "images/effect/guide/zhishi_2.ExportJson",
			animationName = "zhishi_2",
		})
		armature:setPosition(ccp(g_winSize.width * 0.9, g_winSize.height * 0.1))
		layoutManhua:addNode(armature)
		layoutManhua:setTouchEnabled(true)
	end

	local function addArmature( armature )
		armature:getAnimation():setSpeedScale(0.8)
		armature:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
		layoutManhua:addNode(armature)
	end

	local function playArmature3( ... )
		local armature = UIHelper.createArmatureNode({
			filePath = "images/effect/kaichangmanhu/piantou3.ExportJson",
			animationName = "piantou3",
			loop = 0,
			fnMovementCall = function ( sender, MovementEventType , frameEventName)
				if (MovementEventType == 1) then
					addArmatureFinger()
				end
			end,
			fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
				if (frameEventName == "a02") then
					if (UserModel.getUserSex() == 1) then
						AudioHelper.playSpecialEffect("AT_male_02.mp3")
					else
						AudioHelper.playSpecialEffect("AT_female_02.mp3")
					end
				end
			end
		})

		AudioHelper.playSpecialEffect("AT_03.mp3")
		-- 如果为女
		if (UserModel.getUserSex() == 2) then
			local ccSkin1 = CCSkin:create("images/effect/kaichangmanhu/piantou3_2_nv.png")
			local ccSkin2 = CCSkin:create("images/effect/kaichangmanhu/piantou3_3_nv.png")
			armature:getBone("piantou3_2"):addDisplay(ccSkin1, 0)
			armature:getBone("piantou3_3"):addDisplay(ccSkin2, 0)
		end

		addArmature(armature)
	end

	local function playArmature2( ... )
		local armature = UIHelper.createArmatureNode({
			filePath = "images/effect/kaichangmanhu/piantou2.ExportJson",
			animationName = "piantou2",
			loop = 0,
			fnMovementCall = function ( sender, MovementEventType , frameEventName)
				if (MovementEventType == 1) then
					performWithDelay(layoutManhua, addArmatureFinger, 0.5)
				end
			end,
			fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
				if (frameEventName == "a01") then
					if (UserModel.getUserSex() == 1) then
						AudioHelper.playSpecialEffect("AT_male_01.mp3")
					else
						AudioHelper.playSpecialEffect("AT_female_01.mp3")
					end
				end
			end
		})

		AudioHelper.playSpecialEffect("AT_02.mp3")
		-- 如果为女
		if (UserModel.getUserSex() == 2) then
			local ccSkin1 = CCSkin:create("images/effect/kaichangmanhu/piantou2_3_nv.png")
			armature:getBone("piantou2_3"):addDisplay(ccSkin1, 0)
		end

		addArmature(armature)
	end

	local function playArmature1( ... )
		local armature = UIHelper.createArmatureNode({
			filePath = "images/effect/kaichangmanhu/piantou1.ExportJson",
			animationName = "piantou1",
			loop = 0,
			fnMovementCall = function ( sender, MovementEventType , frameEventName)
				if (MovementEventType == 1) then
					performWithDelay(layoutManhua, addArmatureFinger, 0.5)
				end
			end,
		})

		-- 如果为女
		if (UserModel.getUserSex() == 2) then
			local ccSkin1 = CCSkin:create("images/effect/kaichangmanhu/piantou1_2_nv.png")
			local ccSkin2 = CCSkin:create("images/effect/kaichangmanhu/piantou1_5_nv.png")
			armature:getBone("piantou1_2"):addDisplay(ccSkin1, 0)
			armature:getBone("piantou1_5"):addDisplay(ccSkin2, 0)
		end

		addArmature(armature)
		AudioHelper.setMusicVolume(0)
		AudioHelper.playSpecialEffect("AT_01.mp3")
		AudioHelper.playMusic("audio/effect/AT_01.mp3", false)
	end

	layoutManhua:setTouchEnabled(false)
	layoutManhua:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playSpecialEffect("dianjipingmu.mp3")
			logger:debug("layoutManhuaTouched")
			if (index == 3) then
				MainCopy.enterGuildBattle()
			end
			if (index < 3) then
				layoutManhua:removeAllChildrenWithCleanup(true)
				layoutManhua:removeAllNodes()
			end®
			if (index == 1) then
				layoutManhua:setTouchEnabled(false)
				playArmature2()
			elseif (index == 2) then
				layoutManhua:setTouchEnabled(false)
				playArmature3()
			end
			index = index + 1
		end
	end)

	playArmature1()
	m_ExpCollect:info("NewGuyHelper", "showManhua ok")
end


-- 黑屏显示
local function blackScene( layout )
	local tbStrWords = {gi18nString(4601, "  "), gi18nString(4602, "  "), gi18nString(4603, "  ")}

	local function showLabelI( i )
		if (i > #tbStrWords) then
			MainCopy.enterGuildBattle()
			return
		end

		local speedScale = i == 1 and 0.5 or 1

		local label = CCLabelTTF:create(tbStrWords[i], g_FontInfo.name, 36,
			CCSizeMake(g_winSize.width * 0.9, 360), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
		label:setColor(ccc3(255, 255, 255))
		label:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
		layout:addNode(label)

		local acitonArray = CCArray:create()
		acitonArray:addObject(CCFadeIn:create(1.5 * speedScale))
		acitonArray:addObject(CCDelayTime:create(2 * speedScale))
		if (i ~= #tbStrWords) then
			acitonArray:addObject(CCFadeOut:create(1 * speedScale))
		end
		acitonArray:addObject(CCCallFunc:create(function ( ... )
			-- showManhua(layout)
			showLabelI(i + 1)
		end))
		label:runAction(CCSequence:create(acitonArray))
	end
	showLabelI(1)
	m_ExpCollect:info("NewGuyHelper", "showLabelI(1)")
end


-- menghao 新号进入的过场剧情漫画 modified by huxiaozhou
function enterGuide( ... )
	m_ExpCollect:start("NewGuyHelper", "begin enterGuide")

	-- 黑屏和漫画
	local layout = Layout:create()
	createBtnSkip(layout, MainCopy.enterGuildBattle)
	layout:setSize(g_winSize)
	LayerManager.changeModule(layout, "start", {})

	blackScene(layout)
end

