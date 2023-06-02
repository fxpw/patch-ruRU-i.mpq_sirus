--	Filename:	C_Texture.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

C_Texture = {}

local CONST_ATLAS_WIDTH			= 1
local CONST_ATLAS_HEIGHT		= 2
local CONST_ATLAS_LEFT			= 3
local CONST_ATLAS_RIGHT			= 4
local CONST_ATLAS_TOP			= 5
local CONST_ATLAS_BOTTOM		= 6
local CONST_ATLAS_TILESHORIZ	= 7
local CONST_ATLAS_TILESVERT		= 8
local CONST_ATLAS_TEXTUREPATH	= 9

function C_Texture.GetAtlasInfo(atlasName)
	if not atlasName then
		error("C_Texture.GetAtlasInfo: AtlasName must be specified", 2)
	elseif not S_ATLAS_STORAGE[atlasName] then
		error(string.format("C_Texture.GetAtlasInfo: Atlas named %s does not exist", atlasName), 2)
	end

	local atlas = S_ATLAS_STORAGE[atlasName]
	local AtlasInfo = {}

	AtlasInfo.width 			= atlas[CONST_ATLAS_WIDTH]
	AtlasInfo.height 			= atlas[CONST_ATLAS_HEIGHT]
	AtlasInfo.leftTexCoord 		= atlas[CONST_ATLAS_LEFT]
	AtlasInfo.rightTexCoord 	= atlas[CONST_ATLAS_RIGHT]
	AtlasInfo.topTexCoord 		= atlas[CONST_ATLAS_TOP]
	AtlasInfo.bottomTexCoord 	= atlas[CONST_ATLAS_BOTTOM]
	AtlasInfo.tilesHorizontally = atlas[CONST_ATLAS_TILESHORIZ]
	AtlasInfo.tilesVertically 	= atlas[CONST_ATLAS_TILESVERT]
	AtlasInfo.filename 			= atlas[CONST_ATLAS_TEXTUREPATH]

	return AtlasInfo
end