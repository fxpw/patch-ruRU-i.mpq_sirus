--	Filename:	C_CharacterCreation.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_CharacterCreation = {
	isZoomed = false
}

AvailableRacesStorage = {}
AssociateRaces = {}

---@return number racesCount
function C_CharacterCreation.GetNumAvailableRaces()
	return #CHARACTER_CREATE_RACES_ORDER
end

---@return table RaceInfo
function C_CharacterCreation.GetRaceInfo( buttonIndex )
	local raceID 	= CHARACTER_CREATE_RACES_ORDER[buttonIndex]

	assert(raceID, "C_CharacterCreation.GetRaceInfo: raceID "..raceID.." не найден.")

	local RaceInfo		 = C_CreatureInfo.GetRaceInfo( raceID )
	RaceInfo.FactionInfo = C_CreatureInfo.GetFactionInfo( raceID )

	local iconName = GetSelectedSex() == E_SEX.MALE and string.upper(RaceInfo.clientFileString).."MALE" or string.upper(RaceInfo.clientFileString).."FEMALE"
	local raceName

	if GetSelectedSex() == E_SEX.MALE then
		raceName = RaceInfo.localizeName.male
	else
		raceName = RaceInfo.localizeName.female or RaceInfo.localizeName.male
	end

	RaceInfo.raceIndex = AvailableRacesStorage[raceName]

	if not RaceInfo.raceIndex then
		local raceData = {GetAvailableRaces()}
		local raceIndex = 0

		for i = 1, #raceData, 3 do
			local name = raceData[i]

			raceIndex = raceIndex + 1
			AvailableRacesStorage[name] = raceIndex
		end

		RaceInfo.raceIndex = AvailableRacesStorage[raceName]
	end

	AssociateRaces[RaceInfo.raceIndex or -buttonIndex] = buttonIndex

	RaceInfo.raceName 	 = raceName
	RaceInfo.iconTexture = "Interface\\Custom_LoginScreen\\RaceIcon\\RACE_ICON_"..iconName

	return RaceInfo
end

function C_CharacterCreation.GetAvailableRaces()
	local RaceInfo = {}

	for i = 1, C_CharacterCreation.GetNumAvailableRaces() do
		RaceInfo[i] = C_CharacterCreation.GetRaceInfo(i)
	end

	return RaceInfo
end

function C_CharacterCreation.GetSelectedRace()
	local originalID = GetSelectedRace()

	return AssociateRaces[originalID] or originalID
end

function C_CharacterCreation.GetAssociateRaces( raceID )
	return AssociateRaces[raceID] or 0
end

function C_CharacterCreation.SetSelectedRace( buttonID, skipVisual )
	local RaceInfo = C_CharacterCreation.GetRaceInfo(buttonID)

	if not RaceInfo or not RaceInfo.raceIndex then
		CharacterCreate_Back()
		--error(string.format("Не найдена RaceInfo или RaceInfo.raceIndex: %s, %s, %s", buttonID, tostring(RaceInfo), tostring(RaceInfo.raceIndex)))
        error(GetAvailableRaces())
	end

	-- CharacterCreateEnumerateClasses(GetAvailableClasses()) -- Вернуть когда будет ДХ или класс под определенную рассу. (Нужен ресерч классовой системы)

    local selectedSex = GetSelectedSex()

	SetSelectedRace(RaceInfo.raceIndex)

    if selectedSex ~= GetSelectedSex() then
        C_CharacterCreation.UpdateGender()
    end

	if not skipVisual then
		C_CharacterCreation.SetBackgroundModel()

		for index, button in pairs(CharacterCreate.raceButtons) do
			button:SetChecked(buttonID == index)
		end
	end
end

function C_CharacterCreation.FaceZoomIn()
	if C_CharacterCreation.isZoomed then
		return
	end

	local _, classFileName = GetSelectedClass()
	local cameraSettings = CHARACTER_CREATE_FACE_ZOOM_CAMERA_SETTINGS[classFileName] or CHARACTER_CREATE_FACE_ZOOM_CAMERA_SETTINGS

	cameraSettings = cameraSettings[GetSelectedSex()]

	assert(cameraSettings, "C_CharacterCreation.FaceZoomIn: Не найдены настройки камеры для текущего пола персонажа.")

	local buttonID 		= C_CharacterCreation.GetSelectedRace()
	local RaceInfo 		= C_CharacterCreation.GetRaceInfo(buttonID)

	assert(RaceInfo, "C_CharacterCreation.FaceZoomIn: Не найдена расса по кнопке "..buttonID)
	assert(cameraSettings[RaceInfo.raceID], "C_CharacterCreation.FaceZoomIn: Не найдены настройки камеры для рассы "..RaceInfo.raceID)

	local defaultCameraSettings = C_CharacterCreation.GetDefaultCameraSettings()

	cameraSettings = cameraSettings[RaceInfo.raceID]

	dump(cameraSettings)

	CharacterCreate.elapsed = 0

	local animationTime = 0.75

	CharacterCreate:SetScript("OnUpdate", function(self, elapsed)
		local startXOffset = defaultCameraSettings[1]
		local startYOffset = defaultCameraSettings[2]
		local startZOffset = defaultCameraSettings[3]

		local xOffset = C_outCirc(self.elapsed, startXOffset, cameraSettings[1], animationTime)
		local yOffset = C_outCirc(self.elapsed, startYOffset, cameraSettings[2], animationTime)
		local zOffset = C_outCirc(self.elapsed, startZOffset, cameraSettings[3], animationTime)

		self.elapsed = self.elapsed + elapsed

		CharacterCreate:SetPosition(xOffset, yOffset, zOffset)

		if self.elapsed >= animationTime then
			self:SetScript("OnUpdate", nil)
			self.elapsed = 0

			CharacterCreate:SetPosition(unpack(cameraSettings))
		end
	end)

	C_CharacterCreation.isZoomed = true
