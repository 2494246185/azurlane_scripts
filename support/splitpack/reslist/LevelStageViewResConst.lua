ResList = ResList or {}
ResList.LevelStageViewResConst = {}

function ResList.LevelStageViewResConst:GetResource()
	local var_1_0 = {}
	local var_1_1 = self and self.chapterVO

	table.insertto(var_1_0, ResList.ChapterResConst.GetStrategyResList(self and self.chapterVO))
	table.insertto(var_1_0, ResList.ChapterResConst.GetCommanderSkillResList(var_1_1))
	table.insertto(var_1_0, ResList.ChapterResConst.GetFleetIconResList(var_1_1))

	return var_1_0
end

return ResList.LevelStageViewResConst
