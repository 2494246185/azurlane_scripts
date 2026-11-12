local IslandDelayCreationSystem = class("IslandDelayCreationSystem")

function IslandDelayCreationSystem:Ctor(arg_1_1)
	self.controller = arg_1_1
	self.timerDic = {}
end

function IslandDelayCreationSystem:InitUnit()
	for iter_2_0, iter_2_1 in ipairs(self.controller.sceneData.delayInitUnits) do
		if iter_2_1.delayTime then
			self:DelayInitUnit(iter_2_1)
		end
	end
end

function IslandDelayCreationSystem:DelayInitUnit(arg_3_1)
	local var_3_0 = Timer.New(function()
		self.controller:NotifiyCore(ISLAND_EVT.GEN_UNIT, arg_3_1)

		self.timerDic[arg_3_1.id] = nil
	end, arg_3_1.delayTime, 1)

	var_3_0:Start()

	self.timerDic[arg_3_1.id] = var_3_0
end

function IslandDelayCreationSystem:Dispose()
	for iter_5_0, iter_5_1 in pairs(self.timerDic) do
		iter_5_1:Stop()
	end

	self.controller = nil
	self.timerDic = nil
end

return IslandDelayCreationSystem
