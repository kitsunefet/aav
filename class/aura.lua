AAV_Aura = {}
AAV_Aura.__index = AAV_Aura

function AAV_Aura:new(parent, spellid, type, pos, duration, stacks)
	
	local self = {}
	setmetatable(self, AAV_Aura)
	
	self.frame = AAV_Gui:createAura(parent, stacks)
	self.parent = parent
	self.spellid = spellid
	self.type = type
	self.position = pos
	self.duration = duration
	self.stacks = stacks

	-- TODO: may need this debug info to add buff/debuff duration in a future update
	-- if AAV_DEBUG_MODE then
	-- 	--print(type)
	-- 	print(spellid)
	-- 	print(duration)
	-- 	print(stacks)
	-- end
	
	return self
	
end
