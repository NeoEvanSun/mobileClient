-- FileName: UserNameView.lua
-- Author: menghao
-- Date: 2014-07-16
-- Purpose: 输入角色名view


module("UserNameView", package.seeall)


require "script/module/public/ShowNotice"


-- UI控件引用变量 --
local m_UIMain
local m_imgType -- 输入框附加到的背景图片


-- 模块局部变量 --
local m_ExpCollect = ExceptionCollect:getInstance()
local m_fnGetWidget = g_fnGetWidgetByName
local mi18n = gi18n

local nameEditBox
local m_nFlag
local m_tbNames
local m_strName
local m_nCurIndex
local m_tagLabName = 3333 -- 实现昵称居中效果的辅助Label的tag


local function init(...)

end


function destroy(...)
	package.loaded["UserNameView"] = nil
end


function moduleName()
	return "UserNameView"
end


-- 创建角色按钮的网络回调函数
local function createuserAction(cbFlag, dictData, bRet)
	-- 创建不成功要移除屏蔽层，成功会跳到其他模块
	if (not bRet) then
		m_ExpCollect:info("UserNameView", "bRet = " .. tostring(bRet))
		LayerManager.removeLayout()
		nameEditBox:setTouchEnabled(true)
		return
	end

	if (dictData.ret ~= "ok") then
		m_ExpCollect:info("UserNameView", "createuserAction dictData.ret ~= ok " .. tostring(dictData.ret))
		LayerManager.removeLayout()
		nameEditBox:setTouchEnabled(true)
	end

	if (dictData.ret == "ok") then
		m_ExpCollect:finish("UserNameView")

		ShowNotice.showShellInfo(mi18n[1912])

		m_ExpCollect:start("connectAndLogin", "UserNameView.createuserAction")
		Network.rpc(UserHandler.fnGetUsers, "user.getUsers", "user.getUsers", nil, true)
		return
	elseif (dictData.ret == "invalid_char") then
		ShowNotice.showShellInfo(mi18n[1913])
		return
	elseif (dictData.ret == "sensitive_word") then
		ShowNotice.showShellInfo(mi18n[1913])
		return
	elseif (dictData.ret == "name_used") then
		ShowNotice.showShellInfo(mi18n[1914])
		return
	end
end


-- 汉字的 utf8 转换
local function getStringLength(str)
	local strLen = 0
	local i =1
	while i<= #str do
		if(string.byte(str,i) > 127) then
			-- 汉字
			strLen = strLen + 2
			i= i+ 3
		else
			i =i+1
			strLen = strLen + 1
		end
	end
	return strLen
end


-- 获取随机名字请求返回后回调
local function randomNameAction( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		m_ExpCollect:info("UserNameView", "randomNameAction err = " .. tostring(dictData.err))
		return
	end
	m_tbNames = dictData.ret
	if(table.isEmpty(m_tbNames)) then
		m_ExpCollect:info("UserNameView", "randomName table is empty")
		ShowNotice.showShellInfo(mi18n[1917])
		return
	end
	m_strName = m_tbNames[1].name
	m_nCurIndex = 1

	local labName = m_imgType:getChildByTag(m_tagLabName)
	if (not labName) then
		labName = Label:create()
		labName:setTag(m_tagLabName)
		labName:setFontSize(28)
		m_imgType:addChild(labName)
	end
	labName:setText(m_strName)
end


-- 获取随机名字的网络请求
local function getRandomName( ... )
	local args = CCArray:create()
	args:addObject(CCInteger:create(20))
	args:addObject(CCInteger:create(m_nFlag))
	RequestCenter.user_getRandomName(randomNameAction, args)
end


-- 创建角色按钮事件
local onNext = function ( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playEnter()

		local args = CCArray:create()
		args:addObject(CCInteger:create(m_nFlag + 1))
		args:addObject(CCString:create(m_strName))
		if m_strName == "" then
			ShowNotice.showShellInfo(mi18n[1915])
			return
		end
		if getStringLength(m_strName) > 12 then
			ShowNotice.showShellInfo(mi18n[1916])
			return
		end

		-- 加屏蔽层
		local layout = Layout:create()
		layout:setName("layForShield")
		LayerManager.addLayout(layout)
		nameEditBox:setTouchEnabled(false)

		m_ExpCollect:info("UserNameView", "nickname = " .. tostring(m_strName))
		RequestCenter.user_createUser(createuserAction, args)
	end
end


-- 随机名字事件
local onRandom = function ( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		AudioHelper.playBtnEffect("shaizi.mp3")
		if(table.isEmpty(m_tbNames)) then
			ShowNotice.showShellInfo(mi18n[1917])
			return
		end

		m_nCurIndex = m_nCurIndex + 1
		if(m_nCurIndex <= 20 ) then
			m_strName = m_tbNames[m_nCurIndex].name
			-- nameEditBox:setText("" .. m_tbNames[m_nCurIndex].name)
			local labName = m_imgType:getChildByTag(m_tagLabName)
			labName:setText(m_strName)
		else
			getRandomName()
		end
	end
end


local function showArmature11( widget, call )
	local armature11 = UIHelper.createArmatureNode({
		filePath = "images/effect/shop_recruit/zhao1_1.ExportJson",
		fnMovementCall = function ( sender, MovementEventType , frameEventName)
			if (MovementEventType == 1) then

			end
		end
	})
	local bone0101 = armature11:getBone("zhao1_1_01_01")
	local filePath = "images/base/hero/body_img/body_elite_lufeilan.png"

	local ccSkin0101 = CCSkin:create(filePath)
	bone0101:addDisplay(ccSkin0101,0)
	local bone01 = armature11:getBone("zhao1_1_01")
	local ccSkin01 = CCSkin:create(filePath)
	bone01:addDisplay(ccSkin01, 0)

	armature11:getAnimation():play("zhao1_1_1", -1, -1, 0)
	widget:addNode(armature11)
end


local function showArmature2( widget )
	local armature2 = UIHelper.createArmatureNode({
		filePath = "images/effect/shop_recruit/zhao2.ExportJson",
		animationName = "zhao2",
		fnMovementCall = function ( sender, MovementEventType, frameEventName )
			if (MovementEventType == 1) then
				sender:removeFromParentAndCleanup(true)
				performWithDelay(m_UIMain, showArmature2, 1)
			end
		end
	})
	widget:addNode(armature2)
end


local function showArmature4( widget )
	local armature4 = UIHelper.createArmatureNode({
		filePath = "images/effect/shop_recruit/zhao4.ExportJson",
	})
	local bone = armature4:getBone("zhao4_1")
	local ccSkin = CCSkin:create("images/base/hero/body_img/body_elite_lufeilan.png")
	bone:addDisplay(ccSkin, 0)
	armature4:getAnimation():play("zhao4_1", -1, -1, 0)
	widget:addNode(armature4)
end


local function showArmature3( widget )
	local armature3 = UIHelper.createArmatureNode({
		filePath = "images/effect/shop_recruit/zhao3.ExportJson",
		animationName = "zhao3",
	})
	widget:addNode(armature3)
end


local function showArmature1( widget, call )
	local armature1 = UIHelper.createArmatureNode({
		filePath = "images/effect/shop_recruit/zhao1.ExportJson",
		animationName = "zhao1",
		fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
			if (frameEventName == "2") then
				showArmature3(widget)
				showArmature4(widget)
				showArmature2(widget)
			elseif (frameEventName == "1") then
				showArmature11(widget)
			elseif (frameEventName == "6") then
				call()
			end
		end
	})
	armature1:getAnimation():gotoAndPlay(148)
	local fScale = g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY
	armature1:setScale(fScale)
	widget:addNode(armature1)
end


function playEstablish( widget, call )
	local tbParams = {
		filePath = "images/effect/create_user/establish.ExportJson",
		animationName = "establish",
		fnMovementCall = function ( sender, MovementEventType , frameEventName)
			if (MovementEventType == 0) then
			elseif (MovementEventType == 1) then
				local time = os.clock()
				showArmature1(widget, call)
				local time1 = os.clock()
				logger:debug(time1 - time)
			elseif (MovementEventType == 2) then
			end
		end,
	}
	local armature = UIHelper.createArmatureNode(tbParams)
	widget:addNode(armature)
end


function playEstablishTalk( widget, call )
	local tbParams = {
		filePath = "images/effect/create_user/establish_talk.ExportJson",
		animationName = "establish_talk",
	}
	local armature = UIHelper.createArmatureNode(tbParams)
	widget:addNode(armature)
end


function create(isNanSelected)
	m_ExpCollect:start("UserNameView", "create isNanSelected = " .. tostring(isNanSelected))

	m_UIMain = g_fnLoadUI("ui/regist_name.json")

	local layMain = m_fnGetWidget(m_UIMain, "LAY_MAIN")

	local btnNext = m_fnGetWidget(m_UIMain, "BTN_NEXT")
	m_imgType = m_fnGetWidget(m_UIMain, "IMG_TYPE")
	local btnRandom = m_fnGetWidget(m_UIMain, "BTN_RANDOM")
	local imgPlz = m_fnGetWidget(m_UIMain, "img_plz_type")

	btnNext:setEnabled(false)
	m_imgType:setEnabled(false)
	imgPlz:setEnabled(false)

	btnNext:addTouchEventListener(onNext)
	btnRandom:addTouchEventListener(onRandom)

	nameEditBox = UIHelper.createEditBox(CCSizeMake(180, 56), "images/base/potential/input_name_bg1.png", false)
	nameEditBox:setFontSize(28)
	nameEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
	nameEditBox:setMaxLength(12)
	nameEditBox:setReturnType(kKeyboardReturnTypeDone)
	nameEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
	m_imgType:addNode(nameEditBox)

	-- zhangqi, 2015-03-24, 为了实现昵称居中显示，创建一个Label来代替editBox的显示
	UIHelper.bindEventToEditBox({inputBox = nameEditBox, onEnded = function ( ... )
		m_strName = nameEditBox:getText()
		local labName = m_imgType:getChildByTag(m_tagLabName)
		labName:setText(m_strName)
		nameEditBox:setText("")
	end, onBegan = function ( ... )
		local labName = m_imgType:getChildByTag(m_tagLabName)
		nameEditBox:setText(labName:getStringValue())
		labName:setText("")
	end})

	if isNanSelected then
		m_nFlag = 1
	else
		m_nFlag = 0
	end

	local imgLeader = m_fnGetWidget(m_UIMain, "IMG_LEADER")
	local imgChatBG = m_fnGetWidget(m_UIMain, "img_chat_bg")
	local tfdContent = m_fnGetWidget(m_UIMain, "TFD_CHAT_CONTENT")

	-- imgLeader:setEnabled(false)
	imgChatBG:setEnabled(false)
	tfdContent:setEnabled(false)

	tfdContent:setText(gi18n[4756])

	getRandomName()

	local tbWidgets = {imgChatBG, m_imgType, imgPlz}

	btnNext:setTouchEnabled(false)
	btnRandom:setTouchEnabled(false)
	nameEditBox:setTouchEnabled(false)

	playEstablish(imgLeader, function ( ... )
		local function play( i )
			if (i > #tbWidgets) then
				btnNext:setTouchEnabled(true)
				btnRandom:setTouchEnabled(true)
				nameEditBox:setTouchEnabled(true)

				performWithDelay(m_UIMain, function ( ... )
					playEstablishTalk(btnNext, function ( ... )
						end)
				end, 40 / 60)
				return
			end

			local n = i == 1 and 0.63 or 1

			tbWidgets[i]:setScaleY(0.2)
			tbWidgets[i]:setEnabled(true)
			local actionArr1 = CCArray:create()
			actionArr1:addObject(CCScaleTo:create(6 / 60, 1 * n, 1.2 * n))
			actionArr1:addObject(CCScaleTo:create(6 / 60, 1 * n, 0.8 * n))
			actionArr1:addObject(CCScaleTo:create(6 / 60, 1 * n, 1 * n))
			actionArr1:addObject(CCDelayTime:create(6 / 60))
			actionArr1:addObject(CCCallFunc:create(function ( ... )
				if (i > 1) then
					play(i + 1)
					return
				end
				btnNext:setEnabled(true)
				btnNext:setScaleY(0.2)
				btnNext:setScaleY(0)
				local x, y = btnNext:getPosition()
				local actionArr2 = CCArray:create()
				actionArr2:addObject(CCPlace:create(ccp(x + 428, y)))
				actionArr2:addObject(
					CCSpawn:createWithTwoActions(
						CCScaleTo:create(10 / 60, 1, 1.2),
						CCMoveTo:create(10 / 60, ccp(x - 31, y))
					)
				)
				actionArr2:addObject(
					CCSpawn:createWithTwoActions(
						CCScaleTo:create(2 / 60, 1, 1),
						CCMoveTo:create(2 / 60, ccp(x, y))
					)
				)
				actionArr2:addObject(CCCallFunc:create(function ( ... )
					play(i + 1)
				end))
				btnNext:runAction(CCSequence:create(actionArr2))
			end))
			tbWidgets[i]:runAction(CCSequence:create(actionArr1))
		end

		play(1)
	end)

	return m_UIMain
end

