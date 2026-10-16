local NewEducateSelectScene = class("NewEducateSelectScene", import("view.base.BaseUI"))

function NewEducateSelectScene:getUIName()
	return "NewEducateSelectUI"
end

function NewEducateSelectScene:getResource()
	local var_2_0 = {
		"ui/PerformUI",
		"cue/qe-ova-10.b",
		"painting/linghangyuan1_1",
		"storyicon/zhihuiguan",
		"ui/neweducatecommonui_atlas",
		"ui/neweducatescheduleui_atlas",
		"cue/story-richang-quiet.b"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	for iter_2_0, iter_2_1 in ipairs(pg.secretary_special_ship.all) do
		if noEmptyStr(pg.secretary_special_ship[iter_2_1].prefab) and not table.contains(var_2_0, "painting/" .. pg.secretary_special_ship[iter_2_1].prefab) then
			var_2_1("painting/" .. pg.secretary_special_ship[iter_2_1].prefab)
			var_2_1("paintingface/" .. pg.secretary_special_ship[iter_2_1].prefab)
			var_2_1("squareicon/" .. pg.secretary_special_ship[iter_2_1].prefab)
			var_2_1("qicon/" .. pg.secretary_special_ship[iter_2_1].prefab)
		end
	end

	for iter_2_2, iter_2_3 in ipairs(pg.child2_benefit_list.all) do
		if noEmptyStr(pg.child2_benefit_list[iter_2_3].item_icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_benefit_list[iter_2_3].item_icon) then
			var_2_1("neweducateicon/" .. pg.child2_benefit_list[iter_2_3].item_icon)
		end

		if noEmptyStr(pg.child2_benefit_list[iter_2_3].item_icon_little) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_benefit_list[iter_2_3].item_icon_little) then
			var_2_1("neweducateicon/" .. pg.child2_benefit_list[iter_2_3].item_icon_little)
		end
	end

	for iter_2_4, iter_2_5 in ipairs(pg.child2_resource.all) do
		if noEmptyStr(pg.child2_resource[iter_2_5].icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_resource[iter_2_5].icon) then
			var_2_1("neweducateicon/" .. pg.child2_resource[iter_2_5].icon)
		end

		if noEmptyStr(pg.child2_resource[iter_2_5].item_icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_resource[iter_2_5].item_icon) then
			var_2_1("neweducateicon/" .. pg.child2_resource[iter_2_5].item_icon)
		end
	end

	for iter_2_6, iter_2_7 in ipairs(pg.child2_attr.all) do
		if noEmptyStr(pg.child2_attr[iter_2_7].icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_attr[iter_2_7].icon) then
			var_2_1("neweducateicon/" .. pg.child2_attr[iter_2_7].icon)
		end

		if noEmptyStr(pg.child2_attr[iter_2_7].item_icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_attr[iter_2_7].item_icon) then
			var_2_1("neweducateicon/" .. pg.child2_attr[iter_2_7].item_icon)
		end
	end

	for iter_2_8, iter_2_9 in ipairs(pg.child2_memory.all) do
		if noEmptyStr(pg.child2_memory[iter_2_9].pic) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_memory[iter_2_9].pic) then
			var_2_1("neweducateicon/" .. pg.child2_memory[iter_2_9].pic)
		end
	end

	for iter_2_10, iter_2_11 in ipairs(pg.child2_plan.all) do
		if noEmptyStr(pg.child2_plan[iter_2_11].icon_square) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_plan[iter_2_11].icon_square) then
			var_2_1("neweducateicon/" .. pg.child2_plan[iter_2_11].icon_square)
		end

		if noEmptyStr(pg.child2_plan[iter_2_11].plan_rectangle_2) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_plan[iter_2_11].plan_rectangle_2) then
			var_2_1("neweducateicon/" .. pg.child2_plan[iter_2_11].plan_rectangle_2)
		end
	end

	for iter_2_12, iter_2_13 in ipairs(pg.child2_site_display.all) do
		if noEmptyStr(pg.child2_site_display[iter_2_13].event_icon) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_site_display[iter_2_13].event_icon) then
			var_2_1("neweducateicon/" .. pg.child2_site_display[iter_2_13].event_icon)
		end

		if noEmptyStr(pg.child2_site_display[iter_2_13].event_title) and not table.contains(var_2_0, "neweducateicon/" .. pg.child2_site_display[iter_2_13].event_title) then
			var_2_1("neweducateicon/" .. pg.child2_site_display[iter_2_13].event_title)
		end
	end

	local var_2_2 = getProxy(EducateProxy):GetSelectInfo()

	if var_2_2 and var_2_2.bg then
		var_2_1("bg/" .. var_2_2.bg)
	end

	local var_2_3 = getProxy(NewEducateProxy)

	for iter_2_14, iter_2_15 in ipairs(pg.child2_data.all) do
		local var_2_4 = var_2_3:GetChar(iter_2_15)

		if var_2_4 then
			local var_2_5 = var_2_4:GetSelectInfo()

			if var_2_5 and var_2_5.bg then
				var_2_1("bg/" .. var_2_5.bg)
			end
		end

		local var_2_6 = pg.child2_data[iter_2_15]

		if pg.child2_data[iter_2_15] then
			if var_2_6.child2_data_personality_icon and #var_2_6.child2_data_personality_icon > 0 then
				for iter_2_16, iter_2_17 in ipairs(var_2_6.child2_data_personality_icon) do
					var_2_1("neweducateicon/" .. iter_2_17)
				end
			end

			if noEmptyStr(var_2_6.personality_bar_icon) then
				var_2_1("neweducateicon/" .. var_2_6.personality_bar_icon)
			end

			if var_2_6.personality_tag_icon and #var_2_6.personality_tag_icon > 0 then
				for iter_2_18, iter_2_19 in ipairs(var_2_6.personality_tag_icon) do
					for iter_2_20, iter_2_21 in ipairs(iter_2_19) do
						var_2_1("neweducateicon/" .. iter_2_21)
					end
				end
			end

			if var_2_6.spine_char then
				for iter_2_22, iter_2_23 in pairs(var_2_6.spine_char) do
					var_2_1("char/" .. iter_2_23)
				end
			end
		end
	end

	return table.insertto(var_2_0, NewEducateSelectScene.super.getResource(self))
