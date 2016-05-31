-- FileName: ServerListView.lua
-- Author: menghao
-- Date: 2014-07-10
-- Purpose: 服务器列表view


module("ServerListView", package.seeall)


-- UI控件引用变量 --
local m_UIMain

local m_lsvMain
local m_layCell1
local m_layCell2


-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName


local function init(...)

end


function destroy(...)
	package.loaded["ServerListView"] = nil
end


function moduleName()
	return "ServerListView"
end

local function createList( tbListData, cellIdx )
	logger:debug(tbListData)
	local layCell = (cellIdx == 1 and m_layCell1 or m_layCell2)

	if (not tbListData or #tbListData == 0) then
		layCell:setEnabled(false)
		return
	end

	local tNum = (#tbListData + 1) / 2
	local index = m_lsvMain:getIndex(layCell) - 1
	for i=2,tNum do
		if (cellIdx == 1) then
			m_lsvMain:insertDefaultItem(index + i)
		elseif (cellIdx == 2) then
			m_lsvMain:pushBackDefaultItem()
		end
	end
	for i=1,tNum do
		local itemCell = m_lsvMain:getItem(index + i)
		local tbData1 = tbListData[2 * i - 1]
		local tbData2 = tbListData[2 * i]

		if tbData1 then
			local btnServer = m_fnGetWidget(itemCell, "BTN_SERVER1")
			local tfdName = m_fnGetWidget(itemCell, "TFD_SERVER_NAME1")
			local imgNew = m_fnGetWidget(itemCell, "IMG_NEW_1")
			local imgHot = m_fnGetWidget(itemCell, "IMG_HOT_1")
			tfdName:setText(tbData1.name)
			if tbData1.new ~= 1 then
				imgNew:setEnabled(false)
			end
			if tbData1.hot ~= 1 then
				imgHot:setEnabled(false)
			end
			btnServer:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					AudioHelper.playCommonEffect()
					LayerManager.removeLayout()
					NewLoginCtrl.setSelectServer(tbData1)
				end
			end)
		end

		if tbData2 then
			local btnServer = m_fnGetWidget(itemCell, "BTN_SERVER2")
			local tfdName = m_fnGetWidget(itemCell, "TFD_SERVER_NAME2")
			local imgNew = m_fnGetWidget(itemCell, "IMG_NEW_2")
			local imgHot = m_fnGetWidget(itemCell, "IMG_HOT_2")
			tfdName:setText(tbData2.name)
			if tbData2.new ~= 1 then
				imgNew:setEnabled(false)
			end
			if tbData2.hot ~= 1 then
				imgHot:setEnabled(false)
			end
			btnServer:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					AudioHelper.playCommonEffect()
					LayerManager.removeLayout()
					NewLoginCtrl.setSelectServer(tbData2)
				end
			end)
		else
			local btnServer = m_fnGetWidget(itemCell, "BTN_SERVER2")
			btnServer:setEnabled(false)
		end
	end
end

function create(tbAllServerData, recentServerList)
	m_UIMain = g_fnLoadUI("ui/regist_server.json")

	m_lsvMain = m_fnGetWidget(m_UIMain, "LSV_MAIN")
	m_layCell1 = m_fnGetWidget(m_UIMain, "LAY_SERVER2_CLONE1")
	m_layCell2 = m_fnGetWidget(m_UIMain, "LAY_SERVER2_CLONE2")

	m_lsvMain:setItemModel(m_layCell2)

	-- 最近登陆服务器列表
	createList(recentServerList, 1)
	-- 所有服务器列表
	createList(tbAllServerData, 2)

	return m_UIMain
end

