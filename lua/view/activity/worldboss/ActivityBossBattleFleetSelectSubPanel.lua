local ActivityBossBattleFleetSelectSubPanel = class("ActivityBossBattleFleetSelectSubPanel", import("view.base.BaseSubPanel"))

function ActivityBossBattleFleetSelectSubPanel:getUIName()
	return "ActivityBossFleetSelectView"
end

function ActivityBossBattleFleetSelectSubPanel:InvokeParent(arg_2_1, ...)
	if self.viewParent then
		self.viewParent[arg_2_1](self.viewParent, ...)
	end
end

function ActivityBossBattleFleetSelectSubPanel:OnInit()
	self.tfShipTpl = self._tf:Find("panel/shiptpl")
	self.tfEmptyTpl = self._tf:Find("panel/emptytpl")
	self.tfFleets = {
		[FleetType.Normal] = {
			self._tf:Find("panel/fleet/1"),
			self._tf:Find("panel/fleet/2")
		},
		[FleetType.Submarine] = {
			self._tf:Find("panel/sub/1")
		}
	}
	self.tfLimit = self._tf:Find("panel/limit_list/limit")
	self.tfLimitTips = self._tf:Find("panel/limit_list/limit_tip")
	self.tfLimitElite = self._tf:Find("panel/limit_list/limit_elite")
	self.tfLimitContainer = self._tf:Find("panel/limit_list/limit_elite/limit_list")
	self.rtCostLimit = self._tf:Find("panel/limit_list/cost_limit")
	self.btnBack = self._tf:Find("panel/btnBack")
	self.btnGo = self._tf:Find("panel/start_button")
	self.btnGoS = self._tf:Find("panel/start_button_s")
	self.btnAuto = self._tf:Find("panel/auto_button")
	self.btnTry = self._tf:Find("panel/try_button")
	self.btnASHelp = self._tf:Find("panel/title/ASvalue")
	self.commanderToggle = self._tf:Find("panel/commander_btn")
	self.formationToggle = self._tf:Find("panel/formation_btn")
	self.toggleMask = self._tf:Find("mask")
	self.toggleList = self._tf:Find("mask/list")
	self.toggles = {}

	for iter_3_0 = 0, self.toggleList.childCount - 1 do
		table.insert(self.toggles, self.toggleList:Find("item" .. iter_3_0 + 1))
	end

	self.btnSp = self._tf:Find("panel/sp")
	self.spMask = self._tf:Find("mask_sp")

	setActive(self.tfShipTpl, false)
	setActive(self.tfEmptyTpl, false)
	setActive(self.toggleMask, false)
	setActive(self.btnSp, false)
	setActive(self.spMask, false)
	setActive(self.tfLimitElite, false)
	setActive(self.tfLimitTips, false)
	setActive(self.tfLimit, false)
	setActive(self._tf:Find("panel/title/ASvalue"), false)
	setText(self._tf:Find("panel/formation_btn/text"), i18n("autofight_formation"))
	setText(self._tf:Find("panel/commander_btn/text"), i18n("autofight_cat"))
	setText(self._tf:Find("panel/title/Image/text"), i18n("fleet_select_title"))
	self:InitInteractable()

	self.autoPanel = ChapterAutoPanelTypeBoss.New(self._tf, self.event, self.contextData)
end

