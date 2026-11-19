local WorldFleetSelectLayer = class("WorldFleetSelectLayer", import("..base.BaseUI"))

function WorldFleetSelectLayer:getUIName()
	return "WorldFleetSelect"
end

function WorldFleetSelectLayer:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype"
	}

	table.insertto(var_2_0, self:getFleetSelectResList(self.contextData.fleets))

	return table.insertto(var_2_0, WorldFleetSelectLayer.super.getResource(self))
end

function WorldFleetSelectLayer:insertFleetSelectRes(arg_3_1, arg_3_2)
	if noEmptyStr(arg_3_2) and not table.contains(arg_3_1, arg_3_2) then
		table.insert(arg_3_1, arg_3_2)
	end
end

function WorldFleetSelectLayer:insertFleetSelectPrefixRes(arg_4_1, arg_4_2, arg_4_3)
	if noEmptyStr(arg_4_3) then
		self:insertFleetSelectRes(arg_4_1, arg_4_2 .. arg_4_3)
	end
end

function WorldFleetSelectLayer:getShipIconResList(arg_5_1)
	local var_5_0 = {}
	local var_5_1 = getProxy(BayProxy)

	for iter_5_0, iter_5_1 in pairs(arg_5_1 or {}) do
		for iter_5_2, iter_5_3 in ipairs(iter_5_1) do
			for iter_5_4, iter_5_5 in ipairs({
				TeamType.Main,
				TeamType.Vanguard,
				TeamType.Submarine
			}) do
				for iter_5_6, iter_5_7 in pairs(iter_5_3[iter_5_5] or {}) do
					local var_5_3 = var_5_1:getShipById(iter_5_7)

					if var_5_3 then
						self:insertFleetSelectPrefixRes(var_5_0, "SquareIcon/", var_5_3:getPainting())
					end
				end
			end
		end
	end

	return var_5_0
end

function WorldFleetSelectLayer:getCommanderIconResList(arg_6_1)
	local var_6_0 = {}

	for iter_6_0, iter_6_1 in pairs(arg_6_1 or {}) do
		for iter_6_2, iter_6_3 in ipairs(iter_6_1) do
			for iter_6_4, iter_6_5 in pairs(Fleet.New({
				ship_list = {},
				commanders = iter_6_3.commanders
			}):getCommanders()) do
				self:insertFleetSelectPrefixRes(var_6_0, "CommanderHrz/", iter_6_5:getPainting())
			end
		end
	end

	return var_6_0
end

function WorldFleetSelectLayer:getFleetSelectResList(arg_7_1)
	local var_7_0 = {}

	for iter_7_0, iter_7_1 in ipairs(self:getShipIconResList(arg_7_1)) do
		self:insertFleetSelectRes(var_7_0, iter_7_1)
	end

	for iter_7_2, iter_7_3 in ipairs(self:getCommanderIconResList(arg_7_1)) do
		self:insertFleetSelectRes(var_7_0, iter_7_3)
	end

	return var_7_0
end

function WorldFleetSelectLayer:downloadFleetSelectResList(arg_8_1, arg_8_2)
	SplitPackConst.DownloadByLuaArr(self:getFleetSelectResList(arg_8_1), function()
		if self.exited then
			return
		end

		return existCall(arg_8_2)
	end)
end

function WorldFleetSelectLayer:init()
	self.rtBg = self._tf:Find("bg")

	local var_10_0 = nowWorld():GetRealm()

	eachChild(self.rtBg, function(arg_11_0)
		setActive(arg_11_0, arg_11_0.name == tostring(var_10_0))
	end)

	self.rtPanel = self._tf:Find("panel")
	self.rtShipTpl = self.rtPanel:Find("shiptpl")

	setActive(self.rtShipTpl, false)

	self.rtEmptyTpl = self.rtPanel:Find("emptytpl")

	setActive(self.rtEmptyTpl, false)

	self.rtScroll = self.rtPanel:Find("bg")
	self.rtContent = self.rtScroll:Find("content")
	self.rtFleets = {
		[FleetType.Normal] = self.rtContent:Find("fleet"),
		[FleetType.Submarine] = self.rtContent:Find("sub")
	}
	self.btnBack = self.rtPanel:Find("btnBack")
	self.btnGo = self.rtPanel:Find("start_button")
	self.commanderToggle = self.rtPanel:Find("commander_btn")
	self.formationToggle = self.rtPanel:Find("formation_btn")
	self.tfLimitTip = self.rtPanel:Find("limit_tip")

	setText(self.tfLimitTip:Find("Text"), i18n("world_fleet_choose"))

	self.tfLimitSub = self.rtPanel:Find("limit_world/limit_sub")

	setText(self.tfLimitSub:Find("Text"), i18n("ship_limit_notice"))

	self.tfLimitContainer = self.rtPanel:Find("limit_world/limit_list")
	self.tfLimitTpl = self.tfLimitContainer:Find("condition")

	self:buildCommanderPanel()
