local IslandDelayRecycleUnit = class("IslandDelayRecycleUnit", import(".IslandSceneUnit"))

function IslandDelayRecycleUnit:Ctor(arg_1_1, arg_1_2)
	IslandDelayRecycleUnit.super.Ctor(self, arg_1_1, arg_1_2)
end

function IslandDelayRecycleUnit:OnAttach(arg_2_1)
	IslandDelayRecycleUnit.super.OnAttach(self, arg_2_1)

	self.delayRemoveTimer = Timer.New(function()
		self:NotifiyCore(ISLAND_EVT.RMOVE_UNIT, IslandConst.UNIT_LIST_DELAY, self.data.id)
	end, self.data.delayRecycleTime, 1)

	self.delayRemoveTimer:Start()
end

function IslandDelayRecycleUnit:OnDetach()
	if self.delayRemoveTimer then
		self.delayRemoveTimer:Stop()

		self.delayRemoveTimer = nil
	end
end

return IslandDelayRecycleUnit
