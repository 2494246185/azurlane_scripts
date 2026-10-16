local AnniversaryIslandComposite2023Scene = class("AnniversaryIslandComposite2023Scene", import("view.base.BaseUI"))

AnniversaryIslandComposite2023Scene.FilterAll = bit.bor(1, 2)

function AnniversaryIslandComposite2023Scene:Ctor()
	AnniversaryIslandComposite2023Scene.super.Ctor(self)

	self.loader = AutoLoader.New()
end

function AnniversaryIslandComposite2023Scene:getUIName()
	return "AnniversaryIslandComposite2023UI"
end

local var_0_1 = "ui/AnniversaryIslandComposite2023UI_atlas"
local var_0_2 = "ui/AtelierCommonUI_atlas"

function AnniversaryIslandComposite2023Scene:getResource()
	local var_3_0 = AnniversaryIslandComposite2023Scene.super.getResource(self)

	table.insert(var_3_0, var_0_1)
	table.insert(var_3_0, var_0_2)

	return var_3_0
end

function AnniversaryIslandComposite2023Scene:preload(arg_4_1)
	table.ParallelIpairsAsync({
		var_0_1,
		var_0_2
	}, function(arg_5_0, arg_5_1, arg_5_2)
		self.loader:LoadBundle(arg_5_1, arg_5_2)
	end, arg_4_1)
end

function AnniversaryIslandComposite2023Scene:init()
	self.layerFormulaList = self._tf:Find("Panel/FormulaList")
	self.layerFormulaDetail = self._tf:Find("Panel/FormulaDetail")
	self.top = self._tf:Find("Top")
	self.formulaRect = self.layerFormulaList:Find("ScrollView"):GetComponent("LScrollRect")

	setActive(self.layerFormulaList:Find("Item"), false)

	function self.formulaRect.onUpdateItem(arg_7_0, arg_7_1)
		self:UpdateFormulaListItem(arg_7_0 + 1, arg_7_1)
	end

	self.formulaFilterButtons = _.map({
		1,
		2
	}, function(arg_8_0)
		return self.layerFormulaList:Find("Tabs"):GetChild(arg_8_0 - 1)
	end)
	self.lastEnv = nil
	self.env = {}
	self.listeners = {}

	setText(self.layerFormulaList:Find("Empty"), i18n("workbench_tips5"))
	setText(self.layerFormulaList:Find("Tabs/Furniture/UnSelected/Text"), i18n("word_furniture"))
	setText(self.layerFormulaList:Find("Tabs/Furniture/Selected/Text"), i18n("word_furniture"))
	setText(self.layerFormulaList:Find("Tabs/Item/UnSelected/Text"), i18n("workbench_tips7"))
	setText(self.layerFormulaList:Find("Tabs/Item/Selected/Text"), i18n("workbench_tips7"))
	setText(self.layerFormulaList:Find("Filter/Text"), i18n("workbench_tips10"))
	setText(self.layerFormulaDetail:Find("Counters/Text"), i18n("workbench_tips8"))
	setText(self.layerFormulaDetail:Find("MaterialsBG/MaterialsTitle"), i18n("workbench_tips9"))
end

