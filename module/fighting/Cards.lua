--游戏中的麻将
module("Cards", package.seeall)

local sprite
local face

function destroy(...)
    package.loaded["Cards"] = nil
end

function reloadSource()
    local plistCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    -- print("SpriteFramesManager add:",plist,image)
    plistCache:addSpriteFramesWithFile(tpPath,ttPath)
    require "script/battle/data/SpriteFramesManager"
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
    -- BattleLayerManager.battleNumberLayer:addChild(frameSprite)
    return frameSprite
end

-- @spriteName 麻将块图片名称
-- @faceName 麻将牌面图片名称
-- @size 麻将的尺寸
function create(spriteName, faceName, size)
	local cardLayer = CCLayer:create()
	sprite = getWord(spriteName)
	cardLayer:addNode(sprite)
	if faceName ~= nil then
		face = getWord(faceName)
		cardLayer:addNode(face)
	end
	return cardLayer
end