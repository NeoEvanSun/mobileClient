-- Filename: BulletinData.lua
-- Author: fang
-- Date: 2013-07-03
-- Purpose: 该文件用于: 01, 通告栏

module ("BulletinData", package.seeall)

require "db/DB_Game_notice"
require "db/DB_Game_tip"
-- require "db/DB_Heroes"
-- require "script/module/public/ItemUtil"
--require "script/module/partner/HeroPublicUtil"

-- require ""
local _allBulletdata = {}
local _bulletData= {}		-- 从后端传来的数据
local m_i18nString 				= gi18nString
-- 
function setMsgData( msgPara )

	_bulletData = {}

	if(tonumber(msgPara.channel)== 1) then
		table.insert(_allBulletdata, msgPara.message_text)
		--_bulletData =  msgPara.message_text
	end
end

function release( )
	_bulletData = {}
end

-- 处理bulletData中的数据，得到要显示跑马灯的内容
function getBulletNode( )
	
	local bulletInfoNode = nil 
	_bulletData= _allBulletdata[1]
	table.remove(_allBulletdata, 1)
	if(_bulletData== nil) then
		_bulletData= {}
	end

 
		bulletInfoNode = getDefaultMsg()
	--end

	release( )

	if(bulletInfoNode== nil) then
		bulletInfoNode = CCNode:create()
	end
	return bulletInfoNode

end
--把参数中的所有节点按水平方向排开，并加到一个node上
function createHorizontalwidget( node_table )
    local width = 0
    local height = 0
    for k,v in pairs(node_table) do
        width = width + v:getContentSize().width * v:getScaleX()
        if(v:getContentSize().height * v:getScaleY() > height) then
            height = v:getContentSize().height * v:getScaleY()
        end
    end

    local nodeContent = Layout:create()

    nodeContent:setSize(CCSizeMake(width, height))
    local tempWidth = 0
    for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0, 0.5))
        v:setPosition(ccp(tempWidth, 0.5 * height))
        nodeContent:addChild(v)
        tempWidth = tempWidth + v:getContentSize().width * v:getScaleX()
    end
    return nodeContent
end
--[[
	@des 	:创建根据参数显示颜色的
	@param 	:table {
					{txt = ，color}
					}
	@retrun : node
]]
local function createTxtNode( tParam )

	local bInMainShip = TopBar.shouldShowYellow()

	local alertContent = {}
	local fColor = bInMainShip and ccc3(0x47, 0x17, 0x06) or nil -- 2015-04-15, zhangqi, 主界面跑马灯字体颜色
	for i=1,#tParam do
		--alertContent[i]= CCLabelTTF:create("" .. tParam[i].txt , g_sFontName, 18)

		alertContent[i] = Label:create()

		alertContent[i]:setFontName(g_FontCuYuan) -- zhangqi, 2015-04-22, 所有跑马灯字体用方正粗圆简体

    	alertContent[i]:setFontSize(bInMainShip and g_tbFontSize.normal or 20) -- zhangqi, 2015-04-22, 其他跑马灯字体大小 20
    	
		if(tParam[i].txt ) then
			alertContent[i]:setText("" .. tParam[i].txt or " " )
		end

		if (fColor) then
			alertContent[i]:setColor(fColor)
		elseif (tParam[i].color) then
			alertContent[i]:setColor(tParam[i].color)
		end
	end

	local nodeContent= createHorizontalwidget(alertContent)
	return nodeContent
	-- local alertContent = {}
	-- local strContent = ""
	-- local tbColor = {}
	-- for i=1,#tParam do
	-- 	strContent = strContent .. "|" .. tParam[i].txt
	-- --	alertContent[i]= CCLabelTTF:create("" .. tParam[i].txt , g_sFontName, 18)
	-- 	if(tParam[i].color ) then
	-- 		--alertContent[i]:setColor(tParam[i].color)
	-- 		table.insert(tbColor,tParam[i].color)
	-- 	else
	-- 		logger:debug("we can't find any color in DBtable")
	-- 	end
	-- end

	-- local tbRich = {strContent,tbColor}
	-- return tbRich
end

--[[
	@des 	:当后端没有推数据时，从DB_Game_tip 随机得到数据显示
	@param 	:
	@retrun : table
]]

