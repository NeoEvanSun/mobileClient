
-- FileName: UIHelper.lua
-- Author: zhangqi
-- Date: 2014-04-18
-- Purpose: 定义 UI 控件相关的方法，比如简化创建等
--[[TODO List]]

module("UIHelper", package.seeall)


require "script/GlobalVars"
--require "script/module/public/ItemUtil"
--require "script/utils/ItemDropUtil"

-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n

local m_ebHolderColor = ccc3(0xc3, 0xc3, 0xc3) -- editBox默认显示文字的颜色

local function init(...)

end

function destroy(...)
	package.loaded["UIHelper"] = nil
end

function moduleName()
	return "UIHelper"
end

-- 2015-05-07, 从PartnerTransfer中提取出来，添加参数layMain:通常是当前模块的主画布Layout对象
function changepPaomao( layMain, fnCallback )
    LayerManager.setPaomadeng(layMain, 0)
    registExitAndEnterCall(layMain, function ( ... )
        LayerManager.resetPaomadeng()
        if (fnCallback and type(fnCallback) == "function") then
        	fnCallback()
        end
    end)
end

-- 2015-04-15, zhangqi, 创建一个被遮罩的节点
-- image_path: 需要被遮罩的图片路径
-- mask_path: 用作遮罩的图片路径
-- scale_factor: 需要被遮罩的图片的缩放比例，例如1.2，默认nil时比例为1
function addMaskForImage( image_path, mask_path, scale_factor )
	local stencilNode = CCNode:create()
	local node = CCSprite:create(mask_path) -- 表示裁剪区域图片，需要是纯黑色图形
	if (scale_factor) then
		node:setScale(scale_factor)
	end
	node:getTexture():setAntiAliasTexParameters()
	local stencilSize = node:getContentSize()
	stencilNode:addChild(node)

	local imgBg = CCSprite:create(image_path)

	if (scale_factor) then
		imgBg:setScale(scale_factor)
	end

	local clipper = CCClippingNode:create()
	-- clipper:setInverted(true)
	clipper:setAlphaThreshold(0.1)
	clipper:setAnchorPoint(ccp(0.5, 0.5))
	clipper:setPosition(ccp(0, 0))

	clipper:addChild(imgBg, 0, 100)

	clipper:setStencil(stencilNode)

	return clipper, CCSizeMake(stencilSize.width*g_fScaleX, stencilSize.height)
end

--[[desc: zhangqi, 20140614, 删除当前场景上所有节点，并清理所有未使用纹理资源
		  如果不存在当前场景，创建新场景加入当前并返回这个新场景
    arg1: 参数说明
    return: CCScene, 当前运行的scene对象
—]]
function resetScene( ... )
	local scene = CCDirector:sharedDirector():getRunningScene()
	if scene then
		scene:removeAllChildrenWithCleanup(true)	-- 删除当前场景的所有子节点
		CCTextureCache:sharedTextureCache():removeUnusedTextures()	-- 清除所有不用的纹理资源
	else
		scene = CCScene:create()
		CCDirector:sharedDirector():runWithScene(scene)
	end
	return scene
end

--[[desc: 处理图片为灰色,只可传入继承自sprite类的对象
    widget: 图片，sprite对象
    zOrder：要添加的zorder
    return: 无
    other: 20140613, zhangqi, 从LuaUtil.lua中转移过来
--]]
function setTextureGray( widget, zOrder, tag)
	if (widget ~= nil) then
		local widgetNode = tolua.cast(widget:getVirtualRenderer(), "CCSprite")
		local imgTexture = BTGraySprite:createWithSprite(widgetNode)
		widget:addNode(imgTexture, zOrder or 0, tag or 0)
	end
end
function setTextureGray1( widget, zOrder, tag)
	if (widget ~= nil) then
	 	local widgetNode = tolua.cast(widget:getVirtualRenderer(), "CCSprite")
		local imgTexture = BTGraySprite:createWithSprite(widget)
		widget:addNode(imgTexture, zOrder or 0, tag or 0)
	end
end
--[[desc: zhangqi, 指定属性创建一个UIListView对象
-- tbCfg = {dir = SCROLLVIEW_DIR_VERTICAL, 
			sizeType = SIZE_PERCENT, sizePercent = ccp(1, 1), size = CCSize,
			posType = ccp(1, 1), posPercent = ccp(0, 0), pos = ccp(0, 0),
			bClipping = true, bBounce = true}
]]

function createListView(tbCfg)
	local list = ListView:create()
	list:setDirection(tbCfg.dir or SCROLLVIEW_DIR_VERTICAL) -- 垂直滑动
	list:setSizeType(tbCfg.sizeType or SIZE_PERCENT) -- 尺寸模式
	list:setPositionType(tbCfg.posType or POSITION_PERCENT) -- 位置模式
	list:setClippingEnabled(tbCfg.bClipping or true) -- 是否裁切
	list:setBounceEnabled(tbCfg.bBounce or true) -- 是否回弹
	list:ignoreContentAdaptWithSize(false)

	if (list:getSizeType() == SIZE_PERCENT) then
		list:setSizePercent(tbCfg.sizePercent or ccp(1, 1))
	else
		list:setSize(tbCfg.size)
	end

	if (list:getPositionType() == POSITION_PERCENT) then
		list:setPositionPercent(tbCfg.posPercent or ccp(0, 0))
	else
		list:setPosition(tbCfg.pos or ccp(0, 0))
	end

	return list
end

--[[desc: zhangqi, 指定属性创建一个Label对象
    strText, 文本内容；strFontName, 字体名称；nFontSize, 字体大小；ccc3Color，文本颜色，ccc3(r, g, b)
    sizeArea, 文本区域大小，CCSize; 
    alignHorizontal, 水平对齐模式，[kCCTextAlignmentLeft, kCCTextAlignmentCenter, kCCTextAlignmentRight]
    alginVertical, 垂直对齐模式，[kCCVerticalTextAlignmentTop, kCCVerticalTextAlignmentCenter, kCCVerticalTextAlignmentBottom]
    return: 是否有返回值，返回值说明
—]]
function createUILabel( strText, strFontName, nFontSize, ccc3Color,
	sizeArea, alignHorizontal, alginVertical)
	local labText = Label:create()
	if strText then
		labText:setText(strText)
	end

	labText:setFontName(strFontName or g_sFontName)
	labText:setFontSize(nFontSize or g_tbFontSize.normal)
	labText:setColor(ccc3Color or g_FontInfo.color)

	if (sizeArea) then
		labText:setTextAreaSize(sizeArea)
	end

	labText:setTextHorizontalAlignment(alignHorizontal or kCCTextAlignmentLeft)
	labText:setTextVerticalAlignment(alginVertical or kCCVerticalTextAlignmentCenter)

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
function createStrokeTTF( strText, c3FontColor, c3StrokeColor, bShadow, nFontSize, strFontName, nStrokeSize )
	local ttf = CCLabelTTF:create(strText or "", strFontName or g_FontInfo.name, nFontSize or g_tbFontSize.normal) -- 默认方正简黑
	ttf:setFontFillColor(c3FontColor or ccc3(0,0,0)) -- 默认黑色
	ttf:enableStroke(c3StrokeColor or ccc3(0,0,0), nStrokeSize or 2);
	if (bShadow) then
		ttf:enableShadow(CCSizeMake(2, -2), 255, 0);
	end
	return ttf
end


--[[desc: menghao 为label添加描边并设置text
	label : Label对象
	strText : 指定文本
	c3StrokeColor : 描边颜色，缺省时为黑色
	nStrokeSize : 描边宽度，缺省时为2 
    return: 无
    modified: zhangqi, 2014-07-03, 把设置描边的代码单独抽出来一个新方法
—]]
function labelAddStroke( label, strText, c3StrokeColor, nStrokeSize )
	if (label.setText) then
		label:setText(strText or "")
	else
		label:setStringValue(strText or "")
	end
	labelStroke(label, c3StrokeColor, nStrokeSize)
end

-- 给Label添加描边效果，方便不需要重新setText的情况，例如 "/"。zhangqi, 2014-07-03
function labelStroke( label, c3StrokeColor, nStrokeSize )
-- local render = tolua.cast(label:getVirtualRenderer(), "CCLabelTTF")
-- local color = c3StrokeColor or ccc3(0, 0, 0)
-- local size = nStrokeSize or 2
-- render:enableStroke(color, size)
end


-- 新描边效果，目前正在使用
function labelNewStroke( label, c3StrokeColor, nStrokeSize )
	local render = tolua.cast(label:getVirtualRenderer(), "CCLabelTTF")
	local color = c3StrokeColor or ccc3(0, 0, 0)
	local size = nStrokeSize or 2
	render:enableStroke(color, size)
end


-- 基于新描边的封装，同时指定文本内容
function labelAddNewStroke( label, strText, c3StrokeColor, nStrokeSize )
	label:setText(strText)
	labelNewStroke( label, c3StrokeColor, nStrokeSize )
end


-- 给Label取消描边效果。xianghuiZhang, 2014-08-07
function labelUnStroke( label )
	local render = tolua.cast(label:getVirtualRenderer(), "CCLabelTTF")
	render:disableStroke(true)
end

-- 给Label同时添加描边和默认的阴影效果，zhangqi, 2014-07-03
function labelEffect( label, strText )
	if (strText) then
		labelAddStroke(label, strText)
	else
		labelStroke(label)
	end
	--labelShadow(label)
end

-- zhangqi, 同时指定label控件的文本，颜色，字体名称和size属性，减少代码
function setLabel( label, tbArgs )
	label:setText(tbArgs.text)
	if (tbArgs.color) then
		label:setColor(tbArgs.color)
	end
	if (tbArgs.font) then
		label:setFontName(tbArgs.font)
	end
	if (tbArgs.size) then
		label:setFontSize(tbArgs.size)
	end
end

-- 给按钮的标题添加阴影效果 圆角，只有btn参数时添加默认设置，zhangqi, 2014-07-03
function titleShadow( btn, sTitle, szOffset, nOpcity, nBlur )
	if (btn) then
		if sTitle then
			btn:setTitleText(sTitle)
		end

		local ttf = tolua.cast(btn:getTitleTTF(), "CCLabelTTF")
		 ttf:setFontName(g_sFontName)
		local offset = szOffset or CCSizeMake(1, -2) -- 按钮标题的阴影size一般是2
		ttfShadow(ttf, offset, nOpcity, nBlur)
	end
end

-- 给Label添加阴影效果，只有label参数时添加默认设置，zhangqi, 2014-07-03
function labelShadow( label, szOffset, nOpcity, nBlur )
	if (label) then
		local ttf = tolua.cast(label:getVirtualRenderer(), "CCLabelTTF")
		local offset = szOffset or CCSizeMake(1, -2) -- 普通文本的阴影size一般是3
		ttfShadow(ttf, offset, nOpcity, nBlur)
	end
end

-- 给Label添加阴影效果，同时指定文本和阴影size，点击, 2014-07-29
function labelShadowWithText( label, sText, szOffset )
	if (label) then
		label:setText(sText or "")
		labelShadow(label, szOffset)
	end
end

--[[desc: 给一个 CCLabelTTF 对象 设置阴影效果，zhangqi, 2014-07-03
	ttf: CCLabelTTF 对象
    szOffset, nOpcity, nBlur: 第二个参数为阴影相对于标签的坐标，第三个参数设置透明度，第四个参数与模糊有关
    return:
—]]
function ttfShadow(ttf, szOffset, nOpcity, nBlur )
	ttf:enableShadow(szOffset, nOpcity or 1, nBlur or 1)
end

-- 默认的关闭按钮回调方法
function closeCallback(  )
	AudioHelper.playCloseEffect()
	LayerManager.removeLayout()
end

-- 默认的关闭按钮事件
function onClose( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		closeCallback()
	end
end

--[[desc: zhangjunwu, 根据 createCommonDlg创建的公用对话框里的文本的高度来更新对话框的高度
    layDlg: 对话框
—]]
function updateCommonDlgSize( layDlg ,heightTotle)

	local IMG_PROMPT_BG = m_fnGetWidget(layDlg,"IMG_PROMPT_BG")
	--S所有子节点的父容器
	local lay_main = m_fnGetWidget(layDlg,"lay_main")
	--背景图
	local PROMPT_Layout = m_fnGetWidget(layDlg,"TFD_PROMPT_TXT")
	--文本高度
	local textLayHeight = PROMPT_Layout:getSize().height

	local excessHeight = heightTotle - textLayHeight
	logger:debug(excessHeight)


	PROMPT_Layout:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	PROMPT_Layout:ignoreContentAdaptWithSize(false)
	PROMPT_Layout:setSize(CCSizeMake(PROMPT_Layout:getSize().width,heightTotle))

	--超出的比例
	local ratio = heightTotle / textLayHeight

	if(excessHeight > 0)then

		local sizePercentY = IMG_PROMPT_BG:getSize().height  * ratio
		logger:debug(ratio .. " ddd" .. sizePercentY)
		lay_main:setSize(CCSizeMake(lay_main:getSize().width, sizePercentY + 0) )
		IMG_PROMPT_BG:setSize(CCSizeMake(IMG_PROMPT_BG:getSize().width, sizePercentY + 0) )

	end

end

-- 网络断开后的专用提示框，zhangqi，2014-09-03
function showNetworkDlg( fnLoginAgainCallback, fnReconnectCallback, bOtherLogin, sTips )
	local layPrompt = g_fnLoadUI("ui/public_prompt.json")

	local btnClose = m_fnGetWidget(layPrompt, "BTN_CLOSE")
	btnClose:setEnabled(false)

	local labText = m_fnGetWidget(layPrompt, "TFD_PROMPT_TXT")

	local function eventLoginAgain ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCloseEffect()
			if (fnLoginAgainCallback) then
				fnLoginAgainCallback()
			end
			LoginHelper.loginAgain()
		end
	end

	local btnSingleAgain = m_fnGetWidget(layPrompt, "BTN_CONFIRM_SURE") -- 返回登陆
	local btnReconn = m_fnGetWidget(layPrompt, "BTN_CONFIRM") -- 重新连接
	local btnAgain = m_fnGetWidget(layPrompt, "BTN_CANCEL") -- 返回登陆

	-- zhangqi, 2015-01-05, 如果帐号别处登陆导致的断线只显示返回登陆
	-- zhangqi, 2015-03-17, 或者最近一次的rpc请求没收到返回只显示返回登陆
	if (bOtherLogin or (not Network.lastRpcBack()) ) then
		btnReconn:setEnabled(false)
		btnAgain:setEnabled(false)

		btnSingleAgain:setEnabled(true)
		titleShadow(btnSingleAgain, m_i18n[1927])
		btnSingleAgain:addTouchEventListener(eventLoginAgain)
		if (bOtherLogin) then
			labText:setText(sTips or m_i18n[4755]) -- m_i18n[4755]) -- 账号别处登陆的提示
		else
			labText:setText(sTips or m_i18n[4210]) -- m_i18n[4210]) -- 网络异常的提示
		end
		LayerManager.addNetworkDlg(layPrompt)
		return
	else
		labText:setText(sTips or m_i18n[4210]) -- m_i18n[4210]) -- 网络异常的提示
		btnSingleAgain:setEnabled(false)
	end


	titleShadow(btnReconn, m_i18n[1926])
	btnReconn:addTouchEventListener(onClose)
	btnReconn:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCloseEffect()
			if (fnReconnectCallback) then
				fnReconnectCallback()
			end
			LayerManager.addLoginLoading() -- zhangqi, 2015-03-26, 原地重连先显示登陆的loading
			LoginHelper.reconnect()
		end
	end)


	titleShadow(btnAgain, m_i18n[1927])
	btnAgain:addTouchEventListener(eventLoginAgain)

	LayerManager.addNetworkDlg(layPrompt)