function AnniversaryIslandComposite2023Scene:didEnter()
	self.contextData.filterType = self.contextData.filterType or AnniversaryIslandComposite2023Scene.FilterAll

	table.Foreach(self.formulaFilterButtons, function(arg_10_0, arg_10_1)
		onButton(self, arg_10_1, function()
			local var_11_0 = bit.lshift(1, arg_10_0 - 1)

			self.contextData.filterType = self.contextData.filterType == AnniversaryIslandComposite2023Scene.FilterAll and var_11_0 or self.contextData.filterType == var_11_0 and AnniversaryIslandComposite2023Scene.FilterAll or var_11_0

			self:UpdateFilterButtons()
			self:FilterFormulas()
			self:UpdateView()
		end, SFX_PANEL)
	end)

	self.showOnlyComposite = PlayerPrefs.GetInt("workbench_show_composite_avaliable", 0) == 1

	triggerToggle(self.layerFormulaList:Find("Filter/Toggle"), self.showOnlyComposite)
	onToggle(self, self.layerFormulaList:Find("Filter/Toggle"), function(arg_12_0)
		self.showOnlyComposite = arg_12_0

		PlayerPrefs.SetInt("workbench_show_composite_avaliable", arg_12_0 and 1 or 0)
		PlayerPrefs.Save()
		self:FilterFormulas()
		self:UpdateView()
	end)
	onButton(self, self._tf:Find("BG"), function()
		self:onBackPressed()
	end)
	onButton(self, self._tf:Find("Top/Back"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Top/Home"), function()
		self:quickExitFunc()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Top/Help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("workbench_help")
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Top/Upgrade"), function()
		self:emit(AnniversaryIslandComposite2023Mediator.OPEN_UPGRADE_PANEL)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Top/StoreHouse"), function()
		self:emit(AnniversaryIslandComposite2023Mediator.OPEN_STOREHOUSE)
	end, SFX_PANEL)
	self:BindEnv({
		"filterFormulas",
		"formulas",
		"bagAct",
		"formulaId"
	}, function()
		self:UpdateFormulaList()
	end)
	self:BindEnv({
		"formulaId",
		"formulas",
		"bagAct"
	}, function(arg_20_0, arg_20_1)
		self:UpdateFormulaDetail(arg_20_0[1])
	end)
	self:BindEnv({
		"BuildingLv"
	}, function(arg_21_0)
		self.loader:GetSpriteQuiet("ui/AnniversaryIslandComposite2023UI_atlas", "title_" .. arg_21_0[1], self.top:Find("Title/Number"))
	end)
	self:BindEnv({
		"tip"
	}, function(arg_22_0)
		setActive(self._tf:Find("Top/Upgrade/Tip"), arg_22_0[1])
	end)

	self.env.formulaId = self.contextData.formulaId

	self:UpdateFilterButtons()
	self:BuildActivityEnv()
	self:UpdateView()
end

function AnniversaryIslandComposite2023Scene:InitCounter(arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	arg_23_2[2] = math.max(arg_23_2[1], arg_23_2[2])

	local var_23_0 = arg_23_1
	local var_23_1 = self.layerFormulaDetail:Find("Counters")

	assert(var_23_1)

	local function var_23_2()
		local var_24_0 = var_23_0

		if var_23_0 == 0 then
			var_24_0 = setColorStr(var_24_0, "#f9c461")
		end

		setText(var_23_1:Find("Number"), var_24_0)
		arg_23_3(var_23_0)
	end

	var_23_2()
	pressPersistTrigger(var_23_1:Find("Plus"), 0.5, function(arg_25_0)
		var_23_0 = var_23_0 + 1
		var_23_0 = math.clamp(var_23_0, arg_23_2[1], arg_23_2[2])

		if var_23_0 == var_23_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("workbench_tips3"))
			arg_25_0()

			return
		end

		var_23_2()
	end, nil, true, true, 0.1, SFX_PANEL)
	pressPersistTrigger(var_23_1:Find("Minus"), 0.5, function(arg_26_0)
		var_23_0 = var_23_0 - 1
		var_23_0 = math.clamp(var_23_0, arg_23_2[1], arg_23_2[2])

		if var_23_0 == var_23_0 then
			arg_26_0()

			return
		end

		var_23_2()
	end, nil, true, true, 0.1, SFX_PANEL)
	onButton(self, var_23_1:Find("Plus10"), function()
		var_23_0 = var_23_0 + 10
		var_23_0 = math.clamp(var_23_0, arg_23_2[1], arg_23_2[2])

		if var_23_0 == var_23_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("workbench_tips3"))

			return
		end

		var_23_2()
	end)
	onButton(self, var_23_1:Find("Minus10"), function()
		var_23_0 = var_23_0 - 10
		var_23_0 = math.clamp(var_23_0, arg_23_2[1], arg_23_2[2])

		var_23_2()
	end)
	onButton(self, self.layerFormulaDetail:Find("Composite"), function()
		existCall(arg_23_4, var_23_0)
	end, SFX_PANEL)
end

local var_0_3 = {
	[DROP_TYPE_FURNITURE] = "word_furniture",
	[DROP_TYPE_WORKBENCH_DROP] = "workbench_tips7"
}

