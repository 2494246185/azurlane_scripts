local BossRushBattleResultLayer = class("BossRushBattleResultLayer", import("view.base.BaseUI"))

function BossRushBattleResultLayer:getUIName()
	return "BattleResultBossRushUI"
end

function BossRushBattleResultLayer:getGroupName()
	return "BattleScene"
end

function BossRushBattleResultLayer:Ctor(...)
	BossRushBattleResultLayer.super.Ctor(self, ...)

	self.loader = AutoLoader.New()
end

function BossRushBattleResultLayer:GetAtalsName()
	return "ui/battleresult_atlas"
end

function BossRushBattleResultLayer:getResource()
	local var_5_0 = BossRushBattleResultLayer.super.getResource(self)

	table.insert(var_5_0, self:GetAtalsName())

	return var_5_0
end

function BossRushBattleResultLayer:preload(arg_6_1)
	self.loader:LoadBundle(self:GetAtalsName())
	existCall(arg_6_1)
end

function BossRushBattleResultLayer:init()
	local var_7_0 = self._tf:Find("main/Series")

	self.resultScroll = var_7_0:Find("Scroll")
	self.resultList = var_7_0:Find("Scroll/List")
	self.playerExp = var_7_0:Find("playerExp")
	self.rightBottomPanel = var_7_0:Find("rightBottomPanel")

	setText(self.rightBottomPanel:Find("confirmBtn/Text"), i18n("text_confirm"))
	setText(self.resultList:Find("Result/BG/Ships/resulttpl/result/Statistics/kill_count_label"), i18n("battle_result_kill_count"))
	setText(self.resultList:Find("Result/BG/Ships/resulttpl/result/Statistics/dmg_count_label"), i18n("battle_result_dmg"))
	setText(self.resultList:Find("Result/BG/commanderExp/commander_container"):GetChild(0):Find("empty/add/Text"), i18n("series_enemy_empty_commander_main"))
	setText(self.resultList:Find("Result/BG/commanderExp/commander_container"):GetChild(1):Find("empty/add/Text"), i18n("series_enemy_empty_commander_assistant"))
end

local var_0_1 = {
	"sucess_title_bg",
	"fail_title_bg",
	"none_title_bg"
}
local var_0_2 = {
	"1216207f",
	"48160d7f",
	"3c3c3c7f"
}