end
--liweidong 返回红点特效
function createRedTipAnimination()
	local anim = UIHelper.createArmatureNode({
		filePath = "images/effect/sign/sign.ExportJson",
		animationName = "sign",
		loop = -1,
	})
	return anim
end

-- zhangqi, 2015-03-26, 进入游戏拉取版本信息错误（网络不可用）提示面板
function createVersionCheckFailed( sText, sBtnTitle, fnBtnCallback )
	local layPrompt = g_fnLoadUI("ui/public_prompt.json")

	local btnClose = m_fnGetWidget(layPrompt, "BTN_CLOSE")
	btnClose:removeFromParentAndCleanup(true)

	local btnCancel = m_fnGetWidget(layPrompt, "BTN_CANCEL")
	local btnOK = m_fnGetWidget(layPrompt, "BTN_CONFIRM")
	btnCancel:removeFromParentAndCleanup(true)
	btnOK:removeFromParentAndCleanup(true)

	local btnSingleOK = m_fnGetWidget(layPrompt, "BTN_CONFIRM_SURE")
	titleShadow(btnSingleOK, sBtnTitle)
	btnSingleOK:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			if (fnBtnCallback) then
				fnBtnCallback()
			end
		end
	end)

	local labText = m_fnGetWidget(layPrompt, "TFD_PROMPT_TXT")
	labText:setText(sText)

	return layPrompt
end

-- zhangqi, 2014-11-04
-- tbArgs = {strText, richText, fnConfirmEvent, nBtn, fnCloseCallback}
function createCommonDlgNew(tbArgs)
	return createCommonDlg(tbArgs.strText, tbArgs.richText, tbArgs.fnConfirmEvent, tbArgs.nBtn, tbArgs.fnCloseCallback)
end
--[[desc: zhangqi, 指定文本和确认回调事件创建一个公用对话框
    strText: 提示文本，可以是nil
    richText: 富文本对象，可以是nil
    fnConfirmEvent: 确认按钮回调事件，是nil时默认关闭对话框
    nBtn: 1, 显示一个确定按钮; nil 或 2, 默认显示确定和取消按钮
    fnCloseCallback: 关闭按钮的回调
    return: Layout
—]]
function createCommonDlg( strText, richText, fnConfirmEvent, nBtn, fnCloseCallback )
	local layPrompt = g_fnLoadUI("n_ui/commDialog_1.json")

	local function CloseEvent( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			closeCallback()
			if (fnCloseCallback and type(fnCloseCallback) == "function") then
				fnCloseCallback()
			end
		end
	end

	-- local btnClose = m_fnGetWidget(layPrompt, "BTN_CLOSE")
	-- btnClose:addTouchEventListener(CloseEvent)

	local btnCancel = m_fnGetWidget(layPrompt, "BTN_CANCEL")
	titleShadow(btnCancel, m_i18n[1325]) 
	local btnOK = m_fnGetWidget(layPrompt, "BTN_CONFIRM")
	titleShadow(btnOK, m_i18n[1324]) 
	local btnSingleOK = m_fnGetWidget(layPrompt, "BTN_CONFIRM_SURE")
	if (nBtn == 1) then
		btnCancel:removeFromParentAndCleanup(true)
		btnOK:removeFromParentAndCleanup(true)
		btnSingleOK = m_fnGetWidget(layPrompt, "BTN_CONFIRM_SURE")
		titleShadow(btnSingleOK, m_i18n[1324]) 
		btnSingleOK:addTouchEventListener(fnConfirmEvent or CloseEvent)
	else
		btnSingleOK:removeFromParentAndCleanup(true)
		btnCancel:addTouchEventListener(fnCloseCallback or CloseEvent)
		btnOK:addTouchEventListener(fnConfirmEvent or CloseEvent)
	end

	local labText = m_fnGetWidget(layPrompt, "TFD_PROMPT_TXT")
	if (strText) then
		labText:setText(strText)
	elseif (richText) then
		local labText1 = m_fnGetWidget(layPrompt, "TFD_PROMPT_TXT")
		richText:setAnchorPoint(ccp(0.5, 0.5))
		labText1:addChild(richText,100,100)
		labText:setVisible(false)
	end

	--layPrompt:setAnchorPoint(ccp(0.5,0.5))
	return layPrompt
end



--创建debug的输出框
function createDebugDlg( strText)
	local layPrompt = g_fnLoadUI("n_ui/wrong_1.json")

	local btnClose = m_fnGetWidget(layPrompt, "BTN_CLOSE")
	btnClose:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			closeCallback()
			CCDirector:sharedDirector():resume()
		end
	end)

	local labText = m_fnGetWidget(layPrompt, "tfd_wrong")
	labText:setText(strText)
	labText:setTextVerticalAlignment(kCCVerticalTextAlignmentTop)
	labText:ignoreContentAdaptWithSize(false)

	LayerManager.addLayoutNoScale(layPrompt, nil, g_tbTouchPriority.ShieldLayout, 99999999)

	performWithDelay(layPrompt, function ( ... )
		CCDirector:sharedDirector():pause()
	end, 0.2)
end
function logDlg( data )

	createDebugDlg(data)
end
--[[desc: zhangqi, 2014-07-01，根据指定信息显示对应的背包已满提示框
    tbInfo: table, {text = "", btn = {{title = "", callback = func}, ...} }
    备注: 如果只有一个按钮时，需要传递的tbInfo的btn字段也必须包含3个table，第一个和第三个为空表即可，btn = {{}, {title = "", callback = func}, {}}
    return:
—]]
function showFullDlg( tbInfo )
	local layPrompt = g_fnLoadUI("ui/public_bag_full_info.json")
	local labText = m_fnGetWidget(layPrompt, "TFD_PARTNER_BAG_FULL_INFO")
	labText:setText(tbInfo.text or "")

	local btnClose = m_fnGetWidget(layPrompt, "BTN_PARTNER_BAG_FULL_CLOSE") -- 默认关闭
	btnClose:addTouchEventListener(onClose)

	local count = #tbInfo.btn
	if (count == 2) then
		local layThree = m_fnGetWidget(layPrompt, "lay_btn_three")
		layThree:removeFromParentAndCleanup(true)
	elseif (count == 3 or count == 1) then
		local layTwo = m_fnGetWidget(layPrompt, "lay_btn_two")
		layTwo:removeFromParentAndCleanup(true)
	end

	for i, info in ipairs(tbInfo.btn) do
		local btn = m_fnGetWidget(layPrompt, "BTN_" .. i)
		if (table.isEmpty(info)) then
			btn:setEnabled(false)
		else
			titleShadow(btn, info.title)
			btn:addTouchEventListener(function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					closeCallback()
					info.callback()
				end
			end)
		end
	end

	LayerManager.addLayout(layPrompt)
end


--[[--
menghao
创建一个armature对象并返回，可以通过addNode加到widget上

@param table params 参数表格对象

可用参数：
-	imagePath		图片路径
-	plistPath		plist文件路径
-	filePath 		json文件路径
-	animationName 	要播放的动画名字	可缺省
-	loop			循环次数，和引擎的用法一致，缺省无限循环
-	fnMovementCall	动画事件回调，START,COMPLETE,LOOP_COMPLETE三种类型
-	fnFrameCall 	关键帧事件回调

@return  CCArmature对象

示例
local tbParams = {
	imagePath = "",
	plistPath = "",
	filePath = "",
	animationName = "",
	loop = 0,
	fnMovementCall = function ( sender, MovementEventType , frameEventName)
		if (MovementEventType == START) then
		elseif (MovementEventType == COMPLETE) then
		elseif (MovementEventType == LOOP_COMPLETE) then
		end
	end,
	fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
	end
}

]]
function createArmatureNode( tbParams )
	local imagePath = tbParams.imagePath
	local plistPath = tbParams.plistPath
	local filePath = tbParams.filePath
	local animationName = tbParams.animationName
	local loop = tbParams.loop or -1
	local fnMovementCall = tbParams.fnMovementCall
	local fnFrameCall = tbParams.fnFrameCall

	-- 截取文件名
	local function stripextension(filename)
		local idx = filename:match(".+()%.%w+$")
		if(idx) then
			return filename:sub(1, idx-1)
		else
			return filename
		end
	end
	local fileName = string.match(filePath, ".+/([^/]*%.%w+)$")
	logger:debug("fileName == " .. fileName)

	fileName = stripextension(fileName)

	logger:debug("fileName == " .. fileName)

	if (plistPath and imagePath and filePath) then
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(imagePath, plistPath, filePath)
	else
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(filePath)
	end

	local armature = CCArmature:create(fileName)
	if (animationName) then
		armature:getAnimation():play(animationName, -1, -1, loop)
	end
	if (fnMovementCall) then
		armature:getAnimation():setMovementEventCallFunc(fnMovementCall)
	end
	if (fnFrameCall) then
		armature:getAnimation():setFrameEventCallFunc(fnFrameCall)
	end

	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(filePath)
	return armature
end


-- 初始化一个自带默认cell的listView, 把默认cell设置为可以push的默认cell，然后清空列表
function initListView( lsvWidget )
	local refCell = assert(lsvWidget:getItem(0), "refCell of " .. lsvWidget:getName() .. " is nil") -- 获取编辑器中的默认cell
	logger:debug("refCell name = %s", refCell:getName())
	lsvWidget:setItemModel(refCell) -- 设置默认的cell
	lsvWidget:removeAllItems() -- 初始化清空列表
end

--[[desc:根据数量来增减list的cell 保证列表位置不变 liweidong
    arg1: list:ListView列表 num:列表数量
    return: nil  
—]]
function initListWithNumAndCell( list,num )

	local arr = list:getItems()
	local listCount = arr:count()
	if num>listCount then
		for i=1,num-listCount do
			--list:pushBackCustomItem(cell:clone())
			list:pushBackDefaultItem()
		end
	end
	if num<listCount then
		for i=1,listCount-num do
			list:removeLastItem()
		end
	end
end
-- 初始化一个自带默认cell的listView, 把默认cell设置为可以push的默认cell，然后清空列表。参数list必须保存为模块变量
function initListViewCell( list )
	local refCell = assert(list:getItem(0), "refCell of " .. list:getName() .. " is nil") -- 获取编辑器中的默认cell
	refCell:setPositionType(POSITION_ABSOLUTE)
	refCell:setPosition(ccp(0,0))
	local cellCount = math.modf(list:getContentSize().height/(refCell:getContentSize().height+list:getItemsMargin()))+4 --计算需要复用cell的个数
	local cellArr=CCArray:create() --存放复用cell
	cellArr:retain()
	list.cellArr=cellArr
	list.cellWidth=refCell:getContentSize().width --cell宽
	list.cellHeight=refCell:getContentSize().height --cell高
	logger:debug("list size:"..list.cellWidth .."  ".. list.cellHeight .." cout:"..cellCount)
	for i=1,cellCount do
		local cell=refCell:clone()
		cellArr:addObject(cell)
	end
	list:removeAllItems() -- 初始化清空列表
