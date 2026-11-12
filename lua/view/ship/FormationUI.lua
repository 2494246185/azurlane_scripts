local FormationUI = class("FormationUI", import("..base.BaseUI"))

FormationUI.RADIUS = 60
FormationUI.LONGPRESS_Y = 30
FormationUI.INTERVAL = math.pi / 2 / 6
FormationUI.MAX_FLEET_NUM = 6
FormationUI.MAX_SHIPP_NUM = 5
FormationUI.TOGGLE_DETAIL = "_detailToggle"
FormationUI.TOGGLE_FORMATION = "_formationToggle"
FormationUI.BUFF_TYEP = {
	blue = "blue",
	pink = "pink",
	cyan = "cyan"
}
FormationUI.TeamNum = {
	"FIRST",
	"SECOND",
	"THIRD",
	"FOURTH",
	"FIFTH",
	"SIXTH"
}

function FormationUI:getUIName()
	return "FormationUI"
end

function FormationUI:preloadUIList()
	return {
		self:getUIName(),
		"CommanderFormationUI"
	}
end

function FormationUI:getResource()
	return table.insertto({
		"shiptype",
		"energy",
		"shipframeb",
		"ui/proposeshipcard"
	}, FormationUI.super.getResource(self))
end

function FormationUI:getFleetShipResList(arg_4_1)
	local var_4_0 = {}
	local var_4_1 = self.shipVOs or {}

	if arg_4_1 then
		_.each(arg_4_1:getShipIds(), function(arg_5_0)
			if var_4_1[arg_5_0] then
				table.insertto(var_4_0, (ResPathSupport.GetSpineCharListByPrefabName(var_4_1[arg_5_0]:getPrefab())))

				if pg.ship_skin_expression[var_4_1[arg_5_0]:getPrefab()] then
					table.insert(var_4_0, "paintingface/" .. var_4_1[arg_5_0]:getPrefab())
				end

				table.insertto(var_4_0, ResPathSupport.GetPaintingListByPaintingName((var_4_1[arg_5_0]:getPainting())))
				table.insert(var_4_0, (string.format(ResPathSupport.ConstPath.BG.ShipCard, var_4_1[arg_5_0]:rarity2bgPrint())))

				local var_5_0, var_5_1 = var_4_1[arg_5_0]:GetFrameAndEffect(true)

				table.insert(var_4_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_5_1)))
				_.each(var_4_1[arg_5_0]:getAttachmentPrefab(), function(arg_6_0)
					if noEmptyStr(arg_6_0.config and arg_6_0.config.orbit_ui) then
						table.insert(var_4_0, ys.Battle.BattleResourceManager.GetOrbitPath(arg_6_0.config and arg_6_0.config.orbit_ui))
					end
				end)
			end
		end)
	end

	return var_4_0
end

function FormationUI:setPlayer(arg_7_1)
	self.player = arg_7_1
end

function FormationUI:setCommanderPrefabFleet(arg_8_1)
	self.commanderPrefabFleets = arg_8_1
end

