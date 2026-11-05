local InteractSlot = class("InteractSlot")

function InteractSlot:Ctor(arg_1_1, arg_1_2)
	self.id = arg_1_1
	self.hostId = arg_1_2
end

function InteractSlot:GetHostId()
	return self.hostId
end

return InteractSlot