end
--[[desc:根据数量来增减list的cell 保证列表位置不变 liweidong
    arg1: list:ListView列表 num:列表数量
    return: nil  
—]]
function setListViewCount( list,num )
	if (list.itembgArr==nil) then
		list.itembgArr={}
	end
	list.collideBeginIdx=0
	list.collideEndIdx=num-1

	local arr = list:getItems()
	local listCount = arr:count()
	if num>listCount then
		for i=1,num-listCount do
			--list:pushBackCustomItem(cell:clone())
			local cellLayout=Layout:create()
			cellLayout:setSize(CCSizeMake(list.cellWidth,list.cellHeight))
			list:pushBackCustomItem(cellLayout)
			cellLayout.refreshstatus=0
			list.itembgArr[#list.itembgArr+1]=cellLayout --需要为cellLayout添加lua值，需要保存
			--list:pushBackDefaultItem()
		end
	end
	if num<listCount then
		for i=1,listCount-num do
			list:removeLastItem()
		end
	end
end
--[[desc:优化listview实现tableview功能，不在显示范围内的自动隐藏，并且不加载。减少渲染数量和加快加载速度 liweidong
     	list:ListView对象, （必填）
    	listCount:list cell总数量  （必填）
    	updateCell 更新某一行cell的回调函数 （必填）
    return: nil
—]]
function reloadListView(list,listCount,updateCell)
	setListViewCount(list,listCount)
	local listPos=list:convertToWorldSpace(ccp(0,(-list.cellHeight-list:getItemsMargin())*1))
	local listRect=CCRectMake(listPos.x,listPos.y,list:getContentSize().width,list:getContentSize().height+(list.cellHeight+list:getItemsMargin())*2)
	local function graceful(force)
		local cell = tolua.cast(list:getItem(list.collideBeginIdx),"Widget")
		local cellPos=cell:convertToWorldSpace(ccp(0,0))
		local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
		if not (listRect:intersectsRect(cellRect)) then
			cell.refreshstatus=0
			cell:removeAllChildrenWithCleanup(false)
			for i=list.collideBeginIdx+1,listCount-1,1 do
				local cell = tolua.cast(list:getItem(i),"Widget")
				local cellPos=cell:convertToWorldSpace(ccp(0,0))
				local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
				if (listRect:intersectsRect(cellRect)) then
					list.collideBeginIdx=i
					break
				else
					cell.refreshstatus=0
					cell:removeAllChildrenWithCleanup(false)
				end
			end
		else
			for i=list.collideBeginIdx-1,0,-1 do
				local cell = tolua.cast(list:getItem(i),"Widget")
				local cellPos=cell:convertToWorldSpace(ccp(0,0))
				local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
				if (listRect:intersectsRect(cellRect)) then
					list.collideBeginIdx=i
				else
					cell.refreshstatus=0
					cell:removeAllChildrenWithCleanup(false)
					break
				end
			end
		end
		
		local cell = tolua.cast(list:getItem(list.collideEndIdx),"Widget")
		local cellPos=cell:convertToWorldSpace(ccp(0,0))
		local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
		if not (listRect:intersectsRect(cellRect)) then
			cell.refreshstatus=0
			cell:removeAllChildrenWithCleanup(false)
			for i=list.collideEndIdx-1,0,-1 do
				local cell = tolua.cast(list:getItem(i),"Widget")
				local cellPos=cell:convertToWorldSpace(ccp(0,0))
				local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
				if (listRect:intersectsRect(cellRect)) then
					list.collideEndIdx=i
					break
				else
					cell.refreshstatus=0
					cell:removeAllChildrenWithCleanup(false)
				end
			end
		else
			for i=list.collideEndIdx+1,listCount-1,1 do
				local cell = tolua.cast(list:getItem(i),"Widget")
				local cellPos=cell:convertToWorldSpace(ccp(0,0))
				local cellRect=CCRectMake(cellPos.x,cellPos.y,cell:getContentSize().width,cell:getContentSize().height)
				if (listRect:intersectsRect(cellRect)) then
					list.collideEndIdx=i
				else
					cell.refreshstatus=0
					cell:removeAllChildrenWithCleanup(false)
					break
				end
			end
		end
		local cellIdx=0
		for i=list.collideBeginIdx,list.collideEndIdx do
			local cell = tolua.cast(list:getItem(i),"Widget")
			if (cellIdx>=list.cellArr:count()) then
				cell.refreshstatus=0
				cell:removeAllChildrenWithCleanup(false)
			else
				if (cell.refreshstatus==0 or force) then
					cell:removeAllChildrenWithCleanup(false)
					local freeitem=nil
					for i=1,list.cellArr:count() do
						local item = tolua.cast(list.cellArr:objectAtIndex(i-1),"Widget")
						if item:getParent()==nil then
							freeitem=item
							break
						end
					end
					if freeitem then
						cell:setSize(CCSizeMake(list.cellWidth,list.cellHeight))
						cell:addChild(freeitem) --添加复用cell
						updateCell(list,i)
						cell.refreshstatus=1
					end
				end
			end
			cellIdx=cellIdx+1
		end
		if force then
			list.collideBeginIdx=0
			list.collideEndIdx=listCount-1
		end
	end
	list:getActionManager():removeAllActionsFromTarget(list)
	if (listCount>0) then
		local lastPosx,lastPosy=-100,-100
		schedule(list,function()
			if (listCount>0) then
				local lastCell = tolua.cast(list:getItem(listCount-1),"Widget")
				local cellPos=lastCell:convertToWorldSpace(ccp(0,0))
				if (cellPos.x~=lastPosx or cellPos.y~=lastPosy) then
					lastPosx,lastPosy=cellPos.x,cellPos.y
					graceful(false)
				end
			end
		end
		,0.00)
		graceful(true)
	end
	UIHelper.registExitAndEnterCall(list,
		function()
			list.cellArr:release()
		end,
		function()
		end,
		function()
		end
	)
end
-- 把动态创建的 Button 控件 add 到一个 layout 的中心，zhangqi, 2014-07-17
function addBtnToLayout( btn, layout )
	local szLayout = layout:getSize()
	btn:setPosition(ccp(szLayout.width/2, szLayout.height/2))
	layout:addChild(btn)
end

--[[desc: zhangqi, 根据掉落物品创建公用的掉落面板
    tbDrop: 后端返回的drop表
    sTitle: 面板标题文本
    return:
    modified: zhangqi, 20140626, createDropItemDlg 修改为 showDropItemDlg
    		  不再返回layout, 直接调用LayerManger.addLayout来显示
    		  zhangqi, 2014-08-14, 增加参数 bUpdateCache，true 表示将直接获得贝里，金币，经验石等同步更新本地缓存，默认 nil 表示不更新(兼容修改前的调用)
—]]
function showDropItemDlg( tbDrop, sTitle, bUpdateCache )
	logger:debug("createDropItemDlg")
	logger:debug(tbDrop)

	local tbGifts =  ItemDropUtil.getDropItem(tbDrop)
	logger:debug(tbGifts)
	if(table.isEmpty(tbGifts)) then
		return
	end

	if (bUpdateCache) then
		ItemDropUtil.refreshUserInfo(tbGifts)
	end

	-- 从tbGifts中过滤出英雄和物品
	-- local tbItems = {}
	-- for i, v in ipairs(tbGifts) do
	-- 	if (v.type == "hero") then
	-- 		table.insert(tbItems, v)
	-- 	end
	-- end
	-- for i, v in ipairs(tbGifts) do
	-- 	if (v.type == "item") then
	-- 		table.insert(tbItems, v)
	-- 	end
	-- end


	local layMain = g_fnLoadUI("ui/bag_open_gift.json")

	local i18nTITLE = m_fnGetWidget(layMain,"TFD_OPEN_GIFT_TITLE")
	labelEffect(i18nTITLE, sTitle)

	local i18nTitle2 = m_fnGetWidget(layMain, "TFD_COMMON_TITLE") -- 恭喜您获得
	labelEffect(i18nTitle2, m_i18n[1901])

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE")
	btnClose:addTouchEventListener(onClose)

	local btnOK = m_fnGetWidget(layMain, "BTN_CERTAIN")
	titleShadow(btnOK, m_i18n[1029])
	btnOK:addTouchEventListener(onClose)

	local lsvGift = m_fnGetWidget(layMain, "LSV_OPEN_GIFT")
	initListView(lsvGift)

	-- v {type, num, name, tid}
	local cell
	for i, v in ipairs(tbGifts) do
		lsvGift:pushBackDefaultItem()
		cell = lsvGift:getItem(i - 1)  -- cell 索引从 0 开始

		local dropInfo = ItemUtil.getGiftData(v)
		local tbItem = dropInfo.item

		local imgSeal = m_fnGetWidget(cell, "IMG_ITEM_TYPE") -- 印章
		imgSeal:loadTexture(dropInfo.sign)

		local layIcon = m_fnGetWidget(cell, "LAY_ITEM_ICON")
		addBtnToLayout(dropInfo.icon, layIcon)

		local labNumTitle = m_fnGetWidget(cell, "TFD_ITEM_NUM_WORD") -- 数量标题
		labelEffect(labNumTitle, m_i18n[1332])

		local labNum = m_fnGetWidget(cell, "LABN_ITEM_NUM") -- 数量
		labelEffect(labNum, tostring(v.num))

		local labName = m_fnGetWidget(cell, "TFD_ITEM_NAME") -- 名称
		labName:setColor(g_QulityColor[tonumber(v.quality)])
		labelEffect(labName, v.name)

		local labInfo = m_fnGetWidget(cell, "TFD_ITEM_DESC") -- 介绍
		labInfo:setText(tbItem.desc)
	end

	LayerManager.addLayout(layMain, nil, g_tbTouchPriority.popDlg)
end

--[[desc: liweidong, 根据天降宝物的掉落面板
    tbDrop: 后端返回的drop表
    sTitle: 面板标题文本
    return:
—]]
function showTreasureDropItemDlg( tbDrop, sTitle ,callback,subTitle)
	logger:debug("createDropItemDlg＝＝＝＝＝＝＝＝")
	logger:debug(tbDrop)

	local tbGifts =  ItemDropUtil.getDropTreasureItem(tbDrop)
	logger:debug("item＝＝＝＝＝＝＝＝")
	logger:debug(tbGifts)
	if(table.isEmpty(tbGifts)) then
		return
	end

	local layMain = g_fnLoadUI("ui/bag_open_gift.json")

	local i18nTITLE = m_fnGetWidget(layMain,"TFD_OPEN_GIFT_TITLE")
	labelEffect(i18nTITLE, sTitle)

	local i18nTitle2 = m_fnGetWidget(layMain, "TFD_COMMON_TITLE") -- 恭喜您获得
	labelEffect(i18nTitle2, subTitle and subTitle or m_i18n[1901])

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE")
	btnClose:addTouchEventListener(callback)

	local btnOK = m_fnGetWidget(layMain, "BTN_CERTAIN")
	titleShadow(btnOK, m_i18n[1029])
	btnOK:addTouchEventListener(callback)

	local lsvGift = m_fnGetWidget(layMain, "LSV_OPEN_GIFT")
	initListView(lsvGift)

	local img_bg=m_fnGetWidget(layMain, "lay_bg")
	local img_reward_bg=m_fnGetWidget(layMain, "img_open_gift_bg")

	local ncount = table.getn(tbGifts) -- 统计cell 个数
	if(ncount>2) then  -- 对多于两行对处理
		img_reward_bg:setSize(CCSizeMake(img_reward_bg:getSize().width,img_reward_bg:getSize().height*2.3)) --2.3
		img_bg:setSize(CCSizeMake(img_bg:getVirtualRenderer():getContentSize().width,img_bg:getVirtualRenderer():getContentSize().height*1.58)) --1.58
	elseif(ncount==2)  then
		-- for i,cellTemp in ipairs(tbCell) do
		-- 	cellTemp:setSize(CCSizeMake(cellTemp:getSize().width,cellTemp:getSize().height*.25))
		-- end
		img_reward_bg:setSize(CCSizeMake(img_reward_bg:getSize().width,img_reward_bg:getSize().height*1.86))
		img_bg:setSize(CCSizeMake(img_bg:getVirtualRenderer():getContentSize().width,img_bg:getVirtualRenderer():getContentSize().height*1.38))
		-- LSV_DROP:setSize(CCSizeMake(LSV_DROP:getSize().width,LSV_DROP:getSize().height*2))
	end

	-- v {type, num, name, tid}
	local cell
	for i, v in ipairs(tbGifts) do
		lsvGift:pushBackDefaultItem()
		cell = lsvGift:getItem(i - 1)  -- cell 索引从 0 开始

		local dropInfo = ItemUtil.getGiftData(v)
		local tbItem = dropInfo.item

		local imgSeal = m_fnGetWidget(cell, "IMG_ITEM_TYPE") -- 印章
		imgSeal:loadTexture(dropInfo.sign)

		local layIcon = m_fnGetWidget(cell, "LAY_ITEM_ICON")
		addBtnToLayout(v.icon, layIcon)

		local labNumTitle = m_fnGetWidget(cell, "TFD_ITEM_NUM_WORD") -- 数量标题
		labelEffect(labNumTitle, m_i18n[1332])

		local labnNum = m_fnGetWidget(cell, "LABN_ITEM_NUM") -- 数量
		labnNum:setStringValue(v.num)

		local labName = m_fnGetWidget(cell, "TFD_ITEM_NAME") -- 名称
		labName:setColor(g_QulityColor[tonumber(v.quality)])
		labelEffect(labName, v.name)

		local labInfo = m_fnGetWidget(cell, "TFD_ITEM_DESC") -- 介绍
		labInfo:setText(tbItem.desc)
	end

	LayerManager.addLayout(layMain, nil, g_tbTouchPriority.popDlg)
	return layMain
end
--[[desc: liweidong, 探索进度奖励预览
    tbDrop: 后端返回的drop表
    sTitle: 面板标题文本
    return:
—]]
function showExploreProgressItemDlg( tbDrop, sTitle,rewardNum,callback)
	local tbGifts =  ItemDropUtil.getDropTreasureItem(tbDrop)
	logger:debug("item＝＝＝＝＝＝＝＝")
	logger:debug(tbGifts)
	if(table.isEmpty(tbGifts)) then
		return
	end

	local layMain = g_fnLoadUI("ui/supar_reward.json")

	local BTN_SURE = m_fnGetWidget(layMain, "BTN_SURE") -- 确定按钮
	BTN_SURE:addTouchEventListener(callback==nil and closeCallback or callback)
	UIHelper.titleShadow(BTN_SURE,sTitle)

	local lbRewardNum = m_fnGetWidget(layMain, "TFD_TIMES")
	lbRewardNum:setText(rewardNum)
	local lbRewardNum = m_fnGetWidget(layMain, "tfd_now")
	lbRewardNum:setText(gi18n[4307])
	local lbRewardNum = m_fnGetWidget(layMain, "tfd_huode")
	lbRewardNum:setText(gi18n[4308])

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE")
	btnClose:addTouchEventListener(onClose)

	-- v {type, num, name, tid}
	local cell
	for i, v in ipairs(tbGifts) do
		cell = layMain

		local dropInfo = ItemUtil.getGiftData(v)
		local tbItem = dropInfo.item

		local imgSeal = m_fnGetWidget(cell, "IMG_ITEM_TYPE") -- 印章
		imgSeal:loadTexture(dropInfo.sign)

		local layIcon = m_fnGetWidget(cell, "IMG_ITEM_ICON")
		layIcon:addChild(dropInfo.icon)
		--addBtnToLayout(dropInfo.icon, layIcon)

		local labNumTitle = m_fnGetWidget(cell, "TFD_ITEM_NUM_WORD") -- 数量标题
		labelEffect(labNumTitle, m_i18n[1332])

		local labnNum = m_fnGetWidget(cell, "LABN_ITEM_NUM") -- 数量
		labnNum:setStringValue(v.num)

		local labName = m_fnGetWidget(cell, "TFD_ITEM_NAME") -- 名称
		labName:setColor(g_QulityColor[tonumber(v.quality)])
		labelEffect(labName, v.name)

		local labInfo = m_fnGetWidget(cell, "TFD_ITEM_DESC") -- 介绍
		labInfo:setText(tbItem.desc)
	end

	LayerManager.addLayout(layMain, nil, g_tbTouchPriority.popDlg)
	return layMain
end
--[[desc: liweidong, 探索获得item显示面板。点击任意位置关闭，特殊处理
    tbDrop: 后端返回的drop表
    sTitle: 面板标题文本
    return:
—]]
function showExplorDropItemDlg( tbDrop, sTitle ,callback)
	logger:debug("createDropItemDlg＝＝＝＝＝＝＝＝")
	logger:debug(tbDrop)

	local tbGifts =  ItemDropUtil.getDropTreasureItem(tbDrop)
	logger:debug("item＝＝＝＝＝＝＝＝")
	logger:debug(tbGifts)
	if(table.isEmpty(tbGifts)) then
		return
	end

	local layMain = g_fnLoadUI("ui/bag_open_gift.json")

	local i18nTITLE = m_fnGetWidget(layMain,"TFD_OPEN_GIFT_TITLE")
	labelEffect(i18nTITLE, sTitle)

	local i18nTitle2 = m_fnGetWidget(layMain, "TFD_COMMON_TITLE") -- 恭喜您获得
	labelEffect(i18nTitle2, m_i18n[1901])

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE")
	btnClose:addTouchEventListener(callback)

	local btnOK = m_fnGetWidget(layMain, "BTN_CERTAIN")
	titleShadow(btnOK, m_i18n[1029])
	btnOK:addTouchEventListener(callback)

	local lsvGift = m_fnGetWidget(layMain, "LSV_OPEN_GIFT")
	initListView(lsvGift)

	local img_bg=m_fnGetWidget(layMain, "lay_bg")
	local img_reward_bg=m_fnGetWidget(layMain, "img_open_gift_bg")

	local ncount = table.getn(tbGifts) -- 统计cell 个数
	if(ncount>2) then  -- 对多于两行对处理
		img_reward_bg:setSize(CCSizeMake(img_reward_bg:getSize().width,img_reward_bg:getSize().height*2.3)) --2.3
		img_bg:setSize(CCSizeMake(img_bg:getVirtualRenderer():getContentSize().width,img_bg:getVirtualRenderer():getContentSize().height*1.58)) --1.58
	elseif(ncount==2)  then
		-- for i,cellTemp in ipairs(tbCell) do
		-- 	cellTemp:setSize(CCSizeMake(cellTemp:getSize().width,cellTemp:getSize().height*.25))
		-- end
		img_reward_bg:setSize(CCSizeMake(img_reward_bg:getSize().width,img_reward_bg:getSize().height*1.86))
		img_bg:setSize(CCSizeMake(img_bg:getVirtualRenderer():getContentSize().width,img_bg:getVirtualRenderer():getContentSize().height*1.38))
		-- LSV_DROP:setSize(CCSizeMake(LSV_DROP:getSize().width,LSV_DROP:getSize().height*2))
	end

	-- v {type, num, name, tid}
	local cell
	for i, v in ipairs(tbGifts) do
		lsvGift:pushBackDefaultItem()
		cell = lsvGift:getItem(i - 1)  -- cell 索引从 0 开始

		local dropInfo = ItemUtil.getGiftData(v)
		local tbItem = dropInfo.item

		local imgSeal = m_fnGetWidget(cell, "IMG_ITEM_TYPE") -- 印章
		imgSeal:loadTexture(dropInfo.sign)

		local layIcon = m_fnGetWidget(cell, "LAY_ITEM_ICON")
		addBtnToLayout(dropInfo.icon, layIcon)

		local labNumTitle = m_fnGetWidget(cell, "TFD_ITEM_NUM_WORD") -- 数量标题
		labelEffect(labNumTitle, m_i18n[1332])

		local labnNum = m_fnGetWidget(cell, "LABN_ITEM_NUM") -- 数量
		labnNum:setStringValue(v.num)

		local labName = m_fnGetWidget(cell, "TFD_ITEM_NAME") -- 名称
		labName:setColor(g_QulityColor[tonumber(v.quality)])
		labelEffect(labName, v.name)

		local labInfo = m_fnGetWidget(cell, "TFD_ITEM_DESC") -- 介绍
		labInfo:setText(tbItem.desc)
	end

	LayerManager.addLayout(layMain, nil, g_tbTouchPriority.popDlg)

	--点击对话况之外任意地方关闭
	img_bg:setTouchEnabled(true)
	layMain:setTouchEnabled(true)
	layMain:addTouchEventListener(function(sender, eventType)
		if (eventType ~= TOUCH_EVENT_ENDED) then
			return
		end
		LayerManager.removeLayout()
	end
	)
	return layMain
end
--[[desc:创建item的信息框
    arg1: item的DB信息 ，数量
    return: 返回信息面板
    add by huxiaozhou 2014-05-22
—]]
function createItemInfoDlg( _tbItem ,_number)
	local layMain = g_fnLoadUI("ui/public_item_info.json")

	local layIcon = m_fnGetWidget(layMain, "LAY_ITEM_ICON")

	local btnClose = m_fnGetWidget(layMain, "BTN_CLOSE") --关闭按钮
	btnClose:addTouchEventListener(onClose)

	local BTN_SURE = m_fnGetWidget(layMain, "BTN_SURE") -- 确定按钮
	BTN_SURE:addTouchEventListener(onClose)
	UIHelper.titleShadow(BTN_SURE, m_i18n[1029])

	local imgSeal = m_fnGetWidget(layMain, "IMG_ITEM_TYPE") -- 印章
	imgSeal:loadTexture(ItemUtil.getSealFileByItem(_tbItem))

	local labName = m_fnGetWidget(layMain, "TFD_ITEM_NAME") -- 名称
	UIHelper.labelEffect(labName, _tbItem.name)
	assert(_tbItem.quality, "quality is " .. _tbItem.quality or type(_tbItem.quality ))
	labName:setColor(g_QulityColor[tonumber(_tbItem.quality)])

	local labNumI18n = m_fnGetWidget(layMain, "TFD_ITEM_NUM_WORD") -- 文字 “数量” 以后国际化用
	UIHelper.labelEffect(labNumI18n, m_i18n[1332])
	local labnNum = m_fnGetWidget(layMain, "LABN_ITEM_NUM") -- 数量
	labnNum:setStringValue(tostring(_number or 1))

	if not _number then
		labNumI18n:setEnabled(false)
		labnNum:setEnabled(false)
	end

	local labInfo = m_fnGetWidget(layMain, "TFD_ITEM_DESC") -- 介绍
	labInfo:setText(_tbItem.desc)

	local btnIcon = ItemUtil.createBtnByItem(_tbItem)
	addBtnToLayout(btnIcon, layIcon) -- zhangqi, 2014-07-16

	return layMain
end


function getRewardInfoDlg( stitle, _tbItems, fnCallBack, subTitle, fnClose)   ---modife zhangjunwu 返回奖励狂的画布，方便外面获取空间
	return createRewardDlg(_tbItems, fnCallBack)
end

--[[desc:创建获取到的奖励提示框
    stitle:  提示框 名称
    _tbItem:  奖励物品信息 { {icon = btn, name = name, quality = number}, ...}
    return: 返回信息面板
    add by huxiaozhou 2014-05-28 
—]]
function createGetRewardInfoDlg( stitle, _tbItems, fnCallBack, subTitle, fnClose)   ---fnClose  指定 关闭按钮的事件 add by lizy
	local dlg = createRewardDlg(_tbItems, fnCallBack)
	LayerManager.addLayoutNoScale(dlg)
end

-- 原来的奖励面板，现在探索的奖励预览要用
function createRewardPreviewDlg( stitle, _tbItems, fnCallBack, subTitle, fnClose )
	local layMain = g_fnLoadUI("ui/copy_get_reward.json")

	local img_bg = m_fnGetWidget(layMain,"img_bg")-- 主背景

	local tfd_title = m_fnGetWidget(layMain,"tfd_title") -- 奖励提示框名称
	tfd_title:setText(stitle)
	labelEffect(tfd_title,stitle)
	if subTitle then
		logger:debug("subtitle====".. subTitle)
		local tfd_info = m_fnGetWidget(layMain,"tfd_info") -- 奖励提示框名称
		tfd_info:setText(subTitle)
	else
		local i18ntfd_info = m_fnGetWidget(layMain,"tfd_info") -- 奖励介绍 -- 需要本地化的文字 信息 "恭喜船长获得如下奖励："
		labelEffect(i18ntfd_info,m_i18n[1322])
	end


	local LSV_DROP = m_fnGetWidget(layMain,"LSV_DROP") -- listview

	initListView(LSV_DROP)

	logger:debug(_tbItems)

	local tbSortData = {}

	local tbSub = {}
	for i,v in ipairs(_tbItems) do
		table.insert(tbSub,v)
		if(table.maxn(tbSub)>=4) then
			table.insert(tbSortData,tbSub)
			tbSub = {}
		elseif(i==table.maxn(_tbItems)) then
			table.insert(tbSortData,tbSub)
			tbSub = {}
		end
	end

	local cell

	local tbCell = {}
	for i, itemInfo in ipairs(tbSortData) do
		LSV_DROP:pushBackDefaultItem()

		cell = LSV_DROP:getItem(i-1)  -- cell 索引从 0 开始
		table.insert(tbCell,cell)
		for index,item in ipairs(itemInfo) do
			local imgKey = "IMG_" .. index
			local img = m_fnGetWidget(cell, imgKey)
			img:addChild(item.icon)
			local nameKey = "TFD_NAME_" .. index
			local labName = m_fnGetWidget(cell, nameKey) -- 名称
			labName:setText(item.name)
			labelEffect(labName,item.name)

			if (item.quality ~= nil) then
				local color =  g_QulityColor2[tonumber(item.quality)]
				if(color ~= nil) then
					labName:setColor(color)
				end
			end

			if (index == table.maxn(itemInfo) and index < 4) then --移除剩余的
				for j=index+1,4 do
					imgKey = "IMG_" .. j
					nameKey = "TFD_NAME_" .. j
					local img = m_fnGetWidget(cell, imgKey)
					local labName = m_fnGetWidget(cell, nameKey) -- 名称
					img:removeFromParent()
					labName:removeFromParent()
			end
			end
		end
	end

	local bgSize = img_bg:getVirtualRenderer():getContentSize()
	local img_reward_bg = m_fnGetWidget(layMain,"img_reward_bg")
	local rewBgSize = img_reward_bg:getSize()

	logger:debug(tbSortData)

	local ncount = table.count(tbSortData)  -- table.maxn(tbSortData) -- 统计cell 个数
	logger:debug("ncount == %s", ncount)

	logger:debug("ncount/4 = %s" ,ncount/4)

	if (ncount > 2) then  -- 对多于两行对处理, 一行4个
		img_reward_bg:setSize(CCSizeMake(rewBgSize.width, rewBgSize.height*2.5))
		img_bg:setSize(CCSizeMake(bgSize.width, bgSize.height*1.4))
	elseif (ncount == 2) then -- zhangqi, 由 == 2 修改为 <= 2,  20141229 huxiaozhou 由 <= 修改为 ==
		img_reward_bg:setSize(CCSizeMake(rewBgSize.width, rewBgSize.height*2))
		img_bg:setSize(CCSizeMake(bgSize.width, bgSize.height*1.25))
	end


	--绑定按钮事件
	local btnGet = m_fnGetWidget(layMain,"BTN_GET") --确定按钮
	titleShadow(btnGet,m_i18n[1029])
	btnGet:addTouchEventListener( 	function (sender ,eventType )  ---为 按钮加入时间，如果回调空默认为关闭  add by lizy
		if (eventType == TOUCH_EVENT_ENDED) then
			local func = fnCallBack or closeCallback
			func()
	end
	end)

	local btnClose = m_fnGetWidget(layMain,"BTN_CLOSE") --关闭按钮
	btnClose:addTouchEventListener( function ( sender ,eventType)
		if (eventType == TOUCH_EVENT_ENDED) then
			local func = fnClose or closeCallback
			func()
		end
	end)

	return layMain
end


--[[--
menghao
创建一个 奖励对话框 并返回

@param table params 参数表格对象

可用参数：
-	tbItems 	获得的物品table
-	callBack 		确认按钮回调
- 	isAfterEnd 		瞎取的名，传true开完宝箱后才能点按钮

@return  widget

示例

]]
function createRewardDlg( tbItems, callback, isAfterEnd )

	local tbNames = {"win_drop_black/white", "win_drop_black/white", "win_drop_green", "win_drop_blue", "win_drop_purple", "win_drop_orange"}

	local layout = g_fnLoadUI("ui/public_get_reward.json")
	LayerManager.lockOpacity(layout)
	-- registExitAndEnterCall(layout, function ( ... )
	-- 	LayerManager.addRemoveLayoutCallback(nil)
	-- end)
	-- LayerManager.addRemoveLayoutCallback(function ( ... )
	-- 	layout:setTouchEnabled(true)
	-- end)
	for i=1,#tbItems do
		tbItems[i].icon:retain()
	end

	local imgArrowUp = m_fnGetWidget(layout, "IMG_ARROW_UP")
	local imgArrowBottom = m_fnGetWidget(layout, "IMG_ARROW_BOTTOM")
	imgArrowUp:setEnabled(false)
	imgArrowBottom:setEnabled(false)

	local btnSure = m_fnGetWidget(layout, "BTN_SURE")
	local layTouch = m_fnGetWidget(layout, "lay_touch")
	if (callback) then
		btnSure:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playCloseEffect()
				logger:debug("createRewardDlg: do callBack")
				callback()
			end
		end)
		layTouch:addTouchEventListener(function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playCloseEffect()
				logger:debug("createRewardDlg: do callBack")
				callback()
			end
		end)
	else
		local function close( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				closeCallback()
			end
		end
		btnSure:addTouchEventListener(close)
		layTouch:addTouchEventListener(close)
	end

	titleShadow(btnSure, gi18n[1029])

	local layOpen = m_fnGetWidget(layout,"lay_open")
	local btnAgain1  = m_fnGetWidget(layOpen,"BTN_1")
	local btnAgain10 = m_fnGetWidget(layOpen,"BTN_10")
	local btnClose = m_fnGetWidget(layOpen,"BTN_CLOSE")

	local function setBtnTouchEnabled( bValue )
		layTouch:setTouchEnabled(bValue)
		btnSure:setTouchEnabled(bValue)

		if (bValue and not (layOpen:isVisible() and layOpen:isEnabled())) then
			bValue = false
		end

		layOpen:setTouchEnabled(bValue)
		btnAgain1:setTouchEnabled(bValue)
		btnAgain10:setTouchEnabled(bValue)
		btnClose:setTouchEnabled(bValue)
	end

	setBtnTouchEnabled(false)

	local lsvDrop = m_fnGetWidget(layout, "LSV_DROP")
	local defaultItem = lsvDrop:getItem(0)
	lsvDrop:setItemModel(defaultItem)
	lsvDrop:removeAllItems()
	lsvDrop:setTouchEnabled(false)

	local imgForFill1 = ImageView:create()
	imgForFill1:loadTexture("ui/arrow_public.png")
	imgForFill1:setEnabled(false)
	imgForFill1:setScale9Enabled(true)
	imgForFill1:setSize(CCSizeMake(100, 35))
	lsvDrop:pushBackCustomItem(imgForFill1)

	local hei = defaultItem:getSize().height
	local rowCount = math.ceil(#tbItems / 4)
	hCount = rowCount > 4 and 4 or rowCount
	lsvDrop:setSize(CCSizeMake(lsvDrop:getSize().width, lsvDrop:getSize().height * hCount + 45))

	for i = 1, rowCount do
		lsvDrop:pushBackDefaultItem()
		local item = lsvDrop:getItem(i)
		for j=1,4 do
			local layDrop = m_fnGetWidget(item, "LAY_DROP" .. j)
			layDrop:setEnabled(false)
			if (hCount == 1) then
				local pos = layDrop:getPositionPercent()
				local offX = (4 - #tbItems) * 0.5 * layDrop:getSize().width / item:getSize().width
				layDrop:setPositionPercent(ccp(pos.x + offX, pos.y))
			end
		end
	end

	local imgForFill2 = ImageView:create()
	imgForFill2:loadTexture("ui/arrow_public.png")
	imgForFill2:setEnabled(false)
	imgForFill2:setScale9Enabled(true)
	imgForFill2:setSize(CCSizeMake(100, 10))
	lsvDrop:pushBackCustomItem(imgForFill2)

	function playAnimation( index )
		local row = math.ceil(index / 4)
		local col = index - row * 4 + 4
		if (index > #tbItems) then
			setBtnTouchEnabled(true)
			if (rowCount > 4) then
				lsvDrop:setTouchEnabled(true)

				-- 上下剪头
				local arrowUp = UIHelper.fadeInAndOutImage("ui/arrow_public.png")
				local arrowBottom = UIHelper.fadeInAndOutImage("ui/arrow_public.png")
				arrowUp:setRotation(180)
				arrowUp:setPosition(ccp(imgArrowUp:getPositionX(), imgArrowUp:getPositionY()))
				arrowBottom:setPosition(ccp(imgArrowBottom:getPositionX(), imgArrowBottom:getPositionY()))
				imgArrowUp:getParent():addNode(arrowUp)
				imgArrowBottom:getParent():addNode(arrowBottom)
				arrowBottom:setVisible(false)

				lsvDrop:addEventListenerScrollView(function (sender, ScrollviewEventType)
					local offset = lsvDrop:getContentOffset()
					local lisvSizeH = lsvDrop:getSize().height
					local lisvContainerH = lsvDrop:getInnerContainerSize().height
					if (offset - lisvSizeH < 1) then
						arrowUp:setVisible(false)
					else
						arrowUp:setVisible(true)
					end

					if (offset- lisvContainerH < 0) then
						arrowBottom:setVisible(true)
					else
						arrowBottom:setVisible(false)
					end
				end)
			end

			return
		end

		local itemInfo = tbItems[index]

		local item = lsvDrop:getItem(row)
		local layDrop = m_fnGetWidget(item, "LAY_DROP" .. col)
		local imgIcon = m_fnGetWidget(item, "IMG_" .. col)
		local tfdName = m_fnGetWidget(item, "TFD_NAME_" .. col)

		local x, y = imgIcon:getPosition()

		local callfunc1 = CCCallFunc:create(function ( ... )
			if (row > 4) then
				local posY = item:getPositionY()
				local tHeight = hei * rowCount + 45 - lsvDrop:getSize().height
				local nPercent = posY / tHeight * 100
				lsvDrop:scrollToPercentVertical(100 - nPercent, 0.15, true)
			end
		end)

		local callfunc2 = CCCallFunc:create(function ( ... )
			local armature = createArmatureNode({
				filePath = "images/effect/battle_result/win_drop.ExportJson",
				fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
					if (frameEventName == "1") then
						-- imgIcon:setEnabled(true)
						tfdName:setEnabled(true)

						if (itemInfo.quality) then
							local armatureLight = createArmatureNode({
								filePath = "images/effect/battle_result/win_drop.ExportJson",
								animationName = tbNames[tonumber(itemInfo.quality)],
							})
							armatureLight:setPosition(ccp(x, y))
							layDrop:addNode(armatureLight, -1, -1)
						end

						if (index == 1 and not isAfterEnd) then
							setBtnTouchEnabled(true)
						end

						playAnimation( index + 1 )
					end
				end,

				fnMovementCall = function ( sender, MovementEventType , frameEventName)
					if (MovementEventType == 1) then
						imgIcon:setEnabled(true)
						sender:removeFromParentAndCleanup(true)
					end
				end,
			})

			imgIcon:addChild(itemInfo.icon)
			itemInfo.icon:release()
			tfdName:setText(itemInfo.name)
			if (itemInfo.quality) then
				tfdName:setColor(g_QulityColor2[tonumber(itemInfo.quality)])
			end

			-- imgIcon:retain()
			-- imgIcon:removeFromParent()
			local imgIconCopy = imgIcon:clone()
			imgIconCopy:setPosition(ccp(0, 0))
			armature:getBone("win_drop_3"):addDisplay(imgIconCopy, 0)
			-- imgIcon:release()

			armature:setPosition(ccp(x, y))
			layDrop:addNode(armature)
			layDrop:setEnabled(true)
			imgIcon:setEnabled(false)
			imgIconCopy:setEnabled(true)

			-- armature:getAnimation():gotoAndPause(1)
			AudioHelper.playSpecialEffect("texiao_fanpai_wupin.mp3")
			armature:getAnimation():play("win_drop", -1, -1, 0)
			armature:getAnimation():setSpeedScale(math.ceil(rowCount / 32))
		end)
		local sequence = CCSequence:createWithTwoActions(callfunc1, callfunc2)
		layout:runAction(sequence)
	end

	performWithDelay(layout, function ( ... )
		playAnimation(1)
	end, 0.18)

	return layout
end


--[[desc:创建金币不足提示框
    arg1: 无
    return: 金币不足提示框 
    add by huxiaozhou 2014-05-22
—]]
function createNoGoldAlertDlg( )
	local noGoldAlert
	local vip_gift_ids = nil
	logger:debug(table.count(DB_Vip.Vip))
	if(UserModel.getVipLevel() < table.count(DB_Vip.Vip)-1) then
		vip_gift_ids = DB_Vip.getDataById(UserModel.getVipLevel()+2).vip_gift_ids
	end
	if(UserModel.getVipLevel() >= table.count(DB_Vip.Vip)-1 or vip_gift_ids == nil) then -- 判断是否达到最大vip等级
		noGoldAlert = createNoGoldForMaxVip()
	else
		noGoldAlert = createNoGoldForCommon()
	end
	return noGoldAlert
end

-- tbParams = {sTitle = "您得购买次数不足",sUnit = "次" 或者 "个",sName = "竞技场次数",nNowBuyNum=1 (现在vip 能购买的次（个）数),nNextBuyNum=2（下一个vip能购买的次（个）数）,}
function createVipBoxDlg( tbParams)
	local noGoldAlert = nil
	local vip_gift_ids = nil
	logger:debug(table.count(DB_Vip.Vip))
	if(UserModel.getVipLevel() < table.count(DB_Vip.Vip)-1) then
		vip_gift_ids = DB_Vip.getDataById(UserModel.getVipLevel()+2).vip_gift_ids
	end
	if(UserModel.getVipLevel() >= table.count(DB_Vip.Vip)-1 ) then -- 判断是否达到最大vip等级
		local sTips = "您的购买次数不足，请明天再来购买吧"--tbParams.sTitle--m_i18n[1928] --TODO
		-- noGoldAlert = createCommonDlg(sTips, nil, nil,1)
		ShowNotice.showShellInfo(sTips)

	elseif(vip_gift_ids == nil) then -- 礼包是不是空
		noGoldAlert = createNoGiftDlg(tbParams)
	else
		noGoldAlert = createNoGoldForCommon(tbParams)
	end
	return noGoldAlert
end

-- tbParams = {sTitle = "您得购买次数不足",sUnit = "次" 或者 "个",sName = "竞技场次数",nNowBuyNum=1 (现在vip 能购买的次（个）数),nNextBuyNum=2（下一个vip能购买的次（个）数）,}
-- 没有vip礼包 但是有购买次数
function createNoGiftDlg( tbParams )
	local layMain = g_fnLoadUI("ui/public_vip_privilege_nogift.json")
	local i18ntfd_now_vip_level = m_fnGetWidget(layMain,"tfd_now_vip_level") -- 您当前的VIP等级：
	i18ntfd_now_vip_level:setText(m_i18n[1411])
	local LABN_NOW_VIP = m_fnGetWidget(layMain,"LABN_NOW_VIP")
	LABN_NOW_VIP:setStringValue(UserModel.getVipLevel())

	--宝箱名字
	local i18nTFD_TITLE = m_fnGetWidget(layMain,"TFD_TITLE") -- 对话框名字 “您的金币不足”

	labelEffect(i18nTFD_TITLE,tbParams.sTitle)

	--宝箱名字
	local TFD_ITEM_NAME1 = m_fnGetWidget(layMain,"TFD_ITEM_NAME1")
	TFD_ITEM_NAME1:setText(tbParams.sName)
	local TFD_ITEM_NAME2 = m_fnGetWidget(layMain,"TFD_ITEM_NAME2")
	TFD_ITEM_NAME2:setText(tbParams.sName)

	local TFD_NOW_TIMES = m_fnGetWidget(layMain,"TFD_NOW_TIMES")
	TFD_NOW_TIMES:setText(tbParams.nNowBuyNum)
	local TFD_NEXT_TIMES = m_fnGetWidget(layMain,"TFD_NEXT_TIMES")
	TFD_NEXT_TIMES:setText(tbParams.nNextBuyNum)

	local nowBg = m_fnGetWidget(layMain,"lay_now_buytimes")
	local nowText = m_fnGetWidget(nowBg,"tfd_ge")
	local nextBg = m_fnGetWidget(layMain,"lay_next_buytimes")
	local nextText = m_fnGetWidget(nextBg,"tfd_ge")
	nextText:setText(tbParams.sUnit) -- “个” 或者 “次”
	nowText:setText(tbParams.sUnit)

	--下一级的vip等级
	local LABN_NEXT_VIP = m_fnGetWidget(layMain,"LABN_NEXT_VIP")
	LABN_NEXT_VIP:setStringValue(UserModel.getVipLevel() + 1)

	local TFD_RECHARGE_GOLD = m_fnGetWidget(layMain,"TFD_RECHARGE_GOLD") --还需要充值多少钱

	local db_vip = DB_Vip.getDataById(UserModel.getVipLevel()+2)
	local needGold = db_vip.rechargeValue - DataCache.getChargeGoldNum()
	TFD_RECHARGE_GOLD:setText(tostring(needGold)) --还差多少金币

	local BTN_RECHARGE = m_fnGetWidget(layMain,"BTN_RECHARGE") -- 充值按钮
	titleShadow(BTN_RECHARGE,m_i18n[2116])
	local BTN_CLOSE = m_fnGetWidget(layMain,"BTN_CLOSE") -- 关闭按钮
	BTN_CLOSE:addTouchEventListener(onClose)

	return layMain

end

-- add by huxiaozhou 给已经达到最大vip等级的人物提示金币不足 去充值
function createNoGoldForMaxVip( )
	local layMain = g_fnLoadUI("ui/public_top_vip_gold_not_enough.json")
	local i18nTFD_TITLE = m_fnGetWidget(layMain,"TFD_TITLE") -- 对话框名字 “您的金币不足”
	labelEffect(i18nTFD_TITLE,m_i18n[1410])
	local i18ntfd_now_vip_level = m_fnGetWidget(layMain,"tfd_now_vip_level") -- 您当前的VIP等级：
	i18ntfd_now_vip_level:setText(m_i18n[1411])
	local LABN_NOW_VIP = m_fnGetWidget(layMain,"LABN_NOW_VIP")
	LABN_NOW_VIP:setStringValue(UserModel.getVipLevel())

	local BTN_RECHARGE = m_fnGetWidget(layMain,"BTN_RECHARGE") -- 充值按钮
	titleShadow(BTN_RECHARGE,m_i18n[2116])
	BTN_RECHARGE:addTouchEventListener(function ( sender, eventType ) -- 封测包临时给充值按钮添加未开启提示
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			ShowNotice.showShellInfo("充值暂未开放")
	end
	end)

	local BTN_CLOSE = m_fnGetWidget(layMain,"BTN_CLOSE") -- 关闭按钮
	BTN_CLOSE:addTouchEventListener(onClose)

	return layMain
end

-- tbParams = {sTitle = "您得购买次数不足",sUnit = "次" 或者 "个",sName = "竞技场次数",nNowBuyNum=1,nNextBuyNum=2,}
-- add by huxiaozhou 给尚未达到最大vip等级的玩家 提示金币不足 充值
function createNoGoldForCommon( tbParams)
	local layMain = nil
	if tbParams==nil then
		layMain = g_fnLoadUI("ui/public_nor_vip_gold_not_enough.json")

		local i18nTFD_TITLE = m_fnGetWidget(layMain,"TFD_TITLE") -- 对话框名字 “您的金币不足”
		labelEffect(i18nTFD_TITLE,m_i18n[1410])

	else
		layMain = g_fnLoadUI("ui/public_vip_privilege.json")

		local i18nTFD_TITLE = m_fnGetWidget(layMain,"TFD_TITLE") -- 对话框名字 “您的金币不足”

		labelEffect(i18nTFD_TITLE,tbParams.sTitle)

		--宝箱名字
		local TFD_ITEM_NAME1 = m_fnGetWidget(layMain,"TFD_ITEM_NAME1")
		TFD_ITEM_NAME1:setText(tbParams.sName)
		local TFD_ITEM_NAME2 = m_fnGetWidget(layMain,"TFD_ITEM_NAME2")
		TFD_ITEM_NAME2:setText(tbParams.sName)

		local TFD_NOW_TIMES = m_fnGetWidget(layMain,"TFD_NOW_TIMES")
		TFD_NOW_TIMES:setText(tbParams.nNowBuyNum)
		local TFD_NEXT_TIMES = m_fnGetWidget(layMain,"TFD_NEXT_TIMES")
		TFD_NEXT_TIMES:setText(tbParams.nNextBuyNum)

		local nowBg = m_fnGetWidget(layMain,"lay_now_buytimes")
		local nowText = m_fnGetWidget(nowBg,"tfd_ge")
		local nextBg = m_fnGetWidget(layMain,"lay_next_buytimes")
		local nextText = m_fnGetWidget(nextBg,"tfd_ge")
		nextText:setText(tbParams.sUnit) -- “个” 或者 “次”
		nowText:setText(tbParams.sUnit)
		--[[
		TFD_ITEM_NAME1:setText(boxName)

		local maxLimitNum = ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), tbParams.boxTid)
		logger:debug(maxLimitNum)
		--宝箱可以购买的次数
		local TFD_NOW_TIMES = m_fnGetWidget(layMain,"TFD_NOW_TIMES")
		TFD_NOW_TIMES:setText(tostring(maxLimitNum))


		--下一级的vip等级

		--宝箱名字
		local TFD_ITEM_NAME2 = m_fnGetWidget(layMain,"TFD_ITEM_NAME2")
		TFD_ITEM_NAME2:setText(boxName)

		local nextMaxLimitNum = ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel() + 1, tbParams.boxTid)
		logger:debug(nextMaxLimitNum)
		--宝箱可以购买的次数
		local TFD_NEXT_TIMES = m_fnGetWidget(layMain,"TFD_NEXT_TIMES")
		TFD_NEXT_TIMES:setText(tostring(nextMaxLimitNum))
--]]
	end



	local i18ntfd_now_vip_level = m_fnGetWidget(layMain,"tfd_now_vip_level") -- 您当前的VIP等级：
	i18ntfd_now_vip_level:setText(m_i18n[1411])

	local LABN_NOW_VIP = m_fnGetWidget(layMain,"LABN_NOW_VIP")

	LABN_NOW_VIP:setStringValue(UserModel.getVipLevel())

	local i18ntfd_recharge_again = m_fnGetWidget(layMain,"tfd_recharge_again")  -- "再充值"
	i18ntfd_recharge_again:setText(m_i18n[1413])

	local i18nTFD_RECHARGE_GOLD = m_fnGetWidget(layMain,"TFD_RECHARGE_GOLD") --20000金币，
	i18nTFD_RECHARGE_GOLD:setText(m_i18n[1414])

	local db_vip = DB_Vip.getDataById(UserModel.getVipLevel()+2)


	i18nTFD_RECHARGE_GOLD:setText(string.format("%d",db_vip.rechargeValue-DataCache.getChargeGoldNum())) --还差多少金币

	local i18ntfd_will_be = m_fnGetWidget(layMain,"tfd_will_be") -- 您将成为
	local LABN_NEXT_VIP = m_fnGetWidget(layMain,"LABN_NEXT_VIP")
	LABN_NEXT_VIP:setStringValue(UserModel.getVipLevel()+1)



	local LABN_VIP_LEVEL_TILTE = m_fnGetWidget(layMain,"LABN_VIP_LEVEL_TILTE")
	LABN_VIP_LEVEL_TILTE:setStringValue(UserModel.getVipLevel()+1)

	local vipData = DB_Vip.getDataById(UserModel.getVipLevel()+2)
	local vip_gift_ids = string.split(vipData.vip_gift_ids, "|")


	require "script/module/shop/ShopGiftData"
	require "script/module/public/PublicInfoCtrl"

	local tbItems = ShopGiftData.getGiftRewardInfo(vip_gift_ids[1])
	logger:debug(tbItems)
	local tbShowItems = {}
	for k,v in pairs(tbItems or {}) do
		local _icon
		local _name
		local _quality
		local tbItemDB
		local tbSubItem = {}
		if (v.type == "item") then
			_icon,tbItemDB = ItemUtil.createBtnByTemplateIdAndNumber(v.tid,v.num,function (snder,eventType)
				if (eventType == TOUCH_EVENT_ENDED) then
					PublicInfoCtrl.createItemInfoViewByTid(v.tid,v.num)
				end
			end)
			_name = tbItemDB.name
			_quality = tbItemDB.quality
		elseif(v.type == "silver") then
			_icon = ItemUtil.getSiliverIconByNum(v.num)
			_name = m_i18n[1520]
			_quality = 2
		elseif(v.type == "soul") then
			_icon = ItemUtil.getSoulIconByNum(v.num)
			_name = m_i18n[1087]
			_quality = 4
		end
		tbSubItem.icon = _icon
		tbSubItem.name = _name
		tbSubItem.quality = _quality
		table.insert(tbShowItems,tbSubItem)
	end

	local LSV_ITEM_LIST = m_fnGetWidget(layMain,"LSV_ITEM_LIST")
	local LAY_ITEM_BG = m_fnGetWidget(LSV_ITEM_LIST, "LAY_ITEM_BG")

	initListView(LSV_ITEM_LIST)
	local cell, nIdx

	for i,tempIcon in ipairs(tbShowItems) do
		LSV_ITEM_LIST:pushBackDefaultItem()
		nIdx = i - 1
		cell = LSV_ITEM_LIST:getItem(nIdx)  -- cell 索引从 0 开始

		local IMG_ICON = m_fnGetWidget(cell,"IMG_ICON")
		IMG_ICON:addChild(tempIcon.icon)
		local TFD_ITEM_NAME = m_fnGetWidget(cell, "TFD_ITEM_NAME")
		labelAddStroke(TFD_ITEM_NAME)
		TFD_ITEM_NAME:setText(tempIcon.name)
		local color =  g_QulityColor2[tonumber(tempIcon.quality)]
		if(color ~= nil) then
			TFD_ITEM_NAME:setColor(color)
		end

	end


	local BTN_RECHARGE = m_fnGetWidget(layMain,"BTN_RECHARGE") -- 充值按钮
	titleShadow(BTN_RECHARGE,m_i18n[2116])
	BTN_RECHARGE:addTouchEventListener(function ( sender, eventType ) -- 封测包临时给充值按钮添加未开启提示
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			ShowNotice.showShellInfo("充值暂未开放") --TODO
	end
	end)


	local BTN_CLOSE = m_fnGetWidget(layMain,"BTN_CLOSE") -- 关闭按钮
	BTN_CLOSE:addTouchEventListener(onClose)

	logger:debug(DataCache.getChargeGoldNum())
	layMain:setSize(g_winSize)
	return layMain
end




-- 只限版署版
function createEditionCheckNotice( ... )
	local info = "健康游戏忠告\n抵制不良游戏 拒绝盗版游戏；\n注意自我保护 谨防受骗上当；\n适度游戏益脑 沉迷游戏伤身；\n合理安排时间 享受健康生活。"
	local dlg = createCommonDlg(info, nil)
	dlg:setSize(g_winSize)
	return dlg
end

--[[desc: zhangqi, 2014-05-05, 创建一个HZTableView
 szViewSize: CCSize,
 szCellSize: CCSize,
 nCellNumber: cell 个数
 fnCellAtIndex: 创建和刷新cell的方法，原型: function fun(view, idx)
 fnCellTouched: cell被点击的事件回调，nil的话默认显示事件类型名
 fnDidScroll: 滑动的事件回调，nil的话默认显示事件类型名
 fnDidZoom: 缩放事件回调，nil的话默认显示事件类型名
 return: CCTableView 对象
 —]]
function createHZTableView( szViewSize, szCellSize, nCellNumber, fnCellAtIndex, fnCellTouched, fnDidScroll, fnDidZoom )
	local tableView = HZTableView:create(szViewSize)
	tableView:setDirection(kCCScrollViewDirectionVertical) -- 默认垂直滑动
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown) -- 默认从上至下放置
	tableView:setPosition(ccp(0, 0))

	--registerScriptHandler functions must be before the reloadData function
	tableView:registerScriptHandler(fnDidScroll or function ( view )
		logger:debug("CCTableView.kTableViewScroll")
	end, CCTableView.kTableViewScroll)

	tableView:registerScriptHandler(fnDidZoom or function ( view )
		logger:debug("CCTableView.kTableViewZoom")
	end, CCTableView.kTableViewZoom)

	tableView:registerScriptHandler(fnCellTouched or function ( view, cell )
		logger:debug("CCTableView.kTableCellTouched")
	end, CCTableView.kTableCellTouched)

	tableView:registerScriptHandler(function ( view, idx )
		logger:debug("szCellSize.w = ", szCellSize.width, "szCellSize.h = ", szCellSize.height)
		return szCellSize.height, szCellSize.width
	end, CCTableView.kTableCellSizeForIndex)

	tableView:registerScriptHandler(fnCellAtIndex, CCTableView.kTableCellSizeAtIndex)

	tableView:registerScriptHandler(function ( view )
		return nCellNumber or 0
	end, CCTableView.kNumberOfCellsInTableView)

	-- tableView:reloadData()

	return tableView
