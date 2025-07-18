ezSpectator_ClickIcon = {}
ezSpectator_ClickIcon.__index = ezSpectator_ClickIcon

local ICON_ATLASES = {
	["backward"]	= {"Custom-ArenaSpectator-Icon-Backward", 12},
	["exit"]		= {"Custom-ArenaSpectator-Icon-Exit", 10},
	["Eye_Normal"]	= {"Custom-ArenaSpectator-Icon-Eye-Normal", 18},
	["Eye_Stroked"]	= {"Custom-ArenaSpectator-Icon-Eye-Stroked", 18},
	["forward"]		= {"Custom-ArenaSpectator-Icon-Forward", 12},
	["Logout"]		= {"Custom-ArenaSpectator-Icon-Logout", 14},
	["pause"]		= {"Custom-ArenaSpectator-Icon-Pause", 12},
	["play"]		= {"Custom-ArenaSpectator-Icon-Play", 12},
	["Plus"]		= {"Custom-ArenaSpectator-Icon-Plus", 10},
	["Refresh"]		= {"Custom-ArenaSpectator-Icon-Refresh", 10},
	["report"]		= {"Custom-ArenaSpectator-Icon-Report", 10},
	["settings"]	= {"Custom-ArenaSpectator-Icon-Settings", 10},
	["share"]		= {"Custom-ArenaSpectator-Icon-Share", 12},
}

