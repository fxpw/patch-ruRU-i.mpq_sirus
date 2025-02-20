local pairs = pairs
local ipairs = ipairs
local next = next
local CreateFrame = CreateFrame

ObjectPoolMixin = {};

function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc)
	self.creationFunc = creationFunc;
	self.resetterFunc = resetterFunc;

	self.activeObjects = {};
	self.inactiveObjects = {};

	self.numActiveObjects = 0;
end

function ObjectPoolMixin:Acquire()
	local numInactiveObjects = #self.inactiveObjects;
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects];
		self.activeObjects[obj] = true;
		self.numActiveObjects = self.numActiveObjects + 1;
		self.inactiveObjects[numInactiveObjects] = nil;
		return obj, false;
	end

	local newObj = self.creationFunc(self);
	if self.resetterFunc and not self.disallowResetIfNew then
		self.resetterFunc(self, newObj);
	end
	self.activeObjects[newObj] = true;
	self.numActiveObjects = self.numActiveObjects + 1;
	return newObj, true;
end

function ObjectPoolMixin:Release(obj)
	if self:IsActive(obj) then
		self.inactiveObjects[#self.inactiveObjects + 1] = obj;
		self.activeObjects[obj] = nil;
		self.numActiveObjects = self.numActiveObjects - 1;
		if self.resetterFunc then
			self.resetterFunc(self, obj);
		end

		return true;
	end

	return false;
end

function ObjectPoolMixin:ReleaseAll()
	for obj in pairs(self.activeObjects) do
		self:Release(obj);
	end
end

function ObjectPoolMixin:SetResetDisallowedIfNew(disallowed)
	self.disallowResetIfNew = disallowed;
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects);
end

function ObjectPoolMixin:GetNextActive(current)
	return (next(self.activeObjects, current));
end

function ObjectPoolMixin:GetNextInactive(current)
	return (next(self.inactiveObjects, current));
end

function ObjectPoolMixin:IsActive(object)
	return (self.activeObjects[object] ~= nil);
end

function ObjectPoolMixin:GetNumActive()
	return self.numActiveObjects;
end

function ObjectPoolMixin:EnumerateInactive()
	return ipairs(self.inactiveObjects);
end

function CreateObjectPool(creationFunc, resetterFunc)
	local objectPool = CreateFromMixins(ObjectPoolMixin);
	objectPool:OnLoad(creationFunc, resetterFunc);
	return objectPool;
end

FramePoolMixin = CreateFromMixins(ObjectPoolMixin);

local pollFrameIndex = 0
local function FramePoolFactory(framePool)
	framePool.createdFrames = framePool.createdFrames + 1
	pollFrameIndex = pollFrameIndex + 1
	local parentName, frameName = framePool.parent and framePool.parent:GetName()
	if parentName then
		frameName = string.format("%sPoolFrame%s%i_%i", parentName, framePool.frameTemplate or "NoTemplate", framePool.createdFrames, pollFrameIndex)
	elseif framePool.frameTemplate then
		frameName = string.format("UnnamedPoolFrame%s%i_%i", framePool.frameTemplate, framePool.createdFrames, pollFrameIndex)
	else
		frameName = string.format("UnnamedPoolFrameNoTemplate%i_%i", framePool.createdFrames, pollFrameIndex)
	end
	return CreateFrame(framePool.frameType, frameName, framePool.parent, framePool.frameTemplate);
end

local function ForbiddenFramePoolFactory(framePool)
	return FramePoolFactory(framePool)
end

function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	if forbidden then
		local creationFunc = ForbiddenFramePoolFactory;
		if frameInitFunc ~= nil then
			creationFunc = function(framePool)
				local frame =  ForbiddenFramePoolFactory(framePool);
				frameInitFunc(frame);
				return frame;
			end
		end

		ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc);
	else
		local creationFunc = FramePoolFactory;
		if frameInitFunc ~= nil then
			creationFunc = function(framePool)
				local frame = FramePoolFactory(framePool);
				frameInitFunc(frame);
				return frame;
			end
		end

		ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc);
	end
	self.createdFrames = 0;
	self.frameType = frameType;
	self.parent = parent;
	self.frameTemplate = frameTemplate;
end

function FramePoolMixin:GetTemplate()
	return self.frameTemplate;
end

function FramePool_Hide(framePool, frame)
	frame:Hide();
end

function FramePool_HideAndClearAnchors(framePool, frame)
	frame:Hide();
	frame:ClearAllPoints();
end

function CreateFramePool(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	local framePool = CreateFromMixins(FramePoolMixin);
	framePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or FramePool_HideAndClearAnchors, forbidden, frameInitFunc);
	return framePool;
end

TexturePoolMixin = CreateFromMixins(ObjectPoolMixin);

local function TexturePoolFactory(texturePool)
	return texturePool.parent:CreateTexture(nil, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
end

function TexturePoolMixin:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, TexturePoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.textureTemplate = textureTemplate;
end

TexturePool_Hide = FramePool_Hide;
TexturePool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

function CreateTexturePool(parent, layer, subLayer, textureTemplate, resetterFunc)
	local texturePool = CreateFromMixins(TexturePoolMixin);
	texturePool:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc or TexturePool_HideAndClearAnchors);
	return texturePool;
end

FontStringPoolMixin = CreateFromMixins(ObjectPoolMixin);

local function FontStringPoolFactory(fontStringPool)
	return fontStringPool.parent:CreateFontString(nil, fontStringPool.layer, fontStringPool.fontStringTemplate, fontStringPool.subLayer);
end

function FontStringPoolMixin:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, FontStringPoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.fontStringTemplate = fontStringTemplate;
end

FontStringPool_Hide = FramePool_Hide;
FontStringPool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

function CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	local fontStringPool = CreateFromMixins(FontStringPoolMixin);
	fontStringPool:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc or FontStringPool_HideAndClearAnchors);
	return fontStringPool;
end

ActorPoolMixin = CreateFromMixins(ObjectPoolMixin);

local function ActorPoolFactory(actorPool)
	return actorPool.parent:CreateActor(nil, actorPool.actorTemplate);
end

function ActorPoolMixin:OnLoad(parent, actorTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, ActorPoolFactory, resetterFunc);
	self.parent = parent;
	self.actorTemplate = actorTemplate;
end

ActorPool_Hide = FramePool_Hide;
function ActorPool_HideAndClearModel(actorPool, actor)
	actor:ClearModel();
	actor:Hide();
end

function CreateActorPool(parent, actorTemplate, resetterFunc)
	local actorPool = CreateFromMixins(ActorPoolMixin);
	actorPool:OnLoad(parent, actorTemplate, resetterFunc or ActorPool_HideAndClearModel);
	return actorPool;
end

FramePoolCollectionMixin = {};

function CreateFramePoolCollection()
	local poolCollection = CreateFromMixins(FramePoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

function FramePoolCollectionMixin:OnLoad()
	self.pools = {};
end

function FramePoolCollectionMixin:GetNumActive()
	local numTotalActive = 0;
	for _, pool in pairs(self.pools) do
		numTotalActive = numTotalActive + pool:GetNumActive();
	end
	return numTotalActive;
end

-- Returns the pool, and whether or not the pool needed to be created.
function FramePoolCollectionMixin:GetOrCreatePool(frameType, parent, template, resetterFunc, forbidden)
	local pool = self:GetPool(template);
	if not pool then
		return self:CreatePool(frameType, parent, template, resetterFunc, forbidden), true;
	end
	return pool, false;
end

function FramePoolCollectionMixin:CreatePool(frameType, parent, template, resetterFunc, forbidden, frameInitFunc)
	assert(self:GetPool(template) == nil);
	local pool = CreateFramePool(frameType, parent, template, resetterFunc, forbidden, frameInitFunc);
	self.pools[template] = pool;
	return pool;
end

function FramePoolCollectionMixin:GetPool(template)
	return self.pools[template];
end

function FramePoolCollectionMixin:Acquire(template)
	local pool = self:GetPool(template);
	assert(pool);
	return pool:Acquire();
end

function FramePoolCollectionMixin:Release(object)
	for _, pool in pairs(self.pools) do
		if pool:Release(object) then
			-- Found it! Just return
			return;
		end
	end

	-- Huh, we didn't find that object
	assert(false);
end

function FramePoolCollectionMixin:ReleaseAllByTemplate(template)
	local pool = self:GetPool(template);
	if pool then
		pool:ReleaseAll();
	end
end

function FramePoolCollectionMixin:ReleaseAll()
	for key, pool in pairs(self.pools) do
		pool:ReleaseAll();
	end
end

function FramePoolCollectionMixin:EnumerateActiveByTemplate(template)
	local pool = self:GetPool(template);
	if pool then
		return pool:EnumerateActive();
	end

	return nop;
end

function FramePoolCollectionMixin:EnumerateActive()
	local currentPoolKey, currentPool = next(self.pools, nil);
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextActive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey);
				if currentPool then
					currentObject = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end

function FramePoolCollectionMixin:EnumerateInactiveByTemplate(template)
	local pool = self:GetPool(template);
	if pool then
		return pool:EnumerateInactive();
	end

	return nop;
end

FixedSizeFramePoolCollectionMixin = CreateFromMixins(FramePoolCollectionMixin);

function CreateFixedSizeFramePoolCollection()
	local poolCollection = CreateFromMixins(FixedSizeFramePoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

function FixedSizeFramePoolCollectionMixin:OnLoad()
	FramePoolCollectionMixin.OnLoad(self);
	self.sizes = {};
end

function FixedSizeFramePoolCollectionMixin:CreatePool(frameType, parent, template, resetterFunc, forbidden, maxPoolSize, preallocate)
	local pool = FramePoolCollectionMixin.CreatePool(self, frameType, parent, template, resetterFunc, forbidden);

	if preallocate then
		for i = 1, maxPoolSize do
			pool:Acquire();
		end
		pool:ReleaseAll();
	end

	self.sizes[template] = maxPoolSize;

	return pool;
end

function FixedSizeFramePoolCollectionMixin:Acquire(template)
	local pool = self:GetPool(template);
	assert(pool);

	if pool:GetNumActive() < self.sizes[template] then
		return pool:Acquire();
	end
	return nil;
end


FontStringPoolCollectionMixin = CreateFromMixins(FramePoolCollectionMixin);

function CreateFontStringPoolCollection()
	local poolCollection = CreateFromMixins(FontStringPoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

function FontStringPoolCollectionMixin:GetOrCreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	local pool = self:GetPool(fontStringTemplate);
	if not pool then
		pool = self:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	end
	return pool;
end

function FontStringPoolCollectionMixin:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	assert(self:GetPool(fontStringTemplate) == nil);
	local pool = CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	self.pools[fontStringTemplate] = pool;
	return pool;
end

function FontStringPoolCollectionMixin:CreatePoolIfNeeded(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	if not self:GetPool(fontStringTemplate) then
		self:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	end
end

function FontStringPoolCollectionMixin:Acquire(fontStringTemplate, parent, layer, subLayer, resetterFunc)
	local pool = self:GetOrCreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	local newString = pool:Acquire();

	if parent then
		newString:SetParent(parent);
	end

	if layer then
		newString:SetDrawLayer(layer, subLayer);
	end

	return newString;
end