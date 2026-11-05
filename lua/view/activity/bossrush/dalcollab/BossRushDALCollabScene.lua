local BossRushDALCollabScene = class("BossRushDALCollabScene", import("view.base.BaseUI"))

function BossRushDALCollabScene:getUIName()
	return "BossRushDALCollabUI"
end

function BossRushDALCollabScene:getAtalsName()
	return "ui/BossRushDALCollabUI_atlas"
end

function BossRushDALCollabScene:getResource()
	local var_3_0 = BossRushDALCollabScene.super.getResource(self)

	table.insert(var_3_0, self:getAtalsName())

	return var_3_0
end

function BossRushDALCollabScene:ResUISettings()
	return true
end

function BossRushDALCollabScene:Ctor()
	BossRushDALCollabScene.super.Ctor(self)

	self.loader = AutoLoader.New()
end

function BossRushDALCollabScene:preload(arg_6_1)
	existCall(arg_6_1)
	self.loader:LoadBundle(self:getAtalsName())
end

function BossRushDALCollabScene:OverlayComponent(arg_7_1)
	if arg_7_1 then
		self:OverlayPanel(self.top)
		self:OverlayPanel(self.right)
		self:OverlayPanel(self.pt)
		self:OverlayPanel(self.battleNodes)
	else
		self:UnOverlayPanel(self.top, self._tf)
		self:UnOverlayPanel(self.right, self._tf)
		self:UnOverlayPanel(self.pt, self._tf)
		self:UnOverlayPanel(self.battleNodes, self._tf)
	end
end

function BossRushDALCollabScene:init()
	self.top = self._tf:Find("Top")
	self.map = self._tf:Find("Map")
	self.right = self._tf:Find("Right")
	self.pt = self._tf:Find("PT")
	self.battleNodes = self._tf:Find("Battle")
	self.seriesNodes = _.map(_.range(self._tf:Find("Battle/Nodes").childCount), function(arg_9_0)
		return self._tf:Find("Battle/Nodes"):GetChild(arg_9_0 - 1)
	end)

	table.Foreach(self.seriesNodes, function(arg_10_0, arg_10_1)
		local var_10_0 = arg_10_1:Find("ship")
		local var_10_1 = var_10_0:GetComponent(typeof(Animation))

		var_10_0:GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
			if var_10_1:IsPlaying("anim_BossRushDALCollabUI_ship_out") then
				setActive(self._currentShip, true)
				setActive(self._currentShip:Find("vx_teleport_1"), true)
				setActive(var_10_0:Find("vx_teleport_2"), false)
				self:playAnima(self._currentShip, "anim_BossRushDALCollabUI_ship_in")
				setActive(var_10_0, false)
			elseif var_10_1:IsPlaying("anim_BossRushDALCollabUI_ship_in") then
				if self._openSeriesData then
					self.stageView:ExecuteAction("SetData", self._openSeriesData)
					self.stageView:ExecuteAction("Show")

					self.battleNodes:GetComponent(typeof(CanvasGroup)).interactable = true
					self._openSeriesData = nil
				end

				setActive(var_10_0:Find("vx_teleport_1"), false)

				self._lastShip = var_10_0
			end
		end)
	end)

	self.maps = {}

	for iter_8_0 = 1, 6 do
		self.maps[iter_8_0] = self._tf:Find("Map/map_" .. iter_8_0)
	end

	self.shiftMap = self._tf:Find("Map/Map_1")
	self.shiftMapList = {}

	for iter_8_1 = 1, 6 do
		self.shiftMapList[iter_8_1] = self.shiftMap:Find("map_" .. iter_8_1)
	end

	self.mapAnima = self._tf:Find("Map"):GetComponent(typeof(Animation))
	self.mapDftEvt = self._tf:Find("Map"):GetComponent(typeof(DftAniEvent))
	self.mapFX = self._tf:Find("Map/state_fx")
	self.upgradeBtn = self._tf:Find("Right/Upgrade")
	self.shopBtn = self._tf:Find("Right/Store")
	self.ptLabel = self._tf:Find("PT/pt_text/icon")
	self.ptIcon = self._tf:Find("PT/pt_text/icon/Image")
	self.ptCount = self._tf:Find("PT/pt_text/Text")

	setText(self.ptLabel, i18n("pt_count_tip"))

	self.ActionSequence = {}
	self.upgradeView = BossRushDALUpgradeView.New(self._tf, self.event, self.contextData)

	self.upgradeView:RegisterView(self)

	self.stageView = BossRushDALCollabStageView.New(self._tf, self.event, self.contextData)
