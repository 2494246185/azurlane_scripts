local IslandComparableAllocator = class("IslandComparableAllocator")

function IslandComparableAllocator:Ctor(arg_1_1)
	self.controller = arg_1_1
	self.flags = {}

	self:OnInitFlags()
end

function IslandComparableAllocator:Flush()
	local var_2_0 = Clone(self.flags)

	self.flags = {}

	self:OnInitFlags(var_2_0)
	self:OnCompareSample(var_2_0, self.flags)
end

function IslandComparableAllocator:Dispose()
	self:OnDispose()

	self.controller = nil
	self.flags = nil
end

function IslandComparableAllocator:RemoveUnit(arg_4_1, arg_4_2)
	self.controller:NotifiyCore(ISLAND_EVT.RMOVE_UNIT, arg_4_1, arg_4_2)
end

function IslandComparableAllocator:GenUnit(arg_5_1)
	self.controller:NotifiyCore(ISLAND_EVT.GEN_UNIT, arg_5_1)
end

function IslandComparableAllocator:OnInitFlags()
	assert(false, "overwrite!!!")
end

function IslandComparableAllocator:IsVisible(arg_7_1)
	assert(false, "overwrite!!!")
end

function IslandComparableAllocator:OnCompareSample(arg_8_1, arg_8_2)
	assert(false, "overwrite!!!")
end

function IslandComparableAllocator:OnDispose()
	return
end

return IslandComparableAllocator