function FormationUI:init()
	self.eventTriggers = {}
	self.backBtn = self._blurLayer:Find("top/back_btn")
	self._bgFleet = self._adapt:Find("bg_fleet")
	self._bgSub = self._adapt:Find("bg_sub")
	self._bottomPanel = self._blurLayer:Find("bottom")
	self._detailToggle = self._bottomPanel:Find("toggle_list/detail_toggle")
	self._formationToggle = self._bottomPanel:Find("toggle_list/formation_toggle")
	self._nextPage = self._adapt:Find("nextPage")
	self._prevPage = self._adapt:Find("prevPage")
	self._starTpl = self._tf:Find("star_tpl")
	self._heroInfoTpl = self._tf:Find("heroInfo")
	self.topPanel = self._blurLayer:Find("top")
	self._gridTFs = {
		[TeamType.Vanguard] = {},
		[TeamType.Main] = {},
		[TeamType.Submarine] = {}
	}
	self._gridFrame = self._adapt:Find("GridFrame")

	for iter_9_0 = 1, 3 do
		self._gridTFs[TeamType.Main][iter_9_0] = self._gridFrame:Find("main_" .. iter_9_0)
		self._gridTFs[TeamType.Vanguard][iter_9_0] = self._gridFrame:Find("vanguard_" .. iter_9_0)
		self._gridTFs[TeamType.Submarine][iter_9_0] = self._gridFrame:Find("submarine_" .. iter_9_0)
	end

	self._heroContainer = self._adapt:Find("HeroContainer")
	self._formationLogic = BaseFormation.New(self._tf, self._heroContainer, self._heroInfoTpl, self._gridTFs)
	self._fleetInfo = self._blurLayer:Find("fleet_info")
	self._fleetNumText = self._fleetInfo:Find("fleet_number")
	self._fleetNameText = self._fleetInfo:Find("fleet_name/Text")
	self._fleetNameEditBtn = self._fleetInfo:Find("edit_btn")
	self._renamePanel = self._tf:Find("changeName_panel")
	self._renameConfirmBtn = self._renamePanel:Find("frame/queren")
	self._renameCancelBtn = self._renamePanel:Find("frame/cancel")

	setLocalPosition(self._renamePanel, {
		z = -45
	})

	self._propertyFrame = self._blurLayer:Find("property_frame")
	self._cannonPower = self._propertyFrame:Find("cannon/Text")
	self._torpedoPower = self._propertyFrame:Find("torpedo/Text")
	self._AAPower = self._propertyFrame:Find("antiaircraft/Text")
	self._airPower = self._propertyFrame:Find("air/Text")
	self._airDominance = self._propertyFrame:Find("ac/Text")
	self._cost = self._propertyFrame:Find("cost/Text")
	self._mainGS = self._adapt:Find("gear_score/main")
	self._vanguardGS = self._adapt:Find("gear_score/vanguard")
	self._subGS = self._adapt:Find("gear_score/submarine")
	self._arrUpVan = self._vanguardGS:Find("up")
	self._arrDownVan = self._vanguardGS:Find("down")
	self._arrUpMain = self._mainGS:Find("up")
	self._arrDownMain = self._mainGS:Find("down")
	self._arrUpSub = self._subGS:Find("up")
	self._arrDownSub = self._subGS:Find("down")
	self._attrFrame = self._blurLayer:Find("attr_frame")
	self._cardTpl = self._tf:Find("RectShipCardTpl")
	self._cards = {}
	self._cards[TeamType.Main] = {}
	self._cards[TeamType.Vanguard] = {}
	self._cards[TeamType.Submarine] = {}

	setActive(self._attrFrame, false)
	setActive(self._cardTpl, false)

	self.btnRegular = self._bottomPanel:Find("fleet_select/regular")
	self._regularEnFllet = self.btnRegular:Find("fleet/enFleet")
	self._regularNum = self.btnRegular:Find("fleet/num")
	self._regualrCnFleet = self.btnRegular:Find("fleet/CnFleet")
	self.btnSub = self._bottomPanel:Find("fleet_select/sub")
	self._subEnFllet = self.btnSub:Find("fleet/enFleet")
	self._subNum = self.btnSub:Find("fleet/num")
	self._subCnFleet = self.btnSub:Find("fleet/CnFleet")
	self.fleetToggleMask = self._tf:Find("blur_panel/list_mask")
	self.fleetToggleList = self.fleetToggleMask:Find("list")
	self.fleetToggles = {}

	for iter_9_1 = 1, FormationUI.MAX_FLEET_NUM do
		self.fleetToggles[iter_9_1] = self.fleetToggleList:Find("item" .. iter_9_1)
	end

	self._vanGSTxt = self._vanguardGS:Find("Text"):GetComponent("Text")
	self._mainGSTxt = self._mainGS:Find("Text"):GetComponent("Text")
	self._subGSTxt = self._subGS:Find("Text"):GetComponent("Text")
	self.prevMainGS = self.contextData.mainGS
	self.prevVanGS = self.contextData.vanGS
	self.prevSubGS = self.contextData.subGS
	self.mainGSInited = not not self.contextData.mainGS
	self.VanGSInited = not not self.contextData.vanGS
	self.SubGSInited = not not self.contextData.subGS
	self._vanGSTxt.text = self.prevVanGS or 0
	self._mainGSTxt.text = self.prevMainGS or 0
	self._subGSTxt.text = self.prevSubGS or 0
	self.commanderFormationPanel = CommanderFormationPage.New(self._tf, self.event, self.contextData)
	self.index = {
		[FleetType.Normal] = 1,
		[FleetType.Submarine] = 1
	}

	setText(self._adapt:Find("gear_score/main/line/Image/text1"), i18n("pre_combat_main"))
	setText(self._adapt:Find("gear_score/vanguard/line/Image/text1"), i18n("pre_combat_vanguard"))
	setText(self._adapt:Find("gear_score/submarine/line/Image/text1"), i18n("pre_combat_submarine"))

	self.uiSuggestionBtn = self._tf:Find("blur_panel/suggestionBtn")

	setText(self.uiSuggestionBtn:Find("Text"), i18n("formation_suggestion"))
end

function FormationUI:setShips(arg_10_1)
	self.shipVOs = arg_10_1

	self._formationLogic:SetShipVOs(self.shipVOs)
end

function FormationUI:SetFleets(arg_11_1)
	self._fleetVOs = _(arg_11_1):chain():values():filter(function(arg_12_0)
		return arg_12_0:isRegularFleet()
	end):sort(function(arg_13_0, arg_13_1)
		return arg_13_0.id < arg_13_1.id
	end):value()

	if self._currentFleetVO then
		self._currentFleetVO = self:getFleetById(self._currentFleetVO.id)

		self._formationLogic:SetFleetVO(self._currentFleetVO)
	end
end

function FormationUI:getFleetById(arg_14_1)
	return _.detect(self._fleetVOs, function(arg_15_0)
		return arg_15_0.id == arg_14_1
	end)
end

function FormationUI:UpdateFleetView(arg_16_1)
	SplitPackConst.DownloadByLuaArr(self:getFleetShipResList(self._currentFleetVO), function()
		if self.exited then
			return
		end

		self:updateFleetViewAfterResDownload(arg_16_1)
	end)
end

function FormationUI:updateFleetViewAfterResDownload(arg_18_1)
	self:displayFleetInfo()
	self:updateFleetBg()
	self._formationLogic:UpdateGridVisibility()
	self._formationLogic:ResetGrid(TeamType.Vanguard)
	self._formationLogic:ResetGrid(TeamType.Main)
	self._formationLogic:ResetGrid(TeamType.Submarine)
	self:resetFormationComponent()
	self:updateAttrFrame()
	self:updateFleetButton()

	if arg_18_1 then
		self._formationLogic:LoadAllCharacter()
	else
		self._formationLogic:SetAllCharacterPos()
	end
