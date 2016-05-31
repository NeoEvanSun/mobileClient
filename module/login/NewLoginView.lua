-- FileName: NewLoginView.lua
-- Author: menghao
-- Date: 2014-07-10
-- Purpose: 登陆界面view


module("NewLoginView", package.seeall)


-- UI控件引用变量 --
local m_UIMain

local m_tfdSever
local m_imgHot
local m_imgNew
local m_btnChoose
local m_btnLogin

-- 最游戏帐号相关，zhangqi, 2014-11-04
local m_btnAccount -- 显示最游戏账户名的按钮, BTN_LOGIN_NAME, BTN_CHOOSE_UP, BTN_CHOOSE_DOWN, BTN_BOUND
local m_imgComBox -- 最近登陆账户的下拉列表背景，用来控制隐藏和显示, IMG_ACCOUNT_BG
local m_lsvAccounts -- 最近登陆账户的下拉列表, LSV_ACCOUNT
local m_layBind -- 登陆账户按钮上的绑定按钮层
local m_layArrow -- 登陆账户按钮上的箭头按钮层
local m_btnUp -- 向上箭头按钮
local m_btnDown -- 向下箭头按钮
local m_curArrowBtn -- 当前显示的箭头按钮
local m_tbDelTags -- 保存初始化列表时每个表项的index作为Tag, 删除某个表项后 index 会变化，利用tag映射新的index
local bTest = true

local m_imgBG
local m_imgMap
local m_imgCloud
local m_imgBottom
local m_imgMB

-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n

local talkEditBox


local function init(...)

end


function destroy(...)
	package.loaded["NewLoginView"] = nil
end


function moduleName()
	return "NewLoginView"
end


function upServerUI( tbServerData )
	if tbServerData.hot ~= 1 then
		m_imgHot:setEnabled(false)
	else
		m_imgHot:setEnabled(true)
	end
	if (tbServerData.new ~= 1) then
		m_imgNew:setEnabled(false)
	else
		m_imgNew:setEnabled(true)
	end
	m_tfdSever:setText(tbServerData.name)
end


function getText( ... )
	if (not Platform.isPlatform()) then
		return talkEditBox:getText()
	end
end


function setEditBoxEnabled( bValue )
	if (not Platform.isPlatform()) then
		talkEditBox:setTouchEnabled(bValue)
	end
end

local function setBtnTitleStyle( btn, tbStyle )
	btn:setTitleFontSize(tbStyle.size or g_FontInfo.size)
	btn:setTitleColor(tbStyle.color or g_FontInfo.color)
	btn:setTitleFontName(tbStyle.fontName or g_FontInfo.name)
end


