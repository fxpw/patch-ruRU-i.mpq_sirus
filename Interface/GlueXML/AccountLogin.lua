local BACKGROUND_MODEL = "Interface\\Glues\\Models\\UI_MainMenu\\UI_MainMenu.m2"

LOGIN_MODELS = {
	{1, 1, 1, 1.000, 0.310, 5.712, 1, 125,	{-0.427, 0.602, 0.044},		[[Creature\Arthaslichking\arthaslichking.m2]]},
	{1, 1, 1, 1.000, 0.118, 0.417, 1, 108,	{-1.102, -0.602, -0.133},	[[Creature\Illidan\illidan.m2]]},

	{0, 1, 1, 0.475, 0.134, 5.783, 0, 2,	{0.000, 1.534, 0.642},		[[Spells\Instanceportal_green_10man.m2]]},
	{0, 1, 1, 1.000, 0.449, 0.000, 0, 2,	{-18.667, 7.680, -1.253},	[[World\Generic\passivedoodads\christmas\xmastree_largealliance01white.m2]]},
	{0, 1, 1, 1.000, 0.681, 0.000, 0, 2,	{0.000, 0.267, -0.081},		[[World\Generic\passivedoodads\particleemitters\dustwallowgroundfogplane.m2]]},
	{0, 1, 1, 1.000, 0.147, 5.799, 0, 121,	{-3.013, 1.041, 0.195},		[[Creature\Babymoonkin\babymoonkin_ne.m2]]},
	{0, 1, 1, 1.000, 0.601, 0.000, 0, 2,	{0.000, -0.486, 1.160},		[[Spells\Enchantments\soulfrostglow_high.m2]]},
	{0, 1, 1, 1.000, 0.486, 0.000, 0, 2,	{0.000, -0.877, 0.725},		[[Spells\Enchantments\soulfrostglow_high.m2]]},
	{0, 1, 1, 1.000, 1.027, 0.900, 0, 125,	{-11.975, -3.008, -1.137},	[[Creature\Kelthuzad\kelthuzad.m2]]},
	{0, 1, 1, 0.063, 0.504, 0.000, 0, 2,	{-4.002, 2.046, 0.182},		[[Spells\Ritual_frost_precast_base.m2]]},
	{0, 1, 1, 1.000, 0.405, 0.000, 0, 2,	{-7.890, 0.053, 0.408},		[[Creature\Frostlord\frostlordcore.m2]]},
	{0, 1, 1, 1.000, 0.560, 0.000, 0, 2,	{0.000, -0.471, 1.167},		[[Spells\Enchantments\soulfrostglow_high.m2]]},
	{0, 1, 1, 0.482, 0.145, 0.500, 0, 2,	{0.000, -1.453, 0.592},		[[Spells\Instanceportal_green_10man.m2]]},
	{0, 1, 1, 0.090, 3.387, 0.000, 0, 2,	{0.000, 0.021, 0.911},		[[Spells\Deathknight_frozenruneweapon_impact.m2]]},
	{0, 1, 1, 1.000, 0.078, 0.000, 0, 2,	{-8.527, 0.023, 3.459},		[[World\Expansion02\doodads\icecrown\lights\icecrown_green_fire.m2]]},
	{0, 1, 1, 1.000, 0.132, 0.000, 0, 2,	{0.000, 0.017, 1.730},		[[World\Expansion02\doodads\icecrown\lights\icecrown_greenglow_01.m2]]},
	{0, 1, 1, 1.000, 0.201, 5.683, 0, 2,	{0.000, 0.996, 0.619},		[[Creature\Snowman\snowman.m2]]},
	{0, 1, 1, 1.000, 0.049, 0.000, 0, 2,	{0.000, 0.626, 1.337},		[[World\Generic\passivedoodads\christmas\g_xmaswreath.m2]]},
	{0, 1, 1, 1.000, 0.049, 0.000, 0, 2,	{0.000, -0.594, 1.335},		[[World\Generic\passivedoodads\christmas\g_xmaswreath.m2]]},
	{0, 1, 1, 1.000, 0.111, 0.000, 0, 2,	{0.000, 1.225, 0.562},		[[World\Generic\activedoodads\christmas\snowballmound01.m2]]},
	{0, 1, 1, 1.000, 0.150, 0.000, 0, 2,	{0.000, 1.358, 0.562},		[[World\Generic\activedoodads\christmas\snowballmound01.m2]]},
	{0, 1, 1, 1.000, 0.177, 0.000, 0, 2,	{0.000, 1.184, 0.519},		[[World\Generic\passivedoodads\christmas\xmasgift01.m2]]},
	{0, 1, 1, 1.000, 0.198, 0.600, 0, 2,	{0.000, 1.456, 0.498},		[[World\Generic\passivedoodads\christmas\xmasgift04.m2]]},
	{0, 1, 1, 1.000, 0.051, 5.783, 0, 2,	{0.000, 0.587, 1.555},		[[World\Generic\passivedoodads\christmas\xmas_lightsx3.m2]]},
	{0, 1, 1, 1.000, 0.053, 0.500, 0, 2,	{0.000, -0.542, 1.552},		[[World\Generic\passivedoodads\christmas\xmas_lightsx3.m2]]},
	{0, 1, 1, 1.000, 0.224, 0.000, 0, 2,	{0.000, 0.337, 0.684},		[[World\Generic\passivedoodads\christmas\mistletoe.m2]]},
	{0, 1, 1, 1.000, 0.219, 0.000, 0, 2,	{0.000, -0.286, 0.673},		[[World\Generic\passivedoodads\christmas\mistletoe.m2]]},
}