end

function BossRushDALCollabScene:SetUpgradeActvity(arg_12_1)
	self.upgradeView:SetData(arg_12_1)
end

function BossRushDALCollabScene:SetActivity(arg_13_1)
	self.activity = arg_13_1
end

function BossRushDALCollabScene:SetPTActivity(arg_14_1)
	self.ptActivity = arg_14_1
end

function BossRushDALCollabScene:onBackPressed()
	if self.upgradeView:isShowing() then
		self.upgradeView:Hide()
	elseif self.stageView:isShowing() then
		self.stageView:Hide()
	else
		BossRushDALCollabScene.super.onBackPressed(self)
	end
end

function BossRushDALCollabScene:didEnter()
	onButton(self, self.top:Find("back_btn"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self.top:Find("option"), function()
		self:quickExitFunc()
	end, SFX_PANEL)
	onButton(self, self.upgradeBtn, function()
		self.upgradeView:ExecuteAction("Show")
	end, SFX_PANEL)
	onButton(self, self.top:Find("help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = {
				{
					info = i18n("dal_chapter_tip")
				}
			}
		})
	end, SFX_PANEL)
	onButton(self, self.shopBtn, function()
		local var_21_0 = getProxy(ActivityProxy):getActivityById(self.activity:getConfig("config_client").shopID)

		if not var_21_0 or var_21_0:isEnd() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(BossRushDALCollabMediator.GO_SHOPS_LAYER, {
			warp = NewShopsScene.TYPE_ACTIVITY,
			actId = var_21_0 and var_21_0.id
		})
	end, SFX_PANEL)
	self:PlayBGM()
	self:playAnima(self._tf, "anim_BossRushDALCollabUI_in")
	self:OverlayComponent(true)
end

function BossRushDALCollabScene:getBGM()
	if not pg.voice_bgm[self.__cname] then
		return nil
	end

	return pg.voice_bgm[self.__cname].bgm
end

function BossRushDALCollabScene:UpdateView()
	setActive(self.battleNodes, true)
	self:UpdateBattle()
	self:UpdateMap()
	self:updateActivityRes()
end

function BossRushDALCollabScene:playAnima(arg_24_1, arg_24_2, arg_24_3)
	arg_24_1:GetComponent(typeof(Animation)):Play(arg_24_2)

	if arg_24_3 then
		arg_24_1:GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
			arg_24_3()
		end)
	end
end

function BossRushDALCollabScene:PlayMapShiftAnima(arg_26_1, arg_26_2, arg_26_3)
	for iter_26_0, iter_26_1 in pairs(self.maps) do
		setImageSprite(iter_26_1, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_26_0 .. arg_26_2), true)
	end

	for iter_26_2, iter_26_3 in pairs(self.shiftMapList) do
		setImageSprite(iter_26_3, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_26_2 .. arg_26_1), true)
	end

	setActive(self.shiftMap, true)
	self.mapAnima:Play("anim_BossRushDALCollabUI_Map")
end

function BossRushDALCollabScene:updateActivityRes()
	setText(self.ptCount, "x" .. self.ptActivity.data1)
	GetImageSpriteFromAtlasAsync(Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = tonumber(self.ptActivity:getConfig("config_id"))
	}):getIcon(), "", self.ptIcon, true)
end