end


--[[desc:为一个node的enter和exit方法绑定回调-- zhangjunwu,  modified by huxiaozhou
    arg1: node需要绑定的node,onExitCall,onEnterCall是exit和enter的回调
    return: 是否有返回值，返回值说明  
—]]
function registExitAndEnterCall( node,onExitCall,onEnterCall,onEnterFinish)
	local function onNodeEvent( eventType, node )
		logger:debug(eventType)
		if (eventType == "enter") then
			if (onEnterCall) then
				onEnterCall()
			end
		elseif (eventType == "exit") then
			if (onExitCall) then
				onExitCall()
			end
		elseif (eventType =="enterTransitionFinish" ) then
			if (onEnterFinish) then
				onEnterFinish()
			end
		end
	end
	node:registerScriptHandler(onNodeEvent)
end

function clearTouchStat( ... )
	local oneTouch = LayerManager.getCurrentPopLayer()
	if (oneTouch) then
		oneTouch:clearTouchStat()
	end
end
-- zhangqi, 2014-09-17, 文本输入框通用事件处理
-- 清理一下当前弹出层的触摸状态，解决点击按钮同时点击editbox再放开导致的所有按钮无响应问题
local function editboxCommonHandler(eventType, sender)
	if eventType == "began" then
		local x,y = sender:getPosition()
		sender:setPosition(ccp(x,y))
		-- triggered when an edit box gains focus after keyboard is shown
	elseif eventType == "ended" then
	-- triggered when an edit box loses focus after keyboard is hidden.
	elseif eventType == "changed" then
	-- triggered when the edit box text was changed.
	elseif eventType == "return" then
		-- triggered when the return button was pressed or the outside area of keyboard was touched.
		logger:debug("return, text = %s", sender:getText())
		clearTouchStat()
	end