end

function FormationUI:updateFleetBg()
	local var_19_0 = self._currentFleetVO:getFleetType()

	setActive(self._bgFleet, var_19_0 == FleetType.Normal)
	setActive(self._bgSub, var_19_0 == FleetType.Submarine)
end

function FormationUI:updateFleetButton()
	local var_20_1 = self._currentFleetVO:getFleetType()

	self.index[var_20_1] = self._currentFleetVO:getIndex()

	setText(self._regularEnFllet, FormationUI.TeamNum[self.index[FleetType.Normal]] .. " FLEET")
	setText(self._regualrCnFleet, Fleet.DEFAULT_NAME[self.index[FleetType.Normal]])
	setText(self._regularNum, self.index[FleetType.Normal])
	setText(self._subEnFllet, FormationUI.TeamNum[self.index[FleetType.Submarine]] .. " FLEET")
	setText(self._subCnFleet, Fleet.DEFAULT_NAME[self.index[FleetType.Submarine]])
	setText(self._subNum, self.index[FleetType.Submarine])
	setActive(self.btnRegular:Find("on"), var_20_1 == FleetType.Normal)
	setActive(self.btnRegular:Find("off"), var_20_1 ~= FleetType.Normal)
	setActive(self.btnSub:Find("on"), var_20_1 == FleetType.Submarine)
	setActive(self.btnSub:Find("off"), var_20_1 ~= FleetType.Submarine)
end

function FormationUI:SetFleetNameLabel()
	setText(self._fleetNameText, self.defaultFleetName(self._currentFleetVO))
end

function FormationUI:ForceDropChar()
	self._formationLogic:ForceDropChar()

	if self._currentDragDelegate then
		self._forceDropCharacter = true

		LuaHelper.triggerEndDrag(self._currentDragDelegate)
	end
end

function FormationUI:quickExitFunc()
	self:ForceDropChar()
	self:emit(FormationMediator.COMMIT_FLEET, function()
		GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

		self:emit(FormationUI.ON_HOME)
	end)
end

function FormationUI:OnVisible()
	if self._currentFleetVO then
		self:UpdateFleetView(true)
	end
end

