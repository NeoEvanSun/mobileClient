-- FileName: RaiseFightView.lua
-- Author: zhangqi
-- Date: 2015-01-00
-- Purpose: 提升战斗力的UI实现
--[[TODO List]]

-- module("RaiseFightView", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_i18n = gi18n
local m_i18nString 	= gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

RaiseFightView = class("RaiseFightView")

function RaiseFightView:ctor()
	self.layMain = g_fnLoadUI("ui/up_fighting.json")
	self.btns = {}
	self.tabIdx = 0
end

function RaiseFightView:create( tbData )
	local layRoot = self.layMain

	-- 所有提升信息{{icon_path = "", title_path = "", recommend = number, curNum = number, maxNum = number, fnBtnCallback = function}, {}, {}}
	self.raiseList = tbData.raiseList

	local imgBg = m_fnGetWidget(layRoot, "img_bg")
	imgBg:setScale(g_fScaleX)

	local imgSmallBg = m_fnGetWidget(layRoot, "img_small_bg")
	imgSmallBg:setScale(g_fScaleX)

	local imgChain = m_fnGetWidget(layRoot, "img_partner_chain")
	imgChain:setScale(g_fScaleX)

	local imgFightBg = m_fnGetWidget(layRoot, "img_fight_bg")
	imgFightBg:setScale(g_fScaleX)

	local btnBack = m_fnGetWidget(layRoot, "BTN_BACK") -- 返回按钮, 返回主场景
	UIHelper.titleShadow(btnBack, m_i18n[1019])
	btnBack:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playBackEffect()

			require "script/module/main/MainScene"
 			MainScene.homeCallback()
		end
	end)

	local labnFightNum = m_fnGetWidget(layRoot, "LABN_FIGHT") -- 战斗力数值
	labnFightNum:setStringValue(tostring(UserModel.getFightForceValue()))

	-- 页签按钮 BTN_TAB1(急需提升), BTN_TAB2(有待提高), BTN_TAB3(完美无暇)
	local cfgTab = {{title = m_i18n[3217]}, {title = m_i18n[3218]}, {title = m_i18n[3219]},}
	for i = 1, 3 do
		local btnTab = m_fnGetWidget(layRoot, "BTN_TAB" .. i)
		UIHelper.titleShadow(btnTab, cfgTab[i].title)
		btnTab:setTag(i)
		btnTab:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playTabEffect()
				self:onTab(sender:getTag())
			end
		end)
		table.insert(self.btns, btnTab)
	end

	-- 列表 LSV_MAIN
	self.lsvRaise = m_fnGetWidget(layRoot, "LSV_MAIN")
	UIHelper.initListView(self.lsvRaise)

	self:onTab(1) -- 触发第一个标签

	return layRoot
end

function RaiseFightView:onTab( nIdx )
	if (nIdx == self.tabIdx) then -- 避免重复点击标签按钮
		return
	end
	if (self.tabIdx > 0) then
		self.btns[self.tabIdx]:setFocused(false) -- 取消上一个按钮的焦点
		self.btns[self.tabIdx]:setTouchEnabled(true)
	end
	self.tabIdx = nIdx
	self.btns[self.tabIdx]:setFocused(true) -- 给当前按下的按钮设置焦点
	self.btns[self.tabIdx]:setTouchEnabled(false)

	local lsvList = self.lsvRaise
	local tbRaises = self.raiseList[self.tabIdx] -- 每个标签按钮对应的伙伴
	logger:debug("RaiseFightView:onTab nIdx = %d", nIdx)
	logger:debug(tbRaises)
	
	lsvList:removeAllItems() -- 清除列表，准备重建

	if (not table.isEmpty(tbRaises)) then
		local nIdx, cell = -1, nil
		-- img_icon, IMG_TITLE, TFD_RECOMMEND 3221, BTN_GO
		-- tfd_progress 3220, LABN_LEFT, LABN_RIGHT, LOAD_PROGRESS

		for i, item in ipairs(tbRaises) do
			lsvList:pushBackDefaultItem()
			nIdx = nIdx + 1
			cell = lsvList:getItem(nIdx)  -- cell 索引从 0 开始

			local szCell = cell:getSize()
			cell:setSize(CCSizeMake(szCell.width * g_fScaleX, szCell.height * g_fScaleX))

			local imgBg = m_fnGetWidget(cell, "img_cell")
			imgBg:setScale(g_fScaleX)

			-- {icon_path = "", title_path = "", recommend = number, curNum = number, maxNum = number, fnBtnCallback = function}
			local imgIcon = m_fnGetWidget(cell, "img_icon") -- 类型icon
			imgIcon:loadTexture(item.icon_path)

			local imgTitle = m_fnGetWidget(cell, "IMG_TITLE") -- 类型标题
			imgTitle:loadTexture(item.title_path)

			local labRecommend = m_fnGetWidget(cell, "TFD_RECOMMEND")
			labRecommend:setText(m_i18nString(3221, item.recommend)) -- 推荐指数：%s

			local i18n_progress = m_fnGetWidget(cell, "tfd_progress")
			i18n_progress:setText(m_i18n[3220]) -- 提升度

			logger:debug("percent = %d, curNum = %d, maxNum = %d", item.percent, item.curNum, item.maxNum)
			local labnMember = m_fnGetWidget(cell, "LABN_LEFT")
			labnMember:setStringValue(tostring(item.percent))

			local labnDenom = m_fnGetWidget(cell, "LABN_RIGHT")
			labnDenom:setStringValue("100")

			local loadRaise = m_fnGetWidget(cell, "LOAD_PROGRESS")
			loadRaise:setPercent(item.percent)

			local btnGo = m_fnGetWidget(cell, "BTN_GO")
			btnGo:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					AudioHelper.playCommonEffect()
					item.fnBtnCallback()
				end
			end)
		end
	end
end
