-- Custom dropdown buttons are instantiated by some external system.
-- When calling UIDropDownMenu_AddButton that system sets info.customFrame to the instance of the frame it wants to place on the menu.
-- The dropdown menu creates its button for the entry as it normally would, but hides all elements.  The custom frame is then anchored
-- to that button and assumes responsibility for all relevant dropdown menu operations.
-- The hidden button will request a size that it should become from the custom frame.

function UIDropDownMenuButtonScript_OnEnter(self, ...)
	ExecuteFrameScript(self:GetParent(), "OnEnter", ...);
end

function UIDropDownMenuButtonScript_OnLeave(self, ...)
	ExecuteFrameScript(self:GetParent(), "OnLeave", ...);
end

function UIDropDownMenuButtonScript_OnMouseDown(self, button)
--	if self:IsEnabled() == 1 then
		ToggleDropDownMenu(nil, nil, self:GetParent());
		PlaySound("igMainMenuOptionCheckBoxOn");
--	end
end

function DropDownExpandArrow_OnEnter(self)
	local level = self:GetParent():GetParent():GetID() + 1;

	CloseDropDownMenus(level);

--	if self:IsEnabled() == 1 then
		local listFrame = _G["DropDownList"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
			ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self);
		end
--	end
	UIDropDownMenu_StopCounting(self:GetParent():GetParent());
end

function DropDownExpandArrow_OnLeave(self)
	UIDropDownMenu_StartCounting(self:GetParent():GetParent());
end

function DropDownExpandArrow_OnMouseDown(self, button)
--	if self:IsEnabled() == 1 then
		ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self);
--	end
end

UIDropDownCustomMenuEntryMixin = {};

function UIDropDownCustomMenuEntryMixin:GetPreferredEntryWidth()
	return self:GetWidth();
end

function UIDropDownCustomMenuEntryMixin:GetPreferredEntryHeight()
	return self:GetHeight();
end

function UIDropDownCustomMenuEntryMixin:OnSetOwningButton()
	-- for derived objects to implement
end

function UIDropDownCustomMenuEntryMixin:SetOwningButton(button)
	self:SetParent(button:GetParent());
	self.owningButton = button;
	self:OnSetOwningButton();
end

function UIDropDownCustomMenuEntryMixin:GetOwningDropdown()
	return self.owningButton:GetParent();
end

function UIDropDownCustomMenuEntryMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function UIDropDownCustomMenuEntryMixin:GetContextData()
	return self.contextData;
end
