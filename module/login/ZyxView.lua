-- FileName: ZyxView.lua
-- Author: zhangqi
-- Date: 2014-11-03
-- Purpose: 登陆最游戏平台的视图（view)模块
--[[TODO List]]

module("ZyxView", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n

local m_ebBg = "images/base/potential/input_name_bg1.png"
local m_ebHolderColor = ccc3(0xc3, 0xc3, 0xc3)
local m_allText = {account = "", pwd = "", email = "", newPwd = "", pwdConfirm = ""}
local m_InputTag = {account = 111, pwd = 222, newPwd = 333, email = 444, pwdConfirm = 555}
local m_InputName = {[111] = "account", [222] = "pwd", [333] = "newPwd", [444] = "email", [555] = "pwdConfirm"}

m_dlgName = "ZYX_LOGIN" -- 2014-12-04, 所有最游戏面板的统一命名，便于请求成功后删除面板

local function init(...)

end

function destroy(...)
	package.loaded["ZyxView"] = nil
end

function moduleName()
	return "ZyxView"
end

function create(...)

end

function getAllInputText()
	return m_allText
end

function resetAllInputText( ... )
	for k, v in pairs(m_allText) do
		m_allText[k] = ""
	end
	logger:debug("resetAllInputText")
	logger:debug(m_allText)
end

local function bindEventToEditBox( tbArgs )
	local function editboxEventHandler(eventType, sender)
		if eventType == "began" then
			local x,y = sender:getPosition()
			sender:setPosition(ccp(x,y))
			-- triggered when an edit box gains focus after keyboard is shown
			logger:debug("began, text = " .. sender:getText())
			if (tbArgs.onBegan and type(tbArgs.onBegan) == "function") then
				tbArgs.onBegan()
			end
		elseif eventType == "ended" then
			-- triggered when an edit box loses focus after keyboard is hidden.
			logger:debug("ended, text = " .. sender:getText())
			if (tbArgs.onEnded and type(tbArgs.onEnded) == "function") then
				tbArgs.onEnded()
			end
		elseif eventType == "changed" then
			-- triggered when the edit box text was changed.
			logger:debug("changed, text = " .. sender:getText())
			if (tbArgs.onChanged and type(tbArgs.onChanged) == "function") then
				tbArgs.onChanged()
			end
		elseif eventType == "return" then
			-- triggered when the return button was pressed or the outside area of keyboard was touched.
			logger:debug("return, text = " .. sender:getText())
			if (tbArgs.onReturn and type(tbArgs.onReturn) == "function") then
				tbArgs.onReturn()
			end
			m_allText[m_InputName[sender:getTag()]] = sender:getText()
			logger:debug(m_allText)
			UIHelper.clearTouchStat()
		end
	end
	tbArgs.inputBox:registerScriptEditBoxHandler(editboxEventHandler)
end

local function addAccountEdit( layRoot, contentText )
	local imgBg = m_fnGetWidget(layRoot, "IMG_ACCUNT_NUMBER_BG")
	local bgSize = imgBg:getSize()
	local tbEbCfg = { size = CCSizeMake(bgSize.width, bgSize.height), bg = m_ebBg,
		content = contentText, holder = m_i18n[4703], holderColor = m_ebHolderColor, maxLen = 20,
		RetrunType = kKeyboardReturnTypeDone, InputMode = kEditBoxInputModeSingleLine,
	}
	local editbox = UIHelper.createEditBoxNew(tbEbCfg)
	editbox:setInputFlag(kEditBoxInputFlagSensitive)
	imgBg:addNode(editbox)
	editbox:setTag(m_InputTag.account)

	local ebArgs = {inputBox = editbox}
	bindEventToEditBox(ebArgs)

	if (contentText) then
		m_allText[m_InputName[m_InputTag.account]] = contentText -- 避免文本框没有事件导致没有把账户名保存到table
	end

	return editbox
end

local function addPwdEdit( layRoot, ebImgBgName, nTag, contentText, sHolder )
	local imgBg = m_fnGetWidget(layRoot, ebImgBgName)
	local bgSize = imgBg:getSize()
	local tbEbCfg = { size = CCSizeMake(bgSize.width, bgSize.height), bg = m_ebBg,
		holder = sHolder, holderColor = m_ebHolderColor, maxLen = 20,
		RetrunType = kKeyboardReturnTypeDone, InputFlag = kEditBoxInputFlagPassword,
	}
	local editbox = UIHelper.createEditBoxNew(tbEbCfg)
	imgBg:addNode(editbox)
	editbox:setTag(nTag)
	editbox:setText(contentText or "")

	local ebArgs = {inputBox = editbox}
	bindEventToEditBox(ebArgs)

	if (contentText) then
		m_allText[m_InputName[m_InputTag.pwd]] = contentText -- 避免文本框没有事件导致没有把密码保存到table
	end

	return editbox
end

local function addEmailEdit( layRoot )
	local imgBg = m_fnGetWidget(layRoot, "IMG_MAIL_BG")
	local bgSize = imgBg:getSize()
	local tbEbCfg = { size = CCSizeMake(bgSize.width, bgSize.height), bg = m_ebBg,
		holder = m_i18n[4706], holderColor = m_ebHolderColor, maxLen = 20,
		RetrunType = kKeyboardReturnTypeDone, InputMode = kEditBoxInputModeEmailAddr,
	}
	local editbox = UIHelper.createEditBoxNew(tbEbCfg)
	imgBg:addNode(editbox)
	editbox:setTag(m_InputTag.email)

	local ebArgs = {inputBox = editbox}
	bindEventToEditBox(ebArgs)

	return editbox
end

-- 一键清除按钮
local function setResetButton( layParent, tbEditBox )
	local btnReset = m_fnGetWidget(layParent, "BTN_DELETE")
	btnReset:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			for k, inputBox in pairs(tbEditBox) do
				inputBox:setText("")
			end
			m_allText.account = ""
			m_allText.pwd = ""
		end
	end)
	btnReset:setEnabled(tbEditBox.account:getText() ~= "") -- 如果账户名不为空才可用