function ActivityBossBattleFleetSelectSubPanel:InitInteractable()
	onButton(self, self.btnGo, function()
		self:OnCombat()
	end, SFX_UI_WEIGHANCHOR_GO)
	onButton(self, self.btnGoS, function()
		self:OnCombat()
	end, SFX_UI_WEIGHANCHOR_GO)
	onButton(self, self.btnTry, function()
		self:OnTrybat()
	end, SFX_UI_WEIGHANCHOR_GO)
	onButton(self, self.btnBack, function()
		self:OnCancel()
		self:OnCommit()
	end, SFX_CANCEL)
	onButton(self, self._tf, function()
		self:OnCancel()
		self:OnCommit()
	end, SFX_CANCEL)
	onToggle(self, self.commanderToggle, function(arg_10_0)
		if arg_10_0 then
			self.viewParent.contextData.showCommander = arg_10_0

			for iter_10_0, iter_10_1 in pairs(self.tfFleets) do
				for iter_10_2 = 1, #iter_10_1 do
					self:updateCommanderBtn(iter_10_0, iter_10_2)
				end
			end
		end
	end, SFX_PANEL)
	onToggle(self, self.formationToggle, function(arg_11_0)
		if arg_11_0 then
			self.viewParent.contextData.showCommander = not arg_11_0

			for iter_11_0, iter_11_1 in pairs(self.tfFleets) do
				for iter_11_2 = 1, #iter_11_1 do
					self:updateCommanderBtn(iter_11_0, iter_11_2)
				end
			end
		end
	end, SFX_PANEL)
end

function ActivityBossBattleFleetSelectSubPanel:SetFleets(arg_12_1)
	self.fleets = {
		[FleetType.Normal] = {},
		[FleetType.Submarine] = {}
	}

	for iter_12_0, iter_12_1 in pairs(arg_12_1) do
		iter_12_1:RemoveUnusedItems()

		if iter_12_1:isSubmarineFleet() then
			if #self.fleets[FleetType.Submarine] < self:getLimitNums(FleetType.Submarine) then
				table.insert(self.fleets[FleetType.Submarine], iter_12_1)
			end
		elseif #self.fleets[FleetType.Normal] < self:getLimitNums(FleetType.Normal) then
			table.insert(self.fleets[FleetType.Normal], iter_12_1)
		end
	end
end

function ActivityBossBattleFleetSelectSubPanel:SetOilLimit(arg_13_1)
	local var_13_0 = _.any(arg_13_1, function(arg_14_0)
		return arg_14_0 > 0
	end)

	setActive(self.rtCostLimit, var_13_0)
	setText(self.rtCostLimit:Find("text"), i18n("formationScene_use_oil_limit_tip_worldboss"))

	if var_13_0 then
		local var_13_2 = arg_13_1[1]

		setActive(self.rtCostLimit:Find("cost_noraml/Text"), arg_13_1[1] > 0)

		local var_13_4
		local var_13_3

		if var_13_2 > 0 then
			setText(self.rtCostLimit:Find("cost_noraml/Text"), string.format("%s(%d)", i18n("formationScene_use_oil_limit_surface"), var_13_2))

			var_13_3 = setActive
			var_13_4 = self.rtCostLimit:Find("cost_boss/Text")
		end

		var_13_3(var_13_4, 0 > 0)

		local var_13_5 = arg_13_1[2]

		setActive(self.rtCostLimit:Find("cost_sub/Text"), arg_13_1[2] > 0)

		if var_13_5 > 0 then
			setText(self.rtCostLimit:Find("cost_sub/Text"), string.format("%s(%d)", i18n("formationScene_use_oil_limit_submarine"), var_13_5))
		end
	end
end

function ActivityBossBattleFleetSelectSubPanel:SetSettings(arg_15_1, arg_15_2, arg_15_3)
	self.groupNum = arg_15_1
	self.submarineNum = arg_15_2
	self.showTryBtn = arg_15_3
end

function ActivityBossBattleFleetSelectSubPanel:UpdateView()
	self:clearFleets()
	self:UpdateFleets()

	local var_16_0 = not LOCK_COMMANDER and pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getRawData().level, "CommanderCatMediator") or false

	triggerToggle((self.viewParent.contextData.showCommander and var_16_0 or nil) and (self.commanderToggle or self.formationToggle), true)
	setActive(self.commanderToggle, var_16_0)
	setActive(self.btnTry, self.showTryBtn)
	self:UpdateAutoBtn()
end