function AnniversaryIslandComposite2023Scene:UpdateFormulaListItem(arg_30_1, arg_30_2)
	local var_30_0 = tf(arg_30_2)
	local var_30_1 = self.env.filterFormulas[arg_30_1]
	local var_30_2 = self.env.filterFormulas[arg_30_1]:GetProduction()
	local var_30_3 = var_30_0:Find("BG/Icon")

	assert(var_30_3)
	self:UpdateActivityDrop(var_30_3, {
		type = var_30_2[1],
		id = var_30_2[2]
	}, true)

	local var_30_4 = not var_30_1:IsUnlock()

	setActive(var_30_0:Find("Lock"), var_30_4)
	setActive(var_30_0:Find("BG"), not var_30_4)

	if var_30_4 then
		setText(var_30_0:Find("Lock/Text"), var_30_1:GetLockDesc())
	end

	setText(var_30_0:Find("BG/Type"), i18n(var_0_3[var_30_2[1]]))
	setScrollText(var_30_0:Find("BG/Name/Text"), var_30_1:GetName())
	setActive(var_30_0:Find("Selected"), var_30_1:GetConfigID() == self.env.formulaId)

	local var_30_5 = var_30_1:IsAvaliable()

	setActive(var_30_0:Find("Completed"), not var_30_5)

	local var_30_6

	if var_30_1:GetMaxLimit() > 0 then
		local var_30_7 = var_30_1:GetMaxLimit() - var_30_1:GetUsedCount()

		var_30_6 = (var_30_7 <= 0 and setColorStr(var_30_7, "#bb6754") or var_30_7) .. "/" .. var_30_1:GetMaxLimit()
	else
		var_30_6 = "∞"
	end

	setText(var_30_0:Find("BG/Count"), var_30_6)
	onButton(self, var_30_0, function()
		if not var_30_5 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("workbench_tips1"))

			return
		end

		if var_30_4 then
			local var_31_0 = var_30_1:GetLockLimit()

			pg.TipsMgr.GetInstance():ShowTips(i18n("workbench_tips4", var_31_0 and var_31_0[3]))

			return
		end

		self.env.formulaId = var_30_1:GetConfigID()

		self:UpdateView()
	end, SFX_PANEL)
end

function AnniversaryIslandComposite2023Scene:UpdateFilterButtons()
	table.Foreach(self.formulaFilterButtons, function(arg_33_0, arg_33_1)
		local var_33_0 = self.contextData.filterType ~= AnniversaryIslandComposite2023Scene.FilterAll and bit.band(self.contextData.filterType, bit.lshift(1, arg_33_0 - 1)) > 0

		setActive(arg_33_1:Find("Selected"), var_33_0)
		setActive(arg_33_1:Find("UnSelected"), not var_33_0)
	end)
end

function AnniversaryIslandComposite2023Scene:BuildActivityEnv()
	self.env.formulas = _.map(pg.activity_workbench_recipe.all, function(arg_35_0)
		local var_35_0 = WorkBenchFormula.New({
			configId = arg_35_0
		})

		var_35_0:BuildFromActivity()

		return var_35_0
	end)

	if self.env.formulaId then
		local var_34_0 = _.detect(self.env.formulas, function(arg_36_0)
			return arg_36_0:GetConfigID() == self.env.formulaId
		end)

		if not var_34_0 or not var_34_0:IsAvaliable() then
			self.env.formulaId = nil
		end
	end

	self.env.bagAct = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_VIRTUAL_BAG)

	local var_34_1 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2)

	self.env.BuildingLv = var_34_1:GetBuildingLevel(table.keyof(AnniversaryIsland2023Scene.Buildings, "craft"))
	self.env.tip = AnniversaryIsland2023Scene.UpdateBuildingTip(nil, var_34_1, table.keyof(AnniversaryIsland2023Scene.Buildings, "craft"))

	self:FilterFormulas()
end

