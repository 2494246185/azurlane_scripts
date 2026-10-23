local WorldCruiseChargePage4PrevPeriod = class("WorldCruiseChargePage4PrevPeriod", import("..pages.WorldCruiseChargePage"))

function WorldCruiseChargePage4PrevPeriod:getUIName()
	return "WorldCruiseChargePage4PrevPeriod"
end

function WorldCruiseChargePage4PrevPeriod:GetPassId()
	local var_2_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_2_0 and not var_2_0:isEnd() then
		local var_2_1 = var_2_0:GetPreviousPeriodAct()

		assert(var_2_1, "prev period crusing activity is nil")

		for iter_2_0, iter_2_1 in ipairs(pg.pay_data_display.all) do
			if pg.pay_data_display[iter_2_1].sub_display and type(pg.pay_data_display[iter_2_1].sub_display) == "table" and pg.pay_data_display[iter_2_1].sub_display[1] == var_2_1.id then
				return iter_2_1
			end
		end
	end

	return nil
end

return WorldCruiseChargePage4PrevPeriod
