local LevelDropUpActUtil = class("LevelDropUpActUtil")
local var_0_1 = "#-LevelDropUpActUtil-#"

function LevelDropUpActUtil.EixstLevelDropUpAct()
	local var_1_0 = getProxy(ActivityProxy)

	for iter_1_0, iter_1_1 in pairs(pg.expedition_data_template_act.get_id_list_by_act_id) do
		local var_1_1 = var_1_0:RawGetActivityById(iter_1_0)

		if var_1_1 and not var_1_1:isEnd() then
			return true
		end
	end

	return false
end

function LevelDropUpActUtil:IsDropUpChapter()
	local var_2_0 = getProxy(ActivityProxy)
	local var_2_1 = pg.expedition_data_template_act.get_id_list_by_chapter_id[self] or {}

	return var_2_1 and #var_2_1 > 0 and (function(arg_3_0)
		local var_3_0 = var_2_0:RawGetActivityById(arg_3_0)

		if var_3_0 and not var_3_0:isEnd() then
			return true
		end

		return false
	end)(pg.expedition_data_template_act[var_2_1[1]].act_id)
end

function LevelDropUpActUtil:IsLevelDropUpAct()
	for iter_4_0, iter_4_1 in pairs(pg.expedition_data_template_act.get_id_list_by_act_id) do
		if iter_4_0 == self then
			return true
		end
	end

	return false
end

function LevelDropUpActUtil:ShouldTipLevelDropUpAct()
	return PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. var_0_1 .. self, 0) == 0
end

function LevelDropUpActUtil:MarkTipLevelDropUpAct()
	if LevelDropUpActUtil.ShouldTipLevelDropUpAct(self) then
		PlayerPrefs.SetInt(getProxy(PlayerProxy):getRawData().id .. var_0_1 .. self, 1)
		PlayerPrefs.Save()
		getProxy(ActivityProxy):updateActivity(getProxy(ActivityProxy):RawGetActivityById(self))
	end
end

return LevelDropUpActUtil
