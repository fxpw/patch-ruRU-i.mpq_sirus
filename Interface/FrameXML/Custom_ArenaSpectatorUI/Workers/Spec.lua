ezSpectator_SpecWorker = {}
ezSpectator_SpecWorker.__index = ezSpectator_SpecWorker

function ezSpectator_SpecWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_SpecWorker)

    self.Parent = Parent
    
    return self
end



function ezSpectator_SpecWorker:GetData(Class, Spec)
    if not Class or not Spec or Spec == "0" then
        return ''
    end

    local specID, name, description, icon, roleFlag, isRecommended, specNum = GetSpecializationInfoForClassID(tonumber(Class), tonumber(Spec))
    
    return name, icon, bit.band(roleFlag, S_SPECIALIZATION_ROLE_HEAL_FLAG)
end