--	Filename:	LevelUpDisplay.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

-- PlayerEarnCategoryHandler
function LevelUpDisplay_OnLoad( self, ... )
	self:RegisterEvent("PLAYER_LEVEL_UP")
end

function LevelUpDisplay_OnShow( self, ... )
	self.unlockList = {}
	self.currSpell = 0

	self.gLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	self.gLine2:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.gLine:SetVertexColor(1, 1, 1)
	self.gLine2:SetVertexColor(1, 1, 1)

	if self.ups then
		self.levelFrame.reachedText:SetText(LEVEL_UP_YOU_RECEIVED)
		self.levelFrame.levelText:SetFormattedText(LEVEL_UP_UPS_RECEIVED, self.ups)
	end

	if self.level then
		self.levelFrame.reachedText:SetText(LEVEL_UP_YOU_REACHED)
		self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED, self.level)

		for i = 1, GetNumSpellTabs() do
			local temp, texture, offset, numSpells = SpellBook_GetTabInfo(i)
			local lineID

			for id, name in pairs(SIRUS_SPELLBOOK_SKILLLINE) do
				if temp == name then
					lineID = id
				end
			end

			if SIRUS_SPELLBOOK_SPELL and SIRUS_SPELLBOOK_SPELL[lineID] then
				for s = 1, #SIRUS_SPELLBOOK_SPELL[lineID] do
					local data = SIRUS_SPELLBOOK_SPELL[lineID][s]
					if data.spellLevel and data.spellLevel == self.level then
						if not tContains(self.unlockList, data.spellID) then
							table.insert(self.unlockList, data.spellID)
						end
					end
				end
			end
		end
	end

	self.levelFrame.levelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.levelFrame.levelUp:Play()
end

function LevelUpDisplay_OnEvent( self, event, ... )
	local level = ...
	self.level = level
	self.ups = nil
	self:Show()
	LevelUpDisplaySide:Hide()
end

function LevelUpDisplay_AnimStep(self)
	if self.currSpell > #self.unlockList or #self.unlockList == 0 then
		self.currSpell = 0
		self.hideAnim:Play()
	else
		self.currSpell = self.currSpell + 1
		local spellInfo = self.unlockList[self.currSpell]
		if spellInfo then
			local spellName, subSpellName, texture = GetSpellInfo(spellInfo)
			self.spellFrame.name:SetText(spellName)
			self.spellFrame.flavorText:SetText(LEVEL_UP_LEARN_NEW_SPELL)
			self.spellFrame.icon:SetTexture(texture)
			self.spellFrame.subIcon:SetTexCoord(0.64257813, 0.72070313, 0.03710938, 0.11132813)
			self.spellFrame.showAnim:Play()
		else
			self.currSpell = 0
			self.hideAnim:Play()
		end
	end
end