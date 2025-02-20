NPE_TutorialPointerFrame = {};
SIRUS_TUTORIAL_KEY = {}

NPE_TutorialPointerFrame.Direction = {
	UP		= "UP",
	DOWN	= "DOWN",
	LEFT	= "LEFT",
	RIGHT	= "RIGHT",
}

NPE_TutorialPointerFrame.DirectionData = {
	UP = {
		Anchor			= "TOP";
		RelativePoint	= "BOTTOM";
		ContentOffsetY	= 5;
		Opposite		= "DOWN";
	},
	DOWN = {
		Anchor			= "BOTTOM";
		RelativePoint	= "TOP";
		ContentOffsetY	= -5;
		Opposite		= "UP";
	},
	LEFT = {
		Anchor			= "LEFT";
		RelativePoint	= "RIGHT";
		ContentOffsetX	= -5;
		Opposite		= "RIGHT";
	},
	RIGHT = {
		Anchor			= "RIGHT";
		RelativePoint	= "LEFT";
		ContentOffsetX	= 5;
		Opposite		= "LEFT";
	},
}

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:Initialize()
	self.NextID = 1;
	self.FramePool = {};
	self.InUseFrames = {};
	self.FrameCount = 0;
	self.disableContent = {}
end

function NPE_TutorialPointerFrame:SetKey(key, value)
	local name = UnitName("player")
	if SIRUS_TUTORIAL_KEY and not SIRUS_TUTORIAL_KEY[name] then
		SIRUS_TUTORIAL_KEY[name] = {}
	end

	SIRUS_TUTORIAL_KEY[name][key] = value
end

function NPE_TutorialPointerFrame:GetKey(key)
	local name = UnitName("player")
	if SIRUS_TUTORIAL_KEY[UnitName("player")] then
		return SIRUS_TUTORIAL_KEY[name][key]
	end
end

function NPE_TutorialPointerFrame:Disable(content)
	forceinsecure()
	self.disableContent[content] = true
end

function NPE_TutorialPointerFrame:Enable(content)
	forceinsecure()
	self.disableContent[content] = false
end

-- ------------------------------------------------------------------------------------------------------------
-- @Usage NPE_TutorialPointerFrame:Show(content, direction, frame, ofsX, ofsY [,relativePoint])
function NPE_TutorialPointerFrame:Show(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, modelData, width, closeButtonCallback, onReleaseCallback)
	if self.disableContent[content] then
		return
	end

	ofsX = ofsX or 0;
	ofsY = ofsY or 0;

	-- Must have a valid anchor frame
	if (not anchorFrame) then
		error("NPE_TutorialPointerFrame:Show - Invalid Anchor Frame");
		return 0;
	end

	-- Must have a valid direction
	local directionData = self.DirectionData[direction];
	if (not directionData) then
		error(string.format("NPE_TutorialPointerFrame:Show - Invalid Direction '%s'", direction));
		return 0;
	end

	-- Grab the frame
	local frame = self:_GetFrame(anchorFrame);

	-- Make sure there's enough room for the frame
	local fits, newDirection = self:_DoesFrameFit(frame, anchorFrame, directionData);
	if (not fits) then
		if (backupDirection and (self.DirectionData[backupDirection])) then
			direction = backupDirection;
			directionData = self.DirectionData[backupDirection];

			ofsX = 0;
			ofsY = 0;
		else
			direction = newDirection;
			directionData = self.DirectionData[newDirection];

			if ((directionData == self.DirectionData.UP) or (directionData == self.DirectionData.DOWN)) then
				ofsY = -ofsY;
			else
				ofsX = -ofsX;
			end
		end
	end

	width = width or 240
	frame.Content:SetWidth(width)
	frame.Content.Text:SetWidth(width - 40)

	-- Anchor the frame
	frame:ClearAllPoints();
	frame:SetPoint(directionData.Anchor, anchorFrame, relativePoint or directionData.RelativePoint, ofsX, ofsY);

	-- Set the content
	frame.Content:ClearAllPoints();
	frame.Content:SetPoint(directionData.Anchor, frame, directionData.RelativePoint, directionData.ContentOffsetX or 0, directionData.ContentOffsetY or 0);
	frame.Content.Text:SetText(content);

	-- Set the frame size based on the text size
	frame.Content:SetHeight(frame.Content.Text:GetHeight() + 40);

	-- ----------------------------------
	-- Animation

	-- First arrow
	frame["Arrow_" .. direction .. 1]:Show();
	frame["Arrow_" .. direction .. 1].Anim:Play();

	-- Second arrow starts half way through the first arrow's animation (1 second)
	frame.AnimDelayTimer = C_Timer:After(0.5, function()
			frame["Arrow_" .. direction .. 2]:Show();
			frame["Arrow_" .. direction .. 2].Anim:Play();
		end)
	-- ----------------------------------

	local model = frame.Model

	if model then
		if modelData then
			local creatureID, rotation, anchor, relativePoint, offsetX, offsetY, width, height, scale = unpack(modelData)

			model:SetWidth(width)
			model:SetHeight(height)

			model:ClearAllPoints()
			model:SetPoint(anchor, frame.Content, relativePoint, offsetX, offsetY)

			model:SetCreature(creatureID)
			model:SetRotation(rotation)
			model:SetModelScale(scale)
		end

		model:SetShown(modelData)
	end

	if type(closeButtonCallback) == "function" then
		frame.CloseButton:SetScript("OnClick", function()
			frame:Hide()
			closeButtonCallback()
		end)
		frame.CloseButton:Show()
	else
		frame.CloseButton:SetScript("OnClick", nil)
		frame.CloseButton:Hide()
	end

	frame.onReleaseCallback = onReleaseCallback

	frame:Show();

	local id = self.NextID;
	self.InUseFrames[id] = frame;
	self.NextID = self.NextID + 1;

	return id;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:Hide(id)
	local frame = self.InUseFrames[id];
	if (frame) then
		self.InUseFrames[id] = nil;
		self:_RetireFrame(frame);
	end