end
-- 文本框,boxSize:文本框尺寸,boxBg:文本框背景,cellWrap:是否换行，换行为true,verAlignment:垂直布局参数
function createEditBox(boxSize,boxBg,cellWrap,verAlignment, eventHandler)
	local img=CCScale9Sprite:create(boxBg or "images/base/potential/input_name_bg1.png")
	-- img:setOpacity(0)
	local msg_input = CCEditBox:create(boxSize, img)
	msg_input:setInputFlag(kEditBoxInputFlagInitialCapsWord)

	local touchPriority = g_tbTouchPriority.editbox
	local popLayer = LayerManager.getCurrentPopLayer()
	if (popLayer) then
		local tp = popLayer:getTouchPriority()
		-- 如果当前弹出层优先级为0，表示还没有创建弹出层，第一个弹出层优先级必为-1，所以文本框应该为-2
		touchPriority = tp == 0 and -2 or (tp - 1)
	end
	msg_input:setTouchPriority(touchPriority)
	if (not eventHandler) then
		msg_input:registerScriptEditBoxHandler(editboxCommonHandler)
	end

	-- menghao 统一字体和字号
	msg_input:setFont(g_FontInfo.name, g_FontInfo.size)
	msg_input:setPlaceholderFont(g_FontInfo.name, g_FontInfo.size)

	-- 单行输入多行显示
	if(msg_input:getChildByTag(1001))then
		local labelTTF = tolua.cast(msg_input:getChildByTag(1001),"CCLabelTTF")
		labelTTF:setHorizontalAlignment(kCCTextAlignmentLeft)
		if (cellWrap) then
			labelTTF:setDimensions(boxSize)
		end
		if (verAlignment) then
			labelTTF:setVerticalAlignment(verAlignment)
		else
			labelTTF:setVerticalAlignment(kCCVerticalTextAlignmentTop)
		end
	end
	return msg_input