function AnniversaryIslandComposite2023Scene:FilterFormulas()
	local var_37_0 = {}
	local var_37_1 = self.contextData.filterType

	local function var_37_2(arg_38_0)
		if var_37_1 == AnniversaryIslandComposite2023Scene.FilterAll then
			return true
		end

		return switch(arg_38_0:GetProduction()[1], {
			[DROP_TYPE_WORKBENCH_DROP] = function()
				return bit.band(var_37_1, 1) > 0
			end
		}, function()
			return bit.band(var_37_1, 2) > 0
		end)
	end

	for iter_37_0, iter_37_1 in ipairs(_.values(self.env.formulas)) do
		if var_37_2(iter_37_1) and (not self.showOnlyComposite or iter_37_1:IsUnlock() and iter_37_1:IsAvaliable() and _.all(iter_37_1:GetMaterials(), function(arg_41_0)
			return arg_41_0[3] <= self.env.bagAct:getVitemNumber(arg_41_0[2])
		end)) then
			table.insert(var_37_0, iter_37_1)
		end
	end

	table.sort(var_37_0, (CompareFuncs({
		function(arg_42_0)
			return arg_42_0:IsAvaliable() and 0 or 1
		end,
		function(arg_43_0)
			return arg_43_0:IsUnlock() and 0 or 1
		end,
		function(arg_44_0)
			return arg_44_0:GetConfigID()
		end
	})))

	self.env.filterFormulas = var_37_0
end