function FormationUI:didEnter()
	local var_26_0 = pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "CommanderCatMediator")

	var_26_0 = var_26_0 and not LOCK_COMMANDER
	self.isOpenCommander = var_26_0

	local var_26_1 = getProxy(ActivityProxy):getBuffShipList()

	self._formationLogic:AddHeroInfoModify(function(arg_27_0, arg_27_1)
		local var_27_0 = arg_27_1:getConfigTable()
		local var_27_2 = findTF(arg_27_0, "info")
		local var_27_3 = findTF(var_27_2, "stars")
		local var_27_4 = findTF(var_27_2, "energy")

		for iter_27_0 = 1, arg_27_1:getStar() do
			cloneTplTo(self._starTpl, var_27_3)
		end

		local var_27_5 = GetSpriteFromAtlas("shiptype", shipType2print(arg_27_1:getShipType()))

		if not var_27_5 then
			warning("找不到船形, shipConfigId: " .. arg_27_1.configId)
		end

		setImageSprite(findTF(var_27_2, "type"), var_27_5, true)
		setText(findTF(var_27_2, "frame/lv_contain/lv"), arg_27_1.level)

		if arg_27_1.energy <= Ship.ENERGY_MID then
			setImageSprite(var_27_4, (GetSpriteFromAtlas("energy", arg_27_1:getEnergyPrint())))
			setActive(var_27_4, true)
		end

		local var_27_6 = var_26_1[arg_27_1:getGroupId()]
		local var_27_7 = var_27_2:Find("expbuff")

		setActive(var_27_7, var_27_6 ~= nil)

		if var_27_6 then
			local var_27_8 = tostring(var_27_6 / 100)

			if var_27_6 % 100 > 0 then
				var_27_8 = var_27_8 .. "." .. tostring(var_27_6 % 100)
			end

			setText(var_27_7:Find("text"), string.format("EXP +%s%%", var_27_8))
		end
	end)
	self._formationLogic:AddLongPress(function(arg_28_0, arg_28_1, arg_28_2)
		self:emit(FormationMediator.OPEN_SHIP_INFO, arg_28_1.id, self._currentFleetVO, FormationUI.TOGGLE_FORMATION)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)
	end)
	self._formationLogic:AddClick(function(arg_29_0, arg_29_1)
		self:emit(FormationMediator.CHANGE_FLEET_SHIP, arg_29_0, self._currentFleetVO, FormationUI.TOGGLE_FORMATION, arg_29_1)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)
	end)
	self._formationLogic:AddBeginDrag(function(arg_30_0)
		SetActive(findTF(arg_30_0, "info"), false)
	end)
	self._formationLogic:AddEndDrag(function(arg_31_0)
		SetActive(findTF(arg_31_0, "info"), true)
	end)
	self._formationLogic:AddShiftOnly(function(arg_32_0)
		self:emit(FormationMediator.CHANGE_FLEET_SHIPS_ORDER, arg_32_0)
	end)
	self._formationLogic:AddRemoveShip(function(arg_33_0, arg_33_1)
		self:emit(FormationMediator.REMOVE_SHIP, arg_33_0, arg_33_1)
	end)
	self._formationLogic:AddCheckRemove(function(arg_34_0, arg_34_1, arg_34_2, arg_34_3, arg_34_4)
		if not arg_34_3:canRemove(arg_34_2) then
			local var_34_0, var_34_1 = arg_34_3:getShipPos(arg_34_2)

			pg.TipsMgr.GetInstance():ShowTips(i18n("ship_formationUI_removeError_onlyShip", arg_34_2:getConfigTable().name, arg_34_3.name, Fleet.C_TEAM_NAME[var_34_1]))
			arg_34_0()
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				hideNo = false,
				zIndex = -30,
				content = i18n("ship_formationUI_quest_remove", arg_34_2:getName()),
				onYes = arg_34_1,
				onNo = arg_34_0
			})
		end
	end)
	self._formationLogic:AddGridTipClick(function(arg_35_0, arg_35_1)
		self:emit(FormationMediator.CHANGE_FLEET_SHIP, nil, arg_35_1, FormationUI.TOGGLE_FORMATION, arg_35_0)
	end)
	onButton(self, self.backBtn, function()
		self:ForceDropChar()

		if self._attrFrame.gameObject.activeSelf then
			triggerToggle(self._formationToggle, true)
		else
			self:emit(FormationMediator.COMMIT_FLEET, function()
				GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

				self:emit(FormationUI.ON_BACK)
			end)
		end
	end, SOUND_BACK)

	self._stamp = self._adapt:Find("stamp")

	local var_26_2 = setActive
	local var_26_3 = self._stamp
	local var_26_4 = not LOCK_CLICK_MINGSHI and (BATTLE_DEBUG or getProxy(TaskProxy):mingshiTouchFlagEnabled()) or false

	var_26_2(var_26_3, (false or nil) and true)
	onButton(self, self._stamp, function()
		if BATTLE_DEBUG then
			print(self._currentFleetVO:genRobotDataString())
		end

		getProxy(TaskProxy):dealMingshiTouchFlag(6)
	end, SFX_CONFIRM)
	onButton(self, self._fleetNameEditBtn, function()
		self:DisplayRenamePanel(true)
	end, SFX_PANEL)
	onButton(self, self._renameConfirmBtn, function()
		self:emit(FormationMediator.CHANGE_FLEET_NAME, self._currentFleetVO.id, (getInputText(findTF(self._renamePanel, "frame/name_field"))))
	end, SFX_CONFIRM)
	onButton(self, self._renameCancelBtn, function()
		self:DisplayRenamePanel(false)
	end, SFX_CANCEL)
	onToggle(self, self._detailToggle, function(arg_42_0)
		self:ForceDropChar()

		if arg_42_0 then
			self:displayAttrFrame()
		end
	end, SFX_PANEL)
	onToggle(self, self._formationToggle, function(arg_43_0)
		self:ForceDropChar()

		if arg_43_0 then
			self:hideAttrFrame()
		end
	end, SFX_PANEL)
	onButton(self, self._attrFrame, function()
		triggerToggle(self._formationToggle, true)
	end, SFX_PANEL)
	onButton(self, self.fleetToggleMask, function()
		setActive(self.fleetToggleMask, false)
		self:tweenTabArrow(true)
	end, SFX_CANCEL)
	onButton(self, self.btnRegular, function()
		self:updateToggleList(_.filter(self._fleetVOs, function(arg_47_0)
			return arg_47_0:getFleetType() == FleetType.Normal
		end))

		local var_46_0 = self._currentFleetVO:getFleetType() == FleetType.Normal

		triggerToggle(self.fleetToggles[self.index[FleetType.Normal]], true)

		if var_46_0 then
			setActive(self.fleetToggleMask, true)
			self:tweenTabArrow(false)
			setAnchoredPosition(self.fleetToggleList, Vector3.New(209, 129))
		end
	end, SFX_PANEL)
	onButton(self, self.btnSub, function()
		self:updateToggleList(_.filter(self._fleetVOs, function(arg_49_0)
			return arg_49_0:getFleetType() == FleetType.Submarine
		end))

		local var_48_0 = self._currentFleetVO:getFleetType() == FleetType.Submarine

		triggerToggle(self.fleetToggles[self.index[FleetType.Submarine]], true)

		if var_48_0 then
			setActive(self.fleetToggleMask, true)
			self:tweenTabArrow(false)
			setAnchoredPosition(self.fleetToggleList, Vector3.New(755, 129))
		end
	end, SFX_PANEL)
	onButton(self, self._prevPage, function()
		self:ForceDropChar()
		self:emit(FormationMediator.ON_CHANGE_FLEET, (self:selectFleetByStep(-1)))
	end, SFX_PANEL)
	onButton(self, self._nextPage, function()
		self:ForceDropChar()
		self:emit(FormationMediator.ON_CHANGE_FLEET, (self:selectFleetByStep(1)))
	end, SFX_PANEL)
	self:SetCurrentFleetID((defaultValue(self.contextData.number, 1)))

	if self.isOpenCommander then
		self.commanderFormationPanel:ActionInvoke("Show")
	end

	self:UpdateFleetView(true)
	triggerToggle(self[self.contextData.toggle or FormationUI.TOGGLE_FORMATION], true)
	self:tweenTabArrow(true)
	onButton(self, self._vanguardGS:Find("SonarTip"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.fleet_antisub_range_tip.tip
		})
	end, SFX_PANEL)
	onButton(self, self.uiSuggestionBtn, function()
		self:emit(BaseUI.ON_GO_SCENE, SCENE.FORMATION_SUGGESTION)
	end, SFX_PANEL)
	setActive(self.uiSuggestionBtn, LevelTools.HasUnlockSuggestionMap())