function create( tbEvent, selectServer )
	-- test
	-- if (bTest) then
	-- 	local allUsr = {{usr = "hechao", pwd = "aaaaaa"},{usr = "hechao2", pwd = "aaaaaa"},{usr = "hechao3", pwd = "aaaaaa"},
	-- 					{usr = "hechao4", pwd = "aaaaaa"}, {usr = "hechao5", pwd = "aaaaaa"},}
	-- 	require "script/module/login/ZyxCtrl"
	-- 	ZyxCtrl.writeAllLogin(allUsr)
	-- end

	m_UIMain = g_fnLoadUI("ui/regist_main.json")
	-- local imgName = m_fnGetWidget(m_UIMain, "img_logo")
	-- imgName:setEnabled(false)

	-- 最游戏内测临时隐藏游戏名称logo, 2014-12-03
	-- local imgLogo = m_fnGetWidget(m_UIMain, "img_logo")
	-- imgLogo:removeFromParentAndCleanup(true)

	-- 版署提示
	local layBanShu = m_fnGetWidget(m_UIMain, "LAY_BANSHU")
	layBanShu:setEnabled(false)

	m_imgHot = m_fnGetWidget(m_UIMain, "IMG_HOT")
	m_imgNew = m_fnGetWidget(m_UIMain, "IMG_NEW")
	m_tfdSever = m_fnGetWidget(m_UIMain, "TFD_SERVER")
	m_btnLogin = m_fnGetWidget(m_UIMain, "BTN_LOGIN")
	m_btnChoose = m_fnGetWidget(m_UIMain, "BTN_CHOOSE")

	m_imgBG = m_fnGetWidget(m_UIMain, "img_bg")
	m_imgMap = m_fnGetWidget(m_UIMain, "IMG_MAP")
	m_imgCloud = m_fnGetWidget(m_UIMain, "img_cloud")
	m_imgBottom = m_fnGetWidget(m_UIMain, "IMG_BOTTOM")
	m_imgMB = m_fnGetWidget(m_UIMain, "IMG_MENGBAN")

	local layTest = m_fnGetWidget(m_UIMain, "LAY_TEST")
	local size = layTest:getSize()
	layTest:setSize(CCSizeMake(size.width * g_fScaleX, size.height * g_fScaleX))

	m_imgBG:setScale(g_fScaleX)
	m_imgCloud:setScale(g_fScaleX)
	m_imgBottom:setScale(g_fScaleX)
	m_imgMB:setScale(g_fScaleX)
	m_btnLogin:setScale(g_fScaleX)

	-- 最近登陆帐号下拉列表背景, 默认不显示
	m_imgComBox = m_fnGetWidget(m_UIMain, "IMG_ACCOUNT_BG")
	m_imgComBox:setEnabled(false)

	if selectServer.hot ~= 1 then
		m_imgHot:setEnabled(false)
	end
	if (selectServer.new ~= 1) then
		m_imgNew:setEnabled(false)
	end
	m_tfdSever:setText(selectServer.name)
	m_btnLogin:addTouchEventListener(tbEvent.onLogin)
	m_btnChoose:addTouchEventListener(tbEvent.onChoose)
	local btnSeverList = m_fnGetWidget(m_UIMain, "BTN_SERVER_NAME")
	btnSeverList:addTouchEventListener(tbEvent.onChoose)

	if (Platform.isPlatform()) then
		-- 显示最游戏账户的按钮
		m_btnAccount = m_fnGetWidget(m_UIMain, "BTN_LOGIN_NAME")
		-- m_btnAccount:setTouchEnabled(false)
		setBtnTitleStyle(m_btnAccount, {size = 30})
		m_btnAccount:setTitleText(m_i18n[4701]) -- "点击注册登录"
		m_btnAccount:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				local args = {guest = true, logined = false, account = ""}
				require "script/module/login/ZyxCtrl"
				ZyxCtrl.create(args)
			end
		end)

		m_layBind = m_fnGetWidget(m_btnAccount, "LAY_BOUND")
		m_layBind:setEnabled(false)

		m_layArrow = m_fnGetWidget(m_btnAccount, "LAY_ARROW")
		m_layArrow:setEnabled(false)	-- 隐藏箭头按钮
		m_btnUp = m_fnGetWidget(m_layArrow, "BTN_CHOOSE_UP")
		m_btnUp:setTouchEnabled(false)
		m_btnDown = m_fnGetWidget(m_layArrow, "BTN_CHOOSE_DOWN")
		m_btnDown:setTouchEnabled(false)

		m_lsvAccounts = m_fnGetWidget(m_imgComBox, "LSV_ACCOUNT")
	else
		local btnLogin = m_fnGetWidget(m_UIMain, "BTN_LOGIN_NAME")
		-- btnLogin:setTouchEnabled(false)
		local btnBind = m_fnGetWidget(m_UIMain, "BTN_BOUND")
		btnBind:setEnabled(false)

		talkEditBox = UIHelper.createEditBox(CCSizeMake(180 * g_fScaleX, 50 * g_fScaleY), "images/base/potential/input_name_bg1.png", false)
		talkEditBox:setPlaceHolder("Name:")
		talkEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
		talkEditBox:setMaxLength(40)
		talkEditBox:setReturnType(kKeyboardReturnTypeDone)
		talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)

		local strUid = LoginHelper.debugUID() or "1024"
		logger:debug("strUid = %s", strUid)
		talkEditBox:setText(strUid)

		btnLogin:addNode(talkEditBox)
	end

	return m_UIMain
