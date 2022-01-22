--	Filename:	Sirus_AutoQuestPopUpTracker.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

function AutoQuestPopUpButton_OnLoad( self, ... )
	self:RegisterEvent("CHAT_MSG_ADDON")
end

function AutoQuestPopUpButton_OnShow( self, ... )
	PlaySound("igPVPUpdate")
	self.QuestName:SetText("test")
	self.Exclamation:Show()
end

function AutoQuestPopUpButton_OnClick( self, ... )

end

function AutoQuestPopUpButton_OnEvent( self, event, ... )
end

function AutoQuestPopUpButton_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	GameTooltip:SetHyperlink("Hitem:45624")
	GameTooltip:Show()
end

function AutoQuestPopUpButton_OnLeave( self, ... )
	GameTooltip:Hide()
end