LOGIN_MODEL_LIGHTS = {
	[0] = {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0, 1.0, 1.0, 0.8},
	[1] = {1, 0, 1, -0.707, -0.707, 0.4, 1.0, 1.0, 1.0, 1, 1.0, 0.0, 0.0},
}

NEW_YEAR = false

function AccountLogin_OnLoad(self)
	self.LoginUI.Logo:SetAtlas(C_RealmInfo.GetServerLogo(0))
	self.BGModel:SetModel(BACKGROUND_MODEL)
	self.Models = {}

	AcceptTOS()
	AcceptEULA()

	self:RegisterEvent("SHOW_SERVER_ALERT")
	self:RegisterEvent("LOGIN_FAILED")
	self:RegisterEvent("SCANDLL_ERROR")
	self:RegisterEvent("SCANDLL_FINISHED")
	self:RegisterEvent("PLAYER_ENTER_TOKEN")
	self:RegisterEvent("FRAMES_LOADED")

	if NEW_YEAR then
		self.LoginUI.BGTexture:SetTexture([[Interface\Custom_LoginScreen\Kelthuzad_Room]])
		self.LoginUI.BGTexture:Show()
		self.BGModel:Hide()

		for i = 1, 2 do
			LOGIN_MODELS[i][1] = 0
		end

		for i = 3, #LOGIN_MODELS do
			LOGIN_MODELS[i][1] = 1
		end
	end
end

function AccountLogin_OnShow(self)
	PlayGlueMusic(CurrentGlueMusic)

	for _, model in ipairs(self.Models) do
		local data = LOGIN_MODELS[model.id]

		model:SetModel("Character\\Human\\Male\\HumanMale.mdx")
		model:SetCamera(1)

		model:SetModel(data[10])
		model:SetSequence(data[8])

		model:SetModelScale(data[5])
		model:SetFacing(data[6])
		model:SetPosition(unpack(data[9], 1, 3))
	end
end