function getDefaultMsg(  )
	require "script/model/DataCache"
	local length = tonumber(table.count(DataCache.getRules().scrollInfo))
	local length = tonumber(table.count(DB_Game_tip.Game_tip))
	math.randomseed(os.time()) 
	local id =  math.random(1,length)
	local noticeInfo = DB_Game_tip.getDataById(tonumber(id)).game_tip
	--local noticeInfo = DataCache.getRules().scrollInfo
	local noticeInfo= lua_string_split(noticeInfo,"|")
	local noticeTable = {}

	local colorTable --= {255, 255, 255}
	local txt 
	for i=1,#noticeInfo,2 do
	    local templeTable = {txt="", color= nil }
	    colorTable = lua_string_split(noticeInfo[i],",")
	    templeTable.color =  ccc3(tonumber(colorTable[1]), colorTable[2],colorTable[3] )
	    templeTable.txt = noticeInfo[i+1]
	    table.insert(noticeTable, templeTable)
	end
	local nodeContent = createTxtNode(noticeTable)	
	return nodeContent

end


-- 16
 function getHeroEvoMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(16).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	local htid= _bulletData.template_data[3].htid
	local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	noticeInfo= string.gsub(noticeInfo,"|", heroName ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[2].evolveLv ,1)
	return noticeInfo
end

  

--  DB_Game_notice 17
function getShopRecuitMsg( )
	local noticeInfo = DB_Game_notice.getDataById(17).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[2].evolveLv ,1)
	return noticeInfo
end
 

-- DB_Game_notice 18
function getTenRecuitMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(18).content
	noticeInfo= string.gsub(noticeInfo,"|", _bulletData.template_data[1].uname ,1)

	local htid= _bulletData.template_data[2].htid
	local heroName = DB_Heroes.getDataById(tonumber(htid)).name
	noticeInfo= string.gsub(noticeInfo,"|", heroName ,1)

	return noticeInfo
end

 


 

-- DB_Game_notice: 22, 这个和前面的可以重用
function getLuckMsg( )
	local noticeInfo = DB_Game_notice.getDataById(22).content

end


--DB_Game_notice: 23  使用宝箱： |打开|获得了|，奇珍异宝尽在宝箱
function getBoxMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(23).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local noticeTable = {
		{txt=noticeInfo[1], },
		{txt= _bulletData.template_data[1].uname, },
		{txt =noticeInfo[2], },
	}

	local boxTable = {txt= "", color= nil}
	local itemTableInfo  = ItemUtil.getItemById(tonumber(_bulletData.template_data[3].box))
	boxTable.txt = itemTableInfo.name
	boxTable.color = HeroPublicUtil.getCCColorByStarLevel(itemTableInfo.quality)

	table.insert(noticeTable, boxTable)

	local tempTable = {txt= noticeInfo[3] }
	table.insert(noticeTable,tempTable)

	-- 物品
	local tableNum = table.count(_bulletData.template_data[2]) 
	local i=1
	for item_template_id , num in pairs(_bulletData.template_data[2]) do
		local item = { txt = "", color= nil }
		itemTableInfo = ItemUtil.getItemById(item_template_id)
		itemColor =  HeroPublicUtil.getCCColorByStarLevel(itemTableInfo.quality)
		item.txt = itemTableInfo.name .. "*" .. num 
		-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
		item.color = itemColor
		table.insert(noticeTable,item)

		local commaTable = {txt = ",",}
		if(i< tableNum) then
			table.insert(noticeTable, commaTable)
		end 
		i= i+1
	end

	local tempTable1= {txt = noticeInfo[4], }
	table.insert(noticeTable, tempTable1)

	local nodeContent = createTxtNode(noticeTable)	
	return nodeContent
	
end



