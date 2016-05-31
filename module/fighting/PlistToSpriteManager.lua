--游戏中的plist文件转成Sprite工具
module("PlistToSpriteManager", package.seeall)

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

function destroy(...)
    package.loaded["PlistToSpriteManager"] = nil
end

function change(name)
	local sprite = getWord(name)
	return sprite
end