local ChapterPreCombatLayer = class("ChapterPreCombatLayer", import("..base.BaseUI"))
local FormationUI = import("..ship.FormationUI")
local var_0_2 = {
	[99] = true
}

ChapterPreCombatLayer.optionsPath = {
	"adapt/top/option"
}

function ChapterPreCombatLayer:getUIName()
	return "ChapterPreCombatUI"
end

function ChapterPreCombatLayer:ResUISettings()
	return true
end

function ChapterPreCombatLayer:getResource()
	return table.insertto(ResList.ChapterPreCombatLayerResConst.GetConstResource(), ChapterPreCombatLayer.super.getResource(self))
end

function ChapterPreCombatLayer:downloadChapterPreCombatRes(arg_4_1, arg_4_2)
	SplitPackConst.DownloadByLuaArr(ResList.ChapterPreCombatLayerResConst.GetResource(arg_4_1), function()
		if self.exited or self.chapter ~= arg_4_1 then
			return
		end

		arg_4_2()
	end)
end

function ChapterPreCombatLayer:init()
	self._startBtn = self.rtAdapt:Find("right/start")
	self._popup = self.rtAdapt:Find("right/popup")
	self._costText = self.rtAdapt:Find("right/popup/Text")
	self._costTip = self.rtAdapt:Find("right/popup/tip")
	self._extraCostBuffIcon = self.rtAdapt:Find("right/operation_buff_icon")
	self._backBtn = self.rtAdapt:Find("top/back_btn")
	self._moveLayer = self._tf:Find("moveLayer")

	local var_6_0 = self.rtAdapt:Find("middle")

	self._mainGS = var_6_0:Find("gear_score/main/Text")
	self._vanguardGS = var_6_0:Find("gear_score/vanguard/Text")

	setText(self._mainGS, 0)
	setText(self._vanguardGS, 0)

	self._gridTFs = {
		vanguard = {},
		main = {}
	}
	self._gridFrame = var_6_0:Find("mask/GridFrame")

	for iter_6_0 = 1, 3 do
		self._gridTFs[TeamType.Vanguard][iter_6_0] = self._gridFrame:Find("vanguard_" .. iter_6_0)
		self._gridTFs[TeamType.Main][iter_6_0] = self._gridFrame:Find("main_" .. iter_6_0)
	end

	self._heroContainer = var_6_0:Find("HeroContainer")
	self._strategy = var_6_0:Find("strategy")

	setActive(self._strategy, true)

	self._spoilsContainer = self.rtAdapt:Find("right/infomation/spoils/items/items_container")
	self._goals = self.rtAdapt:Find("right/infomation/goal")
	self._item = self:getTpl("right/infomation/spoils/items/item_tpl", self.rtAdapt)
	self._heroInfo = self:getTpl("heroInfo")
	self._starTpl = self:getTpl("star_tpl")
	self._middle = self.rtAdapt:Find("middle")
	self._right = self.rtAdapt:Find("right")
	self._formationLogic = BaseFormation.New(self._tf, self._heroContainer, self._heroInfo, self._gridTFs)

	setmetatable({
		Shift = function(arg_7_0, arg_7_1, arg_7_2)
			return
		end
	}, self._formationLogic)
	setText(self.rtAdapt:Find("middle/gear_score/vanguard/line/Image/Text1"), i18n("pre_combat_vanguard"))
	setText(self.rtAdapt:Find("middle/gear_score/main/line/Image/Text1"), i18n("pre_combat_main"))

	self._fleet = self.rtAdapt:Find("middle/fleet")

	setText(self._fleet:Find("title_bg/Text"), i18n("pre_combat_team"))

	self._ship_tpl = self._fleet:Find("shiptpl")
	self._empty_tpl = self._fleet:Find("emptytpl")

	setActive(self._ship_tpl, false)
	setActive(self._empty_tpl, false)

	self._autoToggle = self.rtAdapt:Find("middle/auto_toggle")
	self._autoSubToggle = self.rtAdapt:Find("middle/sub_toggle_container/sub_toggle")
	self.topPanel = self.rtAdapt:Find("top")
	self.strategyInfo = self._tf:Find("strategy_info")

	setActive(self.strategyInfo, false)

	self._operaionBuffTips = self._extraCostBuffIcon:Find("popup")

	setAnchoredPosition(self._middle, {
		x = -840
	})
	setAnchoredPosition(self._right, {
		x = 470
	})
	self:Register()