end

function FormationUI:SetCurrentFleetID(arg_54_1)
	self._currentFleetVO = self:getFleetById(arg_54_1)

	self._formationLogic:SetFleetVO(self._currentFleetVO)
	self:updateCommanderFormation()
end

function FormationUI:updateCommanderFormation()
	if self.isOpenCommander then
		self.commanderFormationPanel:Load()
		self.commanderFormationPanel:ActionInvoke("Update", self._currentFleetVO, self.commanderPrefabFleets)
	end
end

function FormationUI:selectFleetByStep(arg_56_1)
	local var_56_0 = table.indexof(self._fleetVOs, self._currentFleetVO)

	while true do
		var_56_0 = var_56_0 + arg_56_1

		if var_56_0 < 1 or var_56_0 > #self._fleetVOs then
			break
		end

		if self._fleetVOs[var_56_0]:isUnlock() then
			return self._fleetVOs[var_56_0].id
		end
	end
end

function FormationUI:updateToggleList(arg_57_1)
	local var_57_0 = self.fleetToggleList:GetComponent(typeof(ToggleGroup))

	var_57_0.allowSwitchOff = true

	local var_57_1 = self._currentFleetVO.id

	for iter_57_0 = 1, #self.fleetToggles do
		local var_57_2 = self.fleetToggles[iter_57_0]
		local var_57_3 = arg_57_1[iter_57_0]

		setActive(self.fleetToggles[iter_57_0], arg_57_1[iter_57_0])

		if var_57_3 then
			local var_57_4 = var_57_2:GetComponent(typeof(Toggle))
			local var_57_5 = var_57_2:Find("lock")
			local var_57_6, var_57_7 = var_57_3:isUnlock()

			setToggleEnabled(var_57_2, var_57_6)
			setActive(var_57_5, not var_57_6)
			setActive(var_57_2:Find("on"), var_57_6 and var_57_1 == var_57_3.id)
			setActive(var_57_2:Find("off"), var_57_6 and var_57_1 ~= var_57_3.id)

			if var_57_6 then
				var_57_4.isOn = var_57_3.id == var_57_1

				onToggle(self, var_57_2, function(arg_58_0)
					if arg_58_0 then
						setActive(self.fleetToggleMask, false)
						self:tweenTabArrow(true)

						if var_57_3.id ~= var_57_1 then
							self:ForceDropChar()
							self:emit(FormationMediator.ON_CHANGE_FLEET, var_57_3.id)
						end
					end
				end, SFX_UI_TAG)
			else
				onButton(self, var_57_5, function()
					pg.TipsMgr.GetInstance():ShowTips(var_57_7)
				end, SFX_UI_CLICK)
			end
		end
	end

	var_57_0.allowSwitchOff = false
end

