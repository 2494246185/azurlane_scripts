local PTRankActivity = class("PTRankActivity", import("model.vo.Activity"))

function PTRankActivity:GetPTDrop()
	local var_1_0 = self:getConfig("config_data")

	return Drop.New({
		count = 0,
		type = (type(var_1_0) == "table" or nil) and (var_1_0[1] or DROP_TYPE_RESOURCE),
		id = self:getConfig("config_id")
	})
end

function PTRankActivity:GetTotalPtCount()
	return self.data1
end

function PTRankActivity:IsShowRank()
	local var_3_0 = self:getConfig("config_data")
	local var_3_1 = type(var_3_0)
	local var_3_2

	if var_3_1 == "table" then
		var_3_2 = var_3_0[2]

		if not var_3_0[2] then
			if var_3_1 == "number" then
				var_3_2 = tonumber(var_3_0) or 0
			end
		end
	end

	return var_3_2 > 0
end

return PTRankActivity