function BossRushDALCollabScene:UpdateMap()
	local var_28_0 = self.activity:GetCollabSeriesDataList()

	if var_28_0[6]:IsPass() and var_28_0[6]:GetDefeated(self.activity) then
		setActive(self.mapFX:Find("state_3"), true)
		setActive(self.mapFX:Find("state_4"), true)
		setActive(self.mapFX:Find("state_4/6_3"), true)

		for iter_28_0, iter_28_1 in pairs(self.maps) do
			if iter_28_0 ~= 1 and iter_28_0 ~= 6 then
				setActive(self.mapFX:Find("state_4/" .. iter_28_0), false)
			end

			setActive(iter_28_1, true)
			setImageSprite(iter_28_1, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_28_0), true)
		end
	elseif var_28_0[6]:IsPlayerUnlock(self.activity) and (not var_28_0[6]:IsPass() or not var_28_0[6]:GetDefeated(self.activity)) then
		setActive(self.mapFX:Find("state_4"), true)

		for iter_28_2, iter_28_3 in pairs(self.maps) do
			setActive(iter_28_3, true)

			if iter_28_2 == 6 then
				local var_28_1

				if var_28_0[6]:GetBossHpRate() > 0.5 then
					var_28_1 = "_1"

					setActive(self.mapFX:Find("state_4/6_1"), true)
				else
					setActive(self.mapFX:Find("state_4/6_2"), true)

					var_28_1 = "_2"
				end

				setImageSprite(iter_28_3, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_28_2 .. var_28_1), true)
			else
				setImageSprite(iter_28_3, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_28_2 .. "_3"), true)
			end
		end
	else
		setActive(self.mapFX:Find("state_2"), true)
		setActive(self.mapFX:Find("state_1"), true)
		setActive(self.mapFX:Find("state_3"), true)

		for iter_28_4, iter_28_5 in pairs(self.maps) do
			if iter_28_4 == 6 then
				setActive(iter_28_5, false)
			else
				setActive(iter_28_5, true)

				local var_28_4 = not var_28_0[iter_28_4]:GetDefeated(self.activity) and "_1" or var_28_0[iter_28_4]:GetBossTimeStamp() ~= 0 and "" or var_28_0[iter_28_4]:GetBossHpRate() > 0.5 and "_1" or "_2"

				setImageSprite(iter_28_5, GetSpriteFromAtlas("ui/dalcollabbossrushsceneui_atlas", "map_" .. iter_28_4 .. nil), true)

				if iter_28_4 ~= 1 then
					if var_28_4 == "" then
						setActive(self.mapFX:Find("state_3/" .. iter_28_4), true)
					elseif var_28_4 == "_1" then
						setActive(self.mapFX:Find("state_1/" .. iter_28_4), true)
					elseif var_28_4 == "_2" then
						setActive(self.mapFX:Find("state_2/" .. iter_28_4), true)
					end
				end
			end
		end
	end
end

