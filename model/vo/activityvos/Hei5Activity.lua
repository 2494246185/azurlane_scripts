local Hei5Activity = class("Hei5Activity", import("model.vo.Activity"))

function Hei5Activity:GetHei5Info()
	local var_1_0 = pg.black_friday_battlepass_event_pt[self.id].pt
	local var_1_1 = {}
	local var_1_2 = {}

	for iter_1_0, iter_1_1 in ipairs(pg.black_friday_battlepass_event_pt[self.id].key_point_display) do
		var_1_2[iter_1_1] = true
	end

	for iter_1_2, iter_1_3 in ipairs(pg.black_friday_battlepass_event_pt[self.id].target) do
		table.insert(var_1_1, {
			id = iter_1_2,
			pt = iter_1_3,
			award = pg.black_friday_battlepass_event_award[pg.black_friday_battlepass_event_pt[self.id].award[iter_1_2]].drop_client,
			award_pay = pg.black_friday_battlepass_event_award[pg.black_friday_battlepass_event_pt[self.id].award_pay[iter_1_2]].drop_client,
			isImportent = var_1_2[iter_1_2]
		})
	end

	local var_1_3 = self.data1
	local var_1_4 = self.data2 == 1
	local var_1_5 = {}

	for iter_1_4, iter_1_5 in ipairs(self.data1_list) do
		var_1_5[iter_1_5] = true
	end

	local var_1_6 = {}

	for iter_1_6, iter_1_7 in ipairs(self.data2_list) do
		var_1_6[iter_1_7] = true
	end

	local var_1_7 = 0

	for iter_1_8, iter_1_9 in ipairs(var_1_1) do
		if var_1_3 < iter_1_9.pt then
			break
		else
			var_1_7 = iter_1_8
		end
	end

	return {
		ptId = var_1_0,
		awardList = var_1_1,
		pt = var_1_3,
		isPay = var_1_4,
		awardDic = var_1_5,
		awardPayDic = var_1_6,
		phase = var_1_7
	}
end

function Hei5Activity:GetHei5UnreceiveAward()
	local var_2_0 = {}
	local var_2_1 = {}

	for iter_2_0, iter_2_1 in ipairs(self.data1_list) do
		var_2_1[iter_2_1] = true
	end

	for iter_2_2, iter_2_3 in ipairs(pg.black_friday_battlepass_event_pt[self.id].target) do
		if iter_2_3 > self.data1 then
			break
		elseif not var_2_1[iter_2_3] then
			table.insert(var_2_0, Drop.Create(pg.black_friday_battlepass_event_award[pg.black_friday_battlepass_event_pt[self.id].award[iter_2_2]].drop_client))
		end
	end

	if self.data2 ~= 1 then
		return PlayerConst.MergePassItemDrop(var_2_0)
	end

	local var_2_2 = {}

	for iter_2_4, iter_2_5 in ipairs(self.data2_list) do
		var_2_2[iter_2_5] = true
	end

	for iter_2_6, iter_2_7 in ipairs(pg.black_friday_battlepass_event_pt[self.id].target) do
		if iter_2_7 > self.data1 then
			break
		elseif not var_2_2[iter_2_7] then
			table.insert(var_2_0, Drop.Create(pg.black_friday_battlepass_event_award[pg.black_friday_battlepass_event_pt[self.id].award_pay[iter_2_6]].drop_client))
		end
	end

	return PlayerConst.MergePassItemDrop(var_2_0)
end

function Hei5Activity:GetUpdateToastData(arg_3_1)
	if arg_3_1 and arg_3_1.data1 < pg.black_friday_battlepass_event_pt[self.id].target[#pg.black_friday_battlepass_event_pt[self.id].target] and self.data1 - arg_3_1.data1 > 0 then
		return {
			ptId = pg.black_friday_battlepass_event_pt[self.id].pt,
			ptCount = self.data1 - arg_3_1.data1
		}
	end
end

function Hei5Activity:SyncAwardRecords(arg_4_1)
	self.data1_list = {}
	arg_4_1 = arg_4_1 or pg.black_friday_battlepass_event_pt[self.id]

	for iter_4_0, iter_4_1 in ipairs(arg_4_1.target) do
		if iter_4_1 <= self.data1 then
			table.insert(self.data1_list, iter_4_1)
		else
			break
		end
	end

	self.data2_list = self.data2 == 1 and underscore.rest(self.data1_list, 1) or {}
end

function Hei5Activity:AddAwardRecord(arg_5_1)
	if not table.contains(self.data1_list, arg_5_1) then
		table.insert(self.data1_list, arg_5_1)
	end
end

function Hei5Activity:AddPayAwardRecord(arg_6_1)
	if not table.contains(self.data2_list, arg_6_1) then
		table.insert(self.data2_list, arg_6_1)
	end
end

return Hei5Activity