end

function NewEducateSelectScene:preload(arg_4_1)
	pg.PerformMgr.GetInstance():CheckLoad(function()
		arg_4_1()
	end)
end

function NewEducateSelectScene:init()
	self.rootTF = self._tf:Find("root")
	self.bgTF = self.rootTF:Find("bg")
	self.sureBtn = self.rootTF:Find("window/sure_btn")

	setText(self.sureBtn:Find("Text"), i18n("child2_enter"))

	self.hardSureBtn = self.rootTF:Find("window/hard_sure_btn")

	setText(self.hardSureBtn:Find("Text"), i18n("child2_hard_enter"))

	local var_6_0 = self.rootTF:Find("window/info")

	self.hardTF = var_6_0:Find("hard")

	setText(self.hardTF:Find("Text"), i18n("child2_hard"))

	self.hardToggle = var_6_0:Find("hard/toggle")
	self.nameTF = var_6_0:Find("name")
	self.progressTF = var_6_0:Find("progress")
	self.gameTF = var_6_0:Find("game")
	self.topTF = self.rootTF:Find("adapt/top")
	self.contentTF = self.rootTF:Find("window/view/content")
end

function NewEducateSelectScene:InitData()
	self.infos = {}
	self.infos[0] = getProxy(EducateProxy):GetSelectInfo()

	local var_7_0 = getProxy(NewEducateProxy)

	for iter_7_0, iter_7_1 in ipairs(pg.child2_data.all) do
		self.infos[iter_7_1] = var_7_0:GetChar(iter_7_1):GetSelectInfo()
	end

	self.playerID = getProxy(PlayerProxy):getRawData().id

	if NewEducateHelper.IsShowNewChildTip() then
		self.newId = pg.child2_data.all[#pg.child2_data.all]

		NewEducateHelper.ClearShowNewChildTip()
	end
end

function NewEducateSelectScene:didEnter()
	onButton(self, self.topTF:Find("return_btn"), function()
		self:onBackPressed()
	end, SFX_PANEL)
	onButton(self, self.topTF:Find("btns/collect"), function()
		self:emit(NewEducateSelectMediator.GO_SUBLAYER, Context.New({
			mediator = NewEducateCollectEntranceMediator,
			viewComponent = NewEducateCollectEntranceLayer,
			data = {
				isSelect = true,
				id = self.selectedId
			}
		}))
	end, SFX_PANEL)
	onButton(self, self.sureBtn, function()
		self:EnterEasyMode()
	end, SFX_PANEL)
	onButton(self, self.hardSureBtn, function()
		self:EnterHardMode()
	end, SFX_PANEL)
	eachChild(self.contentTF, function(arg_13_0)
		onToggle(self, arg_13_0, function(arg_14_0)
			local var_14_0 = tonumber(arg_13_0.name)

			if arg_14_0 then
				PlayerPrefs.SetInt(self:GetSelectedLocalKey(), var_14_0)

				self.selectedId = var_14_0

				self:UpdataInfo()
				arg_13_0:SetAsLastSibling()
			end
		end, SFX_PANEL)
	end)
	onToggle(self, self.hardToggle, function(arg_15_0)
		quickPlayAnimation(self._tf:Find("root/window"), arg_15_0 and "anim_educate_select_chage" or "anim_educate_select_chage2")
		setActive(self.hardSureBtn, arg_15_0)
		setActive(self.sureBtn, not arg_15_0)
		setText(self.gameTF, (arg_15_0 and i18n("child2_hard") or "") .. i18n("child2_game_cnt", self.infos[self.selectedId].gameCnt))
	end, SFX_PANEL)
	self:InitData()

	local var_8_0 = self.newId

	if not self.newId then
		var_8_0 = PlayerPrefs.GetInt(self:GetSelectedLocalKey())
		var_8_0 = var_8_0 or 0
	end

	triggerToggle(self.contentTF:Find(tostring(var_8_0)), true)
end

function NewEducateSelectScene:GetSelectedLocalKey()
	return NewEducateConst.NEW_EDUCATE_SELECT_ID .. "_" .. self.playerID
end

function NewEducateSelectScene:UpdataInfo()
	local var_17_0 = self.infos[self.selectedId]

	setText(self.nameTF, self.infos[self.selectedId].name)
	setText(self.progressTF, var_17_0.progressStr)
	setImageSprite(self.bgTF, LoadSprite("bg/" .. var_17_0.bg), false)

	local var_17_1 = self.selectedId > 1 and var_17_0.gameCnt > 1

	setActive(self.hardTF, self.selectedId > 1 and var_17_0.gameCnt > 1)
	triggerToggle(self.hardToggle, var_17_1 and var_17_0.isHard)
	self:CheckGuide(var_17_1)
end

function NewEducateSelectScene:EnterEasyMode()
	if self.selectedId == 0 then
		self:EnterScene()

		return
	end

	local var_18_0 = {}

	if self.infos[self.selectedId].isHard then
		table.insert(var_18_0, function(arg_19_0)
			pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_COMMON_MSGBOX, {
				contentText = i18n("child2_switch_sure"),
				onConfirm = arg_19_0
			})
		end)
		table.insert(var_18_0, function(arg_20_0)
			self:emit(NewEducateSelectMediator.SWITCH_DIFFICULTY, {
				id = self.selectedId,
				difficulty = NewEducateChar.DIFFICULTY.EASY,
				callback = arg_20_0
			})
		end)
	end

	seriesAsync(var_18_0, function()
		self:EnterScene()
	end)