function AccountLogin_OnEvent(self, event, ...)
	if event == "FRAMES_LOADED" then
		self:UnregisterEvent(event)

		for index, data in ipairs(LOGIN_MODELS) do
			if data[1] == 1 then
				local model = CreateFrame("Model", "$parentModel"..index, self.LoginUI)
				model.id = index

				model:SetPoint("CENTER", 0, 0)
				model:SetSize(self:GetWidth() * data[2], self:GetHeight() * data[3])
				model:SetAlpha(data[4])

				model:SetLight(unpack(data[7] and LOGIN_MODEL_LIGHTS[data[7]] or LOGIN_MODEL_LIGHTS[0], 1, 13))

				table.insert(self.Models, model)
			end
		end

		local accountName, oldPassword, oldAutologin = strsplit("|", GetSavedAccountName())
		if accountName then
			if oldPassword then
				SetSavedAccountName(accountName);

				SetCVar("readTerminationWithoutNotice", oldPassword);
				C_GlueCVars.SetCVar("AUTO_LOGIN", oldAutologin == "true" and "1" or "0");
			end

			AccountLoginAccountEdit:SetText(accountName)

			local password = GetCVar("readTerminationWithoutNotice");
			if password and password ~= "" and password ~= "1" and password ~= "0" then
				AccountLoginPasswordEdit:SetText(password)

				if C_GlueCVars.GetCVar("AUTO_LOGIN") == "1" then
					AccountLoginAutoLogin:SetChecked(1)
				end
			end

			AccountLoginSaveAccountName:SetChecked(true)
			AccountLoginAutoLogin.TitleText:SetTextColor(1, 1, 1)
			AccountLoginAutoLogin:Enable()
		else
			AccountLoginSaveAccountName:SetChecked(false)
			AccountLoginAutoLogin.TitleText:SetTextColor(0.5, 0.5, 0.5)
			AccountLoginAutoLogin:Disable()
		end

		AccountLoginDevTools:SetShown(IsDevClient())
	elseif event == "SCANDLL_ERROR" or event == "SCANDLL_FINISHED" then
		ScanDLLContinueAnyway()
	elseif event == "PLAYER_ENTER_TOKEN" then
		TokenEnterDialog:Show()
	end
end

function AccountLoginUI_UpdateServerAlertText(text)
	ServerAlertText:SetText(text)
	ServerAlertFrame:Show()
end

function TokenEnterDialog_Okay()
	if string.len( TokenEnterEditBox:GetText() ) < 6 then
		return
	end

	TokenEntered(TokenEnterEditBox:GetText())
	TokenEnterDialog:Hide()
end

function TokenEnterDialog_Cancel()
	TokenEnterDialog:Hide()
	CancelLogin()
end

function AccountLogin_Login()
	local login = AccountLoginAccountEdit:GetText()
	local password = AccountLoginPasswordEdit:GetText()

	if string.find(login, "@", 1, true) then
		GlueDialog:ShowDialog("OKAY", LOGIN_EMAIL_ERROR)
		return
	end

	if login and password then
		if AccountLoginSaveAccountName:GetChecked() then
			if login ~= "" or password ~= "" then
				SetSavedAccountName(login)

				SetCVar("readTerminationWithoutNotice", password);
				C_GlueCVars.SetCVar("AUTO_LOGIN", AccountLoginAutoLogin:GetChecked() and "1" or "0");
			end
		else
			SetSavedAccountName("")
		end

		PlaySound(SOUNDKIT.GS_LOGIN)
		DefaultServerLogin(login, password)
	end
end

function AccountLogin_AutoLogin()
	if C_GlueCVars.GetCVar("AUTO_LOGIN") == "1" then
		C_Timer:NewTicker(0.01, function()
			if AccountLogin:IsVisible() then
				DefaultServerLogin(GetSavedAccountName(), GetCVar("readTerminationWithoutNotice"))
			end
		end, 5)
	end
end

function AccountLoginDevTools_OnShow(self)
	if not SIRUS_DEV_ACCOUNT_LOGIN_MANAGER then return end
	self.AccountsDropDown_Button:SetShown(type(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts) == "table" and next(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts))
	self.RealmListDropDown:SetShown(type(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList) == "table" and next(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList))
end

