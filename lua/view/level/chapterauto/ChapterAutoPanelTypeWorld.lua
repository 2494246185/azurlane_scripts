local ChapterAutoPanelTypeWorld = class("ChapterAutoPanelTypeWorld", import("view.base.BaseSubView"))

ChapterAutoPanelTypeWorld.Listeners = {
	onUpdateStamina = "OnUpdateStamina"
}

function ChapterAutoPanelTypeWorld:getUIName()
	return "ChapterAutoPanelTypeWorld"
end

function ChapterAutoPanelTypeWorld:OnLoaded()
	for iter_2_0, iter_2_1 in pairs(ChapterAutoPanelTypeWorld.Listeners) do
		self[iter_2_0] = function(...)
			ChapterAutoPanelTypeWorld[iter_2_1](self, ...)
		end
	end

	setText(self.uiStartBtn:Find("Text"), i18n("auto_battle_confirm_button"))
	setText(self.uiUtilTime:Find("header"), i18n("auto_battle_time_left"))
	setText(self.uiUtilCost:Find("header"), i18n("auto_battle_cost_extra"))
	setText(self.uiUtilTime:Find("header"), i18n("auto_battle_time_left"))
	setText(self.uiUtilCost:Find("header"), i18n("auto_battle_cost_extra"))
	setText(self.uiLeftProficiencyHeaderText, i18n("auto_battle_class_exp_head"))
	setText(self.uiUtilLevel:Find("title_bg/Text"), i18n("world_auto_plan_level"))
	setText(self.uiUtilCount:Find("title_bg/Text"), i18n("world_auto_plan_quantity"))
	setText(self.uiProficiency:Find("title_bg/Text"), i18n("auto_battle_base_loot"))
	setText(self.uiDrops:Find("title_bg/Text"), i18n("world_auto_plan_award"))
	setText(self.uiUtilLevel:Find("toggles/until_3/Text"), i18n("world_auto_level_less_3"))
	setText(self.uiUtilLevel:Find("toggles/4/Text"), "4")
	setText(self.uiUtilLevel:Find("toggles/5/Text"), "5")
	setText(self.uiUtilLevel:Find("toggles/all/Text"), i18n("world_auto_level_all"))

	self.ticketUIList = UIItemList.New(self.uiTicketTF, self.uiTicketTF:Find("tpl"))
	self.awardUIList = UIItemList.New(self.uiRightAwardContentTF, self.uiRightAwardContentTF:Find("item"))
end

function ChapterAutoPanelTypeWorld:InitData()
	self.mapDic = nowWorld():GetDelegateMapDic()
	self.countMax = getGameset("world_auto_battle_map_limit")[1]
	self.needTicket = false

	setActive(self.uiUtilCost:Find("Image_1"), self.needTicket)
end

function ChapterAutoPanelTypeWorld:CheckHazardInFilter(arg_5_1)
	for iter_5_0, iter_5_1 in pairs(self.toggleDic) do
		if iter_5_1 and switch(iter_5_0, {
			until_3 = function()
				return arg_5_1 < 4
			end,
			["4"] = function()
				return arg_5_1 == 4
			end,
			["5"] = function()
				return arg_5_1 == 5
			end,
			["6"] = function()
				return arg_5_1 == 6
			end,
			all = function()
				return true
			end
		}) then
			return true
		end
	end

	return false
end

