local var_0_0 = {
	GetActivity = function()
		local var_1_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_PUZZLA)

		if var_1_0 == nil or var_1_0:isEnd() then
			return nil
		end

		if var_1_0:getConfig("config_id") == PuzzleActivity.CONFIG_ID_TYPE.EASTER_EGG then
			return var_1_0
		end
	end
}

function var_0_0:IsEnabled(arg_2_1)
	if self == nil then
		return false
	end

	return not table.contains(self.data2_list, (var_0_0.GetTemplateCfgID(self, arg_2_1)))
end

function var_0_0:GetTemplateCfgID(arg_3_1)
	return pg.activity_event_picturepuzzle[self.id].pickup_picturepuzzle[arg_3_1]
end

function var_0_0.GetHideBtnTime(arg_4_0)
	return 5
end

return var_0_0