function FormationUI:resetFormationComponent()
	SetActive(self._gridTFs.main[1]:Find("flag"), #self._currentFleetVO:getTeamByName(TeamType.Main) ~= 0)
	SetActive(self._gridTFs.submarine[1]:Find("flag"), #self._currentFleetVO:getTeamByName(TeamType.Submarine) ~= 0)
end

function FormationUI:sortCardSiblingIndex()
	_.each({
		TeamType.Main,
		TeamType.Vanguard,
		TeamType.Submarine
	}, function(arg_62_0)
		if #self._cards[arg_62_0] > 0 then
			for iter_62_0 = 1, #self._cards[arg_62_0] do
				self._cards[arg_62_0][iter_62_0].tr:SetSiblingIndex(iter_62_0 - 1)
			end
		end
	end)
end

function FormationUI:displayFleetInfo()
	SetActive(self._prevPage, self:selectFleetByStep(-1))
	SetActive(self._nextPage, self:selectFleetByStep(1))
	setActive(self._adapt:Find("gear_score"), true)
	setActive(self._vanguardGS, false)
	setActive(self._mainGS, false)
	setActive(self._subGS, false)

	local var_63_0 = self._currentFleetVO:GetPropertiesSum()
	local var_63_1 = math.floor(self._currentFleetVO:GetGearScoreSum(TeamType.Vanguard))
	local var_63_2 = math.floor(self._currentFleetVO:GetGearScoreSum(TeamType.Main))
	local var_63_3 = math.floor(self._currentFleetVO:GetGearScoreSum(TeamType.Submarine))

	self.tweenNumText(self._cannonPower, var_63_0.cannon)
	self.tweenNumText(self._torpedoPower, var_63_0.torpedo)
	self.tweenNumText(self._AAPower, var_63_0.antiAir)
	self.tweenNumText(self._airPower, var_63_0.air)
	self.tweenNumText(self._cost, self._currentFleetVO:GetCostSum().oil)

	if OPEN_AIR_DOMINANCE then
		setActive(self._airDominance.parent, true)
		self.tweenNumText(self._airDominance, self._currentFleetVO:getFleetAirDominanceValue())
	else
		setActive(self._airDominance.parent, false)
	end

	local var_63_4 = self._currentFleetVO:getFleetType()

	if var_63_4 == FleetType.Normal then
		setActive(self._vanguardGS, true)
		setActive(self._mainGS, true)
		setActive(self._arrUpVan, false)
		setActive(self._arrDownVan, false)
		setActive(self._arrUpMain, false)
		setActive(self._arrDownMain, false)

		self.prevVanGS = tonumber(self._vanGSTxt.text)

		self.tweenNumText(self._vanguardGS:Find("Text"), var_63_1)

		if self.VanGSInited then
			setActive(self._arrUpVan, var_63_1 > self.prevVanGS)
			setActive(self._arrDownVan, var_63_1 < self.prevVanGS)
		end

		self.prevMainGS = tonumber(self._mainGSTxt.text)

		self.tweenNumText(self._mainGS:Find("Text"), var_63_2)

		if self.mainGSInited then
			setActive(self._arrUpMain, var_63_2 > self.prevMainGS)
			setActive(self._arrDownMain, var_63_2 < self.prevMainGS)
		end

		self.contextData.mainGS = var_63_2
		self.contextData.vanGS = var_63_1
		self.mainGSInited = true
		self.VanGSInited = true

		local var_63_5 = self._currentFleetVO:GetFleetSonarRange()

		setActive(self._vanguardGS:Find("SonarActive"), var_63_5 > 0)
		setActive(self._vanguardGS:Find("SonarInactive"), var_63_5 <= 0)

		local function var_63_6()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = pg.gametip.fleet_antisub_range_tip.tip
			})
		end

		if var_63_5 > 0 then
			setText(self._vanguardGS:Find("SonarActive/Text"), math.floor(var_63_5))
			onButton(self, self._vanguardGS:Find("SonarActive"), var_63_6, SFX_PANEL)
		else
			onButton(self, self._vanguardGS:Find("SonarInactive"), var_63_6, SFX_PANEL)
		end
	elseif var_63_4 == FleetType.Submarine then
		setActive(self._arrUpSub, false)
		setActive(self._arrDownSub, false)
		setActive(self._subGS, true)

		self.prevSubGS = tonumber(self._subGSTxt.text)

		self.tweenNumText(self._subGS:Find("Text"), var_63_3)

		if self.SubGSInited then
			setActive(self._arrUpSub, var_63_3 > self.prevSubGS)
			setActive(self._arrDownSub, var_63_3 < self.prevSubGS)
		end

		self.contextData.subGS = var_63_3
		self.SubGSInited = true
	end

	self:SetFleetNameLabel()
	setText(self._fleetNumText, self._currentFleetVO:getIndex())
end

function FormationUI:DisplayRenamePanel(arg_65_1)
	SetActive(self._renamePanel, arg_65_1)

	if arg_65_1 then
		pg.UIMgr.GetInstance():BlurPanel(self._renamePanel)
		setInputText(findTF(self._renamePanel, "frame/name_field"), (getText(self._fleetNameText)))
	else
		pg.UIMgr.GetInstance():UnOverlayPanel(self._renamePanel, self._tf)
	end
end

function FormationUI:hideAttrFrame()
	SetActive(self._attrFrame, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._blurLayer, self._tf)
end

function FormationUI:displayAttrFrame()
	pg.UIMgr.GetInstance():BlurPanel(self._blurLayer)
	SetActive(self._attrFrame, true)
	self:initAttrFrame()
end

function FormationUI:initAttrFrame()
	local var_68_0 = false

	for iter_68_0, iter_68_1 in pairs({
		[TeamType.Main] = self._currentFleetVO.mainShips,
		[TeamType.Vanguard] = self._currentFleetVO.vanguardShips,
		[TeamType.Submarine] = self._currentFleetVO.subShips
	}) do
		if #self._cards[iter_68_0] == 0 then
			local var_68_1 = self._attrFrame:Find(iter_68_0 .. "/list")

			for iter_68_2 = 1, 3 do
				table.insert(self._cards[iter_68_0], FormationDetailCard.New(cloneTplTo(self._cardTpl, var_68_1).gameObject))
			end

			var_68_0 = true
		end
	end

	if var_68_0 then
		self:updateAttrFrame()
	end
end

function FormationUI:updateAttrFrame()
	local var_69_0 = self._currentFleetVO:getFleetType()

	for iter_69_0, iter_69_1 in pairs({
		[TeamType.Main] = self._currentFleetVO.mainShips,
		[TeamType.Vanguard] = self._currentFleetVO.vanguardShips,
		[TeamType.Submarine] = self._currentFleetVO.subShips
	}) do
		local var_69_1 = self._cards[iter_69_0]

		if #self._cards[iter_69_0] > 0 then
			local var_69_2 = var_69_0 == FleetType.Submarine and iter_69_0 == TeamType.Vanguard

			for iter_69_2 = 1, 3 do
				if iter_69_2 <= #iter_69_1 then
					var_69_1[iter_69_2]:update(self.shipVOs[iter_69_1[iter_69_2]], var_69_2)
					var_69_1[iter_69_2]:updateProps(self:getCardAttrProps(self.shipVOs[iter_69_1[iter_69_2]]))
				else
					var_69_1[iter_69_2]:update(nil, var_69_2)
				end

				self:detachOnCardButton(var_69_1[iter_69_2])

				if not var_69_2 then
					self:attachOnCardButton(var_69_1[iter_69_2], iter_69_0)
				end
			end
		end
	end

	setActive(self._attrFrame:Find(TeamType.Main), var_69_0 == FleetType.Normal)
	setActive(self._attrFrame:Find(TeamType.Submarine), var_69_0 == FleetType.Submarine)
	setActive(self._attrFrame:Find(TeamType.Vanguard .. "/vanguard"), var_69_0 ~= FleetType.Submarine)
	self:updateUltimateTitle()