end

function C_CharacterCreation.FaceZoomOut()
	if not C_CharacterCreation.isZoomed then
		return
	end

	CharacterCreate.elapsed = 0

	local animationTime = 0.75
	local startXOffset, startYOffset, startZOffset = CharacterCreate:GetPosition()
	local cameraSettings = C_CharacterCreation.GetDefaultCameraSettings()

	CharacterCreate:SetScript("OnUpdate", function(self, elapsed)
		local xOffset = C_outCirc(self.elapsed, startXOffset, cameraSettings[1], animationTime)
		local yOffset = C_outCirc(self.elapsed, startYOffset, cameraSettings[2], animationTime)
		local zOffset = C_outCirc(self.elapsed, startZOffset, cameraSettings[3], animationTime)

		self.elapsed = self.elapsed + elapsed

		CharacterCreate:SetPosition(xOffset, yOffset, zOffset)

		if self.elapsed >= animationTime then
			self:SetScript("OnUpdate", nil)
			self.elapsed = 0

			CharacterCreate:SetPosition(unpack(cameraSettings))
		end
	end)
	C_CharacterCreation.isZoomed = false
end

function C_CharacterCreation.GetSelectedModel()
	local buttonID 	= C_CharacterCreation.GetSelectedRace()
	local RaceInfo 	= C_CharacterCreation.GetRaceInfo(buttonID)

	assert(RaceInfo, "C_CharacterCreation.GetSelectedModel: Не найдена расса по кнопке "..buttonID)

	local _, classFileName = GetSelectedClass()

	assert(classFileName, "C_CharacterCreation.GetSelectedModel: не найден classFileName")

	local factionTag 	= RaceInfo.FactionInfo.groupTag
	local modelName 	= factionTag

	if classFileName == "DEATHKNIGHT" then
		modelName = "DeathKnight"
	elseif isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) then
		modelName = "Vulpera"
		C_Timer:After(0.01, function() SetCharacterCreateFacing(-215) end)
	elseif isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_PANDAREN_HORDE, E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE) then
		modelName = "Pandaren"
	end

	if (isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) and classFileName == "DEATHKNIGHT") or not isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) then
		C_Timer:After(0.01, function() SetCharacterCreateFacing(0) end)
	end

	return modelName
end

function C_CharacterCreation.GetDefaultCameraSettings()
	local modelName 		= C_CharacterCreation.GetSelectedModel()
	local cameraSettings 	= CHARACTER_CREATE_CAMERA_SETTINGS[modelName]

	assert(cameraSettings, "C_CharacterCreation.GetDefaultCameraSettings: не найдены настройки камеры для модели "..modelName)

	return cameraSettings
end

function C_CharacterCreation.SetBackgroundModel()
	local modelName = C_CharacterCreation.GetSelectedModel()

	CharacterCreate:SetScript("OnUpdate", nil)

	SetCharCustomizeBackground("Interface\\GLUES\\Models\\UI_BLOODELF\\UI_BLOODELF.m2")
	CharacterSelect:SetCamera(0)

	C_Timer:After(0.001, function() SetCharCustomizeBackground(string.formatx("Interface\\GLUES\\Models\\UI_$1\\UI_$1.m2", modelName)) end)

	CharacterCreate:SetPosition(unpack(C_CharacterCreation.GetDefaultCameraSettings()))

	local lightSettings = CHARACTER_CREATE_MODEL_LIGHT[modelName]

	assert(lightSettings, "C_CharacterCreation.SetBackgroundModel: Не найдены настройки света для модели "..modelName)

	CharacterCreate:ResetLights()

	for _, func in pairs({CharacterCreate.AddCharacterLight, CharacterCreate.AddLight, CharacterCreate.AddPetLight}) do
		func(CharacterCreate, LIGHT_LIVE, 1, 0, unpack(lightSettings))
	end

	C_CharacterCreation.isZoomed = false
end

function C_CharacterCreation.UpdateGender()
	local selectedGender = GetSelectedSex()

    for buttonID, button in pairs({CharCreateMaleButton, CharCreateFemaleButton}) do
        if (buttonID + 1) == selectedGender then
            button:SetChecked(1)
            button:SetAlpha(1)
        else
            button:SetChecked(0)
            button:SetAlpha(0.60)
        end
    end

    -- hack
    C_Timer:After(0.5, function()
        CharacterCreateEnumerateRaces()
        CharacterChangeFixup(true)
    end)

	CharacterCreate_UpdateHairCustomization()
end

---@param gender number
function C_CharacterCreation.SetGender( gender )
	SetSelectedSex(gender)

	C_CharacterCreation.UpdateGender()
end