function ActivityBossBattleFleetSelectSubPanel:UpdateAutoBtn()
	self.expeditionId = self.viewParent.contextData.normalStageIDs[self.viewParent.contextData.editFleet]

	local var_17_0 = ChapterAutoProxy.IsSystemOpen()

	setActive(self.btnAuto, pg.expedition_auto_statistics[self.expeditionId])
	setActive(self.btnGoS, pg.expedition_auto_statistics[self.expeditionId])
	setActive(self.btnGo, not pg.expedition_auto_statistics[self.expeditionId])

	if not pg.expedition_auto_statistics[self.expeditionId] then
		return
	end

	local var_17_1 = var_17_0 and getProxy(ChapterAutoProxy):GetRecord(ChapterAutoProxy.TYPE.BOSS, self.expeditionId) > 0

	setGray(self.btnAuto, not (var_17_0 and getProxy(ChapterAutoProxy):GetRecord(ChapterAutoProxy.TYPE.BOSS, self.expeditionId) > 0), true)
	onButton(self, self.btnAuto, function()
		if var_17_1 then
			local var_18_0 = getProxy(ChapterAutoProxy):GetCommissionDoingType()

			if not var_18_0 then
				self:ShowChapterAutoPanel()
			else
				self:CheckChapterAutoOccupied(var_18_0)
			end
		elseif var_17_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_chapter_unlock_tip_worldboss"))
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_unlock_tip"))
		end
	end, SFX_PANEL)
end

function ActivityBossBattleFleetSelectSubPanel:ShowChapterAutoPanel()
	self.autoPanel:ExecuteAction("Enter", self.expeditionId)
end

function ActivityBossBattleFleetSelectSubPanel:RefreshChapterAutoPanel()
	if self.autoPanel:isShowing() then
		self.autoPanel:ExecuteAction("RefreshView")
	end
end

function ActivityBossBattleFleetSelectSubPanel:HideChapterAutoPanel()
	self.autoPanel:ExecuteAction("Hide")
end

function ActivityBossBattleFleetSelectSubPanel:CheckChapterAutoOccupied(arg_22_1)
	switch(arg_22_1, {
		[ChapterAutoProxy.TYPE.WORLD] = function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_in_world"),
				onYes = function()
					pg.m02:sendNotification(GAME.GO_SCENE, SCENE.WORLD)
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end,
		[ChapterAutoProxy.TYPE.SLG] = function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_in_world"),
				onYes = function()
					pg.m02:sendNotification(GAME.GO_SCENE, SCENE.LEVEL)
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end,
		[ChapterAutoProxy.TYPE.RUSH] = function()
			local var_27_0 = pg.activity_series_enemy_auto[getProxy(ChapterAutoProxy):GetCommissionList()[1].id].link_id
			local var_27_1 = BossRushChapterRemasterHelper.GetRemasterByActivityId(var_27_0) ~= nil

			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_in_world"),
				onYes = function()
					if var_27_1 then
						pg.m02:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_REMASTER, {
							id = var_27_0
						})
					else
						pg.m02:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_MAIN)
					end
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end
	})
end

function ActivityBossBattleFleetSelectSubPanel:getLimitNums(arg_29_1)
	local var_29_0 = 0

	if arg_29_1 == FleetType.Normal then
		var_29_0 = self.groupNum
	elseif arg_29_1 == FleetType.Submarine then
		var_29_0 = self.submarineNum
	end

	return var_29_0 or 0
end

function ActivityBossBattleFleetSelectSubPanel:UpdateFleets()
	for iter_30_0, iter_30_1 in pairs(self.tfFleets) do
		for iter_30_2 = 1, #iter_30_1 do
			self:updateFleet(iter_30_0, iter_30_2)
		end
	end
end

