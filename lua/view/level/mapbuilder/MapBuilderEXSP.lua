local MapBuilderEXSP = class("MapBuilderEXSP", import(".MapBuilderSPSeriesFull"))

function MapBuilderEXSP:GetType()
	return MapBuilder.TYPEEXSP
end

function MapBuilderEXSP:getUIName()
	return "LevelSelectEXSPUI"
end

function MapBuilderEXSP:OnInit()
	MapBuilderEXSP.super.OnInit(self)

	self.personalBtn = self._tf:Find("Story/PersonalCard")
	self.personalPage = SecretsAbyssPersonalPage.New(self._tf, self, {})

	onButton(self, self.personalBtn, function()
		self.personalPage:ExecuteAction("Show")
	end)
end

function MapBuilderEXSP:OnDestroy()
	self.personalPage:Destroy()

	self.personalBtn = nil

	MapBuilderEXSP.super.OnDestroy(self)
end

function MapBuilderEXSP:UpdateMapVO(arg_6_1)
	MapBuilderEXSP.super.UpdateMapVO(self, arg_6_1)

	if self.activity:getConfig("config_client").roll_task then
		self.personalPage:RegisterRandomCallback(function()
			self.sceneParent:emit(LevelMediator2.ON_UPDATE_LOWPRIORITY_TASK, self.activity:getConfig("config_client").roll_task)
		end)
	end
end

function MapBuilderEXSP:SetDisplayMode(arg_8_1)
	MapBuilderEXSP.super.SetDisplayMode(self, arg_8_1)

	if self.contextData.displayMode == MapBuilderEXSP.DISPLAY.BATTLE then
		quickPlayAnimation(self._tf, "Anim_LevelSelectAtelierYumia_Battle_In")
	else
		quickPlayAnimation(self._tf, "Anim_LevelSelectAtelierYumia_In")
	end
end

function MapBuilderEXSP:PlayerLevelTplAnimation(arg_9_1, arg_9_2)
	quickPlayAnimation(arg_9_1, switch(arg_9_2.status, {
		Lock = function()
			return "Anim_LevelSelectAtelierYumia_LevelTplLock_In"
		end,
		Normal = function()
			return "Anim_LevelSelectAtelierYumia_LevelTpNormal_In"
		end,
		Hard = function()
			return "Anim_LevelSelectAtelierYumia_LevelTpHard_In"
		end
	}))
end