function BossRushDALCollabScene:UpdateBattle()
	local var_29_0 = self.activity
	local var_29_1 = self.activity:GetActiveSeriesIds()
	local var_29_2 = {}

	for iter_29_0, iter_29_1 in pairs((self.activity:GetCollabSeriesDataList())) do
		table.insert(var_29_2, iter_29_1)
	end

	table.sort(var_29_2, function(arg_30_0, arg_30_1)
		return arg_30_0:GetTrafficPerH() > arg_30_1:GetTrafficPerH()
	end)
	table.Foreach(self.seriesNodes, function(arg_31_0, arg_31_1)
		local var_31_0 = var_29_0:GetCollabSeriesData(var_29_1[arg_31_0])
		local var_31_1 = var_31_0:IsPlayerUnlock(var_29_0)
		local var_31_2 = var_31_0:IsPass()
		local var_31_3 = var_31_0:GetDefeated(self.activity)

		if var_29_1[arg_31_0] == 6 and not var_31_1 then
			setActive(arg_31_1, false)
		end

		setActive(arg_31_1:Find("lock"), not var_31_1)
		setActive(arg_31_1:Find("clear"), var_31_1 and var_31_2 and var_31_3)
		setActive(arg_31_1:Find("active"), var_31_1 and (not var_31_2 or not var_31_3))

		local var_31_4 = table.indexof(var_29_2, var_31_0)

		if not var_31_1 then
			setText(arg_31_1:Find("lock/name"), var_31_0:GetSeriesCode())
		elseif var_31_0:IsPass() and var_31_3 then
			setText(arg_31_1:Find("clear/current/name/text"), var_31_0:GetSeriesCode())
			setText(arg_31_1:Find("clear/common/name"), var_31_0:GetSeriesCode())
			setActive(arg_31_1:Find("clear/common"), true)
			setActive(arg_31_1:Find("clear/current"), false)
		else
			setText(arg_31_1:Find("active/current/name/text"), var_31_0:GetSeriesCode())
			setText(arg_31_1:Find("active/common/name"), var_31_0:GetSeriesCode())

			local var_31_5 = var_31_0:GetBossHpRate() * 100 .. "%"

			setText(arg_31_1:Find("active/common/value"), var_31_0:IsPass() and "HOLD" or var_31_5)
			setText(arg_31_1:Find("active/current/value"), var_31_0:IsPass() and "HOLD" or var_31_5)
			setActive(arg_31_1:Find("active/common"), true)
			setActive(arg_31_1:Find("active/current"), false)

			arg_31_1:Find("active/current/progress"):GetComponent(typeof(Image)).fillAmount = var_31_0:IsPass() and 1 or var_31_0:GetBossHpRate()
		end

		local function var_31_6(arg_32_0)
			if var_31_4 > 3 then
				setActive(arg_32_0, false)
			else
				setActive(arg_32_0, true)
				table.Foreach(_.map(_.range(arg_32_0.childCount), function(arg_33_0)
					return arg_32_0:GetChild(arg_33_0 - 1)
				end), function(arg_34_0, arg_34_1)
					setActive(arg_34_1, arg_34_0 <= 4 - var_31_4)
				end)
			end
		end

		var_31_6(arg_31_1:Find("active/common/bullets"))
		var_31_6(arg_31_1:Find("clear/common/bullets"))
		onButton(self, arg_31_1, function()
			if not var_31_1 then
				local var_35_0 = var_31_0:GetPreSeriesId()
				local var_35_2 = 1
				local var_35_3 = var_31_0:GetPreSeriesId()
				local var_35_4 = CollabrateBossRushSeriesData.New({
					id = var_35_3[1]
				}):GetSeriesCode()

				while var_35_2 < #var_35_3 do
					var_35_2 = var_35_2 + 1
					var_35_4 = var_35_4 .. "、" .. CollabrateBossRushSeriesData.New({
						id = var_35_3[var_35_2]
					}):GetSeriesCode()
				end

				pg.TipsMgr.GetInstance():ShowTips(i18n("series_enemy_unlock", var_35_4))

				return
			end

			local function var_35_5()
				self._openSeriesData = var_31_0

				PlayerPrefs.SetInt("DAL_ship_position", arg_31_0)

				if not self:updateShipPosition() then
					self.stageView:ExecuteAction("SetData", var_31_0)
					self.stageView:ExecuteAction("Show")

					self.battleNodes:GetComponent(typeof(CanvasGroup)).interactable = true
				end
			end

			local var_35_6 = var_31_0:GetInitStory()

			if var_35_6 then
				self:PlayStory(var_35_6, var_35_5)
			else
				var_35_5()
			end
		end, SFX_PANEL)
	end)
	self:updateShipPosition()
	self:addbubbleMsgBoxList({
		function(arg_37_0)
			self:checkAllStory()
			arg_37_0()
		end,
		function(arg_38_0)
			local var_38_0 = self.activity:getConfig("config_client").first_story
			local var_38_1 = self.activity:getConfig("config_client").first_guide

			if first_guide then
				self:PlayStory(var_38_0, function()
					pg.SystemGuideMgr.GetInstance():PlayByGuideId(var_38_1, nil, arg_38_0)
				end)
			else
				self:PlayStory(var_38_0, arg_38_0)
			end
		end
	})
end

function BossRushDALCollabScene:updateCurrent(arg_40_1)
	table.Foreach(self.seriesNodes, function(arg_41_0, arg_41_1)
		setActive(arg_41_1:Find("clear/common"), arg_40_1 ~= arg_41_1)
		setActive(arg_41_1:Find("clear/current"), arg_40_1 == arg_41_1)
		setActive(arg_41_1:Find("active/common"), arg_40_1 ~= arg_41_1)
		setActive(arg_41_1:Find("active/current"), arg_40_1 == arg_41_1)

		if arg_40_1 == arg_41_1 then
			self:playAnima(arg_40_1, "anim_BossRushDALCollabUI_battle_in")
		end
	end)
end

function BossRushDALCollabScene:updateShipPosition()
	local var_42_0 = PlayerPrefs.GetInt("DAL_ship_position", 1)
	local var_42_1 = self.activity:GetActiveSeriesIds()

	table.Foreach(self.seriesNodes, function(arg_43_0, arg_43_1)
		local var_43_0 = arg_43_1:Find("ship")

		var_43_0:GetComponent(typeof(Animation)):Stop()

		if var_42_0 == var_42_1[arg_43_0] then
			self:updateCurrent(arg_43_1)

			self._currentShip = var_43_0
		elseif var_43_0 ~= self._lastShip then
			setActive(arg_43_1:Find("ship"), false)
		end
	end)

	if self._lastShip then
		if self._lastShip ~= self._currentShip then
			self:playAnima(self._lastShip, "anim_BossRushDALCollabUI_ship_out")
			setActive(self._lastShip:Find("vx_teleport_2"), true)

			self.battleNodes:GetComponent(typeof(CanvasGroup)).interactable = false
		end
	else
		setActive(self._currentShip, true)
		setActive(self._currentShip:Find("vx_teleport_1"), true)
		self:playAnima(self._currentShip, "anim_BossRushDALCollabUI_ship_in")
	end

	return self._lastShip ~= self._currentShip
