local StarLightMedalAlbumView = class("StarLightMedalAlbumView", import("view.base.BaseUI"))

StarLightMedalAlbumView.ICON_SCALE = 1.35
StarLightMedalAlbumView.MEDAL_COUNT = 8

local function var_0_1(arg_1_0)
	return _.any(pg.activity_template[arg_1_0.id].config_data, function(arg_2_0)
		return Task.New({
			id = arg_2_0
		}):HasActMedalAward()
	end)
end

local function var_0_2()
	for iter_3_0, iter_3_1 in ipairs((getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_TASKS))) do
		if var_0_1(iter_3_1) then
			return iter_3_1
		end
	end

	return nil
end

function StarLightMedalAlbumView:GetHelpTips()
	local var_4_0 = var_0_2()

	if not var_4_0 then
		return ""
	end

	local var_4_1 = string.split(var_4_0:GetActivityTimeStr(), "-")

	_.each(pg.gametip.help_starLightAlbum.tip, function(arg_5_0)
		arg_5_0.info = string.gsub(arg_5_0.info, "$1", var_4_1[2])
	end)

	return pg.gametip.help_starLightAlbum.tip
end

function StarLightMedalAlbumView:getResource()
	local var_6_0 = {}
	local var_6_1 = self.GROUP_ID and pg.activity_medal_group[self.GROUP_ID]

	if self.GROUP_ID and pg.activity_medal_group[self.GROUP_ID] and var_6_1.item_show then
		local var_6_2 = {}

		local function var_6_3(arg_7_0)
			if noEmptyStr(arg_7_0) and not table.contains(var_6_2, arg_7_0) then
				table.insert(var_6_2, arg_7_0)
			end
		end

		for iter_6_0, iter_6_1 in ipairs(var_6_1.item_show) do
			if iter_6_1 and #iter_6_1 > 0 then
				local var_6_4 = {
					type = iter_6_1[1],
					id = iter_6_1[2]
				}

				var_6_4.count = iter_6_1[3] or 1

				local var_6_5 = Drop.New(var_6_4)
				local var_6_6 = var_6_5:getIcon()

				if var_6_5.type == DROP_TYPE_FURNITURE then
					var_6_6 = "furnitureicon/" .. var_6_6
				end

				var_6_3(var_6_6)
			end
		end

		for iter_6_2, iter_6_3 in ipairs(var_6_2) do
			table.insert(var_6_0, iter_6_3)
		end
	end

	table.insertto(var_6_0, StarLightMedalAlbumView.super.getResource(self))

	return var_6_0
end

function StarLightMedalAlbumView:SetMedalGroupData(arg_8_1)
	self.medalGroupList = arg_8_1
	self.currentMedalGroup = self.medalGroupList[self.GROUP_ID] or ActivityMedalGroup.New(self.GROUP_ID)

	if self.currentMedalGroup:GetMedalGroupState() == ActivityMedalGroup.STATE_ACTIVE then
		self.medalTaskView:SetMedalGroup(self.currentMedalGroup)
	end

	self.medalDetailView:SetMedalGroup(self.currentMedalGroup)

	local var_8_0 = self.currentMedalGroup:GetMedalIds()

	for iter_8_0 = 1, self.MEDAL_COUNT do
		LoadImageSpriteAsync("activitymedal/" .. var_8_0[iter_8_0] .. "_l", self.slots[iter_8_0].slot, true)
		LoadImageSpriteAsync("activitymedal/" .. var_8_0[iter_8_0], self.slots[iter_8_0].active, true)
	end
end

function StarLightMedalAlbumView:ShowPageBtn(arg_9_1)
	setActive(self.prevBtn, false)
	setActive(self.nextBtn, false)
end

function StarLightMedalAlbumView:UpdateMedalList()
	return
end

function StarLightMedalAlbumView:init()
	self:FindUI()

	self.loader = AutoLoader.New()
end

function StarLightMedalAlbumView:FindUI()
	local var_12_0 = self._tf:Find("Top")

	self.bg = self._tf:Find("mask")
	self.backBtn = var_12_0:Find("BackBtn")
	self.helpBtn = var_12_0:Find("InfoBtn")
	self.taskBtn = self._tf:Find("Desk/taskBtn")
	self.prevBtn = self._tf:Find("Desk/prevBtn")
	self.nextBtn = self._tf:Find("Desk/nextBtn")
	self.slots = {}

	for iter_12_0 = 1, self.MEDAL_COUNT do
		self.slots[iter_12_0] = {
			slot = self._tf:Find("Desk/Slot" .. iter_12_0),
			active = self._tf:Find("Desk/Slot" .. iter_12_0 .. "/active"),
			tips = self._tf:Find("Desk/Slot" .. iter_12_0 .. "/reddot"),
			click = self._tf:Find("Desk/Slot" .. iter_12_0 .. "/Click")
		}
	end

	self.medalLock = self._tf:Find("Desk/medal")
	self.trophyLock = self._tf:Find("Desk/trophy")
	self.medalDetailView = MedalDetailPanel.New(self._tf:Find("DetailView"), self)

	self.medalDetailView:SetIconScale(self.ICON_SCALE)

	self.medalTaskView = MedalTaskPanel.New(self._tf:Find("TaskView"), self)