end

function ChapterPreCombatLayer:uiStartAnimating()
	setAnchoredPosition(self.topPanel, {
		y = 100
	})
	shiftPanel(self._middle, 0, nil, 0.3, 0, true, true)
	shiftPanel(self._right, 0, nil, 0.3, 0, true, true, nil)
	shiftPanel(self.topPanel, nil, 0, 0.3, 0, true, true, nil, nil)
end

function ChapterPreCombatLayer:uiExitAnimating()
	shiftPanel(self._middle, -840, nil, 0.3, 0, true, true)
	shiftPanel(self._right, 470, nil, 0.3, 0, true, true)
	shiftPanel(self.topPanel, nil, self.topPanel.rect.height, 0.3, 0, true, true, nil, nil)
end

function ChapterPreCombatLayer:didEnter()
	onButton(self, self._backBtn, function()
		GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

		self:uiExitAnimating()
		LeanTween.delayedCall(0.3, System.Action(function()
			self:emit(ChapterPreCombatLayer.ON_CLOSE)
		end))
	end, SFX_CANCEL)
	onButton(self, self._startBtn, function()
		self:emit(ChapterPreCombatMediator.ON_START)
	end, SFX_UI_WEIGHANCHOR)
	onToggle(self, self._autoToggle, function(arg_14_0)
		self:emit(ChapterPreCombatMediator.ON_AUTO, {
			isOn = not arg_14_0,
			toggle = self._autoToggle
		})

		if arg_14_0 and self.subUseable == true then
			setActive(self._autoSubToggle, true)
			onToggle(self, self._autoSubToggle, function(arg_15_0)
				self:emit(ChapterPreCombatMediator.ON_SUB_AUTO, {
					isOn = not arg_15_0,
					toggle = self._autoSubToggle
				})
			end, SFX_PANEL, SFX_PANEL)
			triggerToggle(self._autoSubToggle, ys.Battle.BattleState.IsAutoSubActive())
		else
			setActive(self._autoSubToggle, false)
		end
	end, SFX_PANEL, SFX_PANEL)
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)
	onNextTick(function()
		if self.exited then
			return
		end

		triggerToggle(self._autoToggle, ys.Battle.BattleState.IsAutoBotActive())
	end)
	setAnchoredPosition(self.topPanel, {
		y = self.topPanel.rect.height
	})
	onNextTick(function()
		self:uiStartAnimating()
	end)
	onButton(self, self.rtAdapt:Find("middle/gear_score/vanguard/SonarTip"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.fleet_antisub_range_tip.tip
		})
	end, SFX_PANEL)
	onButton(self, self._costTip, function()
		local var_19_0, var_19_1, var_19_2 = self.chapter:isOverFleetCost(self.chapter.fleet, (self.chapter:getStageId(self.chapter.fleet.line.row, self.chapter.fleet.line.column)))

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			hideNo = true,
			content = i18n("use_oil_limit_help", var_19_2, var_19_1)
		})
	end)
end