function MapBuilderEXSP:UpdateStory()
	local var_13_1 = pg.NewStoryMgr.GetInstance()
	local var_13_2 = 0
	local var_13_3 = 0
	local var_13_4 = {}

	for iter_13_0, iter_13_1 in pairs(self.storyNodesDict) do
		local var_13_5 = self.storyHolder:Find(tostring(iter_13_1.id))
		local var_13_6 = iter_13_1:IsActive(self.activity, self.ptActivity)
		local var_13_7 = iter_13_1:IsReaded()

		if not _G.isActive(var_13_5) and var_13_6 then
			setActive(var_13_5, var_13_6)
			quickPlayAnimation(var_13_5, switch(iter_13_1:GetType(), {
				[BossRushStoryNode.NODE_TYPE.NORMAL] = function()
					return "Anim_LevelSelectAtelierYumia_storytpl_In"
				end,
				[BossRushStoryNode.NODE_TYPE.BATTLE] = function()
					return "Anim_LevelSelectAtelierYumia_bettletpl_In"
				end,
				[BossRushStoryNode.NODE_TYPE.LOCATION] = function()
					return "Anim_LevelSelectAtelierYumia_Item_Lock_In"
				end
			}, function()
				assert(false)
			end))
		else
			setActive(var_13_5, var_13_6)
		end

		if iter_13_1:GetType() ~= BossRushStoryNode.NODE_TYPE.LOCATION then
			var_13_2 = var_13_2 + (var_13_7 and 1 or 0)
			var_13_3 = var_13_3 + 1

			if var_13_7 then
				table.insert(var_13_4, iter_13_1)
			end
		end

		if var_13_6 then
			local var_13_9 = iter_13_1:GetParams("item_lock")
			local var_13_10 = var_13_9 and Drop.Create(var_13_9[2]) or nil
			local var_13_11 = var_13_10 and var_13_10.count > var_13_10:getOwnedCount() and "item_lock" or switch(iter_13_1:GetType(), {
				[BossRushStoryNode.NODE_TYPE.NORMAL] = function()
					return "story"
				end,
				[BossRushStoryNode.NODE_TYPE.BATTLE] = function()
					return "battle"
				end,
				[BossRushStoryNode.NODE_TYPE.LOCATION] = function()
					return "location"
				end
			})

			eachChild(var_13_5, function(arg_21_0, arg_21_1)
				setActive(arg_21_0, arg_21_0.name == var_13_11)
			end)
			switch(var_13_11, {
				story = function(self)
					setText(self:Find("name/Text"), iter_13_1:GetName())
					onButton(self, self, function()
						if var_13_7 then
							return
						end

						self:PlayStory(iter_13_1:GetStory(), function()
							self:UpdateView()
							self:CheckAutoShowPersonal()
						end)
					end)
				end,
				battle = function(self)
					setText(self:Find("name/Text"), iter_13_1:GetName())
					onButton(self, self, function()
						if var_13_7 then
							return
						end

						self:PlayStory(iter_13_1:GetStory(), function()
							self:UpdateView()
							self:CheckAutoShowPersonal()
						end)
					end)
				end,
				location = function(self)
					setText(self:Find("name/Text"), iter_13_1:GetName())

					local var_28_0 = self:Find("en")

					if self:Find("en") then
						setActive(self:Find("en"), PLATFORM_CODE ~= PLATFORM_US)
						setText(self:Find("en"), iter_13_1:getConfig("en_name"))
					end
				end
			}, function()
				warning("error state without any display:", var_13_11)
			end, var_13_5:Find(var_13_11))
		end
	end

	setText(self.progressText, var_13_2 .. "/" .. var_13_3)
	setActive(self.storyAward, tobool(self.storyTask))

	if self.storyTask then
		local var_13_12 = Drop.Create(self.storyTask:getConfig("award_display")[1])

		updateDrop(self.storyAward:GetChild(0), var_13_12)

		local var_13_13 = self.storyTask:getTaskStatus()

		setActive(self.storyAward:Find("get"), var_13_13 == 1)
		setActive(self.storyAward:Find("got"), var_13_13 == 2)
		onButton(self, self.storyAward, function()
			self:emit(BaseUI.ON_DROP, var_13_12)
		end)
	end

	table.sort(var_13_4, function(arg_31_0, arg_31_1)
		return arg_31_0:getConfig("id") < arg_31_1:getConfig("id")
	end)

	local var_13_14 = var_13_4[#var_13_4]
	local var_13_15
	local var_13_16 = #var_13_4 - 1

	while var_13_16 > 0 do
		if #self.personalPage:GetActivitySingleEventOption(var_13_4[var_13_16]) > 0 then
			var_13_15 = var_13_4[var_13_16]

			break
		end

		var_13_16 = var_13_16 - 1
	end

	if var_13_14 and #self.personalPage:GetActivitySingleEventOption(var_13_14) > 0 or var_13_15 and #self.personalPage:GetActivitySingleEventOption(var_13_15) > 0 then
		setActive(self.personalBtn, true)
	else
		setActive(self.personalBtn, false)
	end

	var_13_15 = var_13_15 and var_13_15 or var_13_14

	self.personalPage:SetBossRushNode(var_13_14, var_13_15)

	if var_13_2 == var_13_3 then
		self.personalPage:UnlockRandom()
	end

	if self.activity:getConfig("config_client").first_story then
		pg.NewStoryMgr.GetInstance():Play(self.activity:getConfig("config_client").first_story)
	end
end

function MapBuilderEXSP:CheckAutoShowPersonal()
	if #self.personalPage:GetActivitySingleEventOption(self.personalPage:GetCurrentEvent()) > 0 then
		self.personalPage:SetUpgrade()
		self.personalPage:ExecuteAction("Show")
		self.personalPage:ExecuteAction("UpdateView")
	end
end

MapBuilderEXSP.presonalRandomData = nil

return MapBuilderEXSP