end

local function showDownArrow ( bStat )
	m_btnDown:setEnabled(bStat)
	m_btnUp:setEnabled(not bStat)
	m_curArrowBtn = bStat and m_btnDown or m_btnUp
end

local function fnEventRegist ( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		logger:debug("已登录账户的登陆面板, 注册按钮")
		LayerManager.removeLayout() -- 关闭当前面板

		local tbRegist = {} -- 注册界面需要的参数
		tbRegist.eventConfirm = function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				logger:debug("confirm register")
				local allInput = ZyxView.getAllInputText()
				logger:debug("NewLoginView eventRegist")
				logger:debug(allInput)

				require "script/module/login/ZyxCtrl"
				ZyxCtrl.onRegist(allInput)
			end
		end

		local dlg = ZyxView.showRegister(tbRegist)
		LayerManager.addLayout(dlg)
	end
end

local function fnEventLogin( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		logger:debug("confirm Login")
		local allInput = ZyxView.getAllInputText()
		logger:debug("NewLoginView eventLogin")
		logger:debug(allInput)

		require "script/module/login/ZyxCtrl"
		if (ZyxCtrl.onLogin(allInput)) then
			LayerManager.removeLayout() -- 如果前端校验通过，关闭当前面板
		end
	end
end

local function addOtherUserCell( nIdx )
	m_lsvAccounts:pushBackDefaultItem()
	local idx = nIdx + 1
	local cell = m_lsvAccounts:getItem(idx)
	table.insert(m_tbDelTags, idx)

	local btnDel = m_fnGetWidget(cell, "BTN_DELETE")
	btnDel:removeFromParentAndCleanup(true)

	local btnName = m_fnGetWidget(cell, "BTN_ACCOUNT_NAME")
	setBtnTitleStyle(btnName, {size = 30, color = ccc3(0xa8, 0x69, 0x36)})
	btnName:setTitleText(m_i18n[4709]) -- "其他账号"
	btnName:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			m_imgComBox:setEnabled(false)
			showDownArrow(true)

			-- 弹出常规登陆面板，只有"注册"和"登陆"按钮
			local tbData = {other = true}
			tbData.eventLogin = fnEventLogin --
			tbData.eventRegist = fnEventRegist

			require "script/module/login/ZyxView"
			local dlg = ZyxView.showLogin(tbData)
			LayerManager.addLayout(dlg)
		end
	end)
end

--[[desc: 刷新显示已登录账户的标题和按钮事件
    tbLogin: {account = "", udid = true}
    return: 是否有返回值，返回值说明
—]]
function updateAccount(tbLogin)
	if (tbLogin.account and m_btnAccount) then
		m_btnAccount:setTitleText(tbLogin.account)
	end

	local fnClick = nil
	if (tbLogin.udid) then -- 游客已登陆
		if (m_btnAccount) then
			m_btnAccount:setTitleText(m_i18n[4730])

			m_layArrow:setEnabled(false) -- 隐藏箭头按钮

			local function eventBind ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					-- if (true) then
					-- 	return -- 2015-03-19，封测包屏蔽绑定按钮事件
					-- end

					logger:debug("NewLoginView onBind")
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
			end

			m_btnAccount:setTouchEnabled(true)
			m_btnAccount:addTouchEventListener(eventBind) -- 显示游客的大按钮也要添加绑定账户事件

			m_layBind:setEnabled(true)
			local btnBind = m_fnGetWidget(m_layBind, "BTN_BOUND")
			btnBind:addTouchEventListener(eventBind)
	end
	else -- 是注册账户
		if (m_btnAccount) then
			m_btnAccount:setTitleText(tbLogin.account or "") -- zhangqi, 如果异常没有拿到登陆帐号名称，则用空字符串保证不崩溃
			m_btnAccount:setTouchEnabled(true) -- 2015-03-19, 封测包置为false

			if (tbLogin.account and m_lsvAccounts) then
				m_layBind:setEnabled(false) -- 隐藏绑定账户按钮
				m_layArrow:setEnabled(true) -- 显示箭头按钮 -- 2015-03-19, 封测包置为false
				showDownArrow(true) -- 2015-03-19, 封测包置为false

				m_btnAccount:addTouchEventListener(function ( sender, eventType )
					if (eventType == TOUCH_EVENT_BEGAN) then
						if (m_curArrowBtn) then
							m_curArrowBtn:setFocused(true)-- 驱动箭头按钮按下状态
						end
					elseif (eventType == TOUCH_EVENT_CANCELED) then
						if (m_curArrowBtn) then
							m_curArrowBtn:setFocused(false)-- 驱动箭头按钮正常状态
						end
					elseif (eventType == TOUCH_EVENT_ENDED) then
						m_curArrowBtn:setFocused(false)-- 驱动箭头按钮正常状态

						if (m_imgComBox and m_imgComBox:isEnabled()) then
							m_imgComBox:setEnabled(false) -- 如果列表已显示则隐藏
							showDownArrow(true)
							return
						end

						-- 读取最近登陆账户信息
						local tbAllUsers = ZyxCtrl.getLoginRecord()
						logger:debug("NewLoginView tbAllUsers")
						logger:debug(tbAllUsers)

						if (not m_imgComBox or table.isEmpty(tbAllUsers)) then
							return
						end

						showDownArrow(false)

						local needInit = true
						if (m_lsvAccounts:getItem(1)) then
							needInit = false
							m_lsvAccounts:removeAllItems() -- 如果不是第一次构造登陆记录列表，清除列表以便后面重新构造
						end

						m_tbDelTags = {}
						-- 构造最近登陆账户列表
						if (needInit) then
							UIHelper.initListView(m_lsvAccounts)
						end
						local nIdx, cell = 0, nil
						for i, user in ipairs(tbAllUsers) do
							m_lsvAccounts:pushBackDefaultItem()
							nIdx = i - 1
							cell = m_lsvAccounts:getItem(nIdx)  -- cell 索引从 0 开始
							local btnName = m_fnGetWidget(cell, "BTN_ACCOUNT_NAME")
							setBtnTitleStyle(btnName, {size = 30})
							btnName:setTitleText(user.account)
							btnName:setTag(nIdx)
							btnName:addTouchEventListener(function ( sender, eventType )
								if (eventType == TOUCH_EVENT_ENDED) then
									m_imgComBox:setEnabled(false) -- 隐藏下拉列表
									showDownArrow(true) -- 显示向下箭头

									if (sender:getTag() == 0) then -- 是当前已登录账户, 显示已登录账户的登陆面板
										-- 登陆按钮事件
										local tbData = {account = user.account, pwd = user.pwd}
										tbData.eventLogin = function ( sender, eventType )
											if (eventType == TOUCH_EVENT_ENDED) then
												logger:debug("已登录账户的登陆面板, 登陆按钮")
												local allInput = ZyxView.getAllInputText()
												logger:debug("NewLoginView eventLogin nowUser = %s, nowPwd = %s", user.account, user.pwd)
												logger:debug(allInput)
												if (allInput.account == user.account) then
													LayerManager.removeLayout()

													local tbArgs = {strText = "账号已登陆", nBtn = 1}
													-- 测试环境已登陆帐号再点登陆按钮就提交解除绑定的请求
													if (Platform.isDebug()) then
														-- tbArgs = {strText, richText, fnConfirmEvent, nBtn, fnCloseCallback}
														tbArgs.fnConfirmEvent = function ( sender, eventType )
															if (eventType == TOUCH_EVENT_ENDED) then
																LayerManager.removeLayout()
																local tbUnbind = {strText = "测试用：点关闭完成登陆操作, \n点确定则解除当前帐号的绑定！", nBtn = 1}
																tbUnbind.fnConfirmEvent = function ( sender, eventType )
																	if (eventType == TOUCH_EVENT_ENDED) then
																		ZyxCtrl.onUnBind()
																	end
																end
																local dlg = UIHelper.createCommonDlgNew(tbUnbind)
																LayerManager.addLayout(dlg)
															end
														end

													end

													LayerManager.addLayout(UIHelper.createCommonDlgNew(tbArgs))
													return -- 如果点击登陆按钮时的账户名和之前相同，直接关闭面板
												end

												require "script/module/login/ZyxCtrl"
												ZyxCtrl.onLogin(allInput)
											end
										end
										-- 注册按钮事件
										tbData.eventRegist = fnEventRegist
										-- 修改密码按钮事件
										tbData.eventChangePwd = function ( sender, eventType )
											if (eventType == TOUCH_EVENT_ENDED) then
												logger:debug("已登录账户的登陆面板, 修改密码按钮")
												LayerManager.removeLayout() -- 关闭当前面板

												local tbChangePwd = {}
												tbChangePwd.account = user.account
												tbChangePwd.eventConfirm = function ( sender, eventType )
													if (eventType == TOUCH_EVENT_ENDED) then
														local allInput = ZyxView.getAllInputText()
														logger:debug("NewLoginView eventChangePwd")
														logger:debug(allInput)

														require "script/module/login/ZyxCtrl"
														ZyxCtrl.onChangePW(allInput)
													end
												end
												local layChange = ZyxView.showChangePwd(tbChangePwd)
												LayerManager.addLayout(layChange)
											end
										end
										ZyxView.showLogin(tbData)
									else -- 是未登陆账户, 发送切换账户的请求
										-- 获取当前账户和密码，发登陆请求
										local tbLogin = {account = user.account, pwd = user.pwd}
										ZyxCtrl.onLogin(tbLogin)
									end
								end
							end)

							table.insert(m_tbDelTags, nIdx)

							local btnDel = m_fnGetWidget(cell, "BTN_DELETE")
							if (nIdx == 0) then
								btnDel:setEnabled(false) -- 如果是第一条记录就不显示删除按钮
								btnDel:setVisible(false)
							else
								btnDel:setTag(nIdx)
								btnDel:addTouchEventListener(function ( sender, eventType )
									if (eventType == TOUCH_EVENT_ENDED) then
										local dlg = UIHelper.createCommonDlgNew(
											{ strText = m_i18n[4719], -- "该账号将不再保存在此设备上，是否确认删除？"
												fnConfirmEvent = function ( sender, eventType )
													if (eventType == TOUCH_EVENT_ENDED) then
														-- 从CCUserDefault删除帐号记录, 从列表删除
														local delIdx = 0
														for i, idx in ipairs(m_tbDelTags) do
															if (idx == btnDel:getTag()) then
																delIdx = i
																break
															end
														end

														if (delIdx == 0) then
															logger:debug("delete login user error: ")
															return
														end

														logger:debug("delete user i = %d, tag = %d, delIdx = %d",
															i, btnDel:getTag(), delIdx)
														ZyxCtrl.deleteLoginRecord(delIdx)
														m_lsvAccounts:removeItem(delIdx - 1)
														m_lsvAccounts:sortAllChildren()
														table.remove(m_tbDelTags, delIdx)

														LayerManager.removeLayout()

														-- test
														if (bTest) then
															local all = ZyxCtrl.getLoginRecord()
															logger:debug("删除此帐号记录后")
															logger:debug(all)
														end
													end
												end
											})
										LayerManager.addLayout(dlg)
										-- test
										if (bTest) then
											local all = ZyxCtrl.getLoginRecord()
											logger:debug("点确定从列表删除此帐号记录")
											logger:debug(all)
										end
									end
								end)
							end -- end of if (nIdx == 0) then
						end -- end of for

						-- 添加 "其他帐号" cell
						addOtherUserCell(nIdx)

						-- 显示最近登陆账户的下拉列表
						m_imgComBox:setEnabled(true)
					end
				end) -- end of m_btnAccount:addTouchEventListener
			end
	end
	end
end

