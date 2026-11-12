local WorldOverviewLayer = class("WorldOverviewLayer", import("..base.BaseUI"))

function WorldOverviewLayer:getUIName()
	return "WorldOverviewUI"
end

function WorldOverviewLayer:getResource()
	return table.insertto({
		"scenes/worldoverview"
	}, WorldOverviewLayer.super.getResource(self))
end

function WorldOverviewLayer:preload(arg_3_1)
	self:LoadAtlasOverall(arg_3_1)
end

function WorldOverviewLayer:init()
	self.rtBg = self._tf:Find("bg")

	onButton(self, self.rtBg, function()
		self:closeView()
	end, SFX_CANCEL)
	setText(self._tf:Find("tip/Text"), i18n("click_back_tip"))

	self.rtTaskPanel = self._tf:Find("panel/middle/info_panel/task_panel")

	setActive(self.rtTaskPanel, false)
	setActive(self.rtTaskPanel:Find("btn_next"), false)

	self.entranceItemList = UIItemList.New(self.rtTaskPanel:Find("entrance_list/target_list"), self.rtTaskPanel:Find("entrance_list/target_tpl"))

	self.entranceItemList:make(function(arg_6_0, arg_6_1, arg_6_2)
		arg_6_1 = arg_6_1 + 1

		if arg_6_0 == UIItemList.EventUpdate then
			if self.entranceIds[arg_6_1] then
				setActive(arg_6_2:Find("Image"), true)
				setText(arg_6_2:Find("Text"), i18n("world_task_view1") .. nowWorld():GetEntrance(self.entranceIds[arg_6_1]):GetBaseMap():GetName())
			else
				setActive(arg_6_2:Find("Image"), true)
				setText(arg_6_2:Find("Text"), i18n("world_task_view1") .. i18n("world_task_view2"))
			end
		end
	end)

	self.areaItemList = UIItemList.New(self.rtTaskPanel:Find("entrance_list/target_list"), self.rtTaskPanel:Find("entrance_list/target_tpl"))

	self.areaItemList:make(function(arg_7_0, arg_7_1, arg_7_2)
		arg_7_1 = arg_7_1 + 1

		if arg_7_0 == UIItemList.EventUpdate then
			if self.areaIds[arg_7_1] then
				setActive(arg_7_2:Find("Image"), true)
				setText(arg_7_2:Find("Text"), i18n("world_task_view1") .. pg.world_regions_data[self.areaIds[arg_7_1]].name)
			else
				setActive(arg_7_2:Find("Image"), true)
				setText(arg_7_2:Find("Text"), i18n("world_task_view1") .. i18n("world_task_view2"))
			end
		end
	end)

	self.rtAchievementPanel = self._tf:Find("panel/middle/info_panel/achievement_panel")

	setActive(self.rtAchievementPanel, false)

	self.btnAchieve = self.rtAchievementPanel:Find("btn_all")

	onButton(self, self.btnAchieve, function()
		local var_8_0, var_8_1 = nowWorld():GetFinishAchievements()

		if #var_8_0 == 0 then
			pg.TipsMgr.GetInstance():ShowTips("without any award")
		else
			self:emit(WorldOverviewMediator.OnAchieveStar, var_8_0)
			self:closeView()
		end
	end, SFX_CONFIRM)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function WorldOverviewLayer:didEnter()
	self.mode = self.contextData.info.mode

	if self.mode == "Task" then
		self.taskId = self.contextData.info.taskId

		self:UpdateTaskPanel()
	elseif self.mode == "Achievement" then
		self:UpdateAchievementPanel()
	else
		self.entranceIds = self.contextData.info.ids
	end

	self._tf:GetComponent("DftAniEvent"):SetEndEvent(function(arg_10_0)
		local var_10_0 = {}

		_.each(self.entranceIds, function(arg_11_0)
			var_10_0[arg_11_0] = true
		end)

		if #self.entranceIds > 0 then
			self.wsAtlasOverall:UpdateTargetEntrance(self.entranceIds[1])
		end

		self.wsAtlasOverall:UpdateStaticMark(var_10_0, self:GetOverviewMark())
		self:DisplayAtlasOverall()

		if self.mode then
			setActive(self["rt" .. self.mode .. "Panel"], true)

			if self.mode == "Task" then
				eachChild(self.entranceItemList.container, function(arg_12_0)
					local var_12_0 = GetComponent(arg_12_0:Find("Text"), typeof(Typewriter))

					var_12_0:setSpeed(0.03)
					var_12_0:Play()
				end)

				local var_10_1 = GetComponent(self.rtTaskPanel:Find("entrance_list/target_tpl"):Find("Text"), typeof(Typewriter))

				var_10_1:setSpeed(0.03)
				var_10_1:Play()
			end
		end
	end)