function DevToolsRealmListDropDown_OnShow(self)
	GlueDark_DropDownMenu_Initialize(self, DevToolsRealmListDropDown_Initialize)
	GlueDark_DropDownMenu_SetSelectedValue(self, GetCVar("realmList"))
	GlueDark_DropDownMenu_SetWidth(self, 185, true)
	GlueDark_DropDownMenu_JustifyText(self, "CENTER")
end

function DevToolsRealmListDropDown_OnClick(self)
	SetCVar("realmList", self.value)
	GlueDark_DropDownMenu_SetSelectedValue(AccountLoginDevTools.RealmListDropDown, self.value)
end

function DevToolsRealmListDropDown_Initialize()
	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER and SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList then
		local info = GlueDark_DropDownMenu_CreateInfo()
		info.func = DevToolsRealmListDropDown_OnClick

		for _, realmData in ipairs(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList) do
			info.text = string.format("%s (%s)", realmData[1], realmData[2])
			info.value = realmData[2]
			info.checked = GetCVar("realmList") == info.value

			GlueDark_DropDownMenu_AddButton(info)
		end
	end
end

function DevToolsAccountsDropDown_OnShow(self)
	GlueDark_DropDownMenu_Initialize(self, DevToolsAccountsDropDown_Initialize, "MENU")
end

function DevToolsAccountsDropDown_OnClick(self)
	AccountLoginAccountEdit:SetText(string.sub(self.value[1], 2, -2))
	AccountLoginPasswordEdit:SetText(string.sub(self.value[2], 2, -2))
end

function DevToolsAccountsDropDown_Initialize()
	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER and SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts then
		local info = GlueDark_DropDownMenu_CreateInfo()
		info.func = DevToolsAccountsDropDown_OnClick

		for i, accountData in ipairs(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts) do
			info.text = string.format("%i - %s", i, string.sub(accountData[1], 2, -2))
			info.value = {accountData[1], accountData[2]}
			info.checked = nil

			GlueDark_DropDownMenu_AddButton(info)
		end
	end
end

AccountLoginChooseRealmDropDownMixin = {}

local function ChooseRealmDropdown_OnClick(self)
	GlueDark_DropDownMenu_SetSelectedValue(AccountLoginChooseRealmDropDown, self.value)
	SetCVar("realmList", self.value)
	C_GlueCVars.SetCVar("ENTRY_POINT", self.value)
end

local function ChooseRealmDropdownInit()
	local info = GlueDark_DropDownMenu_CreateInfo()

	info.func = ChooseRealmDropdown_OnClick

	for k, v in pairs(AccountLoginChooseRealmDropDown.realmStorage) do
		info.text = v.name
		info.value = v.ip
		info.checked = nil
		GlueDark_DropDownMenu_AddButton(info)
	end
end

function AccountLoginChooseRealmDropDownMixin:Init()
	self.realmStorage = C_ConnectManager:GetAllRealmList()

	GlueDark_DropDownMenu_Initialize(self, ChooseRealmDropdownInit)

	local currentRealmList = GetCVar("realmList")
	local selectedValue = self.realmStorage[1].ip

	if StringStartsWith(currentRealmList, "192.168.") or StringStartsWith(currentRealmList, "127.0.") then
		return
	end

	local entryPoint = C_GlueCVars.GetCVar("ENTRY_POINT")
	if entryPoint ~= "" then
		for _, d in ipairs(self.realmStorage) do
			if d.ip == entryPoint then
				currentRealmList = entryPoint
				break
			end
		end
	end

	for _, v in ipairs(self.realmStorage) do
		if v.ip == currentRealmList then
			selectedValue = v.ip
			break
		end
	end

	GlueDark_DropDownMenu_SetSelectedValue(self, selectedValue)
	SetCVar("realmList", selectedValue)

	GlueDark_DropDownMenu_SetWidth(self, 185, true)
	GlueDark_DropDownMenu_JustifyText(self, "CENTER")
end