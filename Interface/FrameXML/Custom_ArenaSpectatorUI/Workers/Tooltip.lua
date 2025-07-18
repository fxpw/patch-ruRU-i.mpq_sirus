ezSpectator_TooltipWorker = {}
ezSpectator_TooltipWorker.__index = ezSpectator_TooltipWorker

function ezSpectator_TooltipWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_TooltipWorker)

    self.Parent = Parent

    self.MainFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.MainFrame:SetFrameStrata('TOOLTIP')
    self.MainFrame:SetFrameLevel(100500)

    self.TooltipFrame = CreateFrame('GameTooltip', 'ezSpectator_DataWorkerTooltip', self.MainFrame, 'GameTooltipTemplate')

    self.ReactorFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.ReactorFrame:SetFrameStrata('TOOLTIP')
    self.ReactorFrame:SetFrameLevel(100500)
    self.ReactorFrame:EnableMouse(true)
    self.ReactorFrame.Parent = self

    return self
end

function ezSpectator_TooltipWorker:HideTooltipFrame()
    self.TooltipFrame:Hide()
end

function ezSpectator_TooltipWorker:ShowText(tooltipOwner, title, lineText)
    self.ReactorFrame:Hide()

	local isLeft = GetCursorPosition() < (GetScreenWidth() * UIParent:GetEffectiveScale() / 2)
	if isLeft then
		self.TooltipFrame:SetOwner(tooltipOwner, "ANCHOR_TOPLEFT")
	else
		self.TooltipFrame:SetOwner(tooltipOwner, "ANCHOR_TOPRIGHT")
	end

	if title then
		self.TooltipFrame:SetText(title)
	end

	if type(lineText) == "table" then
		for _, lineText in ipairs(lineText) do
			self.TooltipFrame:AddLine(lineText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		end
	elseif type(lineText) == "string" then
		self.TooltipFrame:AddLine(lineText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
	end

    self:Stylize()
    self.TooltipFrame:Show()
end

function ezSpectator_TooltipWorker:ShowSpell(tooltipOwner, spellID, noReactorFrame)
	if not noReactorFrame then
		self.ReactorFrame:Hide()
		self.ReactorFrame:ClearAllPoints()
		self.ReactorFrame:SetAllPoints(tooltipOwner)

		self.ReactorFrame:SetScript("OnLeave", function(this)
			self.TooltipFrame:Hide()

			this:Hide()
			this:SetScript("OnLeave", nil)
		end)
		self.ReactorFrame:Show()
	end

	local isLeft = GetCursorPosition() < (GetScreenWidth() * UIParent:GetEffectiveScale() / 2)
	if isLeft then
		self.TooltipFrame:SetOwner(tooltipOwner, "ANCHOR_TOPLEFT")
	else
		self.TooltipFrame:SetOwner(tooltipOwner, "ANCHOR_TOPRIGHT")
	end

	self.TooltipFrame:SetHyperlink(strconcat("spell:", spellID))
	self.TooltipFrame:AddLine(" ")
	self.TooltipFrame:AddDoubleLine("Spell ID: " .. spellID, "", 0.4, 0.4, 0.4)

    self:Stylize()
    self.TooltipFrame:Show()
end

function ezSpectator_TooltipWorker:Stylize()
    self.TooltipFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = 'Interface\\Custom\\ArenaSpectator\\TooltipEdge',
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })

    self.TooltipFrame:SetBackdropColor(0, 0, 0, 1)
end