function ezSpectator_ClickIcon:Create(Parent, parentFrame, Style, Size, ...)
    local self = {}
    setmetatable(self, ezSpectator_ClickIcon)

	if not parentFrame then
		parentFrame = ArenaSpectatorFrame
	end

    self.Parent = Parent

    self.Action = nil
    self.IsTextInteractive = false

	self.Backdrop = CreateFrame("Frame", nil, parentFrame)
    self.Backdrop:SetFrameLevel(1)
    self.Backdrop:SetFrameStrata('HIGH')
    self.Backdrop:SetSize(Size, Size)
    self.Backdrop:SetScale(_ezSpectatorScale)
    self.Backdrop:SetPoint(...)

	self.Backdrop.texture = self.Backdrop:CreateTexture(nil, "BACKGROUND")
	self.Backdrop.texture:SetAllPoints()
	self.Backdrop.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Backdrop", true)

	self.Normal = CreateFrame("Frame", nil, parentFrame)
    self.Normal:SetFrameLevel(4)
    self.Normal:SetFrameStrata('HIGH')
    self.Normal:SetSize(Size, Size)
    self.Normal:SetScale(_ezSpectatorScale)
    self.Normal:SetPoint(...)

	self.Normal.texture = self.Normal:CreateTexture(nil, "BACKGROUND")
	self.Normal.texture:SetAllPoints()

	self.Highlight = CreateFrame("Frame", nil, parentFrame)
    self.Highlight:SetFrameLevel(5)
    self.Highlight:SetFrameStrata('HIGH')
    self.Highlight:SetSize(Size, Size)
    self.Highlight:SetScale(_ezSpectatorScale)
    self.Highlight:SetPoint(...)
    self.Highlight:Hide()

	self.Highlight.texture = self.Highlight:CreateTexture(nil, "BACKGROUND")
	self.Highlight.texture:SetAllPoints()

    local StyleColor, StyleMode = strsplit('|', Style)
    if not StyleColor then
        StyleColor = Style
    end

    local OffsetX = 0
    local OffsetY = 0
    if StyleColor == 'gold' then
		self.Normal.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Normal-Gold", true)
		self.Highlight.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Highlight-Gold", true)
    elseif StyleColor == 'silver' then
		self.Normal.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Normal-Silver", true)
		self.Highlight.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Highlight-Silver", true)
        OffsetY = 0.5
    elseif StyleColor == 'mild' then
		self.Backdrop.texture:SetTexture(nil)
		self.Normal.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Normal-Mild", true)
		self.Highlight.texture:SetAtlas("Custom-ArenaSpectator-ClickIcon-Highlight-Mild", true)
        OffsetX = -0.5
        OffsetY = 0.5
    elseif StyleColor == 'clear' then
		self.Backdrop.texture:SetTexture(nil)
    end

    self.IsToggleMode = StyleMode == 'toggle'
    self.IsToggleUp = nil
    if self.IsToggleMode then
        self.IsToggleUp = true
    end

    self.Icon = CreateFrame('Frame', nil, self.Backdrop)
    self.Icon:SetFrameLevel(2)
    self.Icon:SetFrameStrata('HIGH')
    self.Icon:SetSize(Size, Size)
    self.Icon:SetScale(_ezSpectatorScale)
    self.Icon:SetPoint('CENTER', self.Normal, 'CENTER', OffsetX, OffsetY)

	self.Icon.texture = self.Icon:CreateTexture(nil, "BACKGROUND")
	self.Icon.texture:SetAllPoints()

    self.TextIcon = self.Backdrop:CreateFontString(nil, 'BACKGROUND', 'PVPInfoTextFont')
    self.TextIcon:SetSize(Size, Size)
    self.TextIcon:SetPoint('CENTER', self.Normal, 'CENTER', 0.5, -0.5)

    self.Cooldown = CreateFrame('Frame', nil, self.Icon, "CustomCooldownFrameTemplate")
	self.Cooldown:UseArenaSpectatorTimescale(true)
    self.Cooldown:SetFrameLevel(3)
    self.Cooldown:SetFrameStrata('HIGH')
    self.Cooldown:SetSize(Size, Size)
    self.Cooldown:SetPoint('CENTER', self.Normal, 'CENTER', OffsetX, OffsetY)

	if self.Parent.HIDE_COOLDOWN_ANIMATION then
		self.Cooldown:SetAlpha(0)
	end
    -- self.Cooldown:SetDrawEdge(true)

	self.TextFrame = CreateFrame("Frame", nil, parentFrame)
    self.TextFrame:SetFrameStrata('TOOLTIP')
    self.TextFrame:SetSize(1, 1)
    self.TextFrame:SetPoint('TOP', self.Normal, 'BOTTOM', 0, 5)

    self.Text = self.TextFrame:CreateFontString(nil, 'OVERLAY')
    self.Text:SetFont('Interface\\CustomFonts\\DejaVuSans.ttf', 8, 'OUTLINE')
    self.Text:SetTextColor(1, 1, 1, 1)
    self.Text:SetShadowColor(0, 0, 0, 0.75)
    self.Text:SetShadowOffset(0, 1)
    self.Text:SetPoint('CENTER', 0, 1)

	self.Reactor = CreateFrame("Frame", nil, parentFrame)
    self.Reactor:SetFrameStrata('TOOLTIP')
    self.Reactor:SetSize(Size, Size)
    self.Reactor:SetScale(_ezSpectatorScale)
    self.Reactor:SetPoint(...)

    self.Reactor.Parent = self
    self.Reactor:EnableMouse(true)
    self.Reactor:SetScript('OnEnter', function()
        if self.tooltipHeader or self.tooltipText then
            self.Parent.Tooltip:ShowText(self.Reactor, self.tooltipHeader, self.tooltipText)
        end

        if self.Backdrop:IsShown() and not self.IsTextInteractive and not self.disable then
            self.Normal:Hide()
            self.Highlight:Show()
        end
    end)
    self.Reactor:SetScript('OnLeave', function()
        self.Parent.Tooltip:HideTooltipFrame()

        if self.Backdrop:IsShown() and not self.IsTextInteractive and not self.disable then
            self.Highlight:Hide()
            self.Normal:Show()
        end
    end)
    self.Reactor:SetScript('OnUpdate', function()
        if self.IsTextInteractive and not self.disable then
			local uiEffectiveScale = UIParent:GetEffectiveScale()
            local OffsetX, OffsetY, Width, Height = self.Icon:GetBoundsRect()
			OffsetX = OffsetX * 1.5 / uiEffectiveScale
			OffsetY = OffsetY * 1.5 / uiEffectiveScale

            local CenterX = OffsetX + Width / 2
            local CenterY = OffsetY + Height / 2

            local CursorX, CursorY =  GetCursorPosition()
			CursorX = CursorX / uiEffectiveScale
			CursorY = CursorY / uiEffectiveScale

            local DiffX = abs(CenterX - CursorX)
            local DiffY = abs(CenterY - CursorY)

            local Distance = math.sqrt(DiffX * DiffX + DiffY * DiffY)

            self.TextFrame:SetAlpha(math.max(1 - Distance / 200, 0.66))
        end
    end)

    return self
end

function ezSpectator_ClickIcon:Show()
    self.Backdrop:Show()
    self.Normal:Show()
    self.Icon:Show()
    self.Cooldown:Show()
    self.TextFrame:Show()
    self.Reactor:Show()
end

function ezSpectator_ClickIcon:Hide()
    self.Backdrop:Hide()
    self.Normal:Hide()
    self.Highlight:Hide()
    self.Icon:Hide()
    self.Cooldown:Hide()
    self.TextFrame:Hide()
    self.Reactor:Hide()
end

function ezSpectator_ClickIcon:SetShown(shown)
	if shown then
		self:Show()
	else
		self:Hide()
	end
end

function ezSpectator_ClickIcon:IsShown()
    return self.Backdrop:IsShown()
end