end

function NewEducateSelectScene:EnterHardMode()
	if self.selectedId == 0 then
		return
	end

	local var_22_0 = {}

	if not self.infos[self.selectedId].isHard then
		table.insert(var_22_0, function(arg_23_0)
			pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_COMMON_MSGBOX, {
				contentText = i18n("child2_switch_sure"),
				onConfirm = arg_23_0
			})
		end)
		table.insert(var_22_0, function(arg_24_0)
			self:emit(NewEducateSelectMediator.SWITCH_DIFFICULTY, {
				id = self.selectedId,
				difficulty = NewEducateChar.DIFFICULTY.HARD,
				callback = arg_24_0
			})
		end)
	end

	seriesAsync(var_22_0, function()
		self:EnterScene()
	end)
end

function NewEducateSelectScene:EnterScene()
	if self.selectedId == 0 then
		self:emit(NewEducateSelectMediator.GO_SCENE, SCENE.EDUCATE, {
			isMainEnter = true
		})
	else
		self:emit(NewEducateSelectMediator.GO_SCENE, SCENE.NEW_EDUCATE, {
			isMainEnter = true,
			id = self.selectedId
		})
	end
end

function NewEducateSelectScene:CheckGuide(arg_27_1)
	if arg_27_1 then
		if not pg.NewStoryMgr.GetInstance():IsPlayed("tb2_19") then
			pg.m02:sendNotification(GAME.STORY_UPDATE, {
				storyId = "tb2_19"
			})
			pg.NewGuideMgr.GetInstance():Play("tb2_19", {
				self.selectedId
			})
		end
	end
end

function NewEducateSelectScene:onBackPressed()
	if self.contextData.isTb1 then
		self:emit(NewEducateBaseUI.ON_HOME)
	else
		NewEducateSelectScene.super.onBackPressed(self)
	end
end

return NewEducateSelectScene
