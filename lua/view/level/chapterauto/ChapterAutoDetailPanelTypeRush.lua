local ChapterAutoDetailPanelTypeRush = class("ChapterAutoDetailPanelTypeRush", import(".ChapterAutoDetailPanel"))

function ChapterAutoDetailPanelTypeRush:getUIName()
	return "ChapterAutoDetailPanelTypeRush"
end

function ChapterAutoDetailPanelTypeRush:Enter(arg_2_1)
	self.seriesId = arg_2_1
	self.config = pg.activity_series_enemy[self.seriesId]

	if self.config.boss_icon and self.config.boss_icon[1] then
		setActive(self.uiHeadTF, true)
		setImageSprite(self.uiHeadTF:Find("Image"), LoadSprite("qicon/" .. self.config.boss_icon[1][1]))
	else
		setActive(self.uiHeadTF, false)
	end

	setText(self.uiNameText, self.config.name)

	local var_2_0 = getProxy(ChapterAutoProxy)

	self.finishTime = var_2_0:GetFinishAllCommissionTime()

	local var_2_1 = var_2_0:GetCommissionList()

	self.proficiencyOnce = var_2_1[1]:GetClassExpAward()

	setText(self.uiProficiencyText, self.proficiencyOnce)

	self.awards = ChapterAutoDetailPanelTypeRush.GetAwards(self.seriesId)

	self.awardUIList:align(#self.awards)

	local var_2_2 = underscore.any(var_2_1, function(arg_3_0)
		return arg_3_0:UsedTicket()
	end)

	setActive(self.uiDropFrameTF:Find("scroll"), var_2_2)
	setActive(self.uiDropFrameTF:Find("empty"), not var_2_2)

	if pg.TimeMgr.GetInstance():GetServerTime() < self.finishTime then
		self:StartTimer()
	else
		self:UpdateContent()
	end

	self:Show()
end

function ChapterAutoDetailPanelTypeRush:UpdateAwardTpl(arg_4_1, arg_4_2)
	local var_4_0 = Drop.Create(self.awards[arg_4_1 + 1])

	updateDrop(arg_4_2, var_4_0)
	onButton(self, arg_4_2, function()
		self:emit(BaseUI.ON_DROP, var_4_0)
	end, SFX_PANEL)
end

function ChapterAutoDetailPanelTypeRush:GetAwards()
	return ChapterAutoPanelTypeRush.GetAwards(self)
end

return ChapterAutoDetailPanelTypeRush
