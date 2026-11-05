local CrusingActivity = class("CrusingActivity", import("model.vo.Activity"))

function CrusingActivity:Ctor(arg_1_1)
	CrusingActivity.super.Ctor(self, arg_1_1)

	self.previousPeriodAct = self:CreatePreviousPeriodAct()

	print("========================&", self.id, self.data3, self.data4)
end

function CrusingActivity:GetCrusingUnreceiveAward()
	assert(self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_PT_CRUSING, "type error")

	local var_2_0 = {}
	local var_2_1 = {}

	for iter_2_0, iter_2_1 in ipairs(self.data1_list) do
		var_2_1[iter_2_1] = true
	end

	for iter_2_2, iter_2_3 in ipairs(pg.battlepass_event_pt[self.id].target) do
		if iter_2_3 > self.data1 then
			break
		elseif not var_2_1[iter_2_3] then
			table.insert(var_2_0, Drop.Create(pg.battlepass_event_award[pg.battlepass_event_pt[self.id].award[iter_2_2]].drop_client))
		end
	end

	if self.data2 ~= 1 then
		return PlayerConst.MergePassItemDrop(var_2_0)
	end

	local var_2_2 = {}

	for iter_2_4, iter_2_5 in ipairs(self.data2_list) do
		var_2_2[iter_2_5] = true
	end

	for iter_2_6, iter_2_7 in ipairs(pg.battlepass_event_pt[self.id].target) do
		if iter_2_7 > self.data1 then
			break
		elseif not var_2_2[iter_2_7] then
			table.insert(var_2_0, Drop.Create(pg.battlepass_event_award[pg.battlepass_event_pt[self.id].award_pay[iter_2_6]].drop_client))
		end
	end

	return PlayerConst.MergePassItemDrop(var_2_0)
end

function CrusingActivity:GetCrusingInfo()
	assert(self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_PT_CRUSING, "type error")

	local var_3_0 = pg.battlepass_event_pt[self.id].pt
	local var_3_1 = {}
	local var_3_2 = {}

	for iter_3_0, iter_3_1 in ipairs(pg.battlepass_event_pt[self.id].key_point_display) do
		var_3_2[iter_3_1] = true
	end

	for iter_3_2, iter_3_3 in ipairs(pg.battlepass_event_pt[self.id].target) do
		table.insert(var_3_1, {
			id = iter_3_2,
			pt = iter_3_3,
			award = pg.battlepass_event_award[pg.battlepass_event_pt[self.id].award[iter_3_2]].drop_client,
			award_pay = pg.battlepass_event_award[pg.battlepass_event_pt[self.id].award_pay[iter_3_2]].drop_client,
			isImportent = var_3_2[iter_3_2]
		})
	end

	local var_3_3 = self.data1
	local var_3_4 = self.data2 == 1
	local var_3_5 = {}

	for iter_3_4, iter_3_5 in ipairs(self.data1_list) do
		var_3_5[iter_3_5] = true
	end

	local var_3_6 = {}

	for iter_3_6, iter_3_7 in ipairs(self.data2_list) do
		var_3_6[iter_3_7] = true
	end

	local var_3_7 = 0

	for iter_3_8, iter_3_9 in ipairs(var_3_1) do
		if var_3_3 < iter_3_9.pt then
			break
		else
			var_3_7 = iter_3_8
		end
	end

	return {
		ptId = var_3_0,
		awardList = var_3_1,
		pt = var_3_3,
		isPay = var_3_4,
		awardDic = var_3_5,
		awardPayDic = var_3_6,
		phase = var_3_7
	}
end

function CrusingActivity:GetUpdateToastData(arg_4_1)
	if arg_4_1 and arg_4_1.data1 < pg.battlepass_event_pt[self.id].target[#pg.battlepass_event_pt[self.id].target] and self.data1 - arg_4_1.data1 > 0 then
		return {
			ptId = pg.battlepass_event_pt[self.id].pt,
			ptCount = self.data1 - arg_4_1.data1
		}
	end
end

function CrusingActivity:SyncAwardRecords(arg_5_1)
	self.data1_list = {}
	arg_5_1 = arg_5_1 or pg.battlepass_event_pt[self.id]

	for iter_5_0, iter_5_1 in ipairs(arg_5_1.target) do
		if iter_5_1 <= self.data1 then
			table.insert(self.data1_list, iter_5_1)
		else
			break
		end
	end

	self.data2_list = self.data2 == 1 and underscore.rest(self.data1_list, 1) or {}
end

function CrusingActivity:AddAwardRecord(arg_6_1)
	if not table.contains(self.data1_list, arg_6_1) then
		table.insert(self.data1_list, arg_6_1)
	end
end

function CrusingActivity:AddPayAwardRecord(arg_7_1)
	if not table.contains(self.data2_list, arg_7_1) then
		table.insert(self.data2_list, arg_7_1)
	end
end

function CrusingActivity:CreatePreviousPeriodAct()
	if self.data3 > 0 and pg.battlepass_event_pt[self.id].related_activity and pg.battlepass_event_pt[self.id].related_activity ~= 0 then
		return PrevPeriodCrusingActivity.New(pg.battlepass_event_pt[self.id].related_activity, self)
	end

	return nil
end

function CrusingActivity:GetPreviousPeriodAct()
	return self.previousPeriodAct
end

function CrusingActivity:UpdatePreviousPeriodAct()
	if not self.previousPeriodAct then
		return
	end

	self.previousPeriodAct:RevertSynCrusingActivity(self)

	self.previousPeriodAct = self:CreatePreviousPeriodAct()
end

return CrusingActivity
