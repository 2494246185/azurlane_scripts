local WorldCruiseAwardPage4PrevPeriod = class("WorldCruiseAwardPage4PrevPeriod", import("..pages.WorldCruiseAwardPage"))

function WorldCruiseAwardPage4PrevPeriod:getUIName()
	return "WorldCruiseAwardPage4PrevPeriod"
end

function WorldCruiseAwardPage4PrevPeriod:UpdateActivity()
	local var_2_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING):GetPreviousPeriodAct()

	self.activity = var_2_0

	assert(var_2_0, "prev period crusing activity is nil")

	for iter_2_0, iter_2_1 in pairs(var_2_0:GetCrusingInfo()) do
		self[iter_2_0] = iter_2_1
	end
end

function WorldCruiseAwardPage4PrevPeriod:Flush()
	self:UpdateActivity()
	WorldCruiseAwardPage4PrevPeriod.super.Flush(self, nil)
end

return WorldCruiseAwardPage4PrevPeriod
