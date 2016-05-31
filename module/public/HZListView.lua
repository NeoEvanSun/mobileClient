-- FileName: HZListView.lua 
-- Author: zhangqi
-- Date: 14-5-25 
-- Purpose: 对 HZTableView 的封装，方便使用

require "script/module/public/class"

HZListView = class("HZListView")

function HZListView:ctor(...)
    -- add by huxiaozhou swallow touch 
    self.sListType = ...
    -- LayerManager.addLoading()
    self.tbCellMap = {} -- 存放CCTableViewCell和Cell对象的对应关系, 便于复用
    self.Data = {} -- 数据源，默认空表
    self.nCount = 0
    self.idxBarData = -1 -- 按钮面板数据的index, 2015-04-20

    self.tbExtData = {} -- zhangqi, 2015-04-27, 存放满足特殊需要的Key-value数据
end

-- tbView = {szView, szCell, tbDataSource, CellAtIndexCallback, CellTouchedCallback, didScrollCallback, didZoomCallback}
function HZListView:init(tbView)
    self.viewCfg = tbView
    self.view = HZTableView:create(tbView.szView)

    self.view:registerScriptHandlerForNode(function ( eventType, node )
        if (eventType == "exit") then
            logger:debug("HZTableView onExit")
            self:setBtnBarData()
        end
    end)

    
    if (self.view) then
        self.view:setDirection(kCCScrollViewDirectionVertical) -- 默认垂直滑动
        self.view:setVerticalFillOrder(kCCTableViewFillTopDown) -- 默认从上至下放置
        self.view:setPosition(ccp(0, 0))
        
        if (tbView.tbDataSource) then
            self.Data = tbView.tbDataSource
            self.count = #self.Data
            logger:debug("self.Data count: %d", #self.Data)
        end
        
        self.CellAtIndexCallback = tbView.CellAtIndexCallback
        self.CellTouchedCallback = tbView.CellTouchedCallback
        self.didScrollCallback = tbView.didScrollCallback
        self.didZoomCallback = tbView.didZoomCallback
        
        
        -- CCTableView.kTableCellSizeAtIndex 事件回调
        local function cellAtIndex( view, idx )
            local cell = view:dequeueCell()
            local tbData = self.Data[idx+1] -- 数据源table的index从1开始，tableView的index从0开始，所以此处需要+1

            if (not cell) then
                if (self.CellAtIndexCallback) then
                    local objCell = self.CellAtIndexCallback(tbData, idx, self)
                    
                    cell = CCTableViewCell:new()
                    local gp = objCell:getGroup() -- 每个cell上的touch group
                    cell:addChild(gp, 100, 100)
                    
                    self.tbCellMap[cell] = objCell
                    self.nCount = self.nCount + 1 -- add by huxiaozhou 
                end
            else
                local objCell = self.tbCellMap[cell]
                if (objCell) then
                    objCell:refresh(tbData,idx)
                end
            end

            return cell
        end
    
        -- CCTableView.kTableCellTouched 事件回调
        local function cellOnTouch( view, cell )
            logger:debug("HZListView:cellOnTouch")

            local cellWdPos = cell:convertToWorldSpace(ccp(0, 0))
            local viewWdPos = self:getWorldPosition()
            self.distY = cellWdPos.y - viewWdPos.y
            logger:debug("cellOnTouch: cellWdPos.x = %f, y = %f; viewWdPos.x = %f, y = %f; distY = %f", cellWdPos.x, cellWdPos.y, viewWdPos.x, viewWdPos.y, self.distY)

            local point = tolua.cast(cell:getUserData(), "CCPoint")
            
            local objCell = self.tbCellMap[cell]
            if (objCell) then
                local objTouch = objCell:touchMask(point)
                if (objTouch) then
                    -- objTouch.sender:setFocused(false)
                    if (objTouch.sender:getName() == self.btnTouchedName and objTouch.event) then
                        objTouch.event(objTouch.sender, TOUCH_EVENT_ENDED)
                    end
                    return
                end
            end
            
            if (self.CellTouchedCallback) then
                -- add by sunyunpeng 2015.5.12
                AudioHelper.playCommonEffect()
                self.CellTouchedCallback(view, cell, objCell)
            end
        end
    
        -- CCTableView.kNumberOfCellsInTableView 事件回调
        local function numberOfCells(view)
            return #self.Data
        end
        
        local function didScroll(view)
            if (self.didScrollCallback) then
                self.didScrollCallback()
            end
        end
        
        local function didZoom(view)
            if (self.didZoomCallback) then
                self.didZoomCallback()
            end
        end

        -- CCTableView::kTableCellHighLight
        local function highLightCell( view, cell )
            logger:debug("HZListView:highLightCell")
            local point = tolua.cast(cell:getUserData(), "CCPoint")
            
            local objCell = self.tbCellMap[cell]
            if (objCell) then
                logger:debug("objCell is not nil")
                local objTouch = objCell:touchMask(point)
                if (type(objTouch) == "table") then -- zhangqi, 如果touchMask返回的是table则包含按钮和按钮事件
                    logger:debug("objTouch is not nil")
                    if (objTouch.sender) then
                        logger:debug("objTouch.sender name = %s", objTouch.sender:getName())
                        self.btnTouchedName = objTouch.sender:getName()
                        objTouch.sender:setFocused(true)
                        self.btnTouched = objTouch.sender
                    end
                end
            end
        end
        -- CCTableView::kTableCellUnhighLight
        local function unhighLightCell( view, cell )
            logger:debug("HZListView:unhighLightCell")
            if (self.btnTouched) then
                self.btnTouched:setFocused(false)
                self.btnTouched = nil
            end
        end
        self.view:registerScriptHandler(highLightCell, CCTableView.kTableCellHighLight)
        self.view:registerScriptHandler(unhighLightCell, CCTableView.kTableCellUnhighLight)

        self.view:registerScriptHandler(cellAtIndex, CCTableView.kTableCellSizeAtIndex)
        self.view:registerScriptHandler(cellOnTouch, CCTableView.kTableCellTouched)
        self.view:registerScriptHandler(numberOfCells, CCTableView.kNumberOfCellsInTableView)
        self.view:registerScriptHandler(
            function ( view, idx )
                local tbData = self.Data[idx+1] -- zhangqi, 2015-04-29, 获取按钮面板对应的数据
                if (tbData.height) then
                    return tbData.height, tbData.width
                else
                    return tbView.szCell.height, tbView.szCell.width
                end
            end, CCTableView.kTableCellSizeForIndex
        )
        if (tbView.didScrollCallback) then
            self.view:registerScriptHandler(didScroll, CCTableView.kTableViewScroll)
        end
        if (tbView.didZoomCallback) then
            self.view:registerScriptHandler(didZoom, CCTableView.kTableViewZoom)
        end
        return true
    end

    return false
end

function HZListView:refresh()
    if (self.view) then
        LayerManager.addLoading()
        -- add by huxiaozhou 2014-08-08 当背包列表数据是空的时候 移除掉loading，因为没用数据不会执行 背包进入动画，需要提前判断是否移除
        if (#self.Data==0 or self.sListType == nil) then
            LayerManager.removeLoading()
        end
        self.view:reloadData()
    end
end
function HZListView:refreshNotReload()
    if (self.view) then
        logger:debug(self.Data)
        -- add by huxiaozhou 2014-08-08 当背包列表数据是空的时候 移除掉loading，因为没用数据不会执行 背包进入动画，需要提前判断是否移除
        if (#self.Data==0 or self.sListType == nil) then
            LayerManager.removeLoading()
        end
       -- self.view:reloadData()
    end
end
--  add by huxiaozhou  2014-08-01 
--  背包 进入 cell 动画
function HZListView:enterAnimation(  )
    logger:debug("self.nCount = " .. self.nCount)
    -- self.view:setTouchEnabled(false)
    for idx=0,self.nCount-1 do
        local cell = self.view:cellAtIndex(idx)
        if (cell==nil) then
            break
        end

        local objCell = self.tbCellMap[cell]
        UIHelper.startCellAnimation(objCell.mCell, idx+1,function ( )
            if(self.view:cellAtIndex(idx+1)==nil or idx==(self.nCount-1)) then
                logger:debug("Cell 动画播放完了")
                -- self.view:setTouchEnabled(true)
                LayerManager.removeLoading()
            end
        end)
    end
end

function HZListView:changeDataSource(tbData)
    self.Data = tbData
    self.count = #self.Data
    self:refresh()
end
 
--by ZhangXiangHui
function HZListView:changeData(tbData)
    self.Data = tbData
    self.count = #self.Data
end
 
--[[desc:zhangjunwu 2014-09-10 重新加载tableview并且保持之前的位置不变
    arg1: nil
    return: nil  
—]]
function HZListView:reloadDataByBeforeOffset()
    local offset = self.view:getContentOffset()
    self.view:reloadData()
    self.view:setContentOffset(ccp(offset.x,offset.y))
end

--[[desc:lizy 2014-09-10 重新加载tableview并且保持之前的位置不变
    modified: zhangqi, 2014-12-26
    num: 需要删除的cell数量
    nIndex: 被删除所有cell里最后一个（最下面一个）在TableView中的index（index从0开始）
    return: nil  
—]]
function HZListView:reloadDataDelByOffset(num, nIndex)
    logger:debug("HZListView:reloadDataDelByOffset-num:%s, nIndex:%s", tostring(num), tostring(nIndex))

    local nInnerCount = math.ceil(self.view:getViewSize().height/self.viewCfg.szCell.height)
    logger:debug("self.count = %d, nInnerCount = %d", self.count, nInnerCount)
    local offset = self.view:getContentOffset()

    self.view:reloadData()

    -- 实际数量比滑动区域可显示的数量少，刷新整个列表
    -- 实际数量比滑动区域可显示的数量多，但是只删除了最上面的第一个cell, 刷新整个列表
    -- 同时删除2个以上cell，刷新整个列表
    if (self.count <= nInnerCount) or (num == 1 and nIndex == 0) or (num > 2) then
        return
    end

    -- 删除 2 个以内的物品，下面的依次上移
    self.view:setContentOffset(ccp(offset.x, offset.y + num * self.viewCfg.szCell.height))  
end

--[[desc:李卫东 20140814 重新加载tableview并且保持之前的位置不变
    arg1: nil
    return: nil  
—]]
function HZListView:reloadDataByOffset()
    local offset=self.view:getContentOffset()
    self.view:reloadData()
    self.view:setContentOffset(ccp(offset.x,offset.y+self.viewCfg.szCell.height))
end

--[[desc:李卫东 20140814 增加新的数据后 重新加载tableview并且保持之前的位置上向移动一个格
    arg1: num 给出新增加的个数
    return: nil  
—]]
function HZListView:reloadDataByInsertData(num)
    local offset=self.view:getContentOffset()
    self.view:reloadData()
    self.view:setContentOffset(ccp(offset.x,-num*self.viewCfg.szCell.height))
    
end
--更新某一个cell,idx为cctableview的行标,更新前需要处理数据，再changeData更新下原来的数据，by ZhangXiangHui
function HZListView:updateCellAtIndex(idx)
    local cell = self.view:cellAtIndex(idx)
    local objCell = self.tbCellMap[cell]
    if (objCell) then
        local tbDataItem = self.Data[idx+1]
        objCell:refresh(tbDataItem)
    end
end

--更新所有cell,更新前需要先删除/改变数据，再changeData更新下原来的数据，by ZhangXiangHui
function HZListView:updateAllCell()
    if (#self.Data > 0) then
        for i, v in ipairs(self.Data) do -- zhangqi, 2014-07-17, self.Data 本来就是一个 array 型table，需要用ipairs来遍历
            self:updateCellAtIndex(i-1)
        end
    else
        self:refresh()
    end
end

function HZListView:insertMoreCell(m,n)
    for i=m,m+n do
        self.view:insertCellAtIndex(i)
    end
end

function HZListView:getView()
   return self.view
end

function HZListView:setEnabled( bStat )
    logger:debug(bStat)
    self.view:setVisible(bStat)
    self.view:setTouchEnabled(bStat)
end

-- 返回列表所有数据的个数
function HZListView:cellCount( ... )
    return self.count
end

-- zhangjunwu
function HZListView:removeView()
    if (self.view) then
        self.view:removeFromParentAndCleanup(true)
    end
end

-- zhangqi, 2015-04-29
function HZListView:getWorldPosition( ... )
    return self.view:convertToWorldSpace(ccp(0, 0));
end

function HZListView:saveOffsetYBeforeBarDown( ... )
    self.downOffsetY = self.view:getContentOffset().y
end

function HZListView:saveOffsetOfInit( ... )
    self.origOffsetY = self.view:getContentOffset().y
    logger:debug("HZListView:saveOffsetOfInit origOffsetY = %f", self.origOffsetY)
end

-- zhangqi, 2015-04-29
function HZListView:reloadDataForBtnBar( nFlag, nDataIdx )
    local oldOffset = self.view:getContentOffset()
    local newOffset = oldOffset
    logger:debug("reloadDataForBtnBar1: oldOffset.x = %f, y = %f", oldOffset.x, oldOffset.y)

    local szBar = self:getBtnBarSize()
    local topView = self:getWorldPosition().y + self.viewCfg.szView.height
    local heightCell = self.viewCfg.szCell.height
    local distY = self.distY

    logger:debug("reloadDataForBtnBar: szBar.height = %f, distY = %f, topView = %f, heightCell = %f", szBar.height, distY, topView, heightCell)
    local offsetY = szBar.height*nFlag

    if (distY < szBar.height) then -- 最底部高度不够，刷新时需要在offset基础上增加高度
        newOffset.y = oldOffset.y - distY -- + szBar.height 
        logger:debug("condition1: newOffset.y = %f", newOffset.y)
    end

    if (distY >= szBar.height and distY <= (topView - heightCell)) then -- 不需要修改offset
        logger:debug("condition2: distY = %f, topOffset.y = %f", distY, topView - heightCell)
        
        if (self.bBtnBar and nFlag == 1) then
            offsetY = 0
        end
        newOffset.y = oldOffset.y - offsetY
        logger:debug("condition2: newOffset.y = %f", newOffset.y)
    end

    -- 需要在offset基础上减少高度
    if ( distY > (topView - heightCell) and distY <= (topView - heightCell/2) ) then
        logger:debug("condition3")

        if (self.bBtnBar and nFlag == 1) then
            offsetY = 0
        end
        newOffset.y = oldOffset.y - (topView - distY) - offsetY
        logger:debug("condition3: newOffset.y = %f", newOffset.y)
    end

    if (nFlag ~= 1) then
        newOffset.y = self.downOffsetY
    end

    if (nDataIdx == 1) then
        newOffset.y = self.view:minContainerOffset().y - offsetY
        logger:debug("condition4: dataIdx = %d, newOffset.y = %f", nDataIdx, newOffset.y)
    elseif (nDataIdx == #self.Data) then
        if (self.downOffsetY < self.origOffsetY) then
            newOffset.y = self.origOffsetY > self.view:maxContainerOffset().y and self.origOffsetY or self.view:maxContainerOffset().y
        end

        logger:debug("condition4: dataIdx = %d, newOffset.y = %f, downOffsetY = %f, ", nDataIdx, newOffset.y, self.downOffsetY)
    end

    self.view:reloadData()

    logger:debug("reloadDataForBtnBar2: newOffset.x = %f, y = %f", newOffset.x, newOffset.y)
    self.view:setContentOffset(newOffset)

    self.bBtnBar = nFlag == 1
end

-- zhangqi, 2015-04-29, 获取ButtonBar的size, 如果没有则返回cell的size
function HZListView:getBtnBarSize( ... )
    if (self.btnBarSize) then
        return self.btnBarSize
    end

    local objCell = nil
    for k, v in pairs(self.tbCellMap) do
        objCell = v
        break
    end
    if (objCell) then
        self.btnBarSize = objCell.objBtnBar:cellSize()
        return self.btnBarSize
    end

    return self.viewCfg.szCell
end

-- 设置和删除给按钮面板构造的cell数据，2015-04-24
function HZListView:setBtnBarData( tbData, idxData )
    logger:debug("HZListView:setBtnBarData")

    if (tbData) then
        self.idxBarData = idxData
        table.insert(self.Data, self.idxBarData, tbData)

        for i, data in ipairs(self.Data) do
            data.idx = i
        end
    elseif (self.idxBarData > 0) then
        logger:debug("self.idxBarData = %d", self.idxBarData)

        table.remove(self.Data, self.idxBarData)
        self.idxBarData = -1

        for i, data in ipairs(self.Data) do
            data.idx = i
        end

        self:setExtData(g_tagBtnBar)
    end
end

function HZListView:getBtnBarDataIdx( ... )
    return self.idxBarData
end

-- 设置需要HZListView保存的额外信息，2015-04-27，zhangqi
function HZListView:setExtData( skey, data )
    self.tbExtData[skey] = data
    return self.tbExtData[skey]
end
-- 读取需要HZListView保存的额外信息，2015-04-27，zhangqi
function HZListView:getExtData( skey )
    return self.tbExtData[skey]
end