function BossRushBattleResultLayer:didEnter()
	self:BlurPanel(self._tf, {
		staticBlur = true,
		lockGlobalBlur = true
	})

	local var_8_0 = self.contextData.seriesData:GetBattleStatistics()
	local var_8_1 = self.contextData.seriesData:GetFinalResults()
	local var_8_2 = self.contextData.seriesData:GetExpeditionIds()
	local var_8_3, var_8_4 = self.contextData.seriesData:GetModeFleetIDs(self.contextData.seriesData:GetMode())
	local var_8_5 = self.contextData.seriesData:GetFleets(var_8_3)
	local var_8_6 = self.contextData.seriesData:GetFleets(var_8_4)[1]
	local var_8_7 = var_8_6:getTeamByName(TeamType.Submarine)
	local var_8_8 = var_8_6:GetRawCommanderIds()
	local var_8_9 = {}
	local var_8_10 = {}

	for iter_8_0 = 1, #var_8_2 do
		local var_8_11 = var_8_5[iter_8_0] or var_8_5[1]
		local var_8_12 = var_8_1[iter_8_0]
		local var_8_13 = {
			index = iter_8_0,
			oldShips = {},
			ships = {},
			oldCmds = {},
			cmds = {}
		}

		if var_8_1[iter_8_0] then
			var_8_13.mvp = var_8_12.mvp or 0
		end

		local var_8_14 = Clone(var_8_13)

		table.Foreach(var_8_11:getShipIds(), function(arg_9_0, arg_9_1)
			if iter_8_0 <= #var_8_1 then
				if var_8_12.newShips[arg_9_1] then
					table.insert(var_8_13.ships, var_8_12.newShips[arg_9_1])

					var_8_13.oldShips[arg_9_1] = var_8_12.oldShips[arg_9_1]
				end
			else
				local var_9_0 = getProxy(BayProxy):getShipById(arg_9_1)

				table.insert(var_8_13.ships, var_9_0)

				var_8_13.oldShips[arg_9_1] = var_9_0
			end
		end)
		table.Foreach(var_8_7, function(arg_10_0, arg_10_1)
			if iter_8_0 <= #var_8_1 then
				if var_8_12.newShips[arg_10_1] then
					table.insert(var_8_14.ships, var_8_12.newShips[arg_10_1])

					var_8_14.oldShips[arg_10_1] = var_8_12.oldShips[arg_10_1]
				end
			end
		end)

		local var_8_15 = var_8_11:GetRawCommanderIds()

		_.each({
			1,
			2
		}, function(arg_11_0)
			local var_11_0 = var_8_15[arg_11_0] or false

			if var_11_0 then
				if iter_8_0 <= #var_8_1 then
					if var_8_12.newCmds[var_11_0] then
						table.insert(var_8_13.cmds, var_8_12.newCmds[var_11_0])

						var_8_13.oldCmds[var_11_0] = var_8_12.oldCmds[var_11_0]
					end
				else
					local var_11_1 = getProxy(CommanderProxy):getCommanderById(var_11_0)

					table.insert(var_8_13.cmds, var_11_1)

					var_8_13.oldCmds[var_11_0] = var_11_1
				end
			else
				table.insert(var_8_13.cmds, false)
			end
		end)
		_.each({
			1,
			2
		}, function(arg_12_0)
			local var_12_0 = var_8_8[arg_12_0] or false

			if iter_8_0 <= #var_8_1 then
				if var_12_0 then
					if var_8_12.newCmds[var_12_0] then
						table.insert(var_8_14.cmds, var_8_12.newCmds[var_12_0])

						var_8_14.oldCmds[var_8_12.newCmds[var_12_0].id] = var_8_12.oldCmds[var_12_0]
					else
						table.insert(var_8_14.cmds, false)
					end
				else
					table.insert(var_8_14.cmds, false)
				end
			end
		end)

		var_8_9[iter_8_0] = var_8_13

		if next(var_8_14.ships) then
			table.insert(var_8_10, var_8_14)
		end
	end

	local var_8_16 = 0
	local var_8_17 = 0

	local function var_8_18(arg_13_0, arg_13_1, arg_13_2)
		UIItemList.StaticAlign(arg_13_0, arg_13_0:GetChild(0), 2, function(arg_14_0, arg_14_1, arg_14_2)
			if arg_14_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_14_0 = arg_13_2[arg_14_1 + 1]

			setActive(arg_14_2:Find("empty"), not arg_13_2[arg_14_1 + 1])
			setActive(arg_14_2:Find("exp"), not not arg_13_2[arg_14_1 + 1])

			if not arg_13_2[arg_14_1 + 1] then
				return
			end

			local var_14_1 = arg_13_1[var_14_0.id]
			local var_14_2 = var_14_0.exp

			GetImageSpriteFromAtlasAsync("commandericon/" .. var_14_0:getPainting(), "", arg_14_2:Find("exp/icon"))
			setText(arg_14_2:Find("exp/name_text"), var_14_0:getName())
			setText(arg_14_2:Find("exp/lv_text"), "Lv." .. var_14_0.level)
			setText(arg_14_2:Find("exp/exp_text"), "+" .. math.max(0, var_14_1.expAdd or 0))

			arg_14_2:Find("exp/exp_progress"):GetComponent(typeof(Image)).fillAmount = var_14_0:isMaxLevel() and 1 or var_14_2 / var_14_0:getNextLevelExp()
		end)
	end

	local function var_8_19(arg_15_0, arg_15_1, arg_15_2)
		setActive(arg_15_0:Find("result/mvpBG"), arg_15_1 == arg_15_2)
	end

	local function var_8_20(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
		UIItemList.StaticAlign(arg_16_0, arg_16_0:GetChild(0), #arg_16_1, function(arg_17_0, arg_17_1, arg_17_2)
			if arg_17_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_17_0 = arg_16_1[arg_17_1 + 1]

			setActive(arg_17_2:Find("result/Exp"), true)
			setActive(arg_17_2:Find("result/Statistics"), false)
			var_8_19(arg_17_2, var_17_0.id, arg_16_3)
			setImageSprite(arg_17_2:Find("result/type"), GetSpriteFromAtlas("shiptype", shipType2print(arg_16_2[arg_16_1[arg_17_1 + 1].id]:getShipType())), true)
			setImageSprite(arg_17_2:Find("result/mask/icon"), LoadSprite("herohrzicon/" .. arg_16_2[arg_16_1[arg_17_1 + 1].id]:getPainting()))

			local var_17_1 = arg_16_2[arg_16_1[arg_17_1 + 1].id]:getStar()
			local var_17_2 = arg_16_2[arg_16_1[arg_17_1 + 1].id]:getMaxStar()

			UIItemList.StaticAlign(findTF(arg_17_2, "result/stars"), findTF(arg_17_2, "result/stars/star_tpl"), var_17_2, function(arg_18_0, arg_18_1, arg_18_2)
				if arg_18_0 ~= UIItemList.EventUpdate then
					return
				end

				local var_18_0 = var_17_2 - arg_18_1

				SetActive(arg_18_2:Find("empty"), var_17_2 - arg_18_1 > var_17_1)
				SetActive(arg_18_2:Find("star"), var_18_0 <= var_17_1)
			end)
			setText(arg_17_2:Find("result/Exp/Level"), "Lv." .. var_17_0.level)
			setText(arg_17_2:Find("result/Exp/name"), var_17_0:getName())

			local var_17_3 = arg_17_2:Find("result/Exp/exp_text")
			local var_17_4 = arg_16_2[arg_16_1[arg_17_1 + 1].id]:getConfig("rarity")

			if arg_16_2[arg_16_1[arg_17_1 + 1].id].level < var_17_0.level then
				local var_17_5 = 0

				for iter_17_0 = arg_16_2[arg_16_1[arg_17_1 + 1].id].level, var_17_0.level - 1 do
					var_17_5 = var_17_5 + getExpByRarityFromLv1(var_17_4, iter_17_0)
				end

				setText(var_17_3, "+" .. var_17_5 + var_17_0:getExp() - arg_16_2[arg_16_1[arg_17_1 + 1].id]:getExp())
			elseif arg_16_2[arg_16_1[arg_17_1 + 1].id].level == arg_16_2[arg_16_1[arg_17_1 + 1].id]:getMaxLevel() then
				setText(var_17_3, "+" .. 0)
			else
				setText(var_17_3, "+" .. ((not arg_16_2[arg_16_1[arg_17_1 + 1].id].expAdd or nil) and 0))
			end

			arg_17_2:Find("result/Progress/progress_bar"):GetComponent(typeof(Image)).fillAmount = var_17_0:getExp() / getExpByRarityFromLv1(var_17_4, var_17_0.level)
		end)
	end

	local function var_8_21(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4)
		arg_19_4 = arg_19_4 and arg_19_4.statistics

		local var_19_0 = 0

		if not arg_19_4 then
			var_19_0 = 10000
		elseif arg_19_3 == 0 then
			var_19_0 = 0

			for iter_19_0, iter_19_1 in pairs(arg_19_2) do
				var_19_0 = math.max(arg_19_4[iter_19_1.id].output, var_19_0)
			end
		elseif arg_19_3 > 0 then
			var_19_0 = arg_19_4[arg_19_3].output
		end

		UIItemList.StaticAlign(arg_19_0, arg_19_0:GetChild(0), #arg_19_1, function(arg_20_0, arg_20_1, arg_20_2)
			if arg_20_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_20_0 = arg_19_1[arg_20_1 + 1]
			local var_20_1 = arg_19_2[arg_19_1[arg_20_1 + 1].id]

			setActive(arg_20_2:Find("result/Statistics"), true)
			setActive(arg_20_2:Find("result/Exp"), false)
			var_8_19(arg_20_2, var_20_0.id, arg_19_3)
			setImageSprite(arg_20_2:Find("result/type"), GetSpriteFromAtlas("shiptype", shipType2print(var_20_1:getShipType())), true)
			setImageSprite(arg_20_2:Find("result/mask/icon"), LoadSprite("herohrzicon/" .. var_20_1:getPainting()))

			local var_20_2 = var_20_1:getStar()
			local var_20_3 = var_20_1:getMaxStar()

			UIItemList.StaticAlign(findTF(arg_20_2, "result/stars"), findTF(arg_20_2, "result/stars/star_tpl"), var_20_3, function(arg_21_0, arg_21_1, arg_21_2)
				if arg_21_0 ~= UIItemList.EventUpdate then
					return
				end

				local var_21_0 = var_20_3 - arg_21_1

				SetActive(arg_21_2:Find("empty"), var_20_3 - arg_21_1 > var_20_2)
				SetActive(arg_21_2:Find("star"), var_21_0 <= var_20_2)
			end)

			local var_20_4

			if arg_19_4 then
				var_20_4 = arg_19_4[var_20_1.id].output or 0

				local var_20_5

				if arg_19_4 then
					var_20_5 = arg_19_4[var_20_1.id].kill_count or 0
				end
			end

			local var_20_6 = arg_20_2:Find("result/Statistics/atk")

			setText(var_20_6, 0)
			setText(var_20_6, var_20_4)

			local var_20_7 = arg_20_2:Find("result/Statistics/killCount")

			setText(var_20_7, 0)
			setText(var_20_7, var_20_5)

			local var_20_8 = arg_20_2:Find("result/Progress/progress_bar")

			var_20_8:GetComponent(typeof(Image)).fillAmount = 0
			var_20_8:GetComponent(typeof(Image)).fillAmount = var_20_4 / var_19_0
		end)
	end

	local function var_8_22(arg_22_0, arg_22_1, arg_22_2, arg_22_3)
		arg_22_2 = arg_22_2 and arg_22_2.statistics

		local var_22_0 = arg_22_0:Find("Title/Label")
		local var_22_1 = arg_22_0:Find("Title/Letter")
		local var_22_3
		local var_22_4
		local var_22_5
		local var_22_6

		if arg_22_2 then
			var_22_5 = "letter_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1]
			var_22_3 = "battlescore/battle_score_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1] .. "/letter_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1]
			var_22_6 = "label_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1]
			var_22_4 = "battlescore/battle_score_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1] .. "/label_" .. ({
				"d",
				"c",
				"b",
				"a",
				"s"
			})[arg_22_2._battleScore + 1]

			if arg_22_2._scoreMark == ys.Battle.BattleConst.DEAD_FLAG then
				var_22_6 = "label_flag_destroy"
				var_22_4 = "battlescore/battle_score_c/label_flag_destroy"
			end
		else
			var_22_5 = ""
			var_22_6 = "label_none"
			var_22_4 = "battlescore/grade_label_none"
		end

		eachChild(var_22_0, function(arg_23_0)
			setActive(arg_23_0, arg_23_0.name == var_22_6)

			if arg_23_0.name == var_22_6 then
				self.loader:GetSprite(var_22_4, "", arg_23_0)
			end
		end)
		eachChild(var_22_1, function(arg_24_0)
			setActive(arg_24_0, arg_24_0.name == var_22_5)

			if arg_24_0.name == var_22_5 then
				self.loader:GetSprite(var_22_3, "", arg_24_0)
			end
		end)

		local var_22_8 = not arg_22_2 and 3 or arg_22_2._battleScore > ys.Battle.BattleConst.BattleScore.C and 1 or 2

		self.loader:GetSprite(self:GetAtalsName(), var_0_1[not arg_22_2 and 3 or arg_22_2._battleScore > ys.Battle.BattleConst.BattleScore.C and 1 or 2], arg_22_0:Find("Title"))
		setImageColor(arg_22_0:Find("BG"), SummerFeastScene.TransformColor(var_0_2[var_22_8]))
		setText(arg_22_0:Find("Title/Name"), pg.expedition_data_template[var_8_2[arg_22_3]].name)
		setText(arg_22_0:Find("BG/FleetName/Text"), i18n("series_enemy_fleet_prefix", GetRomanDigit(arg_22_1.index)))
		var_8_18(arg_22_0:Find("BG/commanderExp/commander_container"), arg_22_1.oldCmds, arg_22_1.cmds)
	end

	local function var_8_23()
		local var_25_0

		if var_8_17 == 1 then
			var_25_0 = var_8_10 or var_8_9
		end

		UIItemList.StaticAlign(self.resultList, self.resultList:GetChild(0), #var_25_0, function(arg_26_0, arg_26_1, arg_26_2)
			if arg_26_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_26_0 = var_25_0[arg_26_1 + 1]

			var_8_22(arg_26_2, var_25_0[arg_26_1 + 1], var_8_0[var_25_0[arg_26_1 + 1].index], var_25_0[arg_26_1 + 1].index)
			warning("yzh----RefreshExps--")
			var_8_20(arg_26_2:Find("BG/Ships"), var_26_0.ships, var_26_0.oldShips, var_26_0.mvp)
		end)
	end

	local function var_8_24()
		local var_27_0

		if var_8_17 == 1 then
			var_27_0 = var_8_10 or var_8_9
		end

		UIItemList.StaticAlign(self.resultList, self.resultList:GetChild(0), #var_27_0, function(arg_28_0, arg_28_1, arg_28_2)
			if arg_28_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_28_0 = var_27_0[arg_28_1 + 1]

			var_8_22(arg_28_2, var_27_0[arg_28_1 + 1], var_8_0[var_27_0[arg_28_1 + 1].index], var_27_0[arg_28_1 + 1].index)
			var_8_21(arg_28_2:Find("BG/Ships"), var_28_0.ships, var_28_0.oldShips, var_28_0.mvp, var_8_0[var_27_0[arg_28_1 + 1].index])
		end)
	end

	local var_8_25 = self.rightBottomPanel:Find("submarine")
	local var_8_26 = self.rightBottomPanel:Find("main")

	setActive(var_8_25, #var_8_10 > 0)

	local function var_8_27()
		setActive(var_8_26, var_8_17 == 1)
		setActive(var_8_25, var_8_17 == 0 and #var_8_10 > 0)

		if var_8_16 == 0 then
			var_8_23()
		elseif var_8_16 == 1 then
			var_8_24()
		end
	end

	var_8_27()
	;(function()
		local var_30_0 = getProxy(PlayerProxy):getRawData()

		setText(self._tf:Find("main/Series/playerExp/name_text"), var_30_0.name)
		setText(self._tf:Find("main/Series/playerExp/lv_text"), "Lv." .. var_30_0.level)
		setText(self._tf:Find("main/Series/playerExp/exp_text"), "+" .. _.reduce(var_8_1, 0, function(arg_31_0, arg_31_1)
			return arg_31_0 + arg_31_1.playerExp.addExp
		end))

		self._tf:Find("main/Series/playerExp/exp_progress"):GetComponent(typeof(Image)).fillAmount = var_30_0.exp / getConfigFromLevel1(pg.user_level, var_30_0.level).exp_interval
	end)()
	onButton(self, self.rightBottomPanel:Find("statisticsBtn"), function()
		var_8_16 = 1 - var_8_16

		var_8_27()
	end, SFX_PANEL)
	onButton(self, var_8_25, function()
		var_8_17 = 1

		var_8_27()
	end, SFX_PANEL)
	onButton(self, var_8_26, function()
		var_8_17 = 0

		var_8_27()
	end, SFX_PANEL)
	onButton(self, self.rightBottomPanel:Find("confirmBtn"), function()
		self:emit(BossRushBattleResultMediator.ON_SETTLE)
	end, SFX_PANEL)

	local var_8_28 = self._tf:Find("main/Series/ArrowLeft")
	local var_8_29 = self._tf:Find("main/Series/ArrowRight")

	Canvas.ForceUpdateCanvases()

	if self.resultScroll.rect.width >= self.resultList.rect.width then
		setActive(var_8_28, false)
		setActive(var_8_29, false)
	else
		setActive(var_8_28, false)
		setActive(var_8_29, true)
		onScroll(self, self.resultScroll, function(arg_36_0)
			setActive(var_8_28, arg_36_0.x > 0.01)
			setActive(var_8_29, arg_36_0.x < 0.99)
		end)
	end
end

function BossRushBattleResultLayer:HideConfirmPanel()
	setActive(self.rightBottomPanel:Find("confirmBtn"), false)
end

function BossRushBattleResultLayer:onBackPressed()
	triggerButton(self.rightBottomPanel:Find("confirmBtn"))
end

function BossRushBattleResultLayer:willExit()
	self:UnOverlayPanel(self._tf)
	self.loader:Clear()

	if self.contextData.OnClose then
		self.contextData.OnClose()
	end
end

return BossRushBattleResultLayer
