-- FileName: ChangeAvatarView.lua
-- Author: zhangqi
-- Date: 2014-12-26
-- Purpose: 实现玩家更换头像的UI
--[[TODO List]]

-- module("ChangeAvatarView", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_i18n = gi18n
local m_i18nString 	= gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

ChangeAvatarView = class("ChangeAvatarView")

function ChangeAvatarView:ctor()
	self.layMain = g_fnLoadUI("ui/choose_face.json")
	self.btns = {}
	self.tabIdx = 0
end

function ChangeAvatarView:create( tbData )
	local layRoot = self.layMain

	local function closeView( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			if (self.imgChoosed) then
				self.imgChoosed:release()
			end
			UIHelper.closeCallback()
		end
	end

	local btnClose = m_fnGetWidget(layRoot, "BTN_CLOSE") -- 关闭按钮
	btnClose:addTouchEventListener(closeView)
	local btnCancel = m_fnGetWidget(layRoot, "BTN_NO") -- 取消按钮
	UIHelper.titleShadow(btnCancel, m_i18n[1325])
	btnCancel:addTouchEventListener(closeView)

	local btnOk = m_fnGetWidget(layRoot, "BTN_YES") -- 确定按钮
	UIHelper.titleShadow(btnOk, m_i18n[1324])
	btnOk:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()

			logger:debug("change avatar ok: htid = %d, oldHtid = %d", self.chooseHtid, self.oldHtid)
			if (self.chooseHtid == self.oldHtid) then
				LayerManager.removeLayout()
				return
			end

			RequestCenter.user_setFigure(function ( cbName, dictData, bRet )
				logger:debug("ChangeAvatarView-user_setFigure")
				logger:debug(dictData)
				local bSucc = (bRet and string.lower(dictData.ret) == "ok")
				local tips = bSucc and "更换头像成功" or "更换头像失败"
				ShowNotice.showShellInfo(tips)

				if (bSucc) then
					LayerManager.removeLayout()
					UserModel.setAvatarHtid(self.chooseHtid)
					
					updateInfoBar() -- 新信息条统一刷新方法
					
					if (tbData.callback) then
						tbData.callback()
					end
				end
			end, Network.argsHandlerOfTable({self.chooseHtid}))
		end
	end)

	-- 选中标志
	if (not self.imgChoosed) then
		self.imgChoosed = ImageView:create()
		self.imgChoosed:retain()
		self.imgChoosed:loadTexture("images/common/face_choose.png")
		self.imgChoosed:setPosition(ccp(9, -3))
	end

	-- 所有伙伴信息{{sName = "", nHtid = id, bUsed = false}, {}, {}, {}}`
	self.heroes = tbData.heroes

	-- 页签按钮 BTN_TAB1(风), BTN_TAB2(雷), BTN_TAB3(水), BTN_TAB4(火)
	-- local cfgTab = {{title = m_i18n[2415]}, {title = m_i18n[2416]}, {title = m_i18n[2417]}, {title = m_i18n[2418]},}
	for i = 1, 4 do
		local btnTab = m_fnGetWidget(layRoot, "BTN_TAB" .. i)
		-- UIHelper.titleShadow(btnTab, cfgTab[i].title)
		btnTab:setTag(i)
		btnTab:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playTabEffect()
				self:onTab(sender:getTag())
			end
		end)
		table.insert(self.btns, btnTab)
	end

	self.lsvAvatar = m_fnGetWidget(layRoot, "LSV_LIST")
	UIHelper.initListView(self.lsvAvatar)

	self:onTab(1) -- 触发第一个标签


	return layRoot
end

function ChangeAvatarView:onTab( nIdx )
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

	local lsvList = self.lsvAvatar
	local tbHeroes = self.heroes[self.tabIdx] -- 每个标签按钮对应的伙伴
	logger:debug("ChangeAvatarView:onTab nIdx = %d", nIdx)
	logger:debug(tbHeroes)
	
	lsvList:removeAllItems() -- 清除列表，准备重建

	if (not table.isEmpty(tbHeroes)) then
		local nIdx, cell = -1, nil
		local layFace, layAvatar = nil, nil -- 每个cell上存放头像的layout

		for i, hero in ipairs(tbHeroes) do
			if (i % 4 == 1) then -- 一行是 1 个 cell，1 个 cell 放 4 个头像
				lsvList:pushBackDefaultItem()
				nIdx = nIdx + 1
				cell = lsvList:getItem(nIdx)  -- cell 索引从 0 开始

				layFace = m_fnGetWidget(cell, "lay_face")
				if (not layAvatar) then
					layAvatar = layFace:clone() -- 先复制头像layout，避免创建头像按钮后的错误复制
					layAvatar:retain() -- 保持供后续头像复制
				end
				self:createAvatar(layFace, hero)
			else
				local newAvatar = layAvatar:clone()
				self:createAvatar(newAvatar, hero)
				cell:addChild(newAvatar) -- clone出来的头像需要添加到cell上
				local percentX = (i % 4 - 1)*0.25
				if (i % 4 == 0) then
					percentX = 0.75
				end
				newAvatar:setPositionPercent(ccp(percentX, 0))
			end
		end
		layAvatar:release() -- 一种类型的所有头像全部创建完后释放
	end
end

function ChangeAvatarView:createAvatar( layFace, hero, fnCallback )
    logger:debug("ChangeAvatarView:createAvatar")
	--item of cell: lay_face(LAY_FACE_BG, TFD_NAME)
	local function eventAvatar ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			
			self.chooseHtid = sender:getTag()
			logger:debug("click avater: htid = %d", self.chooseHtid)
			
			if (self.imgChoosed) then
				self.imgChoosed:removeFromParentAndCleanup(true)
				sender:addChild(self.imgChoosed)
			end
			if (fnCallback) then
				fnCallback()
			end
		end
	end

	local layAvatar = m_fnGetWidget(layFace, "LAY_FACE_BG")
	local btnIcon = HeroUtil.createHeroIconBtnByHtid(hero.nHtid, nil, eventAvatar)
	if (btnIcon) then
		btnIcon:setTag(hero.nHtid)
		local btnSize = btnIcon:getSize()
		btnIcon:setPosition(ccp(btnSize.width/2, btnSize.height/2))
		layAvatar:addChild(btnIcon)
	end

	if (not self.chooseHtid and hero.bUsed) then
		self.chooseHtid = hero.nHtid
		self.oldHtid = hero.nHtid
	end
	if (self.imgChoosed and self.chooseHtid) then
		if (self.chooseHtid == hero.nHtid) then
			btnIcon:addChild(self.imgChoosed)
		end
	end

	local labName = m_fnGetWidget(layFace, "TFD_NAME")
	labName:setText(hero.sName)
end

