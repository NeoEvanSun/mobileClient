
module ("SpriteFramesManager",package.seeall)


local sprites = {}
local addAnimations = {}

function add(plist,image)
	local imgIns = CCTextureCache:sharedTextureCache():textureForKey(image)
	if(sprites[plist] == nil or imgIns == nil) then
		local plistCache = CCSpriteFrameCache:sharedSpriteFrameCache()
		-- print("SpriteFramesManager add:",plist,image)
		plistCache:addSpriteFramesWithFile(plist,image)
	 	sprites[plist] = image
	 	-- imgIns = CCTextureCache:sharedTextureCache():textureForKey(image)
	 	-- if(imgIns) then
	 	-- 	imgIns:retain()
	 	-- end
	end
end


function release( ... )

	for plist,image in pairs(sprites or {}) do

		imgIns = CCTextureCache:sharedTextureCache():textureForKey(image)
		-- if(imgIns and )
	 	if(imgIns ~= nil and not tolua.isnull(imgIns) and imgIns:retainCount() > 0) then
	 		-- imgIns:release()
	 		CCTextureCache:sharedTextureCache():removeTexture(imgIns)
	 	end
	 	-- Logger.debug("-- SpriteFramesManager remove:".. tostring(image) .. "  " ..tostring(plist))
	 	 CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plist)
	end
	sprites = {}
end

-- function addAnimation( json,plist,image )
	
-- 	local imgIns = CCTextureCache:sharedTextureCache():textureForKey(image)
-- 	if(addAnimations[json] == nil or imgIns == nil) then
-- 		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(image, plist ,json );
-- 	 	addAnimations[json] = {plist,image}
-- 	end

-- end

-- function checkPlist(plist,checkValue)
-- 	if(sprites[plist]) then
-- 		local img = sprites[plist][1]
-- 		local imgIns = CCTextureCache:sharedTextureCache():textureForKey(img)
-- 		return imgIns ~= nil
-- 	end
-- 	return false
-- end

