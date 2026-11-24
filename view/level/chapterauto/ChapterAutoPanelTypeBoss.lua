local ChapterAutoPanelTypeBoss = class("ChapterAutoPanelTypeBoss", import(".ChapterAutoPanel"))

function ChapterAutoPanelTypeBoss:getUIName()
	return "ChapterAutoPanelTypeBoss"
end

function ChapterAutoPanelTypeBoss:Enter(arg_2_1)
	self.expeditionId = arg_2_1
	self.config = pg.expedition_auto_statistics[self.expeditionId]
	self.oilCostOnce = self.config.oil_limit
	self.proficiencyOnce = self.config.base_class_exp

	local var_2_0 = getProxy(ChapterAutoProxy)

	self.timeCostOnce = var_2_0:GetRecord(ChapterAutoProxy.TYPE.BOSS, self.expeditionId)
	self.remainTime = var_2_0:GetRemainTime()
	self.storeOil = var_2_0:GetOil()

	setActive(self.uiStoreOilTF, self.storeOil > 0)
	setText(self.uiStoreOilTF:Find("Text"), i18n("auto_battle_oil_store_tip", self.storeOil))

	self.count = self.remainTime >= self.timeCostOnce and 1 or 0
	self.ticketCnt = 0

	self:RefreshTickets()
	self.leftPageUtil:setDefaultNum(self.count)
	self:RefreshLeftPageUtil()
	self:UpdateLeftContent()
	self.rightPageUtil:setDefaultNum(0)
	self:RefreshRightPageUtil()
	self:UpdateRightContent()

	self.awards = ChapterAutoPanelTypeBoss.GetAwards(self.expeditionId)

	self.awardUIList:align(#self.awards)
	self:Show()
end

function ChapterAutoPanelTypeBoss:RefreshView()
	self:Enter(self.expeditionId)
end

function ChapterAutoPanelTypeBoss:UpdateRightContent()
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

		pg.m02:sendNotification(GAME.START_CHAPTER_AUTO, {
			type = ChapterAutoProxy.TYPE.BOSS,
			id = self.expeditionId,
			num = self.count,
			ticketNum = self.ticketCnt
		})
	end, SFX_PANEL)
end

function ChapterAutoPanelTypeBoss:UpdateAwardTpl(arg_6_1, arg_6_2)
	local var_6_0 = Drop.Create(self.awards[arg_6_1 + 1])

	updateDrop(arg_6_2, var_6_0)
	onButton(self, arg_6_2, function()
		self:emit(BaseUI.ON_DROP, var_6_0)
	end, SFX_PANEL)
end

function ChapterAutoPanelTypeBoss:GetAwards()
	local var_8_0 = Clone(pg.expedition_data_template[self].award_display)
	local var_8_1 = checkExist(pg.expedition_activity_template[self], {
		"pt_drop_display"
	})

	if var_8_1 and type(var_8_1) == "table" then
		local var_8_2 = getProxy(ActivityProxy)

		for iter_8_0 = #var_8_1, 1, -1 do
			local var_8_3, var_8_4, var_8_5, var_8_6 = unpack(var_8_1)
			local var_8_7 = var_8_2:getActivityById(var_8_3)

			if var_8_7 and not var_8_7:isEnd() then
				if var_8_4 == DROP_TYPE_RESOURCE then
					table.insert(var_8_0, 1, {
						DROP_TYPE_ITEM,
						id2ItemId(var_8_5)
					})
				else
					table.insert(var_8_0, 1, {
						var_8_4,
						var_8_5
					})
				end
			end
		end
	end

	if type(pg.expedition_auto_statistics[self].drop_display_extra) == "table" then
		for iter_8_1, iter_8_2 in ipairs(pg.expedition_auto_statistics[self].drop_display_extra) do
			table.insert(var_8_0, {
				iter_8_2[1],
				iter_8_2[2]
			})
		end
	end

	return var_8_0
end

return ChapterAutoPanelTypeBoss