end

function WorldOverviewLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)

	if self.mode then
		setActive(self["rt" .. self.mode .. "Panel"], false)
	end

	self:HideAtlasOverall()
	self:DisposeAtlasOverall()
end

function WorldOverviewLayer:GetOverviewMark()
	if self.mode == "Task" then
		if self.isTaskArea then
			return {
				"overview_port"
			}
		else
			return {
				"overview_task_port",
				"overview_task"
			}
		end
	elseif self.mode == "Achievement" then
		return {
			"overview_achievement",
			"overview_achievement"
		}
	else
		return {
			"overview_task_port",
			"overview_task"
		}
	end
end

function WorldOverviewLayer:UpdateTaskPanel()
	local var_15_0 = nowWorld()
	local var_15_1 = var_15_0:GetTaskProxy():getTaskById(self.taskId)

	assert(var_15_1, "without this doing task: " .. self.taskId)

	local var_15_2 = self.rtTaskPanel:Find("task_info")

	GetImageSpriteFromAtlasAsync("ui/worldtaskfloatui_atlas", pg.WorldToastMgr.Type2PictrueName[var_15_1.config.type], var_15_2:Find("type"), true)
	setText(var_15_2:Find("name/Text"), var_15_1.config.name)

	local var_15_3 = var_15_1:GetFollowingAreaId()

	if var_15_3 then
		self.isTaskArea = true
		self.entranceIds = underscore.to_array(var_15_0:GetAreaEntranceIds(var_15_3))
		self.areaIds = {
			var_15_3
		}

		self.areaItemList:align(math.max(#self.areaIds, 1))
	else
		self.isTaskArea = false
		self.entranceIds = {
			var_15_1:GetFollowingEntrance()
		}

		self.entranceItemList:align(math.max(#self.entranceIds, 1))
	end

	local var_15_4 = self.rtTaskPanel:Find("entrance_list/target_tpl")

	setActive(var_15_4:Find("Image"), false)
	setText(var_15_4:Find("Text"), i18n("world_task_view2") .. var_15_0:GetActiveEntrance():GetBaseMap():GetName())
end

function WorldOverviewLayer:UpdateAchievementPanel()
	local var_16_0 = nowWorld()
	local var_16_1, var_16_2, var_16_3 = var_16_0:CountAchievements()

	setText(self.rtAchievementPanel:Find("achievement_info/name/info/number"), var_16_1 + var_16_2 .. "/" .. var_16_3)

	local var_16_4, var_16_5 = var_16_0:GetFinishAchievements()
	local var_16_6 = 0

	for iter_16_0, iter_16_1 in ipairs(var_16_4) do
		var_16_6 = var_16_6 + #iter_16_1.star_list
	end

	local var_16_7 = self.rtAchievementPanel:Find("word_list/target_tpl")

	setActive(var_16_7:Find("Image"), true)
	setText(var_16_7:Find("Text"), i18n("world_target_count", "  " .. setColorStr(tostring(var_16_6), COLOR_YELLOW) .. "  "))

	self.entranceIds = var_16_5

	setActive(self.btnAchieve, pg.gameset.world_target_obtain.key_value <= #var_16_4)
end

function WorldOverviewLayer:DisplayAtlasOverall()
	if self.wsAtlasOverall then
		setActive(self.wsAtlasOverall.tfEntity:Find("Plane"), false)
		self.wsAtlasOverall:ShowOrHide(true)
	end
end

function WorldOverviewLayer:HideAtlasOverall()
	if self.wsAtlasOverall then
		self.wsAtlasOverall:ShowOrHide(false)
	end
end

function WorldOverviewLayer:LoadAtlasOverall(arg_19_1)
	local var_19_0 = {}

	if not self.wsAtlasOverall then
		table.insert(var_19_0, function(arg_20_0)
			self.wsAtlasOverall = WSAtlasOverall.New()

			self.wsAtlasOverall:Setup()
			self.wsAtlasOverall:LoadScene(function()
				self.wsAtlasOverall:UpdateAtlas(nowWorld():GetAtlas())

				return arg_20_0()
			end)
		end)
	end

	seriesAsync(var_19_0, function()
		return existCall(arg_19_1)
	end)
end

function WorldOverviewLayer:DisposeAtlasOverall()
	if self.wsAtlasOverall then
		self.wsAtlasOverall:Dispose()

		self.wsAtlasOverall = nil
	end
end

return WorldOverviewLayer