end

function StarLightMedalAlbumView:didEnter()
	StarLightMedalAlbumView.super.didEnter(self)
	self:AddListener()
	self:UpdateView()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function StarLightMedalAlbumView:AddListener()
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)

	for iter_14_0 = 1, self.MEDAL_COUNT do
		onButton(self, self.slots[iter_14_0].click, function()
			self:showMedalView(iter_14_0)
		end)
	end

	onButton(self, self.taskBtn, function()
		self:showTaskView()
	end)
	onButton(self, self.bg, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		local var_19_0 = self:GetHelpTips()

		if not var_19_0 or var_19_0 == "" then
			return
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = var_19_0
		})
	end)
	onButton(self, self.medalLock, function()
		local var_20_0 = self.currentMedalGroup:getConfig("item_show")[2]

		self:emit(BaseUI.ON_DROP, {
			type = var_20_0[1],
			id = var_20_0[2],
			count = var_20_0[3]
		})
	end, SFX_PANEL)

	if self.trophyLock then
		onButton(self, self.trophyLock, function()
			local var_21_0 = self.currentMedalGroup:getConfig("item_show")[1]

			self:emit(BaseUI.ON_DROP, {
				type = var_21_0[1],
				id = var_21_0[2],
				count = var_21_0[3]
			})
		end, SFX_PANEL)
	end
end

function StarLightMedalAlbumView:showMedalView(arg_22_1)
	self.medalDetailView:SetCurrentIndex(arg_22_1)
	self.medalDetailView:UpdateMedal()
	self.medalDetailView:SetActive(true)
end

function StarLightMedalAlbumView:showTaskView()
	self.medalTaskView:ShowMedalTask()
	self.medalTaskView:SetActive(true)
end

function StarLightMedalAlbumView:UpdateView()
	local var_24_0 = self.currentMedalGroup:GetMedalIds()
	local var_24_1 = self.currentMedalGroup:GetMedalList()

	for iter_24_0 = 1, self.MEDAL_COUNT do
		if var_24_1[var_24_0[iter_24_0]].timeStamp then
			setActive(self.slots[iter_24_0].active, true)
		else
			setActive(self.slots[iter_24_0].active, false)
		end
	end

	if self.trophyLock then
		self.trophyLock:GetComponent(typeof(Image)).enabled = not self:OwnTrophy()
	end

	self.medalLock:GetComponent(typeof(Image)).enabled = not self:OwnMedal()

	setActive(self.taskBtn, self.currentMedalGroup:GetMedalGroupState() == ActivityMedalGroup.STATE_ACTIVE)
end

function StarLightMedalAlbumView:OwnTrophy()
	local var_25_0 = self.currentMedalGroup:getConfig("task_show")
	local var_25_1 = -1

	if var_25_0 and type(var_25_0) == "table" then
		var_25_1 = var_25_0[1]
	end

	if var_25_1 <= 0 then
		return false
	end

	return Task.OwnSpAward(pg.task_data_template[var_25_1].award_display[1])
end

function StarLightMedalAlbumView:OwnMedal()
	local var_26_0 = self.currentMedalGroup:getConfig("task_show")
	local var_26_1 = -1

	if var_26_0 and type(var_26_0) == "table" then
		var_26_1 = var_26_0[2]
	end

	if var_26_1 <= 0 then
		return false
	end

	return Task.OwnSpAward(pg.task_data_template[var_26_1].award_display[#pg.task_data_template[var_26_1].award_display])
end

function StarLightMedalAlbumView:FlushTaskPanel()
	self.medalTaskView:SetMedalGroup(self.currentMedalGroup)
	self.medalTaskView:ShowMedalTask()
end

function StarLightMedalAlbumView:willExit()
	self.medalDetailView:SetActive(false)
	self.medalTaskView:SetActive(false)
	self.medalDetailView:Dispose()
	self.medalTaskView:Dispose()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	self.loader:Clear()
end

return StarLightMedalAlbumView
