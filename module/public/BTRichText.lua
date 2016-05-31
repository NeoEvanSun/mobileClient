-- FileName: BTRichText.lua
-- Author: zhangqi
-- Date: 2014-04-16
-- Purpose: 根据指定的文本资源id查找文本串，然后返回生成的Label控件或UIRichText富文本控件
--[[TODO List]]

module("BTRichText", package.seeall)

-- 模块局部变量 --
local m_tbBtns -- 存放所有文本按钮的引用，便于事件的绑定
local m_FontInfo = g_FontInfo
local m_nRed, m_nGreen, m_nBlue = 0xff, 0xff, 0xff -- 颜色, 默认白色
local m_sRed, m_sGreen, m_sBlue = 0x00, 0x00, 0x00 -- 描边颜色，默认黑色
local m_nOpacity = 255 -- 透明度，默认不透明

local m_strokeWidth = m_FontInfo.stroke -- 描边宽度

local function init(...)
	m_tbBtns = {} 
end

function destroy(...)
	package.loaded["BTRichText"] = nil
end

function moduleName()
    return "BTRichText"
end

local function findStringByid(nId)
	local sampleText = "花费|return {spec=true;color={r=0xff,g=0xe4,b=0x00};font=\"STHeitiSC-Medium\";size=30;style={type=1;color={r=0,g=0,b=0};stroke=2;};text=\"%s\"}|return {color={r=0xff,g=0x00,b=0x00};text=\"金币\"}|" ..
						"可|return {color={r=0x00,g=0xff,b=0x00};btn=true;text=\"消除\"}|冷却"
	--local sampleText = "花费|return {color={r=255,g=0,b=0};font=\"STHeitiSC-Medium\";size=32;text=\"%s\"}|金币可消除冷却" , , 
	return sampleText
end

local function createTextBtn( labText )
	local menuItem = CCMenuItemLabel:create(labText)
	table.insert(m_tbBtns, menuItem) -- 保留menuItem的引用，便于注册事件的方法使用
	logger:debug(menuItem)
	menuItem:setAnchorPoint(ccp(0,0))
	local menuText = CCScrollMenu:create()
	menuText:setTouchPriority(g_tbTouchPriority.richTextBtn)
	menuText:addChild(menuItem)
	menuText:setContentSize(menuItem:getContentSize()) -- 设置menu的大小为item大小，富文本排列元素位置才不会出错
	return menuText
end
local function createUIBtn( str, fontName, fontSize, color  )
	local btnItem = Button:create()
	table.insert(m_tbBtns, btnItem) -- 保留menuItem的引用，便于注册事件的方法使用
	--btnItem:setAnchorPoint(ccp(0,0))
	btnItem:setTitleText(str)
	btnItem:setTitleColor(color)
	btnItem:setTitleFontSize(fontSize)
	btnItem:setTitleFontName(fontName)
	btnItem:setEnabled(true)
	return btnItem
end

--[[desc: 指定属性创建一个Label对象
    strText, 文本内容；strFontName, 字体名称；nFontSize, 字体大小；ccc3Color，文本颜色，ccc3(r, g, b)
    sizeArea, 文本区域大小，CCSize; 
    alignHorizontal, 水平对齐模式，[kCCTextAlignmentLeft, kCCTextAlignmentCenter, kCCTextAlignmentRight]
    alginVertical, 垂直对齐模式，[kCCVerticalTextAlignmentTop, kCCVerticalTextAlignmentCenter, kCCVerticalTextAlignmentBottom]
    return: 是否有返回值，返回值说明
—]]
local function createUILabel( strText, strFontName, nFontSize, ccc3Color,
							  sizeArea, alignHorizontal, alginVertical)
	local labText = Label:create()
	labText:setText(strText)
	if (strFontName) then
		labText:setFontName(strFontName)
	end
	if (nFontSize) then
		labText:setFontSize(nFontSize)
	end
	if (ccc3Color) then
		labText:setColor(ccc3Color)
	end
	if (sizeArea) then
		labText:setTextAreaSize(sizeArea)
	end
	if (alignHorizontal) then
		labText:setTextHorizontalAlignment(alignHorizontal)
	end
	if (alginVertical) then
		labText:setTextVerticalAlignment(alginVertical)
	end

	return labText
end

--[[desc: zhangqi, 创建一个描边效果的CCLabelTTF对象
    strText: 指定文本
    c3FontColor: 字体颜色，nil的话默认黑色
    c3StrokeColor: 描边颜色，nil的话默认黑色
    bShadow: 是否带阴影
    nFontSize: 字号，nil的话默认18
    strFontName: 必须是带后缀名的字体文件名，如果是nil则默认方正简黑
    nStrokeSize: 描边宽度，nil的话默认2px
    return: CCLabelTTF对象
—]]
local function createStrokeTTF( strText, c3FontColor, c3StrokeColor, bShadow, nFontSize, strFontName, nStrokeSize )
	local ttf = LabelFT:create(strText, strFontName or m_FontInfo.name, nFontSize or g_tbFontSize.normal)

	if (nStrokeSize) then
		ttf:enableStroke(c3StrokeColor,nStrokeSize or 2)
	end

	--local ttf = CCLabelTTF:create(strText or "", strFontName or m_FontInfo.name, nFontSize or g_tbFontSize.normal) -- 默认方正简黑
	ttf:setColor(c3FontColor or ccc3(255,255,255))
	ttf:setFontFillColor(c3FontColor or ccc3(0,0,0)) -- 默认黑色
	--ttf:enableStroke(c3StrokeColor or ccc3(0,0,0), nStrokeSize or 2);
	if (bShadow) then
		ttf:enableShadow(CCSizeMake(3, -3), 255, 0);
	end
	return ttf