function ChapterAutoPanelTypeWorld:CheckToggles()
	local var_11_0 = {}

	for iter_11_0, iter_11_1 in pairs(self.toggleDic) do
		if iter_11_1 then
			table.insert(var_11_0, iter_11_0)
		end
	end

	if #var_11_0 == 0 or #var_11_0 >= self.uiUtilLevel:Find("toggles").childCount - 1 then
		self.toggleDic = {
			all = true
		}
	else
		self.toggleDic = {}

		for iter_11_2, iter_11_3 in ipairs(var_11_0) do
			self.toggleDic[iter_11_3] = true
		end
	end

	eachChild(self.uiUtilLevel:Find("toggles"), function(arg_12_0, arg_12_1)
		triggerToggle(arg_12_0, tobool(self.toggleDic[arg_12_0.name]))
	end)

	self.filterMaps = {}

	for iter_11_4, iter_11_5 in pairs(self.mapDic) do
		if self:CheckHazardInFilter(iter_11_4) then
			table.insertto(self.filterMaps, iter_11_5)
		end
	end

	table.sort(self.filterMaps, CompareFuncs({
		function(arg_13_0)
			return arg_13_0:GetDanger()
		end,
		function(arg_14_0)
			return arg_14_0.id
		end
	}))

	local var_11_1 = math.min(self.countMax, #self.filterMaps)
	local var_11_2 = math.min(var_11_1, self.countMaps or 0)

	self.countMaps = nil

	self:SetSlider(var_11_2)
	setSlider(self.uiUtilCount:Find("Slider"), 0, var_11_1, var_11_2)
end

function ChapterAutoPanelTypeWorld:SetSlider(arg_15_1)
	arg_15_1 = calcFloor(arg_15_1)

	if self.countMaps == arg_15_1 then
		return
	end

	self.countMaps = arg_15_1

	setText(self.uiUtilCount:Find("Slider/Text"), string.format("%d/%d", self.countMaps, math.min(self.countMax, #self.filterMaps)))

	self.staminaCount, self.bookCount, self.timeCount, self.expCount = 0, 0, 0, 0
	self.awards = {}

	for iter_15_0 = 1, self.countMaps do
		self.staminaCount = self.staminaCount + pg.world_auto_statistics[self.filterMaps[iter_15_0].id].oil_limit
		self.bookCount = self.bookCount + 1
		self.timeCount = self.timeCount + pg.world_auto_statistics[self.filterMaps[iter_15_0].id].time_correction
		self.expCount = self.expCount + pg.world_auto_statistics[self.filterMaps[iter_15_0].id].drop_expbook

		table.insertto(self.awards, pg.world_auto_statistics[self.filterMaps[iter_15_0].id].award_display)
	end

	setText(self.uiUtilCost:Find("value"), string.format("<icon name=stamina h=0.8 w=0.8 /><color=%s>%s×%d</color>", (self.staminaMgr:GetTotalStamina() < self.staminaCount or nil) and (COLOR_RED or COLOR_GREEN), i18n("world_ap"), self.staminaCount))

	local var_15_3 = ChapterAutoTicket.GetDrop(ChapterAutoTicket.TYPE.WORLD)

	var_15_3.count = self.bookCount

	setText(self.uiUtilCost:Find("value_1"), (self.needTicket or nil) and (string.format("<icon name=ticket h=0.8 w=0.8 /><color=%s>%s×%d</color>", (var_15_3.count > self.ownTicketCnt or nil) and (COLOR_RED or COLOR_GREEN), var_15_3:getName(), var_15_3.count) or ""))
	setText(self.uiUtilTime:Find("time"), pg.TimeMgr.GetInstance():DescCDTime(self.timeCount))
	setText(self.uiLeftProficiencyText, self.expCount)

	local var_15_6 = {}
	local var_15_7 = {}

	for iter_15_1, iter_15_2 in ipairs(self.awards) do
		local var_15_8 = Drop.New({
			count = 0,
			type = iter_15_2[1],
			id = iter_15_2[2]
		})

		if var_15_6[var_15_8.type .. "_" .. var_15_8.id] then
			-- block empty
		else
			var_15_6[var_15_8.type .. "_" .. var_15_8.id] = var_15_8

			table.insert(var_15_7, var_15_8)
		end
	end

	self.awards = var_15_7

	self.awardUIList:align(#self.awards)
end

function ChapterAutoPanelTypeWorld:OnInit()
	self.toggleDic = {}

	eachChild(self.uiUtilLevel:Find("toggles"), function(arg_17_0, arg_17_1)
		local var_17_0 = arg_17_0.name

		onToggle(self, arg_17_0, function(arg_18_0)
			if tobool(self.toggleDic[var_17_0]) == arg_18_0 then
				return
			end

			if var_17_0 == "all" then
				self.toggleDic = {
					all = true
				}
			else
				self.toggleDic[var_17_0] = arg_18_0
				self.toggleDic.all = false
			end

			self:CheckToggles()
		end, SFX_PANEL)
	end)
	onSlider(self, self.uiUtilCount:Find("Slider"), function(arg_19_0)
		self:SetSlider(arg_19_0)
		setSlider(self.uiUtilCount:Find("Slider"), 0, math.min(self.countMax, #self.filterMaps), calcFloor(arg_19_0))
	end)
	self.ticketUIList:make(function(arg_20_0, arg_20_1, arg_20_2)
		if arg_20_0 == UIItemList.EventUpdate then
			setText(arg_20_2:Find("Text"), self.ticketList[arg_20_1 + 1]:GetCount())

			local var_20_0 = self.ticketList[arg_20_1 + 1]:IsForever()

			setActive(arg_20_2:Find("time"), not var_20_0)

			if not var_20_0 then
				local var_20_1 = self.ticketList[arg_20_1 + 1]:GetRemainTime()

				setText(arg_20_2:Find("time/Text"), i18n(var_20_1 > 86400 and "auto_battle_book_day" or "auto_battle_book_hour", (math.floor(var_20_1 / (var_20_1 > 86400 and 86400 or 3600)))))
			end
		end
	end)
	self.awardUIList:make(function(arg_21_0, arg_21_1, arg_21_2)
		arg_21_1 = arg_21_1 + 1

		if arg_21_0 == UIItemList.EventUpdate then
			local var_21_0 = self.awards[arg_21_1]

			updateDrop(arg_21_2, self.awards[arg_21_1])
			onButton(self, arg_21_2, function()
				self:emit(BaseUI.ON_DROP, var_21_0)
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

function ChapterAutoPanelTypeWorld:Show(...)
	self:BlurPanel(self._tf)
	self:RegisterStaminaMgr()
	self:Enter(...)
	ChapterAutoPanelTypeWorld.super.Show(self)
end

function ChapterAutoPanelTypeWorld:Hide()
	self:UnOverlayPanel(self._tf, self.viewComponent.rtPanelList)
	self:RemoveStaminaMgr()
	ChapterAutoPanelTypeWorld.super.Hide(self)
end

function ChapterAutoPanelTypeWorld:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end
end

function ChapterAutoPanelTypeWorld:RegisterStaminaMgr()
	self:RemoveStaminaMgr()

	self.staminaMgr = nowWorld().staminaMgr

	self.staminaMgr:AddListener(WorldStaminaManager.EventUpdateStamina, self.onUpdateStamina)
end

function ChapterAutoPanelTypeWorld:RemoveStaminaMgr()
	if not self.staminaMgr then
		return
	end

	self.staminaMgr:RemoveListener(WorldStaminaManager.EventUpdateStamina, self.onUpdateStamina)

	self.staminaMgr = nil
end

function ChapterAutoPanelTypeWorld:OnUpdateStamina()
	self:RefreshView()
end

function ChapterAutoPanelTypeWorld:Enter()
	self:InitData()

	self.ticketCnt = 0

	self:RefreshTickets()

	self.toggleDic = {
		all = true
	}

	self:CheckToggles()
end

function ChapterAutoPanelTypeWorld:RefreshView()
	self:Enter()
end

function ChapterAutoPanelTypeWorld:RefreshTickets()
	local var_34_0 = getProxy(ChapterAutoProxy)

	self.ticketList = var_34_0:GetTicketListByType(ChapterAutoTicket.TYPE.WORLD)

	table.sort(self.ticketList, CompareFuncs({
		function(arg_35_0)
			return arg_35_0.id
		end
	}))
	self.ticketUIList:align(#self.ticketList)

	self.ownTicketCnt = var_34_0:GetValidTicketCntByType(ChapterAutoTicket.TYPE.WORLD)
end

function ChapterAutoPanelTypeWorld:OnStart(arg_36_1)
	local var_36_0 = {
		type = ChapterAutoProxy.TYPE.WORLD
	}

	var_36_0.list = underscore(self.filterMaps):chain():first(self.countMaps):map(function(arg_37_0)
		return arg_37_0.id
	end):value()
	var_36_0.needTicket = self.needTicket

	pg.m02:sendNotification(GAME.START_WORLD_CHAPTER_AUTO, var_36_0)
end

return ChapterAutoPanelTypeWorld