end

function FormationUI:updateUltimateTitle()
	local var_70_0 = self._cards[TeamType.Main]

	if #self._cards[TeamType.Main] > 0 then
		for iter_70_0 = 1, #var_70_0 do
			go(var_70_0[iter_70_0].shipState):SetActive(iter_70_0 == 1)
		end
	end
end

function FormationUI:getCardAttrProps(arg_71_1)
	return {
		{
			i18n("word_attr_durability"),
			tostring(math.floor(arg_71_1:getProperties().durability))
		},
		{
			i18n("word_attr_luck"),
			"" .. tostring(math.floor((arg_71_1:getBattleTotalExpend())))
		},
		{
			i18n("word_synthesize_power"),
			"<color=#ffff00>" .. arg_71_1:getShipCombatPower() .. "</color>"
		}
	}
end

function FormationUI:detachOnCardButton(arg_72_1)
	local var_72_0 = GetOrAddComponent(arg_72_1.go, "EventTriggerListener")

	var_72_0:RemovePointClickFunc()
	var_72_0:RemoveBeginDragFunc()
	var_72_0:RemoveDragFunc()
	var_72_0:RemoveDragEndFunc()
end

function FormationUI:attachOnCardButton(arg_73_1, arg_73_2)
	local var_73_0 = GetOrAddComponent(arg_73_1.go, "EventTriggerListener")

	self.eventTriggers[var_73_0] = true

	var_73_0:AddPointClickFunc(function(arg_74_0, arg_74_1)
		if not self.carddrag and arg_74_0 == arg_73_1.go then
			if arg_73_1.shipVO then
				self:emit(FormationMediator.OPEN_SHIP_INFO, arg_73_1.shipVO.id, self._currentFleetVO, FormationUI.TOGGLE_DETAIL)
			else
				self:emit(FormationMediator.CHANGE_FLEET_SHIP, arg_73_1.shipVO, self._currentFleetVO, FormationUI.TOGGLE_DETAIL, arg_73_2)
			end

			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)
		end
	end)

	if arg_73_1.shipVO then
		local var_73_1 = self._cards[arg_73_2]
		local var_73_2 = arg_73_1.tr.parent:GetComponent("ContentSizeFitter")
		local var_73_3 = arg_73_1.tr.parent:GetComponent("HorizontalLayoutGroup")
		local var_73_4 = arg_73_1.tr.rect.width * 0.5
		local var_73_5 = {}

		var_73_0:AddBeginDragFunc(function()
			if self.carddrag then
				return
			end

			self._currentDragDelegate = var_73_0
			self.carddrag = arg_73_1
			var_73_2.enabled = false
			var_73_3.enabled = false

			arg_73_1.tr:SetSiblingIndex(#var_73_1)

			for iter_75_0 = 1, #var_73_1 do
				if var_73_1[iter_75_0] == arg_73_1 then
					self._shiftIndex = iter_75_0
				end

				var_73_5[iter_75_0] = var_73_1[iter_75_0].tr.anchoredPosition
			end

			LeanTween.scale(arg_73_1.paintingTr, Vector3(1.1, 1.1, 0), 0.3)
		end)
		var_73_0:AddDragFunc(function(arg_76_0, arg_76_1)
			if self.carddrag ~= arg_73_1 then
				return
			end

			local var_76_0 = arg_73_1.tr.localPosition

			var_76_0.x = self:change2ScrPos(arg_73_1.tr.parent, arg_76_1.position).x
			arg_73_1.tr.localPosition = var_76_0

			local var_76_1 = 1

			for iter_76_0 = 1, #var_73_1 do
				if var_73_1[iter_76_0] ~= arg_73_1 and var_73_1[iter_76_0].shipVO and arg_73_1.tr.localPosition.x > var_73_1[iter_76_0].tr.localPosition.x + (var_76_1 < self._shiftIndex and 1.1 or -1.1) * var_73_4 then
					var_76_1 = var_76_1 + 1
				end
			end

			if self._shiftIndex ~= var_76_1 then
				self._formationLogic:Shift(self._shiftIndex, var_76_1, arg_73_2)
				self:shiftCard(self._shiftIndex, var_76_1, arg_73_2)

				for iter_76_1 = 1, #var_73_1 do
					if var_73_1[iter_76_1] and var_73_1[iter_76_1] ~= arg_73_1 then
						var_73_1[iter_76_1].tr.anchoredPosition = var_73_5[iter_76_1]
					end
				end
			end
		end)
		var_73_0:AddDragEndFunc(function(arg_77_0, arg_77_1)
			if self.carddrag ~= arg_73_1 then
				return
			end

			function resetCard()
				for iter_78_0 = 1, #var_73_1 do
					var_73_1[iter_78_0].tr.anchoredPosition = var_73_5[iter_78_0]
				end

				var_73_2.enabled = true
				var_73_3.enabled = true
				self._shiftIndex = nil

				self:updateUltimateTitle()
				self._formationLogic:SortSiblingIndex()
				self:sortCardSiblingIndex()
				self:emit(FormationMediator.CHANGE_FLEET_SHIPS_ORDER, self._currentFleetVO)

				var_73_0.enabled = true
				self.carddrag = nil
			end

			self._forceDropCharacter = nil
			self._currentDragDelegate = nil
			var_73_0.enabled = false

			if self._forceDropCharacter then
				resetCard()

				arg_73_1.paintingTr.localScale = Vector3(1, 1, 0)
			else
				LeanTween.value(arg_73_1.go, arg_73_1.tr.anchoredPosition.x, var_73_5[self._shiftIndex].x, math.min(math.abs(arg_73_1.tr.anchoredPosition.x - var_73_5[self._shiftIndex].x) / 200, 1) * 0.3):setEase(LeanTweenType.easeOutCubic):setOnUpdate(System.Action_float(function(arg_79_0)
					arg_73_1.tr.anchoredPosition.x = arg_79_0
					arg_73_1.tr.anchoredPosition = arg_73_1.tr.anchoredPosition
				end)):setOnComplete(System.Action(function()
					resetCard()
					LeanTween.scale(arg_73_1.paintingTr, Vector3(1, 1, 0), 0.3)
				end))
			end
		end)
	end
end

function FormationUI:shiftCard(arg_81_1, arg_81_2, arg_81_3)
	local var_81_0 = self._cards[arg_81_3]

	if #self._cards[arg_81_3] > 0 then
		var_81_0[arg_81_1], var_81_0[arg_81_2] = self._cards[arg_81_3][arg_81_2], self._cards[arg_81_3][arg_81_1]
	end

	self._shiftIndex = arg_81_2
end

function FormationUI:change2ScrPos(arg_82_1, arg_82_2)
	return (LuaHelper.ScreenToLocal(arg_82_1, arg_82_2, pg.UIMgr.GetInstance().overlayCameraComp))
end

function FormationUI:tweenNumText(arg_83_1, arg_83_2, arg_83_3, arg_83_4)
	LeanTween.value(go(self), arg_83_4 or 0, math.floor(arg_83_1), arg_83_2 or 0.7):setOnUpdate(System.Action_float(function(arg_84_0)
		setText(self, math.floor(arg_84_0))
	end)):setOnComplete(System.Action(function()
		if arg_83_3 then
			arg_83_3()
		end
	end))
end

function FormationUI:defaultFleetName()
	if self.name == "" or self.name == nil then
		return Fleet.DEFAULT_NAME[self.id]
	else
		return self.name
	end
end

function FormationUI:GetFleetCount()
	local var_87_0 = 0

	for iter_87_0, iter_87_1 in pairs(self._fleetVOs) do
		var_87_0 = var_87_0 + 1
	end

	return var_87_0
end

function FormationUI:tweenTabArrow(arg_88_1)
	local var_88_0 = self.btnRegular:Find("arr")
	local var_88_1 = self.btnSub:Find("arr")

	setActive(var_88_0, arg_88_1)
	setActive(var_88_1, arg_88_1)

	if arg_88_1 then
		LeanTween.moveLocalY(go(var_88_0), var_88_0.localPosition.y + 8, 0.8):setEase(LeanTweenType.easeInOutSine):setLoopPingPong(-1)
		LeanTween.moveLocalY(go(var_88_1), var_88_1.localPosition.y + 8, 0.8):setEase(LeanTweenType.easeInOutSine):setLoopPingPong(-1)
	else
		LeanTween.cancel(go(var_88_0))
		LeanTween.cancel(go(var_88_1))

		var_88_0.localPosition.y = 80
		var_88_0.localPosition = var_88_0.localPosition
		var_88_1.localPosition.y = 80
		var_88_1.localPosition = var_88_1.localPosition
	end
end

function FormationUI:recyclePainting()
	for iter_89_0, iter_89_1 in pairs(self._cards) do
		for iter_89_2, iter_89_3 in ipairs(iter_89_1) do
			iter_89_3:clear()
		end
	end
end

function FormationUI:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if isActive(self._renamePanel) then
		self:DisplayRenamePanel(false)
	else
		triggerButton(self.backBtn)
	end
end

function FormationUI:willExit()
	self.commanderFormationPanel:Destroy()

	if self._attrFrame.gameObject.activeSelf then
		pg.UIMgr.GetInstance():UnOverlayPanel(self._blurLayer, self._tf)
	end

	self._formationLogic:Destroy()
	self:recyclePainting()
	self:DisplayRenamePanel(false)
	self:tweenTabArrow(false)

	if self.tweens then
		cancelTweens(self.tweens)
	end

	if self.eventTriggers then
		for iter_91_0, iter_91_1 in pairs(self.eventTriggers) do
			ClearEventTrigger(iter_91_0)
		end

		self.eventTriggers = nil
	end
end

return FormationUI
