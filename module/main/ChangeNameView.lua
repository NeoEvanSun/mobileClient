-- FileName: ChangeNameView.lua
-- Author: zhangqi
-- Date: 2014-12-25
-- Purpose: 修改玩家角色昵称的UI
--[[TODO List]]

-- module("ChangeNameView", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_i18n = gi18n
local m_i18nString 	= gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

local m_ebBg = "images/base/potential/input_name_bg1.png"

ChangeNameView = class("ChangeNameView")

-- fnUpdateName: 更名成功后刷新玩家名称的方法
function ChangeNameView:ctor(fnUpdateName)
	self.layMain = g_fnLoadUI("ui/home_change_name.json")
	self.ONCE_RANDOM = 20 -- 一次随机实际返回的昵称数量
	self.m_nCurIndex = 0 -- 当前已随机的次数，作为获取随机名称的索引
	self.m_bEnableRandom = true -- 随机按钮实际可用标志，点击后为 false, 后端请求返回后才为 true
	self.ONCE_GOLD = 100 -- 一次更名需要花费的金币数
	self.ONCE_CARD = 1 -- 一次更名需要更名卡数量
	self.MAX_INPUT = 12 -- 输入昵称允许的最大字符数
	self.fnUpdateName = fnUpdateName
end

function ChangeNameView:create( tbData )
	local layRoot = self.layMain

	local i18n_tip1 = m_fnGetWidget(layRoot, "tfd_info")
	i18n_tip1:setText(m_i18n[3208])

	tbArgs = { layRoot = self.layMain, bgName = "IMG_NAME_BG", sHolder = m_i18n[1915], holderColor = ccc3(0x6a, 0x34, 0x07),
				FontName = g_sFontName, FontSize = 28, FontColor = ccc3(0x6a, 0x34, 0x07), maxLen = self.MAX_INPUT}

	self.nameInput = UIHelper.addEditBoxWithBackgroud(tbArgs) -- 输入框
	self.nameInput:setPosition(ccp(4, 0))


	local btnRandom = m_fnGetWidget(layRoot, "BTN_RANDOM") -- 随机名按钮
	btnRandom:addTouchEventListener( function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playBtnEffect("shaizi.mp3")
			if (not self.m_bEnableRandom) then
				return
			end

			if ((self.m_nCurIndex % self.ONCE_RANDOM) == 0) then
				-- 前端getSex返回 1:男，2:女， 给后端 1:男，0:女
				-- local sex = (HeroModel.getSex(UserModel.getAvatarHtid()) == 1) and 1 or 0
				local args = CCArray:create()
				args:addObject(CCInteger:create(20))
				args:addObject(CCInteger:create(1)) -- 性别先统一按男性处理
				RequestCenter.user_getRandomName(function ( cbFlag, dictData, bRet )
					if (bRet) then
						self.m_bEnableRandom = true -- 随机按钮实际可用
						self.m_tbNames = dictData.ret
						if(table.isEmpty(self.m_tbNames)) then
							ShowNotice.showShellInfo(mi18n[1917]) -- 随机名用完
							return
						end
						self.m_nCurIndex = 1
						self.nameInput:setText(self.m_tbNames[self.m_nCurIndex].name)
					end
				end, args)
				self.m_bEnableRandom = false
			else
				if (table.isEmpty(self.m_tbNames)) then
					ShowNotice.showShellInfo(mi18n[1917]) -- 随机名用完
					return
				end
				self.m_nCurIndex = self.m_nCurIndex + 1
				self.nameInput:setText(self.m_tbNames[self.m_nCurIndex].name)
			end
		end
	end )

	local i18n_desc1 = m_fnGetWidget(layRoot, "tfd_consume")
	i18n_desc1:setText(m_i18n[1405]) -- 消耗

	local labNeedGold = m_fnGetWidget(layRoot, "TFD_GOLD_NUM")
	labNeedGold:setText(self.ONCE_GOLD) -- 一次需要金币数量

	local i18n_desc2 = m_fnGetWidget(layRoot, "tfd_or")
	i18n_desc2:setText(m_i18n[1222]) -- 或

	local labNeedCard = m_fnGetWidget(layRoot, "TFD_NEED_ITEM_NUM")
	labNeedCard:setText(self.ONCE_CARD) -- 一次需要需要道具数量

	local i18n_desc3 = m_fnGetWidget(layRoot, "tfd_change")
	i18n_desc3:setText(m_i18n[3215]) -- 个更名牌可以更换昵称

	local i18n_own = m_fnGetWidget(layRoot, "tfd_own")
	i18n_own:setText(m_i18n[3216]) -- 当前拥有更名牌：

	local labOwnNum = m_fnGetWidget(layRoot, "TFD_OWN_NUM") -- 更名卡数量
	self.nItemNum = tonumber(ItemUtil.getNumInBagByTid(60012))
	labOwnNum:setText(self.nItemNum)

	local btnClose = m_fnGetWidget(layRoot, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(UIHelper.onClose)
	local btnBack = m_fnGetWidget(layRoot, "BTN_BACK") -- 返回按钮
	UIHelper.titleShadow(btnBack, m_i18n[1325])
	btnBack:addTouchEventListener(UIHelper.onClose)

	local btnOk = m_fnGetWidget(layRoot, "BTN_CONFIRM") -- 确定按钮
	UIHelper.titleShadow(btnOk, m_i18n[1324])
	btnOk:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			-- LayerManager.removeLayout()  -- 暂时不关闭更名对话框，修改成功才关闭

			self.nType = 2 -- 默认用更名卡修改
			self.m_newName = self.nameInput:getText()

			-- 检测昵称不能为空
			if (self.m_newName == "" or self.m_newName == m_i18n[1915]) then
				ShowNotice.showShellInfo(m_i18n[3209])
				return
			end

			if (self.m_newName == UserModel.getUserName()) then
				ShowNotice.showShellInfo(m_i18n[3210])
				return
			end

			local nameLen = getStringLength(self.m_newName) -- 计算新昵称长度，1个汉字算2个英文字符
			if (nameLen > self.MAX_INPUT) then -- 昵称最多6个汉字，12个英文字符
				ShowNotice.showShellInfo(m_i18n[1916])
				return
			end

			local function sendChangeRPC( ... )
				local args = CCArray:create()
				args:addObject(CCString:create(self.m_newName))
				args:addObject(CCInteger:create(self.nType)) -- 1.消耗金币 2.消耗物品
				RequestCenter.user_changeName(function ( cbFlag, dictData, bRet )
					if (bRet) then
						-- return: invalid_char(包含非法字符) sensitive_word(包含敏感词) duplication(名字已被使用) ok(修改成功)
						local keyRet = string.lower(dictData.ret)
						local tbText = {invalid_char = m_i18n[3211], sensitive_word = m_i18n[3212],
										duplication = m_i18n[3210], ok = m_i18n[3213]}
						ShowNotice.showShellInfo(tbText[keyRet])
						if (self.nameInput) then
							logger:debug("self.nameInput.visible = %s, TouchEnabled = %s", tostring(self.nameInput:isVisible()),
											tostring(self.nameInput:isTouchEnabled()))
							self.nameInput:setTouchEnabled(true)
						end

						if ( keyRet == "ok" ) then
							if (self.nType == 1) then -- 如果修改成功且用金币修改
								UserModel.addGoldNumber( - self.ONCE_GOLD ) -- 扣减金币
							end
							
							UserModel.setUserName(self.m_newName)
							-- 刷新角色详情面板和角色信息条上的昵称
							if (self.fnUpdateName and type(self.fnUpdateName) == "function") then
								self.fnUpdateName()
							end
							LayerManager.removeLayout() -- 关闭更名对话框
						end
					end
				end, args)
			end
			

			if (self.nItemNum <= 0) then -- 更名卡道具不足
				self.nType = 1
				if (UserModel.getGoldNumber() < self.ONCE_GOLD) then -- 金币不足
					-- 弹出提示金币不足的通用对话框
					local alert = UIHelper.createNoGoldAlertDlg()
					LayerManager.addLayout(alert)
					logger:debug("self.nameInput.visible = %s, TouchEnabled = %s", tostring(self.nameInput:isVisible()),
											tostring(self.nameInput:isTouchEnabled()))
				else
					-- 弹出确认是否花费金币更名的二次确认对话框
					local tbArgs = {strText = m_i18nString(3214, self.ONCE_GOLD), nBtn = 2,}
					tbArgs.fnConfirmEvent = function ( sender, eventType )
						if (eventType == TOUCH_EVENT_ENDED) then
							AudioHelper.playCommonEffect()
							LayerManager.removeLayout()
							sendChangeRPC()
						end
					end
					local dlg = UIHelper.createCommonDlgNew(tbArgs)
					LayerManager.addLayout(dlg)
				end
			else
				sendChangeRPC()
			end
		end
	end) -- end for listener function

	LayerManager.addLayout(layRoot)

	local popLayer = LayerManager.getCurrentPopLayer()
	local tp = popLayer:getTouchPriority()
	self.nameInput:setTouchPriority(tp - 1)
end