function ChapterPreCombatLayer:Register()
	self._formationLogic:AddHeroInfoModify(function(arg_21_0, arg_21_1, arg_21_2)
		setAnchoredPosition(arg_21_0, {
			x = 0,
			y = 0
		})
		SetActive(arg_21_0, true)

		arg_21_0.name = "info"

		local var_21_0 = arg_21_0:Find("info")
		local var_21_1 = var_21_0:Find("stars")
		local var_21_2 = arg_21_1:getEnergy() <= Ship.ENERGY_MID
		local var_21_3 = var_21_0:Find("energy")

		if var_21_2 then
			local var_21_4, var_21_5 = arg_21_1:getEnergyPrint()
			local var_21_6 = GetSpriteFromAtlas("energy", var_21_4)

			if not var_21_6 then
				warning("找不到疲劳")
			end

			setImageSprite(var_21_3, var_21_6)
		end

		setActive(var_21_3, var_21_2)

		for iter_21_0 = 1, arg_21_1:getStar() do
			cloneTplTo(self._starTpl, var_21_1)
		end

		local var_21_7 = GetSpriteFromAtlas("shiptype", shipType2print(arg_21_1:getShipType()))

		if not var_21_7 then
			warning("找不到船形, shipConfigId: " .. arg_21_1.configId)
		end

		setImageSprite(var_21_0:Find("type"), var_21_7, true)
		setText(var_21_0:Find("frame/lv_contain/lv"), arg_21_1.level)

		local var_21_8 = var_21_0:Find("blood")
		local var_21_9 = var_21_8:Find("fillarea/green")
		local var_21_10 = var_21_8:Find("fillarea/red")

		setActive(var_21_9, arg_21_1.hpRant >= ChapterConst.HpGreen)
		setActive(var_21_10, arg_21_1.hpRant < ChapterConst.HpGreen)

		;(arg_21_1.hpRant >= ChapterConst.HpGreen and var_21_9 or var_21_10):GetComponent("Image").fillAmount = arg_21_1.hpRant * 0.0001

		arg_21_2:SetVisible(arg_21_1.hpRant > 0)
		SetActive(arg_21_0, arg_21_1.hpRant > 0)

		local var_21_11 = getProxy(ActivityProxy)
		local var_21_12 = var_21_11:getBuffShipList()[arg_21_1:getGroupId()]
		local var_21_13 = var_21_0:Find("expbuff")

		setActive(var_21_11, var_21_12 ~= nil)

		if var_21_12 then
			local var_21_14 = tostring(var_21_12 / 100)

			if var_21_12 % 100 > 0 then
				var_21_14 = var_21_14 .. "." .. tostring(var_21_12 % 100)
			end

			setText(var_21_13:Find("text"), string.format("EXP +%s%%", var_21_14))
		end
	end)
	self._formationLogic:AddShiftOnly(function(arg_22_0)
		self:updateView(false)
	end)
	self._formationLogic:AddEndDrag(function()
		self:emit(ChapterPreCombatMediator.ON_SWITCH_SHIP, self.chapter.fleet)
	end)
	self._formationLogic:AddCheckRemove(function(arg_24_0, arg_24_1)
		arg_24_0()
	end)
	self._formationLogic:AddCheckSwitch(function(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4)
		if arg_25_3.ships[arg_25_3:getTeamByName(arg_25_4)[arg_25_2]].hpRant == 0 then
			return
		end

		arg_25_0()
	end)
	self._formationLogic:AddCheckBeginDrag(function(arg_26_0, arg_26_1, arg_26_2)
		return arg_26_0.hpRant > 0
	end)
end

function ChapterPreCombatLayer:setPlayerInfo(arg_27_1)
	return
end

function ChapterPreCombatLayer:updateChapter(arg_28_1)
	self.chapter = arg_28_1

	self:downloadChapterPreCombatRes(arg_28_1, function()
		self:updateChapterAfterDownload(arg_28_1)
	end)
end

function ChapterPreCombatLayer:updateChapterAfterDownload(arg_30_1)
	if self.chapter ~= arg_30_1 then
		return
	end

	local var_30_0 = self.chapter.fleet

	self._formationLogic:SetFleetVO(self.chapter.fleet)
	self._formationLogic:SetShipVOs(var_30_0.ships)
	self:updateView(true)
end

function ChapterPreCombatLayer:setSubFlag(arg_31_1)
	self.subUseable = arg_31_1 or false
end

function ChapterPreCombatLayer:updateView(arg_32_1)
	self._formationLogic:ResetGrid(TeamType.Vanguard, true)
	self._formationLogic:ResetGrid(TeamType.Main, true)
	SetActive(self._gridTFs[TeamType.Main][1]:Find("flag"), true)

	if arg_32_1 then
		self:updateStageView((self.chapter:getStageId(self.chapter.fleet.line.row, self.chapter.fleet.line.column)))
		self._formationLogic:LoadAllCharacter()
	else
		self._formationLogic:SetAllCharacterPos()
	end

	self:updateBattleFleetView()
	self:updateStrategyIcon()
	self:displayFleetInfo()
end