function ezSpectator_ClickIcon:SetAlpha(Value)
    self.Backdrop:SetAlpha(Value)
    self.Normal:SetAlpha(Value)
    self.Highlight:SetAlpha(Value)
    self.TextFrame:SetAlpha(Value)
end

function ezSpectator_ClickIcon:SetTooltip(header, ...)
    self.tooltipHeader = header
    self.tooltipText = {...}
end

function ezSpectator_ClickIcon:SetEnabled( ... )
    if ... then
       self.disable = false
       self.Icon:SetAlpha(1)
    else
       self.disable = true
       self.Icon:SetAlpha(0.4)
    end
end

function ezSpectator_ClickIcon:SetPoint(...)
    self.Backdrop:ClearAllPoints()
    self.Normal:ClearAllPoints()
    self.Highlight:ClearAllPoints()
    self.Reactor:ClearAllPoints()

    self.Backdrop:SetPoint(...)
    self.Normal:SetPoint(...)
    self.Highlight:SetPoint(...)
    self.Reactor:SetPoint(...)
end

function ezSpectator_ClickIcon:SetBorderClassColor(classID)
	local className = self.Parent.Data.ClassTextEng[classID]
	local Color = RAID_CLASS_COLORS[className] or RAID_CLASS_COLORS["PRIEST"]

    self.Normal.texture:SetVertexColor(Color.r, Color.g, Color.b, 1)
    self.Highlight.texture:SetVertexColor(Color.r, Color.g, Color.b, 1)
end

function ezSpectator_ClickIcon:SetToggleDown()
    if self.Backdrop:IsShown() then
        self.Backdrop:SetFrameStrata('DIALOG')
        self.Icon:SetFrameStrata('FULLSCREEN')
        self.Icon:SetAlpha(0.5)
    end

    self.IsToggleUp = false

    if self.Action then
        self.Action(self)
    end
end

function ezSpectator_ClickIcon:SetToggleUp()
    if self.Backdrop:IsShown() then
        self.Backdrop:SetFrameStrata('LOW')
        self.Icon:SetFrameStrata('MEDIUM')
        self.Icon:SetAlpha(1)
    end

    self.IsToggleUp = true

    if self.Action then
        self.Action(self)
    end
end

function ezSpectator_ClickIcon:SetCooldown(startTime, duration)
	self.Cooldown:SetCooldown(startTime, duration)
end

function ezSpectator_ClickIcon:SetTexture(texturePath, iconSize, cropIconBorder)
	iconSize = iconSize / _ezSpectatorScale

	self.Icon:SetSize(iconSize, iconSize)
	self.Cooldown:SetSize(iconSize, iconSize)

	self.Icon.texture:SetTexture(texturePath)
	if cropIconBorder then
		self.Icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
end

function ezSpectator_ClickIcon:SetIcon(name)
	local iconInfo = ICON_ATLASES[name]
	if iconInfo then
		local atlasName = iconInfo[1]
		local size = iconInfo[2]

		self.Icon:SetSize(size, size)
		self.Cooldown:SetSize(size, size)

		self.Icon.texture:SetAtlas(atlasName, true)
	end
end

function ezSpectator_ClickIcon:SetFontIcon(Name)
    self.TextIcon:SetText(Name)
end

function ezSpectator_ClickIcon:SetTime(Value)
    if Value > 0 then
        self.Highlight:Hide()
        self.Text:SetText(self.Parent.Data:SecondsToTime(Value, true))
    else
        self.Highlight:Show()
        self.Text:SetText('')
    end
end

function ezSpectator_ClickIcon:GetText()
    return self.Text and self.Text:GetText() or '00:00'
end

function ezSpectator_ClickIcon:SetTextInteractive(IsInteractive)
    self.IsTextInteractive = IsInteractive

    if not IsInteractive then
        self.TextFrame:SetAlpha(1)
    end
end

function ezSpectator_ClickIcon:SetAction(Action)
    if not self.Action then
        self.Reactor:SetScript('OnMouseDown', function()
            if self.Backdrop:IsShown() and not self.IsToggleMode and not self.disable then
                self.Backdrop:SetFrameStrata('DIALOG')
                self.Icon:SetFrameStrata('FULLSCREEN')
                self.Icon:SetAlpha(0.75)
            end
        end)
        self.Reactor:SetScript('OnMouseUp', function()
            if self.Backdrop:IsShown() and not self.IsToggleMode and not self.disable then
                self.Backdrop:SetFrameStrata('LOW')
                self.Icon:SetFrameStrata('MEDIUM')
                self.Icon:SetAlpha(1)
            end

            if self.IsToggleMode then
                if self.IsToggleUp then
                    self:SetToggleDown()
                else
                    self:SetToggleUp()
                end
            else
                if self.Action then
                    self.Action(self)
                end
            end
        end)
    end

    self.Action = Action
end