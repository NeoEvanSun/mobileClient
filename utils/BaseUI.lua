--Filename:BaseUI.lua
--Author：Babeltme
--Date：2013/8/13
--Purpose:创建基本的UI组建

require "script/libs/LuaCCLabel" 

module("BaseUI",package.seeall)


-- 创建一个通用的9格sprite，以 imageFile 为纹理
-- arg: point, 以左上角为原点, 需要保留4角contentSize, 实际需要拉伸的大小
function create9gridBg(imageFile, rectInsets, contentSize)
    local spt = CCSprite:create(imageFile)
    local rect = CCRectMake(0, 0, spt:getContentSize().width, spt:getContentSize().height)  -- imageFile 实际size    
    local bg = CCScale9Sprite:create(imageFile,rect,rectInsets)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setContentSize(contentSize)
    return bg
end


-- 创建一个通用的9格sprite，以 y_9s_bg.png 为纹理 
function createYellowBg(contentSize)
    local rectInsets = CCRectMake(33, 33, 15, 50) --9格中间区域
    return create9gridBg("images/common/bg/y_9s_bg.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 y_9s_bg.png 为纹理 
function createYellowSelectBg(contentSize)
    local rectInsets = CCRectMake(33, 33, 15, 50) --9格中间区域
    return create9gridBg("images/common/bg/y_9s_bg_h.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 viewbg1.png 为纹理 
function createViewBg(contentSize)
    local rectInsets = CCRectMake(100, 80, 10, 20) --9格中间区域
    return create9gridBg("images/common/viewbg1.png", rectInsets, contentSize)
end


-- 创建一个通用的9格sprite，以 bg_ng.png 为纹理 
function createNoBorderViewBg(contentSize)
    local rectInsets = CCRectMake(61, 80, 46, 36) --9格中间区域
    return create9gridBg("images/common/bg/bg_ng.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 menubg.png 为纹理 
function createTopMenuBg(contentSize)
    local rectInsets = CCRectMake(20,20,18,59) --9格中间区域
    return create9gridBg("images/common/menubg.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 bg_ng_attr.png 为纹理 
function createContentBg(contentSize)
    local rectInsets = CCRectMake(30, 30, 15, 10) --9格中间区域
    return create9gridBg("images/common/bg/bg_ng_attr.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 search_bg.png 为纹理 
function createSearchBg(contentSize)
    local rectInsets = CCRectMake(20,20,1,1) --9格中间区域
    return create9gridBg("images/common/bg/search_bg.png", rectInsets, contentSize)
end

-- 创建一个在顶部的分页按钮控件 将使用 common/btn_title_n.png common/btn_title_h.png 来创建
-- nameArray: 存储标题数据的数组 ex:{"name1" ,"name2"} 将创建一个有连个按钮的tabLayer 按钮的分别标题是name1 ,name2
-- normal_font_size,select_font_size, 两种字体状态的大小
-- font_name 字体名称
-- normal_color,select_color两种字体颜色
function createTopTabLayer( nameArray, normal_font_size, select_font_size, font_name, normal_color, select_color )
    local array1 = CCArray:create()
    local array2 = CCArray:create()
    local array3 = CCArray:create()

    for i=1,#nameArray do
        array1:addObject(CCString:create("images/common/btn_title_n.png"))      
        array2:addObject(CCString:create("images/common/btn_title_h.png"))      
        array3:addObject(CCString:create("images/common/btn_title_h.png"))    
    end
    local tabLayer = BTTabLayer:create(array1,array2,array3)
    for i=1,#nameArray do
        local size = tabLayer:buttonOfIndex(i-1):getContentSize()
        -- 投影字体
        local normalLable = LuaCCLabel.createShadowLabel(nameArray[i], font_name ,normal_font_size or 25)
        normalLable:setPosition(size.width/2, size.height/2 - 5)
        normalLable:setAnchorPoint(ccp(0.5, 0.5))
        normalLable:setColor(normal_color or ccc3(255,255,255))
        local tabLayerButton = tolua.cast(tabLayer:buttonOfIndex(i-1),"CCMenuItemSprite")
        tabLayerButton:getNormalImage():addChild(normalLable)

        local selectLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        selectLable:setPosition(size.width/2, size.height/2 - 5)
        selectLable:setAnchorPoint(ccp(0.5, 0.5))
        selectLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getSelectedImage():addChild(selectLable)

        local disableLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        disableLable:setPosition(size.width/2, size.height/2 - 5)
        disableLable:setAnchorPoint(ccp(0.5, 0.5))
        disableLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getDisabledImage():addChild(disableLable)
    end
    return tabLayer
end

-- 创建一个在顶部的分页按钮控件 将使用 common/btn_title_n.png common/btn_title_h.png 来创建
-- nameArray: 存储标题数据的数组 ex:{"name1" ,"name2"} 将创建一个有连个按钮的tabLayer 按钮的分别标题是name1 ,name2
-- normal_font_size,select_font_size, 两种字体状态的大小
-- font_name 字体名称
-- normal_color,select_color两种字体颜色
-- btnContentSize:按钮大小
function createSpriteTopTabLayer( nameArray, normal_font_size, select_font_size, font_name, normal_color, select_color,btnContentSize )
    local array1 = CCArray:create()
    local array2 = CCArray:create()
    local array3 = CCArray:create()

    for i=1,#nameArray do
        local normalSprite  =CCScale9Sprite:create("images/common/btn_title_n.png")
        normalSprite:setContentSize(btnContentSize)
        local selectSprite  =CCScale9Sprite:create("images/common/btn_title_h.png")
        selectSprite:setContentSize(btnContentSize)
        local disableSprite =CCScale9Sprite:create("images/common/btn_title_h.png")
        disableSprite:setContentSize(btnContentSize)

        array1:addObject(normalSprite)      
        array2:addObject(selectSprite)      
        array3:addObject(disableSprite)    
    end
    local tabLayer = BTTabLayer:createWithSpriteArray(array1,array2,array3)
    for i=1,#nameArray do
        local size = tabLayer:buttonOfIndex(i-1):getContentSize()
        -- 投影字体
        -- print("createSpriteTopTabLayer .. " .. nameArray[i])
        local tabLayerButton = tolua.cast(tabLayer:buttonOfIndex(i-1),"CCMenuItemSprite")
        -- print( "tabLayer:buttonOfIndex(i-1) = ", tabLayerButton)
        -- print( "tabLayerButton:getNormalImage() = ",  tabLayerButton:getNormalImage())
        local normalLable = LuaCCLabel.createShadowLabel(nameArray[i], font_name ,normal_font_size or 25)
        normalLable:setPosition(size.width/2, size.height/2 - 5)
        normalLable:setAnchorPoint(ccp(0.5, 0.5))
        normalLable:setColor(normal_color or ccc3(255,255,255))
        tabLayerButton:getNormalImage():addChild(normalLable)


        local selectLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        selectLable:setPosition(size.width/2, size.height/2 - 5)
        selectLable:setAnchorPoint(ccp(0.5, 0.5))
        selectLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getSelectedImage():addChild(selectLable)

        local disableLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        disableLable:setPosition(size.width/2, size.height/2 - 5)
        disableLable:setAnchorPoint(ccp(0.5, 0.5))
        disableLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getDisabledImage():addChild(disableLable)
    end
    return tabLayer
end


--把参数中的所有节点按水平方向排开，并加到一个node上
function createHorizontalNode( node_table )
    local width = 0
    local height = 0
    for k,v in pairs(node_table) do
        width = width + v:getContentSize().width * v:getScaleX()
        if(v:getContentSize().height * v:getScaleY() > height) then
            height = v:getContentSize().height * v:getScaleY()
        end
    end

    local nodeContent = CCNode:create()
    nodeContent:setContentSize(CCSizeMake(width, height))
    local tempWidth = 0
    for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0, 0.5))
        v:setPosition(ccp(tempWidth, 0.5 * height))
        nodeContent:addChild(v)
        tempWidth = tempWidth + v:getContentSize().width * v:getScaleX()
    end
    return nodeContent
end

--创建一个吃touch的半透明layer
--priority : touch 权限级别,默认为-1024
--touchRect: 在touchRect 区域会放行touch事件 若touchRect = nil 则全屏吃touch
--touchCallback: 屏蔽层touch 回调
function createMaskLayer( priority,touchRect ,touchCallback, layerOpacity,highRect)
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
                    return false
                else
                    if(touchCallback ~= nil) then
                        touchCallback()
                    end
                    return true
                end
            end
        end
        print(eventType)
    end,false, priority or -1024, true)

    local gw,gh = g_winSize.width, g_winSize.height
    if(touchRect == nil) then
        local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw,gh)
        layerColor:setPosition(ccp(0,0))
        layerColor:setAnchorPoint(ccp(0,0))
        layer:addChild(layerColor)
        return layer
    else
        local ox,oy,ow,oh = touchRect.origin.x, touchRect.origin.y, touchRect.size.width, touchRect.size.height
        local layerColor = CCLayerColor:create(ccc4(0, 0, 0, layerOpacity or 150 ), gw, gh)
        local clipNode = CCClippingNode:create();
        clipNode:setInverted(true)
        clipNode:addChild(layerColor)

        local stencilNode = CCNode:create()
        -- stencilNode:retain()

        local node = CCScale9Sprite:create("images/guide/rect.png");
        node:setContentSize(CCSizeMake(ow, oh))
        node:setAnchorPoint(ccp(0, 0))
        node:setPosition(ccp(ox, oy))
        stencilNode:addChild(node)

        if(highRect ~= nil) then
            local highNode = CCScale9Sprite:create("images/guide/rect.png");
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

--[[
    @des:       截取当前屏幕图片
    @ret:       截取的图片路径
]]
function getScreenshots( ... )
    local size = CCDirector:sharedDirector():getWinSize()
    local in_texture = CCRenderTexture:create(size.width, size.height,kCCTexture2DPixelFormat_RGBA8888)
    in_texture:getSprite():setAnchorPoint( ccp(0.5,0.5) )
    in_texture:setPosition( ccp(size.width/2, size.height/2) )
    in_texture:setAnchorPoint( ccp(0.5,0.5) )

    local runingScene = CCDirector:sharedDirector():getRunningScene()
    in_texture:begin()
    runingScene:visit()
    in_texture:endToLua()

    local picPath = CCFileUtils:sharedFileUtils():getWritablePath() .. "shareTempScreenshots.jpg"
    print("截屏图片",in_texture:saveToFile(picPath))
    return picPath
end



--create(int tag, const ccColor3B& color, GLubyte opacity, const char* text, const char* fontName, float fontSize);

-- 默认格式 可设置
local tbDefaultStyle =  { ccc3(100,100,100) , 255, "JPangWa" , 20 } 
function  setDefaultStyle( color , opacity , fontName , fontSize )

    return  { color , opacity , fontName , fontSize }
end



--[[
    desc:根据传入的信息生成一个RichElement

    arg1: _text=需要显示的文字  
          _tag=tag值 可以没有  
          _type=格式id 预定义的
          可以根据格式id区分 这个富文本是文本类型还是图片类型

    return: 一个RichElementText对象 
-—]]
function richText( _text, _tag, _type)

    --  color  opacity  fontName  fontSize
    --  预定义的各种文字格式 可以放到GlobalVars.lua中 后期酌情处理
    local tbRichTextStyle = {
        type1 = { ccc3(255,0,0), 255, "STHeitiSC-Medium", 24 , },
        type2 = { ccc3(0,255,0), 255, "STHeitiSC-Medium", 14 , },
    }

    if ( _text == nil ) then
        logger:ERROR("richText : text  == nil")
        return nil
    end

    -- 默认样式
    local m_style = {}
    if (_type == nil) then
        m_style =  tbDefaultStyle 
    else
        m_style =  tbRichTextStyle[_type]
    end

    -- 默认tag
    m_tag = _tag
    if ( _tag == nil ) then
        m_tag = 0
    end

    return RichElementText:create(m_tag , m_style[1], m_style[2] , _text , m_style[3] , m_style[4])

end

-- 文本格式信息
local tbStyleInfo = {}    
local   function exchange( str)
     local _str = string.gsub(str , "%s*" ,  '')  
     _str = string.gsub(_str , "[{}]",'')
    table.insert(tbStyleInfo, tostring(_str))
    return "#"
end



--[[
    参考 testRichText 使用
-—]]
function btRich( string , ...)
    
    arg = {...} 

    local strInfo = {}
    
    logger:debug(arg) 

    require "script/utils/LuaUtil"
    local n_str , num = string.gsub(str , "{%s*%w+%s*}" ,  exchange)    
    
    logger:debug(tbStyleInfo) 

    --用#分割 原始字串
    logger:debug(n_str) 
    local t_str = string.split(n_str , "#")    

     -- text 序列 原始字串和替换字串穿插打入
    for i=1,#arg do 
        table.insert(t_str , i*2, arg[i])
    end
    logger:debug(t_str)

    for i = 1,#tbStyleInfo  do

        logger:debug("i = %d" , i)
        logger:debug(" info = %s  arg %s " , tbStyleInfo[i], arg[i] )

        strInfo[arg[i]] = tbStyleInfo[i]
    end


    logger:debug(strInfo)

    logger:debug("2400 = %s",strInfo[2400])

    local myRichText = RichText:create()
    local tag_num = 0

    for k,v in pairs(t_str) do
    
        logger:debug("for : k:%s v %s" , k,v)
        tag_num = tag_num + 1
        local mytext = nil
        
        if (strInfo[v]) then
            mytext = richText(v , tag_num , strInfo[v])
            if(mytext == nil) then
                debug:ERROR("mytext = nil")
            else
                myRichText:pushBackElement(mytext)
            end
        else 
            mytext = richText(v , tag_num )
            if(mytext == nil) then
                debug:ERROR("mytext = nil")
            else
                myRichText:pushBackElement(mytext)
            end
        end
        
    end
    return myRichText
end

function testRichText( ... )

    local  str =  "卖出物品{ type1}，获得{type2 }金币"
    return btRich(str , "恶魔刀锋" , 2400)
    
end