function ActivityBossBattleFleetSelectSubPanel:updateFleet(arg_31_1, arg_31_2)
	self:updateCommanderBtn(arg_31_1, arg_31_2)

	local var_31_0 = arg_31_2 <= self:getLimitNums(arg_31_1)
	local var_31_1 = var_31_0 and self.fleets[arg_31_1][arg_31_2]
	local var_31_2 = findTF(self.tfFleets[arg_31_1][arg_31_2], "bg/name")
	local var_31_3 = self.tfFleets[arg_31_1][arg_31_2]:Find(TeamType.Main)
	local var_31_4 = self.tfFleets[arg_31_1][arg_31_2]:Find(TeamType.Vanguard)
	local var_31_5 = self.tfFleets[arg_31_1][arg_31_2]:Find(TeamType.Submarine)
	local var_31_6 = self.tfFleets[arg_31_1][arg_31_2]:Find("btn_recom")
	local var_31_7 = self.tfFleets[arg_31_1][arg_31_2]:Find("btn_clear")
	local var_31_8 = self.tfFleets[arg_31_1][arg_31_2]:Find("commander")

	setActive(self.tfFleets[arg_31_1][arg_31_2]:Find("selected"), false)
	setText(var_31_2, "")

	if var_31_3 then
		setActive(var_31_3, var_31_0 and var_31_1)
	end

	if var_31_4 then
		setActive(var_31_4, var_31_0 and var_31_1)
	end

	if var_31_5 then
		setActive(var_31_5, var_31_0 and var_31_1)
	end

	if var_31_0 and var_31_1 then
		setText(var_31_2, Fleet.DEFAULT_NAME_BOSS_ACT[var_31_1.id] or "")

		if arg_31_1 == FleetType.Submarine then
			self:updateShips(var_31_5, var_31_1.subShips, var_31_1.id, TeamType.Submarine)
		else
			self:updateShips(var_31_3, var_31_1.mainShips, var_31_1.id, TeamType.Main)
			self:updateShips(var_31_4, var_31_1.vanguardShips, var_31_1.id, TeamType.Vanguard)
		end

		self:updateCommanders(var_31_8, var_31_1)
		onButton(self, var_31_6, function()
			self:emit(self.viewParent.contextData.mediatorClass.ON_FLEET_RECOMMEND, var_31_1.id)
		end)
		onButton(self, var_31_7, function()
			self:emit(self.viewParent.contextData.mediatorClass.ON_FLEET_CLEAR, var_31_1.id)
		end, SFX_UI_CLICK)
	end
end

function ActivityBossBattleFleetSelectSubPanel:updateShips(arg_34_1, arg_34_2, arg_34_3, arg_34_4)
	removeAllChildren(arg_34_1)

	local var_34_0 = getProxy(BayProxy)

	for iter_34_0 = 1, 3 do
		local var_34_1 = var_34_0:getShipById(arg_34_2[iter_34_0])
		local var_34_2 = cloneTplTo((var_34_1 or nil) and (self.tfShipTpl or self.tfEmptyTpl), arg_34_1)

		setActive(var_34_2, true)

		if var_34_1 then
			updateShip(var_34_2, var_34_1)
			setActive(var_34_2:Find("event_block"), var_34_1:getFlag("inEvent"))
		end

		setActive(var_34_2:Find("ship_type"), false)

		local var_34_3 = GetOrAddComponent(var_34_2, typeof(UILongPressTrigger))

		var_34_3.onLongPressed:RemoveAllListeners()

		local function var_34_4()
			self:emit(self.viewParent.contextData.mediatorClass.ON_OPEN_DOCK, {
				fleet = arg_34_2,
				shipVO = var_34_1,
				fleetIndex = arg_34_3,
				teamType = arg_34_4
			})
		end

		onButton(self, var_34_2, var_34_4)
		var_34_3.onLongPressed:AddListener(function()
			if var_34_1 then
				self:OnLongPressShip(arg_34_2[iter_34_0], arg_34_3)
			else
				var_34_4()
			end
		end)
	end
end