end

--[[desc: 创建一个文本输入框, zhangqi, 2014-11-04  main.mp3
    tbArgs: {size, bg, cellWrap, verAlignment, eventHandler, 
				content, holder, holderColor = ccc3(), maxLen = 20,
				FontName, FontSize, FontColor = ccc3(),
				RetrunType, InputFlag, InputMode}
			size,bg, cellWrap, verAlignment, eventHandler 同createEditBox
			content: 文本框要显示的文字内容；holder:文本框默认显示文字；holderColor:默认文字的颜色，ccc3格式；maxLen:最大长度
			RetrunType:回车类型；InputFlag, InputMode, 文本框类型和限制，详见CCEditBox.h定义
    return: 创建好的CCEditBox对象
—]]
function createEditBoxNew(tbArgs)
	local eb = createEditBox(tbArgs.size, tbArgs.bg, tbArgs.cellWrap, tbArgs.verAlignment, tbArgs.eventHandler)
	if (tbArgs.holder) then
		eb:setPlaceHolder(tbArgs.holder)
	end
	if (tbArgs.holderColor) then
		eb:setPlaceholderFontColor(tbArgs.holderColor)
	end
	if (tbArgs.maxLen) then
		eb:setMaxLength(20)
	end

	if (tbArgs.RetrunType) then
		eb:setReturnType(tbArgs.RetrunType)
	end

	if (tbArgs.InputFlag) then
		eb:setInputFlag(tbArgs.InputFlag)
	end

	if (tbArgs.InputMode) then
		eb:setInputMode(tbArgs.InputMode)
	end
	if (tbArgs.content) then
		eb:setText(tbArgs.content)
	end
	if (tbArgs.FontName) then
		eb:setFontName(tbArgs.FontName)
	end
	if (tbArgs.FontSize) then
		eb:setFontSize(tbArgs.FontSize)
	end
	if (tbArgs.FontColor) then
		eb:setFontColor(tbArgs.FontColor)
	end
	return eb
end

function bindEventToEditBox( tbArgs )
	local function editboxEventHandler(eventType, sender)
		if eventType == "began" then
			local x,y = sender:getPosition()
			sender:setPosition(ccp(x,y))
			-- triggered when an edit box gains focus after keyboard is shown
			logger:debug("began, text = " .. sender:getText())
			if (tbArgs.onBegan and type(tbArgs.onBegan) == "function") then
				tbArgs.onBegan(sender:getText())
			end
		elseif eventType == "ended" then
			-- triggered when an edit box loses focus after keyboard is hidden.
			logger:debug("ended, text = " .. sender:getText())
			if (tbArgs.onEnded and type(tbArgs.onEnded) == "function") then
				tbArgs.onEnded(sender:getText())
			end
		elseif eventType == "changed" then
			-- triggered when the edit box text was changed.
			logger:debug("changed, text = " .. sender:getText())
			if (tbArgs.onChanged and type(tbArgs.onChanged) == "function") then
				tbArgs.onChanged(sender:getText())
			end
		elseif eventType == "return" then
			-- triggered when the return button was pressed or the outside area of keyboard was touched.
			logger:debug("return, text = " .. sender:getText())
			if (tbArgs.onReturn and type(tbArgs.onReturn) == "function") then
				tbArgs.onReturn(sender:getText())
			end
			clearTouchStat()
		end
	end
	tbArgs.inputBox:registerScriptEditBoxHandler(editboxEventHandler)
end

-- zhangqi, 创建一个 EidtBox 并附加到参数指定的背景上，并返回EidtBox对象
-- tbArgs = {layRoot = layout, bgName = "", sHolder = "", holderColor = ccc3(), maxLen = 20, contentText = "",
--			  FontName = "", FontSize = 22, FontColor = ccc3(),
--			  event = {onBegan = function, onEnded = function, onChanged = function, onReturn = function}
--		 	 }
function addEditBoxWithBackgroud( tbArgs )
	local imgBg = m_fnGetWidget(tbArgs.layRoot, tbArgs.bgName)
	local bgSize = imgBg:getSize()
	local tbEbCfg = { size = CCSizeMake(bgSize.width, bgSize.height), bg = m_ebBg,
		content = tbArgs.contentText, holder = tbArgs.sHolder,
		holderColor = tbArgs.holderColor or m_ebHolderColor, maxLen = tbArgs.maxLen or 20,
		RetrunType = kKeyboardReturnTypeDone, InputMode = kEditBoxInputModeSingleLine,
	}
	local editbox = UIHelper.createEditBoxNew(tbEbCfg)
	editbox:setInputFlag(kEditBoxInputFlagSensitive)
	imgBg:addNode(editbox)

	local ebArgs = {inputBox = editbox, event = tbArgs.event}
	bindEventToEditBox(ebArgs)

	return editbox
end


