local S_ATLAS_STORAGE = S_ATLAS_STORAGE

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
	if type(atlasName) ~= "string" then
		error("Usage: C_Texture.GetAtlasInfo(\"atlasName\")", 2)
	end

	local atlas = S_ATLAS_STORAGE[atlasName]
	if not atlas then
		error(string.format("C_Texture.GetAtlasInfo: Atlas %s does not exist", atlasName), 2)
	end

	return {
		width 				= atlas[CONST_ATLAS_WIDTH],
		height 				= atlas[CONST_ATLAS_HEIGHT],
		leftTexCoord 		= atlas[CONST_ATLAS_LEFT],
		rightTexCoord 		= atlas[CONST_ATLAS_RIGHT],
		topTexCoord 		= atlas[CONST_ATLAS_TOP],
		bottomTexCoord 		= atlas[CONST_ATLAS_BOTTOM],
		tilesHorizontally	= atlas[CONST_ATLAS_TILESHORIZ],
		tilesVertically 	= atlas[CONST_ATLAS_TILESVERT],
		filename 			= atlas[CONST_ATLAS_TEXTUREPATH],
	}
end