end

--[[desc: 创建一个富文本控件
    tbRich: table, 富文本内容和信息表
    szRect: CCSize, 如果不是nil, 则设置富文本控件的宽高
    nLineSpace: 行高，如果小于0则不设置
    ...: 任意参数，直接作为string.format的参数，替换文本串中的变量占位符 %s
    return: Widget对象，UIRichText
—]]
function create( tbRich, szRect, nLineSpace, ... )
	init()

	local tbParam = {...}

	local tag = 0
	local richEle = nil -- 富文本元素对象引用
	local richText = RichText:create() -- 创建富文本对象
	logger:debug(tbRich[1])
	logger:debug(...)

	local tbText = nil
	local text = nil
	
    if(select("#",...) > 0) then
    	text = string.format(tbRich[1], ...) -- 用需要替换的数值格式化文案
	else
		text = tbRich[1]
	end

	if(not string.find(tbRich[1],string.char(17))) then
		 tbText = string.strsplit(text, "|") -- 各部分文本内容，用|分割
	else
		 tbText = string.strsplit(text, string.char(17)) -- 各部分文本内容，用不可见字符分割
	end
	
	logger:debug(tbText)
	local tbOpt = tbRich[2] -- 富文本信息
	logger:debug("tbOpt.size = %d", #tbOpt)

	for i, str in ipairs(tbText) do
		logger:debug("str = %s", str)
		local r, g, b = m_nRed, m_nGreen, m_nBlue -- 文本颜色
		local fontName, fontSize = m_FontInfo.name, m_FontInfo.size -- 文本大小

		if (table.count(tbOpt[i]) == 0) then -- 纯文本元素
			logger:debug("纯文本元素")
			richEle = RichElementText:create(tag, ccc3(m_nRed, m_nGreen, m_nBlue), m_nOpacity, str, m_FontInfo.name, m_FontInfo.size)
		else -- 携带富文本信息，是table
			local opt = tbOpt[i]

			if (opt.color) then -- 颜色
				r, g, b = opt.color.r, opt.color.g, opt.color.b
			end

			fontName = opt.font or m_FontInfo.name -- 字体
			fontSize = opt.size or m_FontInfo.size -- 字号

			if (opt.style) then  -- 特效字（描边, 1; 阴影, 2）
				logger:debug("创建特效字")
				local style = opt.style
				logger:debug(style)
				local sr, sg, sb = m_sRed, m_sGreen, m_sBlue -- 描边的颜色
				if (style.color) then
					sr, sg, sb = style.color.r, style.color.g, style.color.b
				end
				
				local ttfStroke = createStrokeTTF(str, ccc3(r,g,b), ccc3(sr,sg,sb), false, fontSize, fontName, style.size or m_strokeWidth)
				if (opt.btn) then
					richEle = RichElementCustomNode:create(tag, ccc3(r,g,b), m_nOpacity, createTextBtn(ttfStroke)) -- 文字按钮
					logger:debug("add stroke btnText ok")
				else
					logger:debug("not a btnText")
					richEle = RichElementCustomNode:create(tag, ccc3(r,g,b), m_nOpacity, ttfStroke)
				end
			elseif (opt.img) then -- 图片元素
				print("opt.img type ", type(opt.img))
				richEle = RichElementImage:create(tag, ccc3(0xff,0xff,0xff), m_nOpacity, opt.img)
				logger:debug("image element ok")
			else
				if (opt.btn) then
					local labText = createUILabel(str, fontName, fontSize, ccc3(r,g,b))
					richEle = RichElementCustomNode:create(tag, ccc3(r,g,b), m_nOpacity, createTextBtn(labText)) -- 文字按钮
					--richEle = RichElementCustomNode:create(tag, ccc3(r,g,b), m_nOpacity, createUIBtn(str, fontName, fontSize, ccc3(r,g,b))) -- 文字按钮
					logger:debug("add no stroke btnText ok")
				else
					logger:debug("star create my rich text oye")
					richEle = RichElementText:create(tag, ccc3(r, g, b), m_nOpacity, str, fontName, fontSize)
				end
			end -- of if (opt.style)
		end -- of if (type(v) == "string")
		richText:pushBackElement(richEle)
		tag = tag + 1
	end

	local lineH = tonumber(nLineSpace)
	if ( lineH and lineH > 0) then
		richText:setVerticalSpace(lineH)
	end
	if (szRect) then
		richText:setSize(szRect)
	end
	richText:ignoreContentAdaptWithSize(false)  -- 自动换行
	richText:setAnchorPoint(ccp(0, 0))

	return richText -- 返回富文本对象和需要动态替换的elements的index集合
end

--[[desc: 给富文本中的所有可触摸的文本块注册回调事件
    ...: 任意个数的 table, {handler = function, tag = number}, handler:触摸事件function，tag:模拟sender.tag可以取到的值，
         按从左至右顺序注册到对应顺序的可触摸文本块
    return: 
—]]
function addTouchEventHandler( ... )
	local tbEvents = {...}
	logger:debug("tbEvents.len = %d,  m_tbBtns.len = %d", #tbEvents, #m_tbBtns)
	for i, v in ipairs(m_tbBtns) do
		local menuItem = tolua.cast(v, "CCMenuItem")
		menuItem:setTag(tbEvents[i].tag)
		logger:debug("i = %d， tag = %d", i, tbEvents[i].tag)
		menuItem:registerScriptTapHandler(tbEvents[i].handler)
	end
end