-- add by huxiaozhou 2014-06-09
--创建一个吃touch的半透明layer
--priority : touch 权限级别,默认为-1024  还会修改的
--touchRect: 在touchRect 区域会放行touch事件 若touchRect = nil 则全屏吃touch
--touchCallback: 屏蔽层touch 回调
function createMaskLayer( priority,touchRect ,touchCallback, layerOpacity,highRect, maskRect)
	local layer = CCLayer:create()
	layer:setPosition(ccp(0, 0))
	layer:setAnchorPoint(ccp(0, 0))
	layer:setTouchEnabled(true)
	layer:setTouchPriority(priority or -1024)
	layer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			if(touchRect == nil) then
				if(touchCallback ~= nil) then
					touchCallback()
				end
				return true
			else
				if(touchRect:containsPoint(ccp(x,y))) then
					if(touchCallback ~= nil) then
						touchCallback()
					end
					return false
				else
					if(touchCallback ~= nil) then
						touchCallback()
					end
					return true
				end
			end
		end
	end,false, priority or -1024, true)

	local gw,gh = g_winSize.width, g_winSize.height
	if(touchRect == nil) then
		local layerColor = CCLayerColor:create(ccc4(0,0,0,0),gw,gh)
		layerColor:setAnchorPoint(ccp(0,0))
		layer:addChild(layerColor)
		return layer
	else

		local maskRectTemp = maskRect or touchRect

		local ox,oy,ow,oh = maskRectTemp.origin.x, maskRectTemp.origin.y, maskRectTemp.size.width, maskRectTemp.size.height
		require "script/module/public/EffectHelper"
		local guideEff = EffGuide:new()
		guideEff:Armature():setPosition(ccp(ox+ow/2, oy+oh/2))
		logger:debug("ox+ow/2 = " .. ox+ow/2)

		logger:debug("oy+oh/2 = " .. oy+oh/2)

		local rotation = 0
		if oy+oh/2 < 150 and  g_winSize.width - (ox+ow/2) < 150 then
			rotation = 180
		else
			if oy+oh/2 < 150 then
				rotation = -100
			end

			if g_winSize.width - (ox+ow/2) < 150 then
				rotation = 80
			end
		end
		guideEff:Armature():setRotation(rotation)

		layer:addChild(guideEff:Armature(),9999)


		-- -- 添加编辑器做得蒙版
		-- local jsonMask = "ui/new_mask.json"
		-- local layoutMask = g_fnLoadUI(jsonMask)
		-- layoutMask:setSize(g_winSize)
		-- layer:addChild(layoutMask, -1)
		-- layoutMask:setPosition(ccp(ox+ow/2, oy+oh/2))

		-- local layerColor = CCLayerColor:create(ccc4(0, 0, 0, layerOpacity or 150 ), gw, gh)
		local layerColor = CCLayerColor:create(ccc4(0,0,0,0),gw,gh)
		local clipNode = CCClippingNode:create();
		clipNode:setInverted(true)
		clipNode:addChild(layerColor)

		local stencilNode = CCNode:create()
		-- stencilNode:retain()

		local node = CCScale9Sprite:create("images/common/rect.png")
		node:setContentSize(CCSizeMake(ow, oh))
		node:setAnchorPoint(ccp(0, 0))
		node:setPosition(ccp(ox, oy))
		stencilNode:addChild(node)

		if(highRect ~= nil) then
			local highNode = CCScale9Sprite:create("images/common/rect.png")
			highNode:setContentSize(CCSizeMake(highRect.size.width, highRect.size.height))
			highNode:setAnchorPoint(ccp(0, 0))
			highNode:setPosition(ccp(highRect.origin.x, highRect.origin.y))
			stencilNode:addChild(highNode)
		end

		clipNode:setStencil(stencilNode)
		clipNode:setAlphaThreshold(0.5)
		layer:addChild(clipNode)
	end
	return layer
end

--[[desc: zhangqi, 20140624, 返回一个注册到全局Scheduler的schedulId
    node: CCNode, onExit事件时会 unschedule 已注册的全局 schedulId，确保schedule事件随UI界面关闭而被注销
    fnCallback: schedule 的回调方法
    nInterval: schedule 的间隔，单位秒。If 'interval' is 0, it will be called every frame，默认是1秒
    bPaused: If bPaused is true, then it won't be called until it is resumed, 默认是 false
    return: number
—]]
function getAutoReleaseScheduler( node, fnCallback, nInterval, bPaused )
	local scID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(fnCallback, nInterval or 1, false)
	logger:debug("scID = %d", scID)
	node:registerScriptHandler(function ( eventType,node )
		if(eventType == "exit") then
			logger:debug("getAutoReleaseScheduler onExit")
			if(scID ~= nil)then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scID)
				logger:debug("getAutoReleaseScheduler unschedule ok")
				scID = nil
			end
		end
	end)
	return scID
end

-- 绑定一个回调方法到指定node的onExit事件，可以做一些模块全局变量的重置清理工作
-- 避免UI删除后引用并没有真正置为nil, 其他模块仍然在调用刷新UI方法导致找不到引用的错误
function addCallbackOnExit( node, fnCallback )
	if (node) then
		node:registerScriptHandler(function ( eventType,node )
			if(eventType == "exit") then
				logger:debug("addCallbackOnExit onExit")
				if (fnCallback) then
					fnCallback()
				end
			end
		end)
	end
end

--[[desc:返回一个用|或者不可见的字符 分割的 富文本字符串
    arg1: tbData,:由不同的字符串组成的表；
    	  bState:是否需要用不可见字符分割，默认为nil
    return: 返回富文本所需要的字符串
—]]

function concatString( tbData ,bState)
	if(bState) then
		local str = table.concat(tbData, string.char(17))
		return str
	else
		local str = table.concat(tbData, "|")
		logger:debug(str)
		return str
	end
	return ""
end


--[[
menghao
创建一个渐隐渐现的CCLabelAtlas

可用参数：
-	str1 		原先的字符串值
-	str2 		
-	nInTime 	淡入时间
-	nOutTime 	淡出时间

@return  CCLabelAtlas对象
--]]
function createfadeIOLabelAtlas( str1, str2, nInTime, nOutTime)
	local labelAtlas = CCLabelAtlas:create(str1, "ui/transfer_info_num.png", 27, 28, 48)
	local nTime = 1

	local actionArr = CCArray:create()
	actionArr:addObject(CCFadeIn:create(nInTime or 0.8))
	actionArr:addObject(CCFadeOut:create(nOutTime or 0.8))
	actionArr:addObject(CCCallFunc:create(function ( ... )
		if nTime == 1 then
			labelAtlas:setString(str2)
			nTime = 0
		else
			labelAtlas:setString(str1)
			nTime = 1
		end
	end))

	labelAtlas:runAction(CCRepeatForever:create(CCSequence:create(actionArr)))
	return labelAtlas
end


--[[--
menghao 20150122
创建一个渐隐渐现的label对象并返回，可以通过addNode加到widget上

@param table params 参数表格对象
text1 为必须传的字段
如果传text2则为两个不同 字符串 切换渐隐渐现
如果要描边，strokeColor必须传
其他参数都有默认值

@return  LabelFT对象

示例
label = UIHelper.createBlinkLabel({
	fontName = "", fontSize = 18, strokeColor = ccc3(32,0,0), strokeSize = 2,
	text1 = curPercent .. "%", color1 = ccc3(255,255,0),
	text2 = "100%", color2 = ccc3(255,255,0)
}, 1, 1)
]]
function createBlinkLabel(tbInfo, nInTime, nOutTime)
	local blinkLabel = LabelFT:create(tbInfo.text1, tbInfo.fontName or g_sFontName, tbInfo.fontSize or 20)
	blinkLabel:setColor(tbInfo.color1 or ccc3(255,255,255))
	if (tbInfo.strokeColor) then
		blinkLabel:enableStroke(tbInfo.strokeColor, tbInfo.strokeSize or 2)
	end
	local nFlag = 1

	local actionArr = CCArray:create()
	actionArr:addObject(CCFadeIn:create(nInTime or 1))
	actionArr:addObject(CCFadeOut:create(nOutTime or 1))
	if (tbInfo.text2) then
		actionArr:addObject(CCCallFunc:create(function ( ... )
			if nFlag == 1 then
				blinkLabel:setString(tbInfo.text2)
				blinkLabel:setColor(tbInfo.color2 or ccc3(255,255,255))
				nFlag = 2
			else
				blinkLabel:setString(tbInfo.text1)
				blinkLabel:setColor(tbInfo.color1 or ccc3(255,255,255))
				nFlag = 1
			end
		end))
	end

	blinkLabel:runAction(CCRepeatForever:create(CCSequence:create(actionArr)))
	return blinkLabel
end


-- widget 灰度化 子控件也会变灰
--参数：
--	widget 		控件对象
-- 	bGray 		true or false
function setWidgetGray( widget , bGray)
	widget:setGray(bGray)
	local tbChildren = getTbChildren(widget)
	for _,v in ipairs(tbChildren or {}) do
		v:setGray(bGray)
	end
end



--[[--
menghao
获取一个widget所有的子控件（不包括node类型）组成的table

参数：
-	widget 		控件对象

@return 	table
]]
function getTbChildren( widget )
	tolua.cast(widget, "Widget")
	local tbChildren = {}

	local arrChildren = widget:getChildren()
	for i=1,widget:getChildrenCount() do
		local widgetChild = arrChildren:objectAtIndex(i - 1)
		table.insert(tbChildren, widgetChild)
		for k, v in pairs(getTbChildren(widgetChild)) do
			table.insert(tbChildren, v)
		end
	end

	g_fnCastWidget(widget)

	return tbChildren
end



--[[--
menghao
让widget和其所有的子控件（不包括node类型）执行渐变透明度动作

参数：
-	widget 		控件对象
-	nInterval 	执行动作的时间
-	opacity 	目标透明度

@return

modified by huxiaozhou 
if (call)
to
if (call and widget == v)

]]
function widgetFadeTo( widget, nInterval, opacity, call )
	local tb = getTbChildren(widget)
	table.insert(tb, widget)

	for k, v in pairs(tb) do
		local actionArr = CCArray:create()
		actionArr:addObject(CCFadeTo:create(nInterval, opacity))
		if (call and widget == v) then
			actionArr:addObject(CCCallFunc:create(call))
			call = nil
		end

		sp = tolua.cast(v:getVirtualRenderer(), "CCSprite")
		sp:runAction(CCSequence:create(actionArr))
	end
end


--[[--
menghao
让widget和其所有的子控件（不包括node类型）执行渐隐渐现

@param table params 参数表格对象
参数：
-	widget 			控件对象
-	nIntervalIn 	in的时间
-	nIntervalOut 	out的时间
- 	callAfterIn 	in之后回调
- 	callAfterOut 	out之后回调

参数示例
local tbArgs = {
	widget = hahaha,
	nIntervalIn = 1,
	nIntervalOut = 1,
	callAfterIn = function() end,
	callAfterOut = function() end,
}

@return
]]
function widgetFadeInOut( tbArgs )
	local tb = getTbChildren(tbArgs.widget)
	table.insert(tb, tbArgs.widget)

	for k, v in pairs(tb) do
		local actionArr = CCArray:create()
		actionArr:addObject(CCFadeTo:create(tbArgs.nIntervalIn or 1, 255))
		if (tbArgs.callAfterIn) then
			actionArr:addObject(CCCallFunc:create(tbArgs.callAfterIn))
			tbArgs.callAfterIn = nil
		end
		actionArr:addObject(CCFadeTo:create(tbArgs.nIntervalOut or 1, 0))
		if (tbArgs.callAfterOut) then
			actionArr:addObject(CCCallFunc:create(tbArgs.callAfterOut))
			tbArgs.callAfterOut = nil
		end

		sp = tolua.cast(v:getVirtualRenderer(), "CCSprite")
		sp:runAction(CCRepeatForever:create(CCSequence:create(actionArr)))
	end
end


-- 获取一个控件和其子控件上的所有以addNodes方式添加的节点（非UI控件）
function getTbNodes( widget )
	local tbNode = {}

	local function getNodes( node )
		local array = node:getNodes()
		for i=1,array:count() do
			table.insert(tbNode,array:objectAtIndex(i-1))

		end
	end

	getNodes(widget)

	local tbChildren = getTbChildren(widget)
	for k,v in pairs(tbChildren) do
		getNodes(v)
	end
	logger:debug(tbNode)

	return tbNode
end


--add by yangna
-- 一组节点执行延时和CCFadeTo动作
-- tbnode:table
-- type 节点类型：1 widget控件 2 非widget控件
-- delaytime  延时时间
-- fadetime  执行CCFadeTo的时间
-- oirginaOpa起始透明度
-- finalOpa结束透明度
-- callfunc回调方法，可为nil
function nodeFadeTo( tbnode,type,delaytime,fadetime,oirginaOpa,finalOpa,callfunc)
	for k,v in pairs(tbnode) do
		v:setOpacity(oirginaOpa)
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(delaytime))   --1-4
		array:addObject(CCFadeTo:create(fadetime,finalOpa))   --5-17
		if(callfunc)then
			array:addObject(CCCallFuncN:create(function ( ... )
				callfunc()
			end))
		end
		local seq = CCSequence:create(array)
		if(tonumber(type)==1)then
			imgRender = v:getVirtualRenderer()
			imgRender:runAction(seq)
		end
		if( tonumber(type)==2)then
			v:runAction(seq)
		end
	end
end


-- add by lizy 2014-07-14
--创建一个CCLabelTTF,可实现渐入渐出
--firstText : 要显示的文字 ，变换前
--secondText 要显示的文字 ，变换后
--fontSize    字体大小
--c3FirstText  firstText 字体颜色
--c3SecondText	secondText 字体颜色
--fadeInTime: 变没得效果时间
--fadeOutTime: 出现的时间
--渐变的停止时间
function fadeInAndOut( strFirstText ,strSecondText,nFontSize,c3FirstText,c3SecondText,nFadeInTime,nFadeOutTime,nDelay)
	local   nTime = 1
	local   sprite  =  CCLabelTTF:create(strFirstText ,g_sFontCuYuan,nFontSize or 22)
	local   fuCallfunc = function ( ... )
		if (nTime == 1) then
			-- sprite:setColor(ccc3(255,0,0))
			sprite:setColor( c3SecondText or ccc3(26,134,5))
			sprite:setString(strSecondText)
			nTime = 0
		else
			nTime = 1
			sprite:setString(strFirstText)
			--sprite:setColor(ccc3(0,0,0))
			sprite:setColor( c3FirstText or ccc3(255,255,255))
		end
	end

	local   blinkArray = CCArray:create()
	blinkArray:addObject(CCFadeIn:create(nFadeInTime or 0.8))
	blinkArray:addObject(CCFadeOut:create(nFadeOutTime or 0.8))

	--   blinkArray:addObject(CCDelayTime:create(nDelay or 0.5))
	if (strSecondText ~= nil) then
		blinkArray:addObject(CCCallFunc:create(fuCallfunc))
	end


	local   actionIn = CCSequence:create(blinkArray)
	sprite:runAction(CCRepeatForever:create(actionIn))
	return  sprite
end

-- add by lizy 2014-07-14
-- 创建一个CCSprite的t图片,可实现渐入渐出
--imagePath:  sprite上显示的图片
--fadeInTime: 变没得效果时间
--fadeOutTime: 出现的时间
--渐变的停止时间
function fadeInAndOutImage(imagePath ,fadeInTime,fadeOutTime,delay,notNeddScale)
	local sprite  =  CCSprite:create(imagePath)
	local blinkArray = CCArray:create()
	blinkArray:addObject(CCFadeIn:create(fadeInTime or 0.8))
	blinkArray:addObject(CCFadeOut:create(fadeOutTime or 0.8))
	blinkArray:addObject(CCDelayTime:create(delay or 0))
	local actionIn = CCSequence:create(blinkArray)
	if(not notNeddScale) then
		sprite:setScale(0.85)
	end
	sprite:runAction(CCRepeatForever:create(actionIn))

	return  sprite
