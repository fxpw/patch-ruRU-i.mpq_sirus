
function CinematicFrame_OnDisplaySizeChanged(self)
	if (self:IsShown()) then
		local width = CinematicFrame:GetWidth();
		local height = CinematicFrame:GetHeight();

		local viewableHeight = width * 9 / 16;
		local worldFrameHeight = WorldFrame:GetHeight();
		local halfDiff = math.max(math.floor((worldFrameHeight - viewableHeight) / 2), 0);

		WorldFrame:ClearAllPoints();
		WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -halfDiff);
		WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, halfDiff);

		local blackBarHeight = math.max(halfDiff, 40);
		UpperBlackBar:SetHeight( blackBarHeight );
		LowerBlackBar:SetHeight( blackBarHeight );
	end
end

function CinematicFrame_OnLoad(self)
	self:RegisterEvent("CINEMATIC_START");
	self:RegisterEvent("CINEMATIC_STOP");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function CinematicFrame_OnShow(self)
	CinematicFrame_OnDisplaySizeChanged(self)
end

function CinematicFrame_OnHide(self)
	WorldFrame:SetAllPoints(nil);
end

function CinematicFrame_OnEvent(self, event, ...)
	if ( event == "CINEMATIC_START" ) then
		EventRegistry:TriggerEvent("CinematicFrame.CinematicStarting");
		ShowUIPanel(self, 1);
		LowHealthFrame:EvaluateVisibleState();
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);
		RaidNotice_Clear(RaidBossEmoteFrame);	--Clear the normal boss emote frame. If there are any messages left over from the cinematic, we don't want to show them.

		LowHealthFrame:EvaluateVisibleState();

		EventRegistry:TriggerEvent("CinematicFrame.CinematicStopped");
	elseif ( event == "DISPLAY_SIZE_CHANGED") then
		CinematicFrame_OnDisplaySizeChanged(self);
	end
end

function CinematicFrame_OnKeyDown(self, key)
	local keybind = GetBindingFromClick(key);
	if ( keybind == "TOGGLEGAMEMENU" ) then
		StopCinematic();
	elseif ( keybind == "SCREENSHOT" or keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" ) then
		RunBinding(keybind);
	end
end