function ActivityBossBattleFleetSelectSubPanel:updateCommanderBtn(arg_37_1, arg_37_2)
	local var_37_0 = arg_37_2 <= self:getLimitNums(arg_37_1)
	local var_37_1 = var_37_0 and self.fleets[arg_37_1][arg_37_2]
	local var_37_2 = self.tfFleets[arg_37_1][arg_37_2]:Find("blank")

	setActive(self.tfFleets[arg_37_1][arg_37_2]:Find("btn_select"), false)
	setActive(self.tfFleets[arg_37_1][arg_37_2]:Find("btn_clear"), var_37_0 and not self.viewParent.contextData.showCommander)
	setActive(self.tfFleets[arg_37_1][arg_37_2]:Find("btn_recom"), var_37_0 and not self.viewParent.contextData.showCommander)
	setActive(self.tfFleets[arg_37_1][arg_37_2]:Find("commander"), var_37_0 and var_37_1 and self.viewParent.contextData.showCommander)
	setActive(var_37_2, not var_37_0 or var_37_0 and not var_37_1 and self.viewParent.contextData.showCommander)
end

function ActivityBossBattleFleetSelectSubPanel:updateCommanders(arg_38_1, arg_38_2)
	for iter_38_0 = 1, 2 do
		local var_38_0 = arg_38_2:getCommanderByPos(iter_38_0)
		local var_38_1 = arg_38_1:Find("pos" .. iter_38_0)
		local var_38_2 = var_38_1:Find("add")
		local var_38_3 = var_38_1:Find("info")

		setActive(var_38_2, not var_38_0)
		setActive(var_38_3, var_38_0)

		if var_38_0 then
			setImageSprite(var_38_3:Find("frame"), GetSpriteFromAtlas("weaponframes", "commander_" .. Commander.rarity2Frame(var_38_0:getRarity())))
			GetImageSpriteFromAtlasAsync("CommanderHrz/" .. var_38_0:getPainting(), "", var_38_3:Find("mask/icon"))
		end

		onButton(self, var_38_2, function()
			self:InvokeParent("openCommanderPanel", arg_38_2, arg_38_2.id)
		end, SFX_PANEL)
		onButton(self, var_38_3, function()
			self:InvokeParent("openCommanderPanel", arg_38_2, arg_38_2.id)
		end, SFX_PANEL)
	end
end

function ActivityBossBattleFleetSelectSubPanel:clearFleets()
	for iter_41_0, iter_41_1 in pairs(self.tfFleets) do
		_.each(iter_41_1, function(arg_42_0)
			self:clearFleet(arg_42_0)
		end)
	end
end

function ActivityBossBattleFleetSelectSubPanel:clearFleet(arg_43_1)
	local var_43_0 = arg_43_1:Find(TeamType.Main)
	local var_43_1 = arg_43_1:Find(TeamType.Vanguard)
	local var_43_2 = arg_43_1:Find(TeamType.Submarine)

	if var_43_0 then
		removeAllChildren(var_43_0)
	end

	if var_43_1 then
		removeAllChildren(var_43_1)
	end

	if var_43_2 then
		removeAllChildren(var_43_2)
	end
end

function ActivityBossBattleFleetSelectSubPanel:OnShow()
	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		groupDelta = -1,
		groupName = "ActivityBossSceneTemplate"
	})
end

function ActivityBossBattleFleetSelectSubPanel:OnHide()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.viewParent._tf)
	triggerToggle(self.commanderToggle, false)
	self:HideChapterAutoPanel()
end

function ActivityBossBattleFleetSelectSubPanel:OnCancel()
	self:InvokeParent("hideFleetEdit")
end

function ActivityBossBattleFleetSelectSubPanel:OnCommit()
	self:InvokeParent("commitEdit")
end

function ActivityBossBattleFleetSelectSubPanel:OnCombat()
	self:InvokeParent("commitEdit")
	self:InvokeParent("commitCombat")
end

function ActivityBossBattleFleetSelectSubPanel:OnTrybat()
	self:InvokeParent("commitEdit")
	self:InvokeParent("commitTrybat")
end

function ActivityBossBattleFleetSelectSubPanel:OnLongPressShip(arg_50_1, arg_50_2)
	self:InvokeParent("openShipInfo", arg_50_1, arg_50_2)
end

function ActivityBossBattleFleetSelectSubPanel:OnDestroy()
	if self.autoPanel then
		self.autoPanel:Destroy()

		self.autoPanel = nil
	end
end

return ActivityBossBattleFleetSelectSubPanel