end

-- add by lizy 2014-07-14
-- 创建一个CCSprite的进度条,可实现渐入渐出
--nGreenBarWidth:  需要闪烁的进度条的值 范围 0 - 100
--fadeInTime: 变没得效果时间
--fadeOutTime: 出现的时间
--渐变的停止时间
function fadeInAndOutBar(nGreenBarWidth,fadeInTime,fadeOutTime,delay , imageFile)
	local  nMaxWidth = 120

	-- local insetRect = CCRectMake(20, 8, 5, 1)
	local  preferredSize = CCSizeMake(nMaxWidth, 10)

	if  (nGreenBarWidth > nMaxWidth) then
		nGreenBarWidth = nMaxWidth
	end

	local pImage = imageFile or "ui/short_progress_green.png"

	local  progressSprite = CCSprite:create(pImage)

	local  progress1=CCProgressTimer:create(progressSprite)

	progress1:setType(kCCProgressTimerTypeBar)

	progress1:setMidpoint(ccp(0, 0))

	progress1:setBarChangeRate(ccp(1, 0))

	progress1:setPercentage(nGreenBarWidth)


	local   arrActions = CCArray:create()
	local   fadeIn = CCFadeIn:create( fadeInTime or 0.8)
	local   fadeOut = CCFadeOut:create(fadeOutTime or 0.8)

	arrActions:addObject(fadeIn)
	arrActions:addObject(fadeOut)

	--arrActions:addObject(CCDelayTime:create(delay or 0))
	local   sequence = CCSequence:create(arrActions)
	local   action = CCRepeatForever:create(sequence)
	--progress1:setScale(1.1);
	progress1:runAction(action)
	-- progress1:setPosition(ccp(nPos,0))
	return  progress1
end
--渐入渐出node lizy
function fadeInAndOutUI(node,fadeInTime,fadeOutTime,delay)
	local   arrActions = CCArray:create()
	local   fadeIn = CCFadeIn:create( fadeInTime or 0.8)
	local   fadeOut = CCFadeOut:create(fadeOutTime or 0.8)

	arrActions:addObject(fadeIn)
	arrActions:addObject(fadeOut)
	arrActions:addObject(CCDelayTime:create(delay or 0.01))

	local   sequence = CCSequence:create(arrActions)
	local   action = CCRepeatForever:create(sequence)
	node:runAction(action)
end
--  背包cell 出来效果
-- add by lizy
-- modified by huxiaozhou Tuesday,January 27 2015
-- _cell： 要播放 action 的 cell
-- animatedIndex: 第几个cell
-- fnCallback: 播放完成一个cell的action 后的回调
-- posType 坐标类型 0 绝对坐标， 1 百分比坐标
function startCellAnimation( _cell, animatedIndex ,fnCallback, posType)
	if (_cell == nil) then
		return
	end

	local layCell = _cell
	local posType = posType or 0
	if posType == 0 then
		layCell:setPosition(ccp(layCell:getSize().width, 0))
	else
		layCell:setPositionPercent(ccp(1, 0))
	end

	local moveto = CCMoveTo:create(g_cellAnimateDuration * (animatedIndex), ccp(0,0))
	local func = CCCallFunc:create(fnCallback)
	local actionArray = CCArray:create()
	actionArray:addObject(moveto)
	actionArray:addObject(func)
	local seq = CCSequence:create(actionArray)

	layCell:runAction(seq)
end


--[[
lizy
创建一个button对象并返回，用于创建奖励物品的图标
如果是物品和英雄会有点击事件

参数：
-	reward_type 		奖励类型
-	reward_values		奖励相关数值（表里字段直接传进来）

return button对象
]]
-- 奖励类型 1、贝里,2、将魂,3、金币,4、体力,5、耐力,6、物品,7、多个物品,8、等级*贝里,9、等级*将魂
-- zhangqi, 2015-04-25, 增加海魂类型的处理，将类型判断改为table索引；另外给其他类型加上参数判断
local fnIcon = {}
fnIcon[1] = 1
fnIcon[3] = 2
fnIcon[11] = 3
function getItemIcon(reward_type, reward_values)
	reward_type = tonumber(reward_type)
	local itemIcon

	local fnCreate = fnIcon[reward_type]
	if (fnCreate) then
		itemIcon = fnCreate(reward_values)
	else
		local values = string.split(reward_values, "|")

		local tid = values[1]
		local num = values[2]
		itemIcon = ItemUtil.createBtnByTemplateIdAndNumber(tid, num, function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				PublicInfoCtrl.createItemInfoViewByTid(tid, num)
			end
		end)
	end

	return itemIcon
end

-- lizy 同上，增加获取icon的同时更新数据（金币银币之类）
function getItemIconAndUpdate(reward_type, reward_values)
	reward_type = tonumber(reward_type)
	local itemIcon
	if(reward_type == 1) then
		itemIcon = ItemUtil.getSiliverIconByNum(reward_values)
		UserModel.addSilverNumber(tonumber(reward_values))
		-- elseif(reward_type == 2) then -- zhangqi, 2015-01-09, 已经去经验石，此判断暂无意义
		-- 	itemIcon = ItemUtil.getSoulIconByNum(reward_values)
		-- 	UserModel.addSoulNum(tonumber(reward_values))
	elseif(reward_type == 3) then
		itemIcon = ItemUtil.getGoldIconByNum(reward_values)
		UserModel.addGoldNumber(tonumber(reward_values))
		-- elseif(reward_type == 10) then -- zhangqi, 2015-01-09, 已经去经验石，此判断暂无意义
		-- 	itemIcon = HeroUtil.createHeroIconBtnByHtid(reward_values, nil, function ( sender, eventType )
		-- 		if (eventType == TOUCH_EVENT_ENDED) then
		-- 			AudioHelper.playInfoEffect()
		-- 			PublicInfoCtrl.createHeroInfoView(reward_values)
		-- 		end
		-- 	end)
	else
		local tid = (string.split(reward_values, "|"))[1]
		local num = (string.split(reward_values, "|"))[2]
		itemIcon = ItemUtil.createBtnByTemplateIdAndNumber(tid, num, function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				AudioHelper.playInfoEffect()
				PublicInfoCtrl.createItemInfoViewByTid(tid, num)
			end
		end)
	end

	return itemIcon
end

-- 玩家名字的颜色 -- 常用较qian的配色
function getHeroNameColor1By( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end

-- 玩家名字的颜色 -- 常用较暗的配色
function getHeroNameColor2By( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xa1,0x15,0xb6)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家
		name_color = ccc3(0x00,0x3d,0xc7)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end

--by lizy 20150206 对象播放呼吸特效 2秒标准，1.02倍缩放，
function fnPlayHuxiAni( pBody , pScale , pTime)
	if(not pBody) then
		return
	end
	local nScale = pBody:getScale()
	local m_time = pTime or 1
	local m_scale = pScale or (nScale+0.02)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(m_time, m_scale))
	arr:addObject(CCScaleTo:create(m_time, nScale))
	local pAction = CCRepeatForever:create(CCSequence:create(arr))
	pBody:runAction(pAction)
	return pAction
end

-- add by huxiaozhou 2015-02-06 对象播放 上下浮动动画 应用于装备、宝物 信息装备强化， etc
function runFloatAction( pTarget)
	if pTarget then
		local arrActions = CCArray:create()
		arrActions:addObject(CCMoveBy:create(1.5,ccp(0,20)))
		arrActions:addObject(CCMoveBy:create(1.5,ccp(0,-20)))
		local sequence = CCSequence:create(arrActions)
		local repeatSequence = CCRepeatForever:create(sequence)
		pTarget:runAction(repeatSequence)
	end
end

-- add by wangming 20150227 根据type类型返回宝物或空岛贝对应的类型图片路径
function fnGetConchTypeFilePath( pType )
	local pids = {8,8,6,6,4,1,3,7,7,5,5,5,5,0}
	local n = pids[tonumber(pType)] or 0
	logger:debug("wm----pids ： " .. pType .. n)
	local pString = "images/item/equipinfo/card/trea_type_" .. n .. ".png"
	return pString
end





--[[desc:获取主页面的主船id
    主船改造功能没开启之前，默认id＝ 1，开启之后进入游戏时，从服务器拉取的主船信息在DataCache中。根据DataCache中的数据读DB_Ship表。
    return: 主船id
—]]
function getHomeShipID( )
	require "db/DB_Ship"
	local ship_figure = tonumber(UserModel.getShipFigure())
	if (ship_figure < 1) then
		ship_figure = 1
	end
	local data = DB_Ship.getDataById(ship_figure)
	return data.home_graph
end


--[[desc:获取探索页面主船id
    主船改造功能没开启之前，默认id＝ 1，开启之后进入游戏时，从服务器拉取的主船信息在DataCache中。根据DataCache中的数据读DB_Ship表。
    return: 主船id
—]]
function getExploreShipID( ... )
	require "db/DB_Ship"
	local ship_figure =  tonumber(UserModel.getShipFigure())
	if (ship_figure < 1) then
		ship_figure = 1
	end
	local data = DB_Ship.getDataById(ship_figure)
	return data.explore_graph
end

--[[desc:添加船和浪花特效
    layout:船和浪花要添加的目标层
    ship_id:当前船形象id ，(id=0,1 小木船，id＝2 黄金梅里号)
    tbShipPos:船坐标
    tbShipAnchor:船锚点
    nScale:船和浪花的缩放,传空值默认没有缩放
    nShipTag:船的tag
    nLangHuaTag：浪花的tag
    return: 船动画（返回值 为了兼容mainShip中添加主船后 zOrder调整问题）
—]]
function addShipAnimation( layout,ship_id,tbShipPos,tbShipAnchor,nScale,nShipTag,nLangHuaTag )

	if nShipTag then
		local oldShip = layout:getNodeByTag(nShipTag)
		if (oldShip) then
			oldShip:removeFromParentAndCleanup(true)
		end
	end

	if nLangHuaTag then
		local oldShuiLang = layout:getNodeByTag(nLangHuaTag)
		if (oldShuiLang) then
			oldShuiLang:removeFromParentAndCleanup(true)
		end
	end

	--船动画
	local file_Path = "images/effect/home/zhujiemian_ship.ExportJson"
	local animation_Name = "zhujiemian_ship"

	if tonumber(ship_id) > 1 then
		file_Path = "images/effect/home/zhujiemian_ship" .. tonumber(ship_id) ..".ExportJson"
	end

	local aniShip = UIHelper.createArmatureNode({
		filePath = file_Path,
	})

	aniShip:getAnimation():playWithIndex(0, -1, -1, -1)
	aniShip:setPosition(tbShipPos)
	aniShip:setAnchorPoint(tbShipAnchor)
	layout:addNode(aniShip,0)
	if nShipTag then
		aniShip:setTag(nShipTag)
	end


	local aniShuiLang = UIHelper.createArmatureNode({
		filePath = "images/effect/home/zhujiemian_shuiliang.ExportJson",
		animationName =  "zhujiemian_shuiliang",
	})

	local binder = CCBattleBoneBinder:create()  --用于添加骨骼的容器
	binder:setAnchorPoint(ccp(0.5,0.5))
	binder:setCascadeOpacityEnabled(true)

	local animationBone = aniShip:getBone("ship")
	binder:bindBone(animationBone)
	layout:addNode(binder,1)
	binder:addChild(aniShuiLang)
	if nLangHuaTag then
		binder:setTag(nLangHuaTag)
	end

	nScale = nScale or 1
	aniShip:setScale(nScale)
	aniShuiLang:setScale(nScale)
	aniShuiLang:setPositionY(3)


	return aniShip

end

--获取一个progresstimer对象
function fnGetProgress( imageFile )
	local pImage = imageFile or "ui/conch_progress_blue.png"
	local progressSprite = CCSprite:create(pImage)
	local progress1=CCProgressTimer:create(progressSprite)
	progress1:setType(kCCProgressTimerTypeBar)
	progress1:setMidpoint(ccp(0, 0))
	progress1:setBarChangeRate(ccp(1, 0))
	return progress1
end

--播放获取一个progresstimer对象的升级动画
-- changeTimes 升级次数，
-- stratPercent 起始百分比，
-- finalPercent 最终百分比，
-- callBack 完成的回调
function fnPlayExpChangeAni( progress, changeTimes, stratPercent, finalPercent, callBack )
	local pProgress = progress or nil
	if(not pProgress or not pProgress.setPercentage) then
		if(callBack) then
			callBack()
		end
		return
	end
	local pChangeTimes = tonumber(changeTimes) or 0
	local pStratPercent = tonumber(stratPercent) or 0
	local pFinalPercent = tonumber(finalPercent) or 0

	pProgress:setPercentage(pStratPercent)

	local time1 = 0.05
	local time2 = 0.3
	local time3 = 0.5

	local arr = CCArray:create()
	if(pChangeTimes > 0) then
		for i=1,pChangeTimes do
			arr:addObject(CCProgressTo:create(2*time1 , 100))
			arr:addObject(CCDelayTime:create(time1))
			arr:addObject(CCCallFunc:create(function( ... )
				pProgress:setPercentage(0)
			end))
		end
		arr:addObject(CCProgressTo:create(time2 , pFinalPercent))
	else
		arr:addObject(CCProgressTo:create(time3 , pFinalPercent))
	end

	arr:addObject(CCCallFunc:create(function( ... )
		pProgress:setPercentage(pFinalPercent)
		if(callBack) then
			callBack()
		end
	end))

	pProgress:runAction(CCSequence:create(arr))
end

function fnPlayLR_FlyEff( flyNode, callBack, notRemove )
	local pNode = flyNode or nil
	if(not pNode) then
		if(callBack) then
			callBack()
		end
		return
	end

	local delayTime1 = 0.3
	local delayTime2 = 1.5
	local moveTime = 0.5
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local pSize = runningScene:getContentSize()

	pNode:setVisible(false)
	pNode:setPositionX(pNode:getPositionX() - pSize.width*0.2)
	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(delayTime1))
	actionArr:addObject(CCCallFuncN:create(function ( ... )
		pNode:setVisible(true)
	end))
	local nextPoint = ccp(pNode:getPositionX() + pSize.width*0.2 , pNode:getPositionY())
	actionArr:addObject(CCEaseOut:create(CCMoveTo:create(moveTime, nextPoint),2))
	actionArr:addObject(CCDelayTime:create(delayTime2))
	if(not notRemove) then
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			pNode:setVisible(false)
		end))
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			if(pNode) then
				pNode:removeFromParentAndCleanup(true)
				pNode = nil
			end
		end))
	end
	if(callBack ) then
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			callBack()
		end))
	end

	pNode:runAction(CCSequence:create(actionArr))
end

 