function ChapterPreCombatLayer:updateStageView(arg_33_1)
	assert(pg.expedition_data_template[arg_33_1], "expedition_data_template not exist: " .. arg_33_1)

	local var_33_3 = Clone(pg.expedition_data_template[arg_33_1].award_display)
	local var_33_4 = checkExist(pg.expedition_activity_template[arg_33_1], {
		"pt_drop_display"
	})

	if var_33_4 and type(var_33_4) == "table" then
		local var_33_5 = getProxy(ActivityProxy)

		for iter_33_0 = #var_33_4, 1, -1 do
			local var_33_6, var_33_7, var_33_8, var_33_9 = unpack(var_33_4[iter_33_0])
			local var_33_10 = var_33_5:getActivityById(var_33_6)

			if var_33_10 and not var_33_10:isEnd() then
				if var_33_7 == DROP_TYPE_RESOURCE then
					table.insert(var_33_3, 1, {
						DROP_TYPE_ITEM,
						id2ItemId(var_33_8)
					})
				else
					table.insert(var_33_3, 1, {
						var_33_7,
						var_33_8
					})
				end
			end
		end
	end

	local var_33_11 = UIItemList.New(self._spoilsContainer, self._item)

	var_33_11:make(function(arg_34_0, arg_34_1, arg_34_2)
		local var_34_0 = var_33_3[arg_34_1 + 1]
		local var_34_1 = {
			type = var_33_3[arg_34_1 + 1][1],
			id = var_33_3[arg_34_1 + 1][2]
		}

		updateDrop(arg_34_2, var_34_1)
		onButton(self, arg_34_2, function()
			local var_35_0 = Item.getConfigData(var_34_0[2])

			if var_35_0 and var_0_2[var_35_0.type] then
				self:emit(ChapterPreCombatMediator.GET_CHAPTER_DROP_SHIP_LIST, self.chapter.id, function(arg_36_0)
					local var_36_0 = {}

					for iter_36_0, iter_36_1 in ipairs(var_35_0.display_icon) do
						local var_36_1 = iter_36_1[2]

						var_36_0[#var_36_0 + 1] = {
							type = iter_36_1[1],
							id = iter_36_1[2],
							anonymous = iter_36_1[1] == DROP_TYPE_SHIP and not table.contains(arg_36_0, var_36_1)
						}
					end

					self:emit(ChapterPreCombatLayer.ON_DROP_LIST, {
						item2Row = true,
						itemList = var_36_0,
						content = var_35_0.display
					})
				end)
			else
				self:emit(ChapterPreCombatLayer.ON_DROP, var_34_1)
			end
		end, SFX_PANEL)
	end)
	var_33_11:align(math.min(#var_33_3, 6))

	local function var_33_12(arg_37_0, arg_37_1)
		if type(arg_37_0) == "table" then
			setActive(arg_37_1, true)
			setWidgetText(arg_37_1, (i18n(PreCombatLayer.ObjectiveList[arg_37_0[1]], arg_37_0[2])))
		else
			setActive(arg_37_1, false)
		end
	end

	local var_33_13 = {
		self._goals:Find("goal_tpl"),
		self._goals:Find("goal_sink"),
		self._goals:Find("goal_time")
	}
	local var_33_14 = 1

	for iter_33_1, iter_33_2 in ipairs({
		pg.expedition_data_template[arg_33_1].objective_1,
		pg.expedition_data_template[arg_33_1].objective_2,
		pg.expedition_data_template[arg_33_1].objective_3
	}) do
		if type(iter_33_2) ~= "string" then
			var_33_12(iter_33_2, var_33_13[var_33_14])

			var_33_14 = var_33_14 + 1
		end
	end

	for iter_33_3 = var_33_14, #var_33_13 do
		var_33_12("", var_33_13[iter_33_3])
	end
end

function ChapterPreCombatLayer:updateBattleFleetView()
	local function var_38_0(arg_39_0, arg_39_1)
		removeAllChildren(arg_39_0)

		for iter_39_0 = 1, 3 do
			if arg_39_1[iter_39_0] then
				local var_39_0 = cloneTplTo(self._ship_tpl, arg_39_0)

				updateShip(var_39_0, arg_39_1[iter_39_0])

				local var_39_1 = arg_39_1[iter_39_0].hpRant
				local var_39_2 = var_39_0:Find("blood")
				local var_39_3 = var_39_0:Find("blood/fillarea/green")
				local var_39_4 = var_39_0:Find("blood/fillarea/red")

				setActive(var_39_3, arg_39_1[iter_39_0].hpRant >= ChapterConst.HpGreen)
				setActive(var_39_4, var_39_1 < ChapterConst.HpGreen)

				;(var_39_1 >= ChapterConst.HpGreen and var_39_3 or var_39_4):GetComponent("Image").fillAmount = var_39_1 * 0.0001

				setActive(var_39_0:Find("broken"), var_39_1 == 0)
			end
		end
	end

	var_38_0(self._fleet:Find("main"), self.chapter.fleet:getShipsByTeam(TeamType.Main, true))
	var_38_0(self._fleet:Find("vanguard"), self.chapter.fleet:getShipsByTeam(TeamType.Vanguard, true))
end

function ChapterPreCombatLayer:displayFleetInfo()
	local var_40_0 = self.chapter.fleet
	local var_40_1 = self.chapter:getStageId(self.chapter.fleet.line.row, self.chapter.fleet.line.column)
	local var_40_2 = self.chapter.fleet:getCommanders()
	local var_40_3 = _.reduce(self.chapter.fleet:getShipsByTeam(TeamType.Vanguard, false), 0, function(arg_41_0, arg_41_1)
		return arg_41_0 + arg_41_1:getShipCombatPower(var_40_2)
	end)
	local var_40_4 = _.reduce(self.chapter.fleet:getShipsByTeam(TeamType.Main, false), 0, function(arg_42_0, arg_42_1)
		return arg_42_0 + arg_42_1:getShipCombatPower(var_40_2)
	end)
	local var_40_5 = 0

	for iter_40_0, iter_40_1 in ipairs({
		self.chapter:getFleetCost(self.chapter.fleet, var_40_1)
	}) do
		var_40_5 = var_40_5 + iter_40_1.oil
	end

	local var_40_6 = self.chapter:isOverFleetCost(var_40_0, var_40_1)

	setActive(self._popup, true)
	setActive(self._costTip, var_40_6)
	setTextColor(self._costText, var_40_6 and Color(0.9803921568627451, 0.39215686274509803, 0.39215686274509803) or Color.white)
	FormationUI.tweenNumText(self._costText, var_40_5)
	FormationUI.tweenNumText(self._vanguardGS, var_40_3)
	FormationUI.tweenNumText(self._mainGS, var_40_4)

	local var_40_7, var_40_8 = self.chapter:GetExtraCostRate()

	setActive(self._extraCostBuffIcon, #var_40_8 > 0)

	for iter_40_2, iter_40_3 in ipairs(var_40_8) do
		if iter_40_3.benefit_type == Chapter.OPERATION_BUFF_TYPE_COST then
			setText(self._extraCostBuffIcon:Find("text_cost"), tonumber(iter_40_3.benefit_effect) * 0.01 + 1)
		elseif iter_40_3.benefit_type == Chapter.OPERATION_BUFF_TYPE_EXP then
			setText(self._extraCostBuffIcon:Find("text_reward"), tonumber(iter_40_3.benefit_effect) * 0.01 + 1)
		elseif iter_40_3.benefit_type == Chapter.OPERATION_BUFF_TYPE_DESC then
			onButton(self, self._extraCostBuffIcon, function()
				local var_43_0 = ActivityBuff.GetBenefitCondition(iter_40_3.benefit_condition)

				assert(var_43_0[1] == "item")
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					hideNo = true,
					type = MSGBOX_TYPE_SINGLE_ITEM,
					drop = {
						count = 1,
						type = DROP_TYPE_ITEM,
						id = var_43_0[2]
					},
					intro = pg.strategy_data_template[iter_40_3.id].desc
				})
			end)
		end
	end

	local var_40_9 = self.rtAdapt:Find("middle/gear_score/vanguard")
	local var_40_10 = ChapterFleet.StaticTransformChapterFleet2Fleet(var_40_0):GetFleetSonarRange()

	setActive(var_40_9:Find("SonarActive"), var_40_10 > 0)
	setActive(var_40_9:Find("SonarInactive"), var_40_10 <= 0)

	if var_40_10 > 0 then
		setText(var_40_9:Find("SonarActive/Text"), math.floor(var_40_10))
	end
end

function ChapterPreCombatLayer:updateStrategyIcon()
	local var_44_0 = _.detect(self.chapter.fleet:getStrategies(), function(arg_45_0)
		return arg_45_0.id == ChapterConst.StrategyRepair
	end)

	GetImageSpriteFromAtlasAsync("strategyicon/" .. pg.strategy_data_template[var_44_0.id].icon, "", self._strategy:Find("icon"))
	onButton(self, self._strategy, function()
		self:displayStrategyInfo(var_44_0)
	end, SFX_PANEL)
	setText(self._strategy:Find("nums"), var_44_0.count)
	setActive(self._strategy:Find("mask"), var_44_0.count == 0)
	setActive(self._strategy:Find("selected"), false)

	local var_44_1 = self.rtAdapt:Find("middle/formation_list")
	local var_44_2 = var_44_1:Find("formation")

	setActive(var_44_2, false)

	local var_44_3 = ChapterConst.StrategyForms
	local var_44_4 = {}

	table.insert(var_44_4, 1, {
		id = self.chapter.fleet:getFormationStg()
	})

	local var_44_5 = UIItemList.New(var_44_1, var_44_2)

	var_44_5:make(function(arg_47_0, arg_47_1, arg_47_2)
		if arg_47_0 == UIItemList.EventUpdate then
			local var_47_0 = var_44_4[arg_47_1 + 1]
			local var_47_1 = pg.strategy_data_template[var_44_4[arg_47_1 + 1].id]

			if pg.strategy_data_template[var_44_4[arg_47_1 + 1].id].type ~= ChapterConst.StgTypeForm then
				return
			end

			GetImageSpriteFromAtlasAsync("strategyicon/" .. pg.strategy_data_template[var_44_4[arg_47_1 + 1].id].icon, "", arg_47_2:Find("icon"))
			onButton(self, arg_47_2, function()
				if var_47_1.type == ChapterConst.StgTypeForm then
					self:emit(ChapterPreCombatMediator.ON_OP, {
						type = ChapterConst.OpStrategy,
						id = self.chapter.fleet:getNextStgUser(var_47_0.id),
						arg1 = var_44_3[table.indexof(var_44_3, var_47_0.id) % #var_44_3 + 1]
					})
				end
			end, SFX_PANEL)
			setText(arg_47_2:Find("nums"), "")
			setActive(arg_47_2:Find("mask"), false)
			setActive(arg_47_2:Find("selected"), false)
		end
	end)
	var_44_5:align(#var_44_4)
end

function ChapterPreCombatLayer:displayStrategyInfo(arg_49_1)
	self.strategyPanel = self.strategyPanel or StrategyPanel.New(self.strategyInfo)

	self.strategyPanel:attach(self)
	self.strategyPanel:set(arg_49_1)
	pg.UIMgr.GetInstance():BlurPanel(self.strategyPanel._tf)

	function self.strategyPanel.onConfirm()
		local var_50_1

		if not self.chapter.fleet:canUseStrategy(arg_49_1) then
			do return end

			var_50_1 = {
				type = ChapterConst.OpStrategy
			}
		end

		var_50_1.id = self.chapter.fleet:getNextStgUser(arg_49_1.id)
		var_50_1.arg1 = arg_49_1.id

		self:emit(ChapterPreCombatMediator.ON_OP, var_50_1)
		self:hideStrategyInfo()
	end

	function self.strategyPanel.onCancel()
		self:hideStrategyInfo()
	end
end

function ChapterPreCombatLayer:hideStrategyInfo()
	if self.strategyPanel then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.strategyPanel._tf)
		self.strategyPanel:detach()
	end
end

function ChapterPreCombatLayer:onBackPressed()
	if self.strategyPanel and self.strategyPanel._go and isActive(self.strategyPanel._go) then
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
		self:hideStrategyInfo()
	else
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
		triggerButton(self._backBtn)
	end
end

function ChapterPreCombatLayer:willExit()
	if self.strategyPanel and self.strategyPanel._go and isActive(self.strategyPanel._go) then
		self:hideStrategyInfo()
	end

	self._formationLogic:Destroy()

	self._formationLogic = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return ChapterPreCombatLayer
