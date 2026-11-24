local ChapterAutoPanelTypeRush = class("ChapterAutoPanelTypeRush", import(".ChapterAutoPanel"))

function ChapterAutoPanelTypeRush:getUIName()
	return "ChapterAutoPanelTypeRush"
end

function ChapterAutoPanelTypeRush:Enter(arg_2_1)
	self.activity = getProxy(ActivityProxy):getActivityById(pg.activity_series_enemy_auto[arg_2_1].link_id)

	assert(self.activity, "activity not found for seriesId: " .. arg_2_1)

	self.seriesId = arg_2_1
	self.config = pg.activity_series_enemy_auto[self.seriesId]
	self.oilCostOnce = self.config.oil_limit
	self.proficiencyOnce = self.config.base_class_exp

	local var_2_0 = getProxy(ChapterAutoProxy)

	self.timeCostOnce = var_2_0:GetRecord(ChapterAutoProxy.TYPE.RUSH, self.seriesId)
	self.remainTime = var_2_0:GetRemainTime()
	self.remasterTicketCost = BossRushChapterRemasterHelper.GetPermanentActivityTicketCost(self.activity.actId, self.seriesId)
	self.storeOil = var_2_0:GetOil()

	setActive(self.uiStoreOilTF, self.storeOil > 0)
	setText(self.uiStoreOilTF:Find("Text"), i18n("auto_battle_oil_store_tip", self.storeOil))
	setText(self.uiTipText, (pg.activity_series_enemy[arg_2_1].whether_singlefight ~= 1 and "" or i18n(self.activity:IsPassWithMulti(arg_2_1) and "auto_battle_series_finish_tip" or "auto_battle_series_tip") .. "\n") .. i18n("auto_battle_info_tips"))

	self.count = self.remainTime >= self.timeCostOnce and 1 or 0
	self.ticketCnt = 0

	self:RefreshTickets()
	self.leftPageUtil:setDefaultNum(self.count)
	self:RefreshLeftPageUtil()
	self:UpdateLeftContent()
	self.rightPageUtil:setDefaultNum(0)
	self:RefreshRightPageUtil()
	self:UpdateRightContent()

	self.awards = ChapterAutoPanelTypeRush.GetAwards(self.seriesId)

	self.awardUIList:align(#self.awards)
	self:Show()
end

function ChapterAutoPanelTypeRush:RefreshView()
	self:Enter(self.seriesId)
end

function ChapterAutoPanelTypeRush:UpdateRightContent()
	local var_4_0 = self.ticketCnt <= 0
	local var_4_1 = i18n("auto_battle_cost_oil", self.oilCostOnce * self.ticketCnt)
	local var_4_2 = self.oilCostOnce * self.ticketCnt - self.storeOil > getProxy(PlayerProxy):getRawData().oil

	if var_4_2 then
		var_4_1 = string.gsub(var_4_1, "#92fc63", COLOR_RED)
	end

	setText(self.uiRightCostOilText, var_4_0 and "" or var_4_1)

	local var_4_3 = i18n("auto_battle_cost_book", self.ticketCnt)
	local var_4_4 = self.ticketCnt > self.ownTicketCnt

	if self.ticketCnt > self.ownTicketCnt then
		var_4_3 = string.gsub(var_4_3, "#92fc63", COLOR_RED)
	end

	setText(self.uiRightCostTicketText, var_4_0 and "" or var_4_3)
	setActive(self.awardEmptyTF, var_4_0)
	setActive(self.oilCostTF:Find("empty"), var_4_0)
	setActive(self.ticketCostTF:Find("empty"), var_4_0)

	GetOrAddComponent(self.oilCostTF, typeof(CanvasGroup)).alpha = var_4_0 and 0.5 or 1
	GetOrAddComponent(self.ticketCostTF, typeof(CanvasGroup)).alpha = var_4_0 and 0.5 or 1

	onButton(self, self.uiStartBtn, function()
		if self.count <= 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_times_zero"))

			return
		end

		if var_4_2 or var_4_4 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_not_enough_resource"))

			return
		end

		if getProxy(ChapterProxy).remasterTickets < self.ticketCnt * self.remasterTicketCost then
			pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_remaster_tickets_not_enough"))

			return
		end

		self:OnStart()
	end, SFX_PANEL)
end

function ChapterAutoPanelTypeRush:OnStart()
	seriesAsync({
		function(arg_7_0)
			if self.remasterTicketCost > 0 and self.ticketCnt > 0 then
				if PlayerPrefs.GetString("remaster_tip") ~= pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d") then
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						showStopRemind = true,
						content = i18n("levelScene_activate_remaster_auto", self.ticketCnt * self.remasterTicketCost),
						onYes = function()
							if pg.MsgboxMgr.GetInstance().stopRemindToggle.isOn then
								PlayerPrefs.SetString("remaster_tip", pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d"))
							end

							arg_7_0()
						end
					})

					return
				end
			end

			arg_7_0()
		end
	}, function()
		pg.m02:sendNotification(GAME.START_CHAPTER_AUTO, {
			type = ChapterAutoProxy.TYPE.RUSH,
			id = self.seriesId,
			num = self.count,
			ticketNum = self.ticketCnt
		})
	end)
end

function ChapterAutoPanelTypeRush:UpdateAwardTpl(arg_10_1, arg_10_2)
	local var_10_0 = Drop.Create(self.awards[arg_10_1 + 1])

	updateDrop(arg_10_2, var_10_0)
	onButton(self, arg_10_2, function()
		self:emit(BaseUI.ON_DROP, var_10_0)
	end, SFX_PANEL)
end

function ChapterAutoPanelTypeRush:GetAwards()
	local var_12_0 = Clone(pg.activity_series_enemy[self].pass_awards_display)

	if type(pg.activity_series_enemy_auto[self].drop_display_extra) == "table" then
		for iter_12_0, iter_12_1 in ipairs(pg.activity_series_enemy_auto[self].drop_display_extra) do
			table.insert(var_12_0, {
				iter_12_1[1],
				iter_12_1[2]
			})
		end
	end

	local var_12_1 = getProxy(ActivityProxy):getActivityById(pg.activity_series_enemy_auto[self].link_id)

	if var_12_1 and var_12_1:IsPassWithMulti(self) then
		if type(pg.activity_series_enemy[self].additional_awards_display) == "table" then
			for iter_12_2, iter_12_3 in ipairs(pg.activity_series_enemy[self].additional_awards_display) do
				table.insert(var_12_0, {
					iter_12_3[1],
					iter_12_3[2],
					iter_12_3[3]
				})
			end
		end
	end

	return var_12_0
end

return ChapterAutoPanelTypeRush
