local PTBuffActivity = class("PTBuffActivity", import("model.vo.Activity"))

function PTBuffActivity:GetPTDrop()
	local var_1_0 = switch(self:getDataConfig("type"), {
		function()
			return DROP_TYPE_RESOURCE
		end,
		function()
			return DROP_TYPE_RESOURCE
		end,
		[8] = function()
			return DROP_TYPE_VITEM
		end,
		[9] = function()
			return DROP_TYPE_VITEM
		end
	})

	return var_1_0 and Drop.New({
		count = 0,
		type = var_1_0,
		id = self:getDataConfig("pt")
	}) or nil
end

function PTBuffActivity:GetTotalPtCount()
	assert(self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2)

	return self.data1
end

return PTBuffActivity