end

function NPE_TutorialPointerFrame:HideAll()
	for k, v in pairs(self.InUseFrames) do
		self.InUseFrames[k] = nil
		self:_RetireFrame(v)
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:_DoesFrameFit(frame, anchorFrame, directionData)
	local size;
	local getEdgeFunc;

	if (directionData == self.DirectionData.UP) then
		size = self:_GetTotalEffectiveHeight(frame);
		getEdgeFunc = UIParent.GetBottom;

	elseif (directionData == self.DirectionData.DOWN) then
		size = self:_GetTotalEffectiveHeight(frame);
		getEdgeFunc = UIParent.GetTop;

	elseif (directionData == self.DirectionData.LEFT) then
		size = self:_GetTotalEffectiveWidth(frame);
		getEdgeFunc = UIParent.GetRight;

	elseif (directionData == self.DirectionData.RIGHT) then
		size = self:_GetTotalEffectiveWidth(frame);
		getEdgeFunc = UIParent.GetLeft;
	end

	local uiParentEdge = getEdgeFunc(UIParent);
	local anchorFrameEdge = getEdgeFunc(anchorFrame);

	-- if layout isn't complete for either frame, we have to continue positioning anyway.
	-- In this case, assume it can fit (QA should find any one-off places where it doesnt)
	if ((not uiParentEdge) or (not anchorFrameEdge)) then
		return true;
	end

	if (size > math.abs(uiParentEdge - anchorFrameEdge)) then
		return false, directionData.Opposite;
	end

	return true;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:_GetTotalEffectiveHeight(frame)
	return (frame:GetHeight() + frame.Content:GetHeight()) * frame:GetEffectiveScale();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:_GetTotalEffectiveWidth(frame)
	return (frame:GetWidth() + frame.Content:GetWidth()) * frame:GetEffectiveScale();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:_GetFrame(parentFrame)
	local frame;

	if (#self.FramePool > 0) then
		frame = table.remove(self.FramePool);
	else
		self.FrameCount = self.FrameCount + 1;
		frame = CreateFrame("frame", "NPE_PointerFrame_" .. self.FrameCount, UIParent, "TutorialPointerFrame");
	end

	if (not parentFrame.hasHookedScriptsForNPE) then
		parentFrame:HookScript("OnShow", function (self)
			if (self.currentNPEPointer) then
				self.currentNPEPointer:Show();
			end
		end);

		parentFrame:HookScript("OnHide", function (self)
			if (self.currentNPEPointer) then
				self.currentNPEPointer:Hide();
			end
		end);

		parentFrame.hasHookedScriptsForNPE = true;
	end

	parentFrame.currentNPEPointer = frame;
	frame.currentTarget = parentFrame;

	return frame;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialPointerFrame:_RetireFrame(frame)

	if type(frame.onReleaseCallback) == "function" then
		local success, err = pcall(frame.onReleaseCallback, frame)
		if not success then
			geterrorhandler()(err)
		end
		frame.onReleaseCallback = nil
	end

	-- TODO: fade the frame out?
	frame:Hide();

	frame.currentTarget.currentNPEPointer = nil;
	frame.currentTarget = nil;

	-- Stop all animations
	frame.AnimDelayTimer:Cancel();
	for k, direction in pairs(NPE_TutorialPointerFrame.Direction) do
		for i = 1, 2 do
			local arrow = frame["Arrow_" .. direction .. i];
			arrow:Hide();
			arrow.Anim:Stop();
		end
	end

	-- Return the fame to the pool
	table.insert(self.FramePool, frame);
end

-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialPointerFrame:Initialize();