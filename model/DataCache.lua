-- Filename：	DataCache.lua
-- Author：		lizy
-- Date：		2016-5-09
-- Purpose：		数据中心


module ("DataCache", package.seeall)
-- require "script/utils/LuaUtil"
-- require "script/module/public/ItemUtil"
-- require "script/module/bag/BagUtil"
-- require "db/DB_Vip"
-- require "db/DB_Formation"

local _userInfo			= nil  --用户信息
local _rules -- 房间玩法集合

local tpPath = "n_ui/cards.plist"
local ttPath = "n_ui/cards.png"

-- 储存麻将的数组
-- 我这边的麻将
local myCards = {}
-- 我这边打出的麻将
local myOutCards = {}
-- 左边打出的麻将
local leftOutCards = {}
-- 右边打出的麻将
local rightOutCards = {}
function mabiao( ... )
    local x = 1
end
function reloadSource()
    local plistCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    -- print("SpriteFramesManager add:",plist,image)
    plistCache:addSpriteFramesWithFile(tpPath,ttPath)
    require "script/module/fighting/SpriteFramesManager"
    SpriteFramesManager.add(tpPath,ttPath)
end

function getWord( word )
   local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
 
   local frameData = cache:spriteFrameByName(word)
    if(word == nil or frameData == nil) then 
    	reloadSource()
          frameData = cache:spriteFrameByName(word)
          if(word == nil or frameData == nil) then 
            error("CCSpriteFrame can't find :" .. word) 
          end
    end -- if end
    -- print("getWord:",words .. tostring(word))
    local frameSprite = CCSprite:create()
     
    frameSprite:setDisplayFrame(frameData)
    frameSprite:setAnchorPoint(ccp(0.5, 0.5))
    frameSprite:setCascadeOpacityEnabled(true)
    if tolua.cast(frameSprite,"CCSprite") == nil then
      print("本来就是空的")
    end
    return frameSprite
end

function getUserInfo( ... )
	return _userInfo
end

function setUserInfo(  userInfo )
	_userInfo = userInfo
 
end

function getRules( ... )
	return _userInfo
end

function setRules(  rules )
	_rules = rules
 
end

function getMyCards( index )
	return myCards[index]
end

function getMyOutCards( index )
	return myOutCards[index]
end

function getLeftOutCards( index )
	return leftOutCards[index]
end

function getRightOutCards( index )
	return rightOutCards[index]
end

function getUpOutCards( index )
	return myOutCards[index]
end

-- 返回牌面名称
-- @param head 图片头字符串 传入"c_" "c_l_" "c_r_"
-- @param index 序号
function retFaceName( head , index)
	local imageName
	local row = math.floor(index / 10)
	 local col = index % 10
     -- 去除中间分隔的"0"
     if col ~= 0 and i~= 37 then
      if row == 0 then 
        -- 第一行，条 c_31~c_39
	    imageName = head.."3"..col..".png"
      end
      if row == 1 then
        -- 第二行，筒 c_21~c_29
	    imageName = head.."2"..col..".png"
      end
      if row == 2 then
        -- 第三行 万 c_11~c_19
        imageName = head.."1"..col..".png"
      end
      if row == 3 then
        -- 第四行
        imageName = head.."4"..col..".png"
      end
	 end
	 if imageName ~= nil then
		 print("--11--"..imageName)
	 end
     return imageName
end

-- 万 c_11~c_19
-- 筒 c_21~c_29
-- 条 c_31~c_39
-- 东 c_41
-- 南 c_42
-- 西 c_43
-- 北 c_44
-- 中 c_45
-- 储存服务器返回的牌数组 条 筒 万
-- 创建我方的牌
function createMyCards( ... )
	for i=1,37 do
	  local cardsBase = getWord("b_04.png")
	  cardsBase:setTag(i)
	  -- local outCardsBase = getWord("b_07.png")

	  -- local currentName = retFaceName("c_",i)
	  -- if currentName ~= nil then
	  	-- local cardsFace = getWord(currentName)
		-- cardsBase:addChild(cardsFace)
		-- outCardsBase:addChild(cardsFace)
  	  -- end
  	  table.insert(myCards,i,tolua.cast(cardsBase,"CCSprite"))
  	  -- table.insert(myOutCards,i,outCardsBase)
	end
end

function createLeftOutCards( ... )
	for i=1,37 do
	  -- local outCardsLayer = CCLayer:create()
	  local cardsBase = getWord("b_02_2.png")

	  local currentName = retFaceName("c_l_",i)
	  if currentName ~= nil then
	  	local cardsFace = getWord(currentName)
		cardsBase:addChild(cardsFace)
	  end
	  table.insert(leftOutCards,i,cardsBase)
	end
end

function createRightOutCards( ... )
	for i=1,37 do
	  -- local outCardsLayer = CCLayer:create()
	  local cardsBase = getWord("b_02.png")

	  local currentName = retFaceName("c_r_",i)
	  if currentName ~= nil then
	  	local cardsFace = getWord(currentName)
	    cardsBase:addChild(cardsFace)
	  end
	  table.insert(rightOutCards,i,cardsBase)
	end
end

function createCards( ... )
	createMyCards()
	-- createRightOutCards()
	-- createLeftOutCards()
	return true
end