end

function WorldFleetSelectLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self.rtPanel)
	onButton(self, self.btnGo, function()
		local var_13_0, var_13_1 = self:CheckValid()

		if var_13_0 then
			self:emit(WorldFleetSelectMediator.OnGO)
		else
			pg.TipsMgr.GetInstance():ShowTips(var_13_1)
		end
	end, SFX_PANEL)
	onButton(self, self.btnBack, function()
		self:closeView()
	end, SFX_CANCEL)

	local function var_12_0(arg_15_0)
		self.contextData.showCommander = arg_15_0

		for iter_15_0, iter_15_1 in pairs(self.rtFleets) do
			for iter_15_2 = 1, #self.contextData.fleets[iter_15_0] do
				self:updateCommanderBtn(iter_15_1:GetChild(iter_15_2 - 1))
			end
		end
	end

	onToggle(self, self.commanderToggle, function(arg_16_0)
		if arg_16_0 then
			var_12_0(arg_16_0)
		end
	end, SFX_PANEL)
	onToggle(self, self.formationToggle, function(arg_17_0)
		if arg_17_0 then
			var_12_0(not arg_17_0)
		end
	end, SFX_PANEL)
	self:UpdateFleets()
	scrollTo(self.rtContent, nil, self.contextData.scrollY)

	self.contextData.showCommander = defaultValue(self.contextData.showCommander, true)

	triggerToggle((self.contextData.showCommander or nil) and (self.commanderToggle or self.formationToggle), true)
	seriesAsync({
		function(arg_18_0)
			self:CheckWorldDelegateAward(arg_18_0)
		end,
		function(arg_19_0)
			self:CheckWorldResetAward(arg_19_0)
		end
	}, function()
		return
	end)
end

function WorldFleetSelectLayer:willExit()
	self.contextData.scrollY = GetComponent(self.rtContent, typeof(ScrollRect)).normalizedPosition.y

	pg.UIMgr.GetInstance():UnOverlayPanel(self.rtPanel, self._tf)
	self:destroyCommanderPanel()
end

function WorldFleetSelectLayer:onBackPressed()
	if self.levelCMDFormationView:isShowing() then
		self.levelCMDFormationView:ActionInvoke("Hide")
	else
		self:closeView()
	end
end

function WorldFleetSelectLayer:UpdateFleets(arg_23_1)
	self:downloadFleetSelectResList(self.contextData.fleets, function()
		self:UpdateFleetsAfterResDownload()

		return existCall(arg_23_1)
	end)
end