end

-- 带试玩按钮的登陆界面
function showLogin( tbData )
	local laySignIn = nil
	if (tbData.guest) then -- 2015-03-19
		laySignIn = g_fnLoadUI("ui/sign_in.json")
	else
		laySignIn = g_fnLoadUI("ui/sign_in_other.json")
	end

	laySignIn:setName(m_dlgName)
	LayerManager.addLayout(laySignIn)

	local i18n_topTip = m_fnGetWidget(laySignIn, "tfd_explain")
	i18n_topTip:setText(m_i18n[4702]) -- "使用巴别时代最游戏账号可直接登录"
	i18n_topTip:setEnabled(true) -- 2015-03-19 封测包隐藏

	-- 2015-03-19 封测包隐藏
	-- local tbHide = {"img_accunt_number", "IMG_ACCUNT_NUMBER_BG", "BTN_DELETE", "img_password",
	-- 				"IMG_PASSWORD_BG", "BTN_REGISTER_NEW", "BTN_SIGN_IN"}
	-- for i, v in ipairs(tbHide) do
	-- 	local widget = m_fnGetWidget(laySignIn, v)
	-- 	if (widget) then
	-- 		widget:setEnabled(false)
	-- 	end
	-- end


	local btnClose = m_fnGetWidget(laySignIn, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	if (tbData.guest) then
		local layGuest = m_fnGetWidget(laySignIn, "lay_sign_in_bindling_btn")

		if (tbData.guest) then
			local btn = m_fnGetWidget(laySignIn, "BTN_NOW_GAME")
			if (tbData.eventTry) then -- 试玩
				btn:addTouchEventListener(tbData.eventTry)
			else -- 如果底层获取不到UDID, 则不显示试玩按钮和说明文字图片
				btn:setEnabled(false)
				btn:setVisible(false)
				local imgText = m_fnGetWidget(laySignIn, "img_text")
				img_text:setEnabled(false)
			end
		end
	else
		local laySign = m_fnGetWidget(laySignIn, "lay_sign_in_btn")
		local layOtherSign = m_fnGetWidget(laySignIn, "lay_sign_in_other_btn")

		if (tbData.other) then -- 账户列表切换其他用户
			laySign:removeFromParentAndCleanup(true)
		else -- 当前已登陆账户
			layOtherSign:removeFromParentAndCleanup(true)

			if (tbData.eventChangePwd) then -- 修改密码
				local btn = m_fnGetWidget(laySignIn, "BTN_REVISE_PASSWORD")
				btn:addTouchEventListener(tbData.eventChangePwd)
				UIHelper.titleShadow(btn, m_i18n[4713])
			end
		end
	end

	if (tbData.eventLogin) then -- 登陆
		local btn = m_fnGetWidget(laySignIn, "BTN_SIGN_IN")
		btn:addTouchEventListener(tbData.eventLogin)
		UIHelper.titleShadow(btn, m_i18n[4715])
	end

	if (tbData.eventRegist) then -- 注册
		local btn = m_fnGetWidget(laySignIn, "BTN_REGISTER_NEW")
		btn:addTouchEventListener(tbData.eventRegist)
		UIHelper.titleShadow(btn, m_i18n[4714])
	end

	-- 附加帐号的editbox
	local ebAccount = addAccountEdit(laySignIn, tbData.account) -- 2015-03-19，封测包

	-- 密码的editbox
	local ebPwd = addPwdEdit(laySignIn, "IMG_PASSWORD_BG", m_InputTag.pwd, tbData.pwd, m_i18n[4704])

	-- 一键清除按钮
	setResetButton(laySignIn, {account = ebAccount, pwd = ebPwd})
end

-- 普通登陆和带修改密码的登陆界面
function showOtherLogin( tbData )
	local laySignIn = nil
	if (tbData.guest) then
		laySignIn = g_fnLoadUI("ui/sign_in.json")
	else
		laySignIn = g_fnLoadUI("ui/sign_in_other.json")
	end

	local i18n_topTip = m_fnGetWidget(laySignIn, "tfd_explain")
	i18n_topTip:setText(m_i18n[4702]) -- "使用巴别时代最游戏账号可直接登录"

	local btnClose = m_fnGetWidget(laySignIn, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	local laySign = m_fnGetWidget(laySignIn, "lay_sign_in_btn")
	local layOtherSign = m_fnGetWidget(laySignIn, "lay_sign_in_other_btn")

	if (tbData.other) then -- 账户列表切换其他用户
		laySign:removeFromParentAndCleanup(true)
	else -- 当前已登陆账户
		layOtherSign:removeFromParentAndCleanup(true)

		if (tbData.eventChangePwd) then -- 修改密码
			local btn = m_fnGetWidget(laySignIn, "BTN_REVISE_PASSWORD")
			btn:addTouchEventListener(tbData.eventChangePwd)
			UIHelper.titleShadow(btn, m_i18n[4713])
		end
	end

	if (tbData.eventLogin) then -- 登陆
		local btn = m_fnGetWidget(laySignIn, "BTN_SIGN_IN")
		btn:addTouchEventListener(tbData.eventLogin)
		UIHelper.titleShadow(btn, m_i18n[4715])
	end

	if (tbData.eventRegist) then -- 注册
		local btn = m_fnGetWidget(laySignIn, "BTN_REGISTER_NEW")
		btn:addTouchEventListener(tbData.eventRegist)
		UIHelper.titleShadow(btn, m_i18n[4714])
	end

	laySignIn:setName(m_dlgName)
	LayerManager.addLayout(laySignIn)

	-- 附加帐号的editbox
	local ebAccount = addAccountEdit(laySignIn, tbData.account)

	-- 密码的editbox
	local ebPwd = addPwdEdit(laySignIn, "IMG_PASSWORD_BG", m_InputTag.pwd, tbData.pwd, m_i18n[4704])

	-- 一键清除按钮
	setResetButton(laySignIn, {account = ebAccount, pwd = ebPwd})
end

-- 注册界面
function showRegister( tbData )
	local layReg = g_fnLoadUI("ui/register_account.json")
	layReg:setName(m_dlgName)
	LayerManager.addLayout(layReg)

	local btnClose = m_fnGetWidget(layReg, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	local ebAccount = addAccountEdit(layReg, tbData.account)
	local ebPwd = addPwdEdit(layReg, "IMG_PASSWORD_BG", m_InputTag.pwd, "", m_i18n[4704])
	local ebPwdConfirm = addPwdEdit(layReg, "IMG_CONFIRMATION_PASSWORD_BG", m_InputTag.pwdConfirm, "", m_i18n[4705])
	local ebMail = addEmailEdit(layReg)

	local btnConfirm = m_fnGetWidget(layReg, "BTN_SIGN_IN")
	btnConfirm:addTouchEventListener(tbData.eventConfirm)
	UIHelper.titleShadow(btnConfirm, m_i18n[4716])
end

-- 修改密码界面
function showChangePwd( tbData )
	local layPwd = g_fnLoadUI("ui/revise_password.json")
	layPwd:setName(m_dlgName)
	LayerManager.addLayout(layPwd)

	local btnClose = m_fnGetWidget(layPwd, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	local ebAccount = addAccountEdit(layPwd, tbData.account)
	local ebOldPwd = addPwdEdit(layPwd, "IMG_OLD_PASSWORD_BG", m_InputTag.pwd, "", m_i18n[4710])
	local ebNewPwd = addPwdEdit(layPwd, "IMG_NEW_PASSWORD_BG", m_InputTag.newPwd, "", m_i18n[4711])
	local ebPwdConfirm = addPwdEdit(layPwd, "IMG_CONFIRMATION_PASSWORD_BG", m_InputTag.pwdConfirm, "", m_i18n[4712])

	local btnConfirm = m_fnGetWidget(layPwd, "BTN_REVISE_PASSWORD")
	btnConfirm:addTouchEventListener(tbData.eventConfirm)
	UIHelper.titleShadow(btnConfirm, m_i18n[4713])
end

-- 老账户绑定界面
function showBindOld( tbData )
	local layBinding = g_fnLoadUI("ui/account_binding_old.json")
	layBinding:setName(m_dlgName)
	LayerManager.addLayout(layBinding)

	local i18n_explain = m_fnGetWidget(layBinding, "tfd_explain")
	i18n_explain:setText(m_i18n[4736])

	local i18n_explain_txt = m_fnGetWidget(layBinding, "tfd_explain_txt")
	i18n_explain_txt:setText(m_i18n[4707])

	local btnClose = m_fnGetWidget(layBinding, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	-- 附加帐号的editbox
	local ebAccount = addAccountEdit(layBinding, tbData.account)

	-- 密码的editbox
	local ebPwd = addPwdEdit(layBinding, "IMG_PASSWORD_BG", m_InputTag.pwd, tbData.pwd, m_i18n[4704])

	-- 一键清除按钮
	setResetButton(layBinding, {account = ebAccount, pwd = ebPwd})

	local btnBingNew = m_fnGetWidget(layBinding, "BTN_NEW")
	btnBingNew:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			local tbBind = {}
			tbBind.account = ""
			tbBind.eventConfirm = function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					logger:debug("onBindNew")
					local tbLogin = getAllInputText()
					ZyxCtrl.onGuestRegist(tbLogin) -- 绑定新账户
				end
			end
			LayerManager.removeLayout() -- 关闭当前绑定帐号面板
			showBinding(tbBind) -- 弹出提示绑定账户的面板
		end
	end)
	UIHelper.titleShadow(btnBingNew, m_i18n[4732])

	local btnBingOld = m_fnGetWidget(layBinding, "BTN_OLD")
	btnBingOld:addTouchEventListener(tbData.eventConfirm)
	UIHelper.titleShadow(btnBingOld, m_i18n[4733])
end

-- 账户绑定界面
function showBinding( tbData )
	local layBinding = g_fnLoadUI("ui/account_number_binding.json")
	layBinding:setName(m_dlgName)
	LayerManager.addLayout(layBinding)

	local i18n_explain = m_fnGetWidget(layBinding, "tfd_explain")
	i18n_explain:setText(m_i18n[4707])

	local btnClose = m_fnGetWidget(layBinding, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)

	local ebAccount = addAccountEdit(layBinding, tbData.account)
	local ebPwd = addPwdEdit(layBinding, "IMG_PASSWORD_BG", m_InputTag.pwd, "", m_i18n[4704])
	local ebPwdConfirm = addPwdEdit(layBinding, "IMG_CONFIRMATION_BG", m_InputTag.pwdConfirm, "", m_i18n[4705])
	local ebMail = addEmailEdit(layBinding)

	local btnConfirm = m_fnGetWidget(layBinding, "BTN_BINDING")
	btnConfirm:addTouchEventListener(tbData.eventConfirm)
	UIHelper.titleShadow(btnConfirm, m_i18n[4708])
end