end

function BossRushDALCollabScene:checkAllStory()
	local var_44_0 = {}

	for iter_44_0, iter_44_1 in pairs((self.activity:GetCollabSeriesDataList())) do
		if table.contains(self.activity:GetPassCounts(), iter_44_0) then
			for iter_44_2, iter_44_3 in ipairs((iter_44_1:GetStorys())) do
				table.insert(var_44_0, iter_44_3)
			end
		end
	end

	local var_44_1 = 1

	local function var_44_2()
		var_44_1 = var_44_1 + 1

		local var_45_0
		local var_45_1 = self.activity:getConfig("config_client").storys_unlock_story

		if var_44_0[var_44_1] == nil and var_45_1 then
			local var_45_2 = pg.NewStoryMgr.GetInstance()

			var_45_0 = true

			for iter_45_0, iter_45_1 in ipairs(var_45_1[2]) do
				var_45_0 = var_45_0 and var_45_2:IsPlayed(iter_45_1)
			end

			var_45_0 = var_45_0 and not var_45_2:IsPlayed(var_45_1[1])
		end

		if var_45_0 then
			self:PlayStory(var_45_1[1], function()
				setActive(self.shiftMap:Find("map_6"), false)
				self:PlayMapShiftAnima("", "_3")
			end)
		else
			self:PlayStory(var_44_0[var_44_1], var_44_2)
		end
	end

	self:PlayStory(var_44_0[1], var_44_2)
end

function BossRushDALCollabScene:GetFinalStoryName()
	local var_47_0 = Clone(self.activity:GetCollabSeriesDataList()[6]:getConfig("story_worldboss"))

	table.sort(var_47_0, function(arg_48_0, arg_48_1)
		return arg_48_0[2] < arg_48_1[2]
	end)

	return var_47_0[1][1]
end

function BossRushDALCollabScene:PlayStory(arg_49_1, arg_49_2)
	if not arg_49_1 then
		return
	end

	local var_49_0 = pg.NewStoryMgr.GetInstance()

	if var_49_0:IsPlayed(arg_49_1) then
		return existCall(arg_49_2)
	end

	if arg_49_1 == self:GetFinalStoryName() then
		var_49_0:Play(arg_49_1, function()
			self:PlayMapShiftAnima("_3", "")
		end)
	else
		var_49_0:Play(arg_49_1, arg_49_2)
	end
end

function BossRushDALCollabScene:UpdateTasks(arg_51_1)
	if _.any(arg_51_1, function(arg_52_0)
		return self.storyTask and self.storyTask.id == arg_52_0
	end) then
		self.storyTask.submitTime = 1

		self:UpdateView()
	end
end

function BossRushDALCollabScene:addbubbleMsgBoxList(arg_53_1)
	local var_53_0 = #self.ActionSequence == 0

	table.insertto(self.ActionSequence, arg_53_1)

	if not var_53_0 then
		return
	end

	self:resumeBubble()
end

function BossRushDALCollabScene:addbubbleMsgBox(arg_54_1)
	local var_54_0 = #self.ActionSequence == 0

	table.insert(self.ActionSequence, arg_54_1)

	if not var_54_0 then
		return
	end

	self:resumeBubble()
end

function BossRushDALCollabScene:resumeBubble()
	if #self.ActionSequence == 0 then
		return
	end

	local function var_55_1()
		if self.ActionSequence[1] then
			self.ActionSequence[1](function()
				table.remove(self.ActionSequence, 1)
				var_55_1()
			end)
		end
	end

	;(nil)()
end

function BossRushDALCollabScene:CleanBubbleMsgbox()
	table.clean(self.ActionSequence)
end

function BossRushDALCollabScene:willExit()
	self:OverlayComponent(false)
	self.stageView:Destroy()
	self.upgradeView:Destroy()
	self.loader:Clear()
	BossRushDALCollabScene.super.willExit(self)
end

return BossRushDALCollabScene