function WorldFleetSelectLayer:UpdateFleetsAfterResDownload()
	local var_25_0 = self.contextData.fleets

	for iter_25_0, iter_25_1 in pairs(self.contextData.fleets) do
		local var_25_1 = self.rtFleets[iter_25_0]
		local var_25_2 = UIItemList.New(self.rtFleets[iter_25_0], self.rtFleets[iter_25_0]:GetChild(0))

		var_25_2:make(function(arg_26_0, arg_26_1, arg_26_2)
			if arg_26_0 == UIItemList.EventUpdate then
				self:UpdateFleet(arg_26_2, iter_25_0, arg_26_1 + 1)
			end
		end)
		var_25_2:align(#var_25_0[iter_25_0])
		setActive(var_25_1, #var_25_0[iter_25_0] > 0)
	end

	self:updateEliteLimit()
end

function WorldFleetSelectLayer:IsPropertyLimitationSatisfy()
	local var_27_0 = getProxy(BayProxy):getRawData()
	local var_27_1 = {}

	for iter_27_0, iter_27_1 in ipairs(pg.gameset.world_fleet_unlock_level.description) do
		var_27_1[iter_27_1[1]] = 0
	end

	local var_27_2 = 0

	for iter_27_2, iter_27_3 in ipairs(self.contextData.fleets[FleetType.Normal]) do
		if self:GetTeamShipCount(iter_27_3[TeamType.Main]) == 0 or self:GetTeamShipCount(iter_27_3[TeamType.Vanguard]) == 0 then
			-- block empty
		else
			local var_27_3 = {}
			local var_27_4 = {}
			local var_27_5 = 0

			for iter_27_4, iter_27_5 in ipairs(pg.gameset.world_fleet_unlock_level.description) do
				local var_27_6, var_27_7, var_27_8, var_27_9 = unpack(iter_27_5)

				if string.sub(var_27_6, 1, 5) == "fleet" then
					var_27_3[var_27_6] = 0
					var_27_4[var_27_6] = var_27_9
				end
			end

			for iter_27_6, iter_27_7 in pairs(iter_27_3) do
				for iter_27_8 = 1, 3 do
					local var_27_10 = iter_27_7[iter_27_8] and var_27_0[iter_27_7[iter_27_8]]

					if var_27_10 then
						var_27_2 = var_27_2 + 1
						var_27_5 = var_27_5 + 1

						local var_27_11 = intProperties(var_27_10:getProperties())

						for iter_27_9, iter_27_10 in pairs(var_27_1) do
							if string.sub(iter_27_9, 1, 5) == "fleet" then
								if iter_27_9 == "fleet_totle_level" then
									var_27_3[iter_27_9] = var_27_3[iter_27_9] + var_27_10.level
								end
							else
								var_27_1[iter_27_9] = iter_27_9 == "level" and iter_27_10 + var_27_10.level or iter_27_10 + var_27_11[iter_27_9]
							end
						end
					end
				end
			end

			for iter_27_11, iter_27_12 in pairs(var_27_3) do
				if iter_27_11 == "fleet_totle_level" and iter_27_12 > var_27_4[iter_27_11] then
					var_27_1[iter_27_11] = var_27_1[iter_27_11] + 1
				end
			end
		end
	end

	local var_27_12 = {}

	for iter_27_13, iter_27_14 in ipairs(pg.gameset.world_fleet_unlock_level.description) do
		local var_27_13, var_27_14, var_27_15, var_27_16 = unpack(iter_27_14)

		if var_27_13 == "level" and var_27_2 > 0 then
			var_27_1[var_27_13] = math.ceil(var_27_1[var_27_13] / var_27_2)
		end

		var_27_12[iter_27_13] = AttributeType.EliteConditionCompare(var_27_14, var_27_1[var_27_13], var_27_15) and 1 or 0
	end

	return var_27_12, var_27_1
end

function WorldFleetSelectLayer:updateEliteLimit()
	local var_28_0 = pg.gameset.world_fleet_unlock_level.description

	if #pg.gameset.world_fleet_unlock_level.description == 0 then
		return
	end

	local var_28_1, var_28_2 = self:IsPropertyLimitationSatisfy()
	local var_28_3 = UIItemList.New(self.tfLimitContainer, self.tfLimitTpl)

	var_28_3:make(function(arg_29_0, arg_29_1, arg_29_2)
		arg_29_1 = arg_29_1 + 1

		if arg_29_0 == UIItemList.EventUpdate then
			local var_29_0, var_29_1, var_29_2, var_29_3 = unpack(var_28_0[arg_29_1])

			arg_29_2:Find("Text"):GetComponent(typeof(Text)).color = var_28_1[arg_29_1] == 1 and Color.New(1, 0.9607843137254902, 0.5019607843137255) or Color.New(0.9568627450980393, 0.30196078431372547, 0.30196078431372547)

			setText(arg_29_2:Find("Text"), (AttributeType.EliteCondition2Name(var_29_0, var_29_3) .. AttributeType.eliteConditionCompareTip(var_29_1) .. var_29_2) .. "（" .. var_28_2[var_29_0] .. "）")
		end
	end)
	var_28_3:align(#pg.gameset.world_fleet_unlock_level.description)
end

function WorldFleetSelectLayer:updateCommanderBtn(arg_30_1)
	setActive(arg_30_1:Find("btn_recom"), not self.contextData.showCommander)
	setActive(arg_30_1:Find("btn_clear"), not self.contextData.showCommander)
	setActive(arg_30_1:Find("commander"), self.contextData.showCommander)
end

function WorldFleetSelectLayer:UpdateFleet(arg_31_1, arg_31_2, arg_31_3)
	self:updateCommanders(arg_31_1:Find("commander"), arg_31_2, arg_31_3)

	local var_31_0 = self.contextData.fleets[arg_31_2][arg_31_3]

	setText(arg_31_1:Find("bg/name"), Fleet.DEFAULT_NAME[(arg_31_2 == FleetType.Submarine and 10 or 0) + arg_31_3])

	if arg_31_2 == FleetType.Normal then
		self:UpdateShips(arg_31_1:Find(TeamType.Main), TeamType.Main, var_31_0)
		self:UpdateShips(arg_31_1:Find(TeamType.Vanguard), TeamType.Vanguard, var_31_0)
		setActive(arg_31_1:Find("selected"), self:GetTeamShipCount(var_31_0[TeamType.Main]) > 0 and self:GetTeamShipCount(var_31_0[TeamType.Vanguard]) > 0)
	elseif arg_31_2 == FleetType.Submarine then
		self:UpdateShips(arg_31_1:Find(TeamType.Submarine), TeamType.Submarine, var_31_0)
		setActive(arg_31_1:Find("selected"), self:GetTeamShipCount(var_31_0[TeamType.Submarine]) > 0)
	end

	onButton(self, arg_31_1:Find("btn_recom"), function()
		self:RecommendFormation(arg_31_2, arg_31_3)
		self:downloadFleetSelectResList(self.contextData.fleets, function()
			self:UpdateFleet(arg_31_1, arg_31_2, arg_31_3)
			self:updateEliteLimit()
		end)
	end, SFX_PANEL)
	onButton(self, arg_31_1:Find("btn_clear"), function()
		if self:GetTeamShipCount(var_31_0[TeamType.Main]) > 0 or self:GetTeamShipCount(var_31_0[TeamType.Vanguard]) > 0 or self:GetTeamShipCount(var_31_0[TeamType.Submarine]) > 0 then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("battle_preCombatLayer_clear_confirm"),
				onYes = function()
					var_31_0[TeamType.Main] = {}
					var_31_0[TeamType.Vanguard] = {}
					var_31_0[TeamType.Submarine] = {}

					self:UpdateFleet(arg_31_1, arg_31_2, arg_31_3)
					self:updateEliteLimit()
				end
			})
		end
	end, SFX_CANCEL)
end

function WorldFleetSelectLayer:updateCommanders(arg_36_1, arg_36_2, arg_36_3)
	local var_36_0 = Fleet.New({
		ship_list = {},
		commanders = self.contextData.fleets[arg_36_2][arg_36_3].commanders
	})

	for iter_36_0 = 1, 2 do
		local var_36_1 = var_36_0:getCommanderByPos(iter_36_0)
		local var_36_2 = arg_36_1:Find("pos" .. iter_36_0)
		local var_36_3 = var_36_2:Find("add")
		local var_36_4 = var_36_2:Find("info")

		setActive(var_36_3, not var_36_1)
		setActive(var_36_4, var_36_1)

		if var_36_1 then
			setImageSprite(var_36_4:Find("frame"), GetSpriteFromAtlas("weaponframes", "commander_" .. Commander.rarity2Frame(var_36_1:getRarity())))
			GetImageSpriteFromAtlasAsync("CommanderHrz/" .. var_36_1:getPainting(), "", var_36_4:Find("mask/icon"))
		else
			local var_36_5 = 1

			while self.contextData.fleets[arg_36_2][arg_36_3].commanders[var_36_5] and self.contextData.fleets[arg_36_2][arg_36_3].commanders[var_36_5].pos ~= iter_36_0 do
				var_36_5 = var_36_5 + 1
			end

			if self.contextData.fleets[arg_36_2][arg_36_3].commanders[var_36_5] then
				table.remove(self.contextData.fleets[arg_36_2][arg_36_3].commanders, var_36_5)
			end
		end

		onButton(self, var_36_3, function()
			self:openCommanderPanel(var_36_0, arg_36_2, arg_36_3)
		end, SFX_PANEL)
		onButton(self, var_36_4, function()
			self:openCommanderPanel(var_36_0, arg_36_2, arg_36_3)
		end, SFX_PANEL)
	end
end

function WorldFleetSelectLayer:UpdateShips(arg_39_1, arg_39_2, arg_39_3)
	local var_39_0 = getProxy(BayProxy)
	local var_39_1 = arg_39_3[arg_39_2]
	local var_39_2 = {}

	for iter_39_0, iter_39_1 in ipairs({
		TeamType.Vanguard,
		TeamType.Main,
		TeamType.Submarine
	}) do
		for iter_39_2 = 1, 3 do
			local var_39_3 = arg_39_3[iter_39_1][iter_39_2] and var_39_0:getShipById(arg_39_3[iter_39_1][iter_39_2]) or nil

			table.insert(var_39_2, var_39_3)

			if not var_39_3 then
				arg_39_3[iter_39_1][iter_39_2] = nil
			end
		end
	end

	removeAllChildren(arg_39_1)

	for iter_39_3 = 1, 3 do
		local var_39_4
		local var_39_5

		if arg_39_3[arg_39_2][iter_39_3] then
			var_39_4 = cloneTplTo(self.rtShipTpl, arg_39_1, "ship_" .. arg_39_3[arg_39_2][iter_39_3])
			var_39_5 = var_39_0:getShipById(arg_39_3[arg_39_2][iter_39_3])

			updateShip(var_39_4, var_39_5)
		else
			var_39_4 = cloneTplTo(self.rtEmptyTpl, arg_39_1, "empty")

			setActive(var_39_4:Find("ship_type"), false)
		end

		onButton(self, var_39_4:Find("icon_bg"), function()
			self:emit(WorldFleetSelectMediator.OnSelectShip, arg_39_2, var_39_1, iter_39_3)
		end, SFX_PANEL)

		local var_39_6 = GetOrAddComponent(var_39_4:Find("icon_bg"), typeof(UILongPressTrigger))

		pg.DelegateInfo.Add(self, var_39_6.onLongPressed)
		var_39_6.onLongPressed:RemoveAllListeners()
		var_39_6.onLongPressed:AddListener(function()
			if not var_39_5 then
				self:emit(WorldFleetSelectMediator.OnSelectShip, arg_39_2, var_39_1, iter_39_3)
			else
				self:emit(WorldFleetSelectMediator.OnShipDetail, {
					shipId = var_39_5.id,
					shipVOs = var_39_2
				})
			end
		end)
	end
end

function WorldFleetSelectLayer:setCommanderPrefabs(arg_42_1)
	self.commanderPrefabs = arg_42_1
end

function WorldFleetSelectLayer:openCommanderPanel(arg_43_1, arg_43_2, arg_43_3)
	self.levelCMDFormationView:setCallback(function(arg_44_0)
		if arg_44_0.type == LevelUIConst.COMMANDER_OP_SHOW_SKILL then
			self:emit(WorldFleetSelectMediator.OnCommanderSkill, arg_44_0.skill)
		elseif arg_44_0.type == LevelUIConst.COMMANDER_OP_ADD then
			self.contextData.eliteCommanderSelected = {
				fleetType = arg_43_2,
				fleetIndex = arg_43_3,
				pos = arg_44_0.pos
			}

			self:emit(WorldFleetSelectMediator.OnSelectEliteCommander, arg_43_2, arg_43_3, arg_44_0.pos)
			self:closeCommanderPanel()
		else
			self:emit(WorldFleetSelectMediator.OnCommanderFormationOp, {
				FleetType = LevelUIConst.FLEET_TYPE_WORLD,
				data = arg_44_0,
				fleets = self.contextData.fleets,
				fleetType = arg_43_2,
				fleetIndex = arg_43_3
			})
		end
	end)
	self.levelCMDFormationView:Load()
	self.levelCMDFormationView:ActionInvoke("update", arg_43_1, self.commanderPrefabs)
	self.levelCMDFormationView:ActionInvoke("Show")
end

function WorldFleetSelectLayer:closeCommanderPanel()
	self.levelCMDFormationView:ActionInvoke("Hide")
end

function WorldFleetSelectLayer:updateCommanderFleet(arg_46_1)
	if self.levelCMDFormationView:isShowing() then
		self.levelCMDFormationView:ActionInvoke("updateFleet", arg_46_1)
	end
end

function WorldFleetSelectLayer:updateCommanderPrefab()
	if self.levelCMDFormationView:isShowing() then
		self.levelCMDFormationView:ActionInvoke("updatePrefabs", self.commanderPrefabs)
	end
end

function WorldFleetSelectLayer:buildCommanderPanel()
	self.levelCMDFormationView = LevelCMDFormationView.New(self._tf, self.event, self.contextData)
end

function WorldFleetSelectLayer:destroyCommanderPanel()
	self.levelCMDFormationView:Destroy()

	self.levelCMDFormationView = nil
end

function WorldFleetSelectLayer:CheckValid()
	for iter_50_0, iter_50_1 in pairs(self.contextData.fleets) do
		if iter_50_0 == FleetType.Normal then
			for iter_50_2, iter_50_3 in ipairs(iter_50_1) do
				if self:GetTeamShipCount(iter_50_3[TeamType.Main]) == 0 or self:GetTeamShipCount(iter_50_3[TeamType.Vanguard]) == 0 then
					return false, i18n("world_fleet_formation_not_valid", Fleet.DEFAULT_NAME[iter_50_2])
				end
			end
		end
	end

	local var_50_0, var_50_1 = self:IsPropertyLimitationSatisfy()
	local var_50_2 = 1

	for iter_50_4, iter_50_5 in ipairs(var_50_0) do
		var_50_2 = var_50_2 * iter_50_5
	end

	if var_50_2 ~= 1 then
		return false, i18n("elite_disable_property_unsatisfied")
	end

	return true
end

function WorldFleetSelectLayer:GetTeamShipCount(arg_51_1)
	local var_51_0 = 0

	for iter_51_0 = 1, 3 do
		if arg_51_1[iter_51_0] then
			var_51_0 = var_51_0 + 1
		end
	end

	return var_51_0
end

function WorldFleetSelectLayer:RecommendFormation(arg_52_1, arg_52_2)
	local var_52_0 = {
		[FleetType.Normal] = {
			TeamType.Main,
			TeamType.Vanguard
		},
		[FleetType.Submarine] = {
			TeamType.Submarine
		}
	}
	local var_52_1 = {}

	for iter_52_0, iter_52_1 in pairs(self.contextData.fleets) do
		for iter_52_2, iter_52_3 in ipairs(iter_52_1) do
			for iter_52_4, iter_52_5 in ipairs(var_52_0[iter_52_0]) do
				for iter_52_6 = 1, 3 do
					if iter_52_3[iter_52_5][iter_52_6] then
						table.insert(var_52_1, iter_52_3[iter_52_5][iter_52_6])
					end
				end
			end
		end
	end

	local var_52_2 = getProxy(BayProxy)

	for iter_52_7, iter_52_8 in ipairs(var_52_0[arg_52_1]) do
		for iter_52_9 = 1, 3 do
			if not self.contextData.fleets[arg_52_1][arg_52_2][iter_52_8][iter_52_9] then
				local var_52_3 = var_52_2:getWorldRecommendShip(iter_52_8, var_52_1)

				if var_52_3 then
					self.contextData.fleets[arg_52_1][arg_52_2][iter_52_8][iter_52_9] = var_52_3.id

					table.insert(var_52_1, var_52_3.id)
				end
			end
		end
	end
end

function WorldFleetSelectLayer:CheckWorldDelegateAward(arg_53_1)
	if getProxy(WorldProxy):GetDelegateAward() then
		getProxy(WorldProxy):RemoveDelegateAward()
		pg.TipsMgr.GetInstance():ShowTips(i18n("world_auto_plan_error_tip4"))
	end

	arg_53_1()
end

function WorldFleetSelectLayer:CheckWorldResetAward(arg_54_1)
	local var_54_0 = {}
	local var_54_1 = nowWorld()
	local var_54_2 = var_54_1.resetAward

	if var_54_1.resetAward and #var_54_1.resetAward > 0 then
		local var_54_3 = pg.gameset.world_resetting_story.description[1]

		if #pg.gameset.world_resetting_story.description[1] > 0 then
			table.insert(var_54_0, function(arg_55_0)
				pg.NewStoryMgr.GetInstance():Play(var_54_3, arg_55_0, true)
			end)
		end

		table.insert(var_54_0, function(arg_56_0)
			local var_56_0

			var_56_0 = {
				hideYes = true,
				hideNo = true,
				type = MSGBOX_TYPE_WORLD_RESET,
				itemFunc = function(arg_57_0)
					self:emit(WorldFleetSelectLayer.ON_DROP, arg_57_0, function()
						pg.MsgboxMgr.GetInstance():ShowMsgBox(var_56_0)
					end)
				end,
				drops = var_54_2,
				tipWord = i18n("world_recycle_item_transform"),
				onNo = arg_56_0
			}

			pg.MsgboxMgr.GetInstance():ShowMsgBox(nil)
		end)
	end

	if var_54_1.resetLimitTip then
		table.insert(var_54_0, function(arg_59_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				hideNo = true,
				content = i18n("world_resource_fill")
			})
		end)
	end

	seriesAsync(var_54_0, function()
		var_54_1:ClearResetAward()
		arg_54_1()
	end)
end

return WorldFleetSelectLayer