function AnniversaryIslandComposite2023Scene:UpdateFormulaList()
	local var_45_0 = #self.env.filterFormulas == 0

	setActive(self.layerFormulaList:Find("Empty"), #self.env.filterFormulas == 0)
	setActive(self.layerFormulaList:Find("ScrollView"), not var_45_0)
	self.formulaRect:SetTotalCount(#self.env.filterFormulas)
end

function AnniversaryIslandComposite2023Scene:UpdateFormulaDetail(arg_46_1)
	self.contextData.formulaId = arg_46_1

	setActive(self.layerFormulaDetail, arg_46_1)

	if not arg_46_1 then
		return
	end

	local var_46_0 = _.detect(self.env.formulas, function(arg_47_0)
		return arg_47_0:GetConfigID() == arg_46_1
	end)

	assert(var_46_0)

	local var_46_1 = var_46_0:GetProduction()
	local var_46_2 = var_46_0:GetMaterials()
	local var_46_3 = 100

	;(function()
		local var_48_0 = {
			type = var_46_1[1],
			id = var_46_1[2],
			count = var_46_1[3]
		}
		local var_48_1 = var_46_0:GetMaxLimit()

		if var_48_1 > 0 then
			var_46_3 = var_48_1 - getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_WORKBENCH):GetFormulaUseCount(arg_46_1)
		end

		local var_48_2 = self.layerFormulaDetail:Find("Icon")

		assert(var_48_2)
		self:UpdateActivityDrop(var_48_2, var_48_0)
		onButton(self, var_48_2, function()
			if var_48_0.type == DROP_TYPE_WORKBENCH_DROP then
				self:emit(WorkBenchItemDetailMediator.SHOW_DETAIL, WorkBenchItem.New({
					configId = var_48_0.id,
					count = var_48_0.count
				}))
			else
				self:emit(BaseUI.ON_DROP, var_48_0)
			end
		end)
		setText(self.layerFormulaDetail:Find("Name"), var_48_0:getConfig("name"))
	end)()

	local var_46_4 = 100
	local var_46_5 = self.env.bagAct

	UIItemList.StaticAlign(self.layerFormulaDetail:Find("Materials"), self.layerFormulaDetail:Find("Materials/Item"), #var_46_2, function(arg_50_0, arg_50_1, arg_50_2)
		if arg_50_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_50_0 = var_46_2[arg_50_1 + 1]
		local var_50_1 = {
			type = var_46_2[arg_50_1 + 1][1],
			id = var_46_2[arg_50_1 + 1][2],
			count = var_46_2[arg_50_1 + 1][3]
		}

		self:UpdateActivityDrop(arg_50_2:Find("Icon"), var_50_1)
		onButton(self, arg_50_2:Find("Icon"), function()
			if var_50_1.type == DROP_TYPE_WORKBENCH_DROP then
				self:emit(WorkBenchItemDetailMediator.SHOW_DETAIL, WorkBenchItem.New({
					configId = var_50_1.id,
					count = var_50_1.count
				}))
			else
				self:emit(BaseUI.ON_DROP, var_50_1)
			end
		end)

		if var_50_0[3] > 0 then
			var_46_4 = math.min(var_46_4, math.floor(var_46_5:getVitemNumber(var_50_0[2]) / var_50_0[3]))
		end
	end)

	local function var_46_6(arg_52_0)
		UIItemList.StaticAlign(self.layerFormulaDetail:Find("Materials"), self.layerFormulaDetail:Find("Materials/Item"), #var_46_2, function(arg_53_0, arg_53_1, arg_53_2)
			if arg_53_0 ~= UIItemList.EventUpdate then
				return
			end

			local var_53_0 = var_46_2[arg_53_1 + 1][3]
			local var_53_1 = var_46_5:getVitemNumber(var_46_2[arg_53_1 + 1][2])

			arg_52_0 = math.max(arg_52_0, 1)

			setText(arg_53_2:Find("Text"), setColorStr(var_53_1, var_53_1 < var_53_0 * arg_52_0 and "#bb6754" or "#6b5a48") .. "/" .. var_53_0 * arg_52_0)
		end)
	end

	local var_46_7 = math.min(1, 100)

	self:InitCounter(var_46_7, {
		0,
		100
	}, var_46_6, function(arg_54_0)
		self:emit(GAME.WORKBENCH_COMPOSITE, arg_46_1, arg_54_0)
	end)
	var_46_6(var_46_7)
end

function AnniversaryIslandComposite2023Scene:BindEnv(arg_55_1, arg_55_2)
	table.insert(self.listeners, {
		keys = arg_55_1,
		func = arg_55_2
	})
end

function AnniversaryIslandComposite2023Scene:RefreshData()
	self.lastEnv = self.lastEnv or {}

	local var_56_0 = {}
	local var_56_1

	local function var_56_2(arg_57_0, arg_57_1)
		if var_56_0[arg_57_0] then
			return
		end

		var_56_0[arg_57_0] = arg_57_1
		var_56_1 = var_56_1 or {}

		_.each(_.select(self.listeners, function(arg_58_0)
			return table.contains(arg_58_0.keys, arg_57_0)
		end), function(arg_59_0)
			var_56_1[arg_59_0] = true
		end)
	end

	for iter_56_0, iter_56_1 in pairs(self.env) do
		if iter_56_1 ~= self.lastEnv[iter_56_0] then
			var_56_2(iter_56_0, iter_56_1)
		end
	end

	for iter_56_2, iter_56_3 in pairs(self.lastEnv) do
		if iter_56_3 ~= self.env[iter_56_2] then
			var_56_2(iter_56_2, self.env[iter_56_2])
		end
	end

	if nil then
		table.Foreach(nil, function(arg_60_0)
			arg_60_0.func(table.map(arg_60_0.keys, function(arg_61_0)
				return self.env[arg_61_0]
			end), (table.map(arg_60_0.keys, function(arg_62_0)
				return self.lastEnv[arg_62_0]
			end)))
		end)
	end

	self.lastEnv = table.shallowCopy(self.env)
end

function AnniversaryIslandComposite2023Scene:UpdateView()
	self:RefreshData()
	AnniversaryIsland2023Scene.PlayStory()
end

function AnniversaryIslandComposite2023Scene:OnReceiveFormualRequest(arg_64_1)
	self.env.formulaId = arg_64_1

	self:UpdateView()
end

function AnniversaryIslandComposite2023Scene:UpdateActivityDrop(arg_65_1, arg_65_2, arg_65_3)
	updateDrop(arg_65_1, arg_65_2)
	SetCompomentEnabled(arg_65_1:Find("icon_bg"), typeof(Image), false)
	setActive(arg_65_1:Find("bg"), false)
	setActive(arg_65_1:Find("icon_bg/frame"), false)
	setActive(arg_65_1:Find("icon_bg/stars"), false)

	local var_65_0 = arg_65_2:getConfig("rarity")

	if arg_65_2.type == DROP_TYPE_EQUIP or arg_65_2.type == DROP_TYPE_EQUIPMENT_SKIN then
		var_65_0 = var_65_0 - 1
	end

	local var_65_1 = "icon_frame_" .. var_65_0

	if arg_65_3 then
		var_65_1 = var_65_1 .. "_small"
	end

	self.loader:GetSpriteQuiet(var_0_2, var_65_1, arg_65_1)
end

function AnniversaryIslandComposite2023Scene:willExit()
	self.loader:Clear()
end

return AnniversaryIslandComposite2023Scene
