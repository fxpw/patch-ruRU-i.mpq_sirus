function SetClampedTextureRotation(texture, rotationDegrees)
	if (rotationDegrees ~= 0 and rotationDegrees ~= 90 and rotationDegrees ~= 180 and rotationDegrees ~= 270) then
		error("SetRotation: rotationDegrees must be 0, 90, 180, or 270");
		return;
	end

	if not (texture.rotationDegrees) then
		texture.origTexCoords = {texture:GetTexCoord()};
		texture.origWidth = texture:GetWidth();
		texture.origHeight = texture:GetHeight();
	end

	if (texture.rotationDegrees == rotationDegrees) then
		return;
	end

	texture.rotationDegrees = rotationDegrees;

	if (rotationDegrees == 0 or rotationDegrees == 180) then
		texture:SetWidth(texture.origWidth);
		texture:SetHeight(texture.origHeight);
	else
		texture:SetWidth(texture.origHeight);
		texture:SetHeight(texture.origWidth);
	end

	if (rotationDegrees == 0) then
		texture:SetTexCoord( texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[7], texture.origTexCoords[8] );
	elseif (rotationDegrees == 90) then
		texture:SetTexCoord( texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[5], texture.origTexCoords[6] );
	elseif (rotationDegrees == 180) then
		texture:SetTexCoord( texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[1], texture.origTexCoords[2] );
	elseif (rotationDegrees == 270) then
		texture:SetTexCoord( texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[3], texture.origTexCoords[4] );
	end
end

function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
end

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;

	if ( role == "GUIDE" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGER" ) then
		return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "RANGEDAMAGER" ) then
		return GetTexCoordsByGrid(3, 3, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Unknown role: "..tostring(role));
	end
end

function GetTexCoordsForRoleSmallCircle(role)
	if ( role == "TANK" ) then
		return 0, 19/64, 22/64, 41/64;
	elseif ( role == "HEALER" ) then
		return 20/64, 39/64, 1/64, 20/64;
	elseif ( role == "DAMAGER" ) then
		return 20/64, 39/64, 22/64, 41/64;
	else
		error("Unknown role: "..tostring(role));
	end
end

function GetTexCoordsForRoleSmall(role)
	if ( role == "TANK" ) then
		return 0.5, 0.75, 0, 1;
	elseif ( role == "HEALER" ) then
		return 0.75, 1, 0, 1;
	elseif ( role == "DAMAGER" ) then
		return 0.25, 0.5, 0, 1;
	else
		error("Unknown role: "..tostring(role));
	end
end

function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom)
	return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(
		  file
		, height
		, width
		, fileWidth
		, fileHeight
		, left * fileWidth
		, right * fileWidth
		, top * fileHeight
		, bottom * fileHeight
	);
end

function CreateAtlasMarkup(atlasName, width, height, offsetX, offsetY, fileWidth, fileHeight)
	if S_ATLAS_STORAGE[atlasName] then
		local atlasWidth, atlasHeight, left, right, top, bottom, _, _, texturePath = unpack(S_ATLAS_STORAGE[atlasName])
		width = width or atlasWidth
		height = height or atlasHeight
		return ("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"):format(
			  texturePath
			, width
			, height
			, offsetX
			, offsetY
			, fileWidth
			, fileHeight
			, math.ceil(left * fileWidth)
			, math.ceil(right * fileWidth)
			, math.ceil(top * fileHeight)
			, math.ceil(bottom * fileHeight)
		);
	else
		return ""
	end
end

function GetFinalNameFromTextureKit(fmt, textureKit)
	return fmt:format(textureKit);
end