--	Filename:	AccountLogin.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local AccountLogin_Background = "Interface\\Glues\\Models\\UI_MainMenu\\UI_MainMenu.m2"
local AccountLogin_Texture = "Interface\\Custom_LoginScreen\\do_not_fine"

AccountLogin_Models = {
	{1, 0.602, 0.044, -0.427, 5.712, 0.310, 1.000, {1, 0, 1, -0.707, -0.707, 0.4, 1.0, 1.0, 1.0, 1, 1, 0, 0}, 125, 1, 1, "Creature\\Arthaslichking\\arthaslichking.m2", _, _, nil},
	{1, -0.602, -0.133, -1.102, 0.417, 0.118, 1.000, {1, 0, 1, -0.707, -0.707, 0.4, 1.0, 1.0, 1.0, 1, 1, 0, 0}, 108, 1, 1, "Creature\\Illidan\\illidan.m2", _, _, nil}

	--{1, -0.486, 1.160, 0.000, 0.000, 0.601, 1.000, _, 2, 1, 1, "Spells\\Enchantments\\soulfrostglow_high.m2", _, _},
	--{1, -0.877, 0.725, 0.000, 0.000, 0.486, 1.000, _, 2, 1, 1, "Spells\\Enchantments\\soulfrostglow_high.m2", _, _},
	--{1, 1.534, 0.642, 0.000, 5.783, 0.134, 0.475, _, 2, 1, 1, "Spells\\Instanceportal_green_10man.m2", _, _},
	--{1, -3.008, -1.137, -11.975, 0.900, 1.027, 1.000, _, 125, 1, 1, "Creature\\Kelthuzad\\kelthuzad.m2", _, _},
	--{1, 2.046, 0.182, -4.002, 0.000, 0.504, 0.063, _, 2, 1, 1, "Spells\\Ritual_frost_precast_base.m2", _, _},
	--{1, 0.053, 0.408, -7.890, 0.000, 0.405, 1.000, _, 2, 1, 1, "Creature\\Frostlord\\frostlordcore.m2", _, _},
	--{1, -0.471, 1.167, 0.000, 0.000, 0.560, 1.000, _, 2, 1, 1, "Spells\\Enchantments\\soulfrostglow_high.m2", _, _},
	--{1, -1.453, 0.592, 0.000, 0.500, 0.145, 0.482, _, 2, 1, 1, "Spells\\Instanceportal_green_10man.m2", _, _},
	--{1, 0.267, -0.081, 0.000, 0.000, 0.681, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\particleemitters\\dustwallowgroundfogplane.m2", _, _},
	--{1, 0.021, 0.911, 0.000, 0.000, 3.387, 0.090, _, 2, 1, 1, "Spells\\Deathknight_frozenruneweapon_impact.m2", _, _},
	--{1, 0.023, 3.459, -8.527, 0.000, 0.078, 1.000, _, 2, 1, 1, "World\\Expansion02\\doodads\\icecrown\\lights\\icecrown_green_fire.m2", _, _},
	--{1, 0.017, 1.730, 0.000, 0.000, 0.132, 1.000, _, 2, 1, 1, "World\\Expansion02\\doodads\\icecrown\\lights\\icecrown_greenglow_01.m2", _, _},
	--{1, 0.996, 0.619, 0.000, 5.683, 0.201, 1.000, _, 2, 1, 1, "Creature\\Snowman\\snowman.m2", _, _},
	--{1, 0.626, 1.337, 0.000, 0.000, 0.049, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\g_xmaswreath.m2", _, _},
	--{1, -0.594, 1.335, 0.000, 0.000, 0.049, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\g_xmaswreath.m2", _, _},
	--{1, 7.680, -1.253, -18.667, 0.000, 0.449, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\xmastree_largealliance01white.m2", _, _},
	--{1, 1.225, 0.562, 0.000, 0.000, 0.111, 1.000, _, 2, 1, 1, "World\\Generic\\activedoodads\\christmas\\snowballmound01.m2", _, _},
	--{1, 1.358, 0.562, 0.000, 0.000, 0.150, 1.000, _, 2, 1, 1, "World\\Generic\\activedoodads\\christmas\\snowballmound01.m2", _, _},
	--{1, 1.184, 0.519, 0.000, 0.000, 0.177, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\xmasgift01.m2", _, _},
	--{1, 1.456, 0.498, 0.000, 0.600, 0.198, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\xmasgift04.m2", _, _},
	--{1, 0.587, 1.555, 0.000, 5.783, 0.051, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\xmas_lightsx3.m2", _, _},
	--{1, -0.542, 1.552, 0.000, 0.500, 0.053, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\xmas_lightsx3.m2", _, _},
	--{1, 0.337, 0.684, 0.000, 0.000, 0.224, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\mistletoe.m2", _, _},
	--{1, -0.286, 0.673, 0.000, 0.000, 0.219, 1.000, _, 2, 1, 1, "World\\Generic\\passivedoodads\\christmas\\mistletoe.m2", _, _},
	--{1, 1.041, 0.195, -3.013, 5.799, 0.147, 1.000, _, 121, 1, 1, "Creature\\Babymoonkin\\babymoonkin_ne.m2", _, _}
}

AccountLogin_Models_Lights = {

}

function AccountLoginBackground_OnLoad( self, ... )
	self.Models = {}

	PlayGlueMusic(CurrentGlueMusic)

	AccountLoginBackgroundModel:SetModel(AccountLogin_Background)
	--AccountLoginBackgroundTexture:SetTexture(AccountLogin_Texture)

	for i = 1, #AccountLogin_Models do
		local model = self.Models[i]
		local data = AccountLogin_Models[i]

		model = CreateFrame("Model", "AccountLoginModel"..i, self)
		model:SetModel(data[14] or "Character\\Human\\Male\\HumanMale.mdx")
		model:SetPoint("CENTER", 0, 0)
		model:SetSize(self:GetWidth() / data[10], self:GetHeight() / data[11])
		model:SetCamera(1)
		model:SetLight(unpack(data[8] or {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0, 1.0, 1.0, 0.8}))
		model:SetAlpha(data[7])
		model:Hide()

		self.Models[i] = model
	end

	if self.renderUpdate then
		self.renderUpdate:Cancel()
		self.renderUpdate = nil
	end

	self.renderUpdate = C_Timer:NewTicker(0.01, function()

		for i = 1, #self.Models do
			local model = self.Models[i]
			local data = AccountLogin_Models[i]

			if data then
				model:SetModel(data[12])
				model:SetPosition(data[4], data[2], data[3])
				model:SetFacing(data[5])
				model:SetModelScale(data[6])
				model:SetSequence(data[9])
				model:Show()
			end
		end

		local login, password, autologin = strsplit("|", GetSavedAccountName())
		if login and password then
			AccountLoginAccountEdit:SetText(login)
			AccountLoginPasswordEdit:SetText(password)

			if autologin == "true" then
				AccountLoginAutoLogin:SetChecked(1)
				if AccountLogin:IsShown() then
					AccountLogin_AutoLogin(login, password)
				end
			end
		end

		AccountLoginDevTools:SetShown(IsDevClient())
	end, 5)

	if self.parallaxUpdate then
		self.parallaxUpdate:Cancel()
		self.parallaxUpdate = nil
	end

	self.parallaxUpdate = C_Timer:NewTicker(0.01, function()
		local mposX, mposY = GetCursorPosition()
		local fposX, fposY = self:GetCenter()

		local x = mposX - fposX
		local y = mposY - fposY

		for i = 1, #self.Models do
			local data = AccountLogin_Models[i]
			local parallax = data[15]

			if parallax then
				local model = self.Models[i]
				model:SetPosition(data[4], data[2] + (parallax[1] * ((x / fposX) / parallax[2])), data[3] + (parallax[3] * ((y / fposY) / parallax[4])))
			end
		end
	end, nil)
end

function AccountLoginUI_OnLoad( self, ... )
	AcceptTOS()
	AcceptEULA()

	self:RegisterEvent("SHOW_SERVER_ALERT")
	self:RegisterEvent("LOGIN_FAILED")
	self:RegisterEvent("SCANDLL_ERROR")
	self:RegisterEvent("SCANDLL_FINISHED")
	self:RegisterEvent("PLAYER_ENTER_TOKEN")

	local accountName = GetSavedAccountName()
	if ( not accountName ) or accountName == ""  then
		SetSavedAccountName("")
		AccountLoginSaveAccountName:SetChecked(0)
	else
		AccountLoginSaveAccountName:SetChecked(1)
		AccountLoginAutoLogin.TittleText:SetTextColor(0.91, 0.78, 0.53)
		AccountLoginAutoLogin:Enable()
	end
end

function AccountLoginUI_OnShow( self, ... )
	self.Logo:SetAtlas("ServerGameLogo-"..math.random(4))
end

function AccountLoginUI_OnHide( self, ... )
	-- body
end

function AccountLoginUI_UpdateServerAlertText( text )
	ServerAlertText:SetText(text)
end

function AccountLoginUI_OnEvent( self, event, ... )
	if ( event == "SCANDLL_ERROR" or event == "SCANDLL_FINISHED" ) then
		ScanDLLContinueAnyway()
	end

	if event == "PLAYER_ENTER_TOKEN" then
		TokenEnterDialog:Show()
	end
end

function TokenEnterDialog_Okay( self, ... )
	if string.len( TokenEnterEditBox:GetText() ) < 6 then
		return
	end

	TokenEntered(TokenEnterEditBox:GetText())
	TokenEnterDialog:Hide()
end

function TokenEnterDialog_Cancel( self, ... )
	TokenEnterDialog:Hide()
	CancelLogin()
end

function AccountLogin_Login()
	local Login = AccountLoginAccountEdit:GetText()
	local Password = AccountLoginPasswordEdit:GetText()

	if string.find(Login, "@") then
		GlueDialog_Show("OKAY", LOGIN_EMAIL_ERROR)
		return
	end

	if Login and Password then
		if AccountLoginSaveAccountName:GetChecked() then
			if Login ~= "" or Password ~= "" then
				SetSavedAccountName(string.format("%s|%s|%s", Login, Password, (AccountLoginAutoLogin:GetChecked()) and "true" or "false"))
			end
		else
			SetSavedAccountName("")
		end

		DefaultServerLogin(Login, Password)
	end
end

function AccountLogin_AutoLogin(Login, Password)
	DefaultServerLogin(Login, Password)
end

function DevToolsRealmListDropDown_OnShow( self, ... )
	GlueDropDownMenu_Initialize(self, DevToolsRealmListDropDown_Initialize)
	GlueDropDownMenu_SetSelectedValue(self, GetCVar("realmList"))
	GlueDropDownMenu_SetWidth(180, self)
	GlueDropDownMenu_JustifyText("LEFT", self)
end

function DevToolsRealmListDropDown_OnClick( button, ... )
	SetCVar("realmList", button.value)
	GlueDropDownMenu_SetSelectedValue(AccountLoginDevTools.RealmListDropDown, button.value)
end

function DevToolsRealmListDropDown_Initialize()
	local info = GlueDropDownMenu_CreateInfo()

	info.func = DevToolsRealmListDropDown_OnClick

	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER then
		for i = 1, tCount(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList) do
			local realmData = SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList[i]

			if realmData then

				info.text = string.format("%s (%s)", realmData[1], realmData[2])
				info.value = realmData[2]
				info.checked = GetCVar("realmList") == info.value

				GlueDropDownMenu_AddButton(info)
			end
		end
	end
end

function DevToolsAccountsDropDown_OnShow( self, ... )
	GlueDropDownMenu_Initialize(self, DevToolsAccountsDropDown_Initialize, "MENU")
end

function DevToolsAccountsDropDown_OnClick( button, ... )
	AccountLoginAccountEdit:SetText(string.sub(button.value[1], 2, -2))
	AccountLoginPasswordEdit:SetText(string.sub(button.value[2], 2, -2))
end

function DevToolsAccountsDropDown_Initialize()
	local info = GlueDropDownMenu_CreateInfo()

	info.func = DevToolsAccountsDropDown_OnClick

	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER then
		for i = 1, tCount(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts) do
			local accountData = SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts[i]

			if accountData then

				info.text = i.." - "..string.sub(accountData[1], 2, -2)
				info.value = {accountData[1], accountData[2]}
				info.checked = nil

				GlueDropDownMenu_AddButton(info)
			end
		end
	end
end