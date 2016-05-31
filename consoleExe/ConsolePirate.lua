-- FileName: ConsolePirate.lua
-- Author: zhangqi
-- Date: 2014-03-25
-- Purpose: 控制台

module("ConsolePirate", package.seeall)

local inputCmd
local btnCommit

local function consoleCallback( cbFlag, dictData, bRet )
	require "script/utils/LuaUtil"
	logger:debug("dictData",dictData)

	if (inputCmd) then
		inputCmd:setText(inputCmd:getText() .. " :" .. dictData.err)
	end
end

local function createEditBoxWithLayout(panel)
	if panel then
		local boxSize = CCSizeMake(400, 60)
		inputCmd = CCEditBox:create(boxSize, CCScale9Sprite:create("ui/login_text_bg.png"))
		inputCmd:setTouchPriority(g_tbTouchPriority.editbox)
		--inputCmd:setFontSize(25);
		inputCmd:setAnchorPoint(ccp(0.5, 0.5))
		inputCmd:setFontColor(ccc3(255,0, 0));
		inputCmd:setPlaceHolder("help");
		inputCmd:setPlaceholderFontColor(ccc3(255,255,255));
		--inputCmd:setMaxLength(8);
		inputCmd:setReturnType(kKeyboardReturnTypeDone);

		local pSize = panel:getSize()
		inputCmd:setPosition(ccp((pSize.width - boxSize.width)/2 + 100, panel:getSize().height - 250))

		local function editboxEventHandler(eventType, sender)
			if eventType == "began" then
				-- triggered when an edit box gains focus after keyboard is shown
				logger:debug("began, text = " .. sender:getText())
			elseif eventType == "ended" then
				-- triggered when an edit box loses focus after keyboard is hidden.
				logger:debug("ended, text = " .. sender:getText())
			elseif eventType == "changed" then
			-- triggered when the edit box text was changed.
			--logger:debug("changed, text = " .. sender:getText())
			elseif eventType == "return" then
				-- triggered when the return button was pressed or the outside area of keyboard was touched.
				logger:debug("return, text = " .. sender:getText())
			end
		end
		inputCmd:registerScriptEditBoxHandler(editboxEventHandler)
		panel:addNode(inputCmd, 99998, 99998)
	end
end

local function createBtn(panel)
	local function btnCommitCallback( sender, eventType )
		--CCLuaLog("btnCommitCarllback touched, eventType = " .. tostring(eventType))
		if (eventType == TOUCH_EVENT_ENDED) then
			local strCmd = inputCmd:getText()
			if (strCmd == "") then
				inputCmd:setText("help")
				strCmd = inputCmd:getText()
			end
			--CCLuaLog("strCmd = " .. strCmd)
			local args = CCArray:createWithObject(CCString:create(strCmd));
			Network.rpc(consoleCallback, "console.execute", "console.execute", args, true)
		end
	end

	btnCommit = Button:create()
	btnCommit:loadTextures("ui/gold.png", "ui/silver.png", nil)
	btnCommit:setScale(2)
	btnCommit:addTouchEventListener(btnCommitCallback)
	local x, y = inputCmd:getPosition()
	btnCommit:setPosition(ccp(x, y - inputCmd:getContentSize().height))
	panel:addChild(btnCommit, 99999, 99999)
end

function create(rootLayer)
	createEditBoxWithLayout(rootLayer)
	createBtn(rootLayer)
end
