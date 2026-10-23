local ChapterAutoPanelTypeWorldSingle = class("ChapterAutoPanelTypeWorldSingle", import(".ChapterAutoPanelTypeWorld"))

function ChapterAutoPanelTypeWorldSingle:getUIName()
	return "ChapterAutoPanelTypeWorldSingle"
end

function ChapterAutoPanelTypeWorldSingle:OnInit()
	self.ticketUIList:make(function(arg_3_0, arg_3_1, arg_3_2)
		if arg_3_0 == UIItemList.EventUpdate then
			setText(arg_3_2:Find("Text"), self.ticketList[arg_3_1 + 1]:GetCount())

			local var_3_0 = self.ticketList[arg_3_1 + 1]:IsForever()

			setActive(arg_3_2:Find("time"), not var_3_0)

			if not var_3_0 then
				local var_3_1 = self.ticketList[arg_3_1 + 1]:GetRemainTime()

				setText(arg_3_2:Find("time/Text"), i18n(var_3_1 > 86400 and "auto_battle_book_day" or "auto_battle_book_hour", (math.floor(var_3_1 / (var_3_1 > 86400 and 86400 or 3600)))))
			end
		end
	end)
	self.awardUIList:make(function(arg_4_0, arg_4_1, arg_4_2)
		arg_4_1 = arg_4_1 + 1

		if arg_4_0 == UIItemList.EventUpdate then
			local var_4_0 = self.awards[arg_4_1]

			updateDrop(arg_4_2, self.awards[arg_4_1])
			onButton(self, arg_4_2, function()
				self:emit(BaseUI.ON_DROP, var_4_0)
			end, SFX_PANEL)
		end
	end)
	onButton(self, self.uiStartBtn, function()
		if self.countMaps < 1 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_times_zero"))

			return
		end

		if self.needTicket and self.bookCount > self.ownTicketCnt then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_not_enough_resource"))

			return
		end

		if self.staminaCount > self.staminaMgr:GetTotalStamina() then
			self.staminaMgr:Show()

			return
		end

		self:OnStart()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bg"), function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self.uiCloseBtn, function()
		self:Hide()
	end, SFX_CANCEL)
end

function ChapterAutoPanelTypeWorldSingle:SetSlider()
	self.countMaps = 1
	self.staminaCount, self.bookCount, self.timeCount, self.expCount = 0, 0, 0, 0
	self.awards = {}

	for iter_9_0 = 1, self.countMaps do
		self.staminaCount = self.staminaCount + pg.world_auto_statistics[self.filterMaps[iter_9_0].id].oil_limit
		self.bookCount = self.bookCount + 1
		self.timeCount = self.timeCount + pg.world_auto_statistics[self.filterMaps[iter_9_0].id].time_correction
		self.expCount = self.expCount + pg.world_auto_statistics[self.filterMaps[iter_9_0].id].drop_expbook

		table.insertto(self.awards, pg.world_auto_statistics[self.filterMaps[iter_9_0].id].award_display)
	end

	setText(self.uiUtilCost:Find("value"), string.format("<icon name=stamina h=0.8 w=0.8 /><color=%s>%s×%d</color>", (self.world.staminaMgr:GetTotalStamina() < self.staminaCount or nil) and (COLOR_RED or COLOR_GREEN), i18n("world_ap"), self.staminaCount))

	local var_9_3 = ChapterAutoTicket.GetDrop(ChapterAutoTicket.TYPE.WORLD)

	var_9_3.count = self.bookCount

	setText(self.uiUtilCost:Find("value_1"), (self.needTicket or nil) and (string.format("<icon name=ticket h=0.8 w=0.8 /><color=%s>%s×%d</color>", (var_9_3.count > self.ownTicketCnt or nil) and (COLOR_RED or COLOR_GREEN), var_9_3:getName(), var_9_3.count) or ""))
	setText(self.uiUtilTime:Find("time"), pg.TimeMgr.GetInstance():DescCDTime(self.timeCount))
	setText(self.uiLeftProficiencyText, self.expCount)

	local var_9_6 = {}
	local var_9_7 = {}

	for iter_9_1, iter_9_2 in ipairs(self.awards) do
		local var_9_8 = Drop.New({
			count = 0,
			type = iter_9_2[1],
			id = iter_9_2[2]
		})

		if var_9_6[var_9_8.type .. "_" .. var_9_8.id] then
			-- block empty
		else
			var_9_6[var_9_8.type .. "_" .. var_9_8.id] = var_9_8

			table.insert(var_9_7, var_9_8)
		end
	end

	self.awards = var_9_7

	self.awardUIList:align(#self.awards)
end

function ChapterAutoPanelTypeWorldSingle:Enter(arg_10_1)
	self.world = nowWorld()
	self.ticketCnt = 0

	self:RefreshTickets()

	self.needTicket = false

	setActive(self.uiUtilCost:Find("Image_1"), self.needTicket)

	self.filterMaps = {
		self.world:GetMap(arg_10_1)
	}

	self:SetSlider()
end

function ChapterAutoPanelTypeWorldSingle:RefreshView()
	self:Enter(self.filterMaps[1].id)
end

function ChapterAutoPanelTypeWorldSingle:OnStart()
	pg.m02:sendNotification(GAME.START_WORLD_CHAPTER_AUTO, {
		type = ChapterAutoProxy.TYPE.WORLD,
		list = {
			self.filterMaps[1].id
		},
		needTicket = self.needTicket
	})
end

return ChapterAutoPanelTypeWorldSingle
