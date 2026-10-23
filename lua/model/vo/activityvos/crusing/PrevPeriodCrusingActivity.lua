local PrevPeriodCrusingActivity = class("PrevPeriodCrusingActivity", import(".CrusingActivity"))

function PrevPeriodCrusingActivity.StaticExistPrevPeriodCrusingActivity()
	local var_1_0 = getProxy(ActivityProxy)

	if not var_1_0 then
		return false
	end

	local var_1_1 = var_1_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_1_1 and not var_1_1:isEnd() then
		local var_1_2 = var_1_1:GetPreviousPeriodAct()

		if var_1_2 and var_1_2:CanRecharge() then
			return true, var_1_2.id
		end
	end

	return false
end

function PrevPeriodCrusingActivity:Ctor(arg_2_1, arg_2_2)
	self.crusingActivity = arg_2_2
	self.id = arg_2_1
	self.configId = self.id

	self:SynCrusingActivity(arg_2_2)
end

function PrevPeriodCrusingActivity:CanRecharge()
	local var_3_0 = self:GetCrusingInfo()

	return var_3_0 and not var_3_0.isPay and pg.gameset.last_worldcruise_pay.key_value <= var_3_0.phase
end

function PrevPeriodCrusingActivity:SynCrusingActivity(arg_4_1)
	arg_4_1 = arg_4_1 or self.crusingActivity
	self.stopTime = arg_4_1.stopTime
	self.data1 = arg_4_1.data3
	self.data2 = arg_4_1.data4
	self.data3 = 0
	self.data4 = 0
	self.str_data1 = ""
	self.data1_list = {}

	for iter_4_0, iter_4_1 in ipairs(arg_4_1.data3_list or {}) do
		table.insert(self.data1_list, iter_4_1)
	end

	self.data2_list = {}

	for iter_4_2, iter_4_3 in ipairs(arg_4_1.data4_list or {}) do
		table.insert(self.data2_list, iter_4_3)
	end

	self.data3_list = {}
	self.data4_list = {}
	self.data1KeyValueList = {}
	self.buffList = {}
	self.clientData1 = 0
end

function PrevPeriodCrusingActivity:RevertSynCrusingActivity()
	self.crusingActivity.data3 = self.data1
	self.crusingActivity.data4 = self.data2
	self.crusingActivity.data3_list = {}

	for iter_5_0, iter_5_1 in ipairs(self.data1_list or {}) do
		table.insert(self.crusingActivity.data3_list, iter_5_1)
	end

	self.crusingActivity.data4_list = {}

	for iter_5_2, iter_5_3 in ipairs(self.data2_list or {}) do
		table.insert(self.crusingActivity.data4_list, iter_5_3)
	end
end

return PrevPeriodCrusingActivity