-- DB_Game_notice: 25
function getFirstGiftMsg()
	-- local noticeInfo = DB_Game_notice.getDataById(25).content
	-- noticeInfo = lua_string_split(noticeInfo, "|")

	-- local silver = _bulletData.template_data[3].silver

	-- local noticeTable = {
	-- 	{txt=noticeInfo[1], },
	-- 	{txt= _bulletData.template_data[1].uname, },
	-- 	{txt =noticeInfo[2], },
	-- }

	-- -- 物品
	-- local tableNum = table.count(_bulletData.template_data[2]) 
	-- local i=1
	-- for item_template_id , num in pairs(_bulletData.template_data[2]) do
	-- 	local item = { txt = "", color= nil }
	-- 	itemTableInfo = ItemUtil.getItemById(item_template_id)
	-- 	itemColor =  HeroPublicUtil.getCCColorByStarLevel(itemTableInfo.quality)
	-- 	item.txt = itemTableInfo.name .. "*" .. num 
	-- 	-- item.txt =string.gsub(item.txt,"，，", "，" ,1)
	-- 	item.color = itemColor
	-- 	table.insert(noticeTable,item)

	-- 	local commaTable = {txt = ",",}
	-- 	if(i< tableNum) then
	-- 		table.insert(noticeTable, commaTable)
	-- 	end 
	-- 	i= i+1
	-- end

	-- local tempTable1= {txt = noticeInfo[3], }
	-- table.insert(noticeTable, tempTable1)

	-- local tempTable2 = {txt = "" .. _bulletData.template_data[3].silver, }
	-- table.insert(noticeTable, tempTable2)

	-- local tempTable3= {txt = noticeInfo[4], }
	-- table.insert(noticeTable, tempTable3)

	-- local nodeContent = createTxtNode(noticeTable)	
	return nil
	
end

-- 得到世界boss 中的广播  DB_Game_notice: 26,27
function getBossMsg( template_id )
	-- local noticeInfo = DB_Game_notice.getDataById(template_id).content
	-- noticeInfo= lua_string_split(noticeInfo,"|")

	-- local id = tonumber(_bulletData.template_data[1].bossId)  
	-- require "db/DB_Worldboss"
	-- local bossName= DB_Worldboss.getDataById(id).name

	-- local noticeTable = {
	-- 	{txt=noticeInfo[1]},
	-- 	{txt=bossName , color = ccc3(0x00,0xff,0x18) },
	-- 	{txt =noticeInfo[2], },
	-- }
	-- local nodeContent = createTxtNode(noticeTable)	
	return nil
end

-- 获得世界boss中的谁击杀了XXX,  DB_Game_notice: 28
function getBossKillMsg( )
	-- local noticeInfo = DB_Game_notice.getDataById(28).content
	-- noticeInfo= lua_string_split(noticeInfo,"|")

	-- local playName= _bulletData.template_data.uname
	-- local id = tonumber(_bulletData.template_data.bossId) 
	-- require "db/DB_Worldboss"
	-- local bossName= DB_Worldboss.getDataById(id).name

	-- local noticeTable = {
	-- 	{txt=noticeInfo[1]},
	-- 	{txt=playName , color = ccc3(0x00,0xff,0x18) },
	-- 	{txt =noticeInfo[2], },
	-- 	{txt = bossName,color = ccc3(0x00,0xff,0x18) },
	-- 	{txt = noticeInfo[3] },

	-- }

	-- local nodeContent = createTxtNode(noticeTable)	
	return nil

end

function getBossRankMsg(  )
	local noticeInfo = DB_Game_notice.getDataById(29).content
	noticeInfo= lua_string_split(noticeInfo,"|")

	local template_data= _bulletData.template_data

	local noticeTable= {
		-- {txt=noticeInfo[1]},
	}


	local function keySort(data_1, data_2 )
		return tonumber(data_1.rank)<tonumber(data_2.rank)
	end

	table.sort(template_data, keySort)
	print("template_data  is : ")
	print_t(template_data)

	for i=1, #template_data do
		local firstContent = {txt=noticeInfo[2*i-1], }
		table.insert(noticeTable, firstContent)

		local nameContent = { txt = "", color= ccc3(0x00,0xff,0x18) }
		nameContent.txt= template_data[i].uname
		table.insert(noticeTable,nameContent)

		local commaTable= { txt =noticeInfo[2*i] , color= ccc3(0x00,0xff,0x18) }
		table.insert(noticeTable, commaTable)

		local hurtContent = { txt = template_data[i].percent , color= ccc3(0x00,0xff,0x18)}
		table.insert(noticeTable, hurtContent)

	end
	local lastContent= {txt=  noticeInfo[7], }
	table.insert(noticeTable, lastContent )

	local nodeContent = createTxtNode(noticeTable)	
	return nodeContent

end



