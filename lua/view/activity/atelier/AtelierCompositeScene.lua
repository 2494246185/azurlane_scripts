local AtelierCompositeScene = class("AtelierCompositeScene", import("view.base.BaseUI"))

function AtelierCompositeScene:getUIName()
	return "AtelierCompositeUI"
end

local AtelierFormula = import("model.vo.AtelierFormula")
local AtelierFormulaCircle = import("model.vo.AtelierFormulaCircle")
local PoolPlural = import("Mgr.Pool.PoolPlural")

AtelierCompositeScene.FilterAll = bit.bor(1, 2, 4)

function AtelierCompositeScene:Ctor(...)
	AtelierCompositeScene.super.Ctor(self, ...)

	self.loader = AutoLoader.New()
end

function AtelierCompositeScene:init()
	self.layerEmpty = self._tf:Find("Empty")
	self.layerFormula = self._tf:Find("FormulaList")
	self.painting = self._tf:Find("Painting")
	self.chat = self.painting:Find("Chat")
	self.layerFormulaDetail = self._tf:Find("FormulaDetail")
	self.layerFormulaOverlay = self.layerFormulaDetail:Find("Overlay")
	self.layerMaterialSelect = self.layerFormulaOverlay:Find("AvaliableMaterials")
	self.layerCompositeConfirm = self._tf:Find("CompositeConfirmWindow")
	self.layerCompositeResult = self._tf:Find("CompositeResultWindow")
	self.layerStoreHouse = self._tf:Find("StoreHouseWindow")
	self.layerMaterialsPreview = self._tf:Find("FormulaMaterialsPreview")
	self.top = self._tf:Find("Top")
	self.formulaRect = self.layerFormula:Find("Frame/ScrollView"):GetComponent("LScrollRect")

	setActive(self.layerFormula:Find("Frame/Item"), false)

	function self.formulaRect.onUpdateItem(arg_4_0, arg_4_1)
		self:UpdateFormulaItem(arg_4_0 + 1, arg_4_1)
	end

	self.formulaFilterButtons = _.map({
		1,
		2,
		3
	}, function(arg_5_0)
		return self.layerFormula:Find("Frame/Tabs"):GetChild(arg_5_0 - 1)
	end)
	self.candicatesRect = self.layerMaterialSelect:Find("Frame/List"):GetComponent("LScrollRect")

	local var_3_0 = self.layerMaterialSelect:Find("Frame/Item")

	setActive(var_3_0, false)

	function self.candicatesRect.onUpdateItem(arg_6_0, arg_6_1)
		self:UpdateCandicateItem(arg_6_0 + 1, arg_6_1)
	end

	self.storehouseRect = self.layerStoreHouse:Find("Window/ScrollView"):GetComponent("LScrollRect")

	setActive(self.layerStoreHouse:Find("Window/ScrollView/Item"), false)
	setActive(self.layerFormula, false)
	setActive(self.layerFormulaDetail, false)
	setActive(self.layerMaterialSelect, false)
	setActive(self.layerEmpty, false)
	setActive(self.layerStoreHouse, false)
	setActive(self.chat, false)
	pg.ViewUtils.SetSortingOrder(self._tf:Find("Mask/BG"):GetChild(0), -1)
	setText(self._tf:Find("Empty/Bar/Text"), i18n("ryza_tip_composite_unlock"))
	setText(self.layerFormula:Find("Frame/Filter/Text"), i18n("ryza_toggle_only_composite"))
	setText(self.layerFormula:Find("Frame/Empty"), i18n("ryza_tip_no_recipe"))
	setText(self.layerFormula:Find("Frame/Item/Lock/Text"), i18n("ryza_tip_unlock_all_tools"))
	setText(self.layerFormula:Find("Bar/Text"), i18n("ryza_tip_select_recipe"))
	setText(self.layerStoreHouse:Find("Window/Empty"), i18n("ryza_tip_no_item"))
	setText(self.layerCompositeResult:Find("Window/CountBG/Tip"), i18n("ryza_composite_count"))
	setText(self.layerMaterialsPreview:Find("Frame/Text"), i18n("ryza_tip_item_access"))
	setText(var_3_0:Find("IconBG/Lack/Text"), i18n("ryza_ui_show_acess"))
end

function AtelierCompositeScene:SetEnabled(arg_7_1)
	self.unlockSystem = arg_7_1
end

function AtelierCompositeScene:SetActivity(arg_8_1)
	self.activity = arg_8_1
end

local var_0_4 = "ui/AtelierCompositeUI_atlas"
local var_0_5 = "ui/AtelierCommonUI_atlas"

function AtelierCompositeScene:preload(arg_9_1)
	table.ParallelIpairsAsync({
		var_0_4,
		var_0_5
	}, function(arg_10_0, arg_10_1, arg_10_2)
		self.loader:LoadBundle(arg_10_1, arg_10_2)
	end, arg_9_1)
end

function AtelierCompositeScene:getResource()
	local var_11_0 = AtelierCompositeScene.super.getResource(self)

	for iter_11_0, iter_11_1 in ipairs({
		var_0_4,
		var_0_5,
		"ui/laisha_ui_huo_o",
		"ui/laisha_ui_huo_6",
		"ui/laisha_ui_bing_o",
		"ui/laisha_ui_bing_6",
		"ui/laisha_ui_lei_o",
		"ui/laisha_ui_lei_6",
		"ui/laisha_ui_feng_o",
		"ui/laisha_ui_feng_6",
		"ui/laisha_ui_sairen_o",
		"ui/laisha_ui_sairen_6",
		"ui/laisha_ui_wupinshanguang",
		"ui/laisha_ui_jiesuo",
		"ui/laisha_ui_lianjie01",
		"ui/laisha_ui_lianjie02",
		"ui/laisha_ui_lianjie_qiehuan",
		"ui/laisha_ui_wupinzhiru",
		"ui/laisha_ui_baoshi"
	}) do
		if noEmptyStr(iter_11_1) and not table.contains(var_11_0, iter_11_1) then
			table.insert(var_11_0, iter_11_1)
		end
	end

	return var_11_0
end

function AtelierCompositeScene:didEnter()
	self.contextData.filterType = AtelierCompositeScene.FilterAll

	table.Foreach(self.formulaFilterButtons, function(arg_13_0, arg_13_1)
		onButton(self, arg_13_1, function()
			if self.contextData.filterType == AtelierCompositeScene.FilterAll then
				self.contextData.filterType = bit.lshift(1, arg_13_0 - 1)
			else
				self.contextData.filterType = bit.bxor(self.contextData.filterType, bit.lshift(1, arg_13_0 - 1))

				if self.contextData.filterType == 0 then
					self.contextData.filterType = AtelierCompositeScene.FilterAll
				end
			end

			self:UpdateFilterButtons()
			self:FilterFormulas()
			self:UpdateFormulaList()
		end, SFX_PANEL)
	end)
	onToggle(self, self.layerFormula:Find("Frame/Filter/Toggle"), function(arg_15_0)
		self.showOnlyComposite = arg_15_0

		self:FilterFormulas()
		self:UpdateFormulaList()
	end)
	onButton(self, self.layerFormulaOverlay:Find("Description/List"), function()
		self:HideFormulaDetail()

		self.contextData.formulaId = nil

		self:ShowFormulaList()
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
			helps = i18n("ryza_composite_help_tip")
		})
	end, SFX_PANEL)
	onButton(self, self.layerMaterialSelect:Find("BG"), function()
		self:CloseCandicatePanel()
	end, SFX_CANCEL)
	onButton(self, self.layerCompositeConfirm:Find("BG"), function()
		self:HideCompositeConfirmWindow()
	end, SFX_CANCEL)
	onButton(self, self.layerCompositeConfirm:Find("Window/Cancel"), function()
		self:HideCompositeConfirmWindow()
	end, SFX_CANCEL)
	onButton(self, self.layerCompositeResult:Find("BG"), function()
		self:HideCompositeResult()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Top/StoreHouse"), function()
		self.contextData.showStoreHouse = true

		self:ShowStoreHouseWindow()
	end, SFX_PANEL)
	onButton(self, self.layerStoreHouse:Find("Window/Close"), function()
		self:CloseStoreHouseWindow()
	end, SFX_CANCEL)
	onButton(self, self.layerStoreHouse:Find("BG"), function()
		self:CloseStoreHouseWindow()
	end, SFX_CANCEL)
	onButton(self, self.layerMaterialsPreview:Find("BG"), function()
		self:HideMaterialsPreview()
	end, SFX_CANCEL)
	pg.UIMgr.GetInstance():OverlayPanel(self.top)

	if not self.unlockSystem then
		setActive(self.layerEmpty, true)
		setActive(self.painting, false)
	else
		if self.contextData.formulaId then
			self:ShowFormulaDetail(self.activity:GetFormulas()[self.contextData.formulaId])
		else
			self:DispalyChat({
				"ryza_atellier1"
			})
			self:ShowFormulaList()
		end

		if self.contextData.showStoreHouse then
			self:ShowStoreHouseWindow()
		end
	end

	if self.unlockSystem then
		if PlayerPrefs.GetInt("first_enter_ryza_atelier_" .. getProxy(PlayerProxy):getRawData().id, 0) == 0 then
			triggerButton(self._tf:Find("Top/Help"))
			PlayerPrefs.SetInt("first_enter_ryza_atelier_" .. getProxy(PlayerProxy):getRawData().id, 1)
		end
	end
end

function AtelierCompositeScene:onBackPressed()
	if self.animating then
		return true
	end

	if self:CloseStoreHouseWindow() then
		return true
	end

	if self:HideMaterialsPreview() then
		return true
	end

	if self:HideCompositeResult() then
		return true
	end

	if self:HideCompositeConfirmWindow() then
		return true
	end

	if self:HideCandicatePanel() then
		return true
	end

	if self:HideFormulaDetail() then
		self.contextData.formulaId = nil

		self:ShowFormulaList()

		return true
	end

	self:emit(AtelierCompositeScene.ON_BACK_PRESSED)
end

function AtelierCompositeScene:UpdateFilterButtons()
	table.Foreach(self.formulaFilterButtons, function(arg_30_0, arg_30_1)
		setActive(arg_30_1:Find("Selected"), self.contextData.filterType ~= AtelierCompositeScene.FilterAll and bit.band(self.contextData.filterType, bit.lshift(1, arg_30_0 - 1)) > 0)
	end)
end

function AtelierCompositeScene:AddIdleTimer()
	self:RemoveIdleTimer()

	self.idleTimer = Timer.New(function()
		self:DispalyChat({
			"ryza_atellier1"
		})
		self:AddIdleTimer()
	end, 8 + math.random() * 4)

	self.idleTimer:Start()
end

function AtelierCompositeScene:RemoveIdleTimer()
	if not self.idleTimer then
		return
	end

	self.idleTimer:Stop()

	self.idleTimer = nil
end

function AtelierCompositeScene:ShowFormulaList()
	self:AddIdleTimer()
	setActive(self.layerFormula, true)
	setParent(self.layerFormula, self.top)
	self.layerFormula:SetSiblingIndex(0)
	self:UpdateFilterButtons()
	self:FilterFormulas()
	self:UpdateFormulaList()
end

function AtelierCompositeScene:HideFormulaList()
	if not self.layerFormula then
		return
	end

	self:RemoveIdleTimer()
	setParent(self.layerFormula, self._tf)
	setActive(self.layerFormula, false)

	return true
end

function AtelierCompositeScene:FilterFormulas()
	self.filterFormulas = {}

	local var_36_0 = self.contextData.filterType

	local function var_36_1(arg_37_0)
		if var_36_0 == AtelierCompositeScene.FilterAll then
			return true
		end

		return switch(arg_37_0:GetType(), {
			[AtelierFormula.TYPE.EQUIP] = function()
				return bit.band(var_36_0, 1) > 0
			end,
			[AtelierFormula.TYPE.ITEM] = function()
				return bit.band(var_36_0, 2) > 0
			end,
			[AtelierFormula.TYPE.TOOL] = function()
				return bit.band(var_36_0, 4) > 0
			end,
			[AtelierFormula.TYPE.OTHER] = function()
				return bit.band(var_36_0, 4) > 0
			end
		})
	end

	for iter_36_0, iter_36_1 in ipairs(_.values(self.activity:GetFormulas())) do
		if var_36_1(iter_36_1) and (not self.showOnlyComposite or iter_36_1:IsAvaliable() and AtelierFormula.IsFormualCanComposite(iter_36_1, self.activity)) then
			table.insert(self.filterFormulas, iter_36_1)
		end
	end

	table.sort(self.filterFormulas, function(arg_42_0, arg_42_1)
		for iter_42_0, iter_42_1 in ipairs({
			function(arg_43_0)
				return arg_43_0:IsAvaliable() and 0 or 1
			end,
			function(arg_44_0)
				if arg_44_0:GetType() ~= AtelierFormula.TYPE.TOOL and not self.activity:IsCompleteAllTools() then
					return 1
				else
					return 0
				end
			end,
			function(arg_45_0)
				return arg_45_0:GetConfigID()
			end
		}) do
			local var_42_0 = iter_42_1(arg_42_0)
			local var_42_1 = iter_42_1(arg_42_1)

			if var_42_0 ~= var_42_1 then
				return var_42_0 < var_42_1
			end
		end

		return false
	end)
end

function AtelierCompositeScene:UpdateFormulaList()
	local var_46_0 = #self.filterFormulas == 0

	setActive(self.layerFormula:Find("Frame/Empty"), #self.filterFormulas == 0)
	setActive(self.layerFormula:Find("Frame/ScrollView"), not var_46_0)
	self.formulaRect:SetTotalCount(#self.filterFormulas)
end

local var_0_6 = {
	[AtelierFormula.TYPE.EQUIP] = "ryza_word_equip",
	[AtelierFormula.TYPE.ITEM] = "word_item",
	[AtelierFormula.TYPE.TOOL] = "word_tool",
	[AtelierFormula.TYPE.OTHER] = "word_other"
}

function AtelierCompositeScene:UpdateFormulaItem(arg_47_1, arg_47_2)
	local var_47_0 = tf(arg_47_2)
	local var_47_1 = self.filterFormulas[arg_47_1]
	local var_47_2 = self.filterFormulas[arg_47_1]:GetProduction()

	self:UpdateRyzaDrop(var_47_0:Find("BG/Icon"), {
		type = var_47_2[1],
		id = var_47_2[2]
	}, true)

	local var_47_3 = var_0_6[var_47_1:GetType()]
	local var_47_4 = var_47_1:GetType() ~= AtelierFormula.TYPE.TOOL and not self.activity:IsCompleteAllTools()

	setActive(var_47_0:Find("Lock"), var_47_4)
	setActive(var_47_0:Find("BG"), not var_47_4)
	setText(var_47_0:Find("BG/Type"), i18n(var_47_3))
	setScrollText(var_47_0:Find("BG/Name/Text"), var_47_1:GetName())

	local var_47_5 = var_47_1:GetMaxLimit() > 0 and var_47_1:GetMaxLimit() - var_47_1:GetUsedCount() .. "/" .. var_47_1:GetMaxLimit() or "∞"
	local var_47_6 = var_47_1:IsAvaliable()

	setActive(var_47_0:Find("BG/Count"), var_47_6)
	setActive(var_47_0:Find("Completed"), not var_47_6)

	if var_47_6 then
		setTextColor(var_47_0:Find("BG/Count"), (SummerFeastScene.TransformColor(AtelierFormula.IsFormualCanComposite(var_47_1, self.activity) and "4fb3a3" or "d55a54")))
	end

	setText(var_47_0:Find("BG/Count"), var_47_5)
	onButton(self, var_47_0, function()
		if not var_47_6 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_tip_composite_invalid"))

			return
		end

		if var_47_4 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_tip_unlock_all_tools"))

			return
		end

		self:HideFormulaList()
		self:ShowFormulaDetail(var_47_1)
		self:DispalyChat({
			"ryza_atellier2",
			"ryza_atellier3",
			"ryza_atellier4"
		})
		pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_1")
	end, SFX_PANEL)
end

function AtelierCompositeScene:UpdateRyzaDrop(arg_49_1, arg_49_2, arg_49_3)
	updateDrop(arg_49_1, arg_49_2)
	SetCompomentEnabled(arg_49_1:Find("icon_bg"), typeof(Image), false)
	setActive(arg_49_1:Find("bg"), false)
	setActive(arg_49_1:Find("icon_bg/frame"), false)
	setActive(arg_49_1:Find("icon_bg/stars"), false)

	local var_49_0 = arg_49_2:getConfig("rarity")

	if arg_49_2.type == DROP_TYPE_EQUIP or arg_49_2.type == DROP_TYPE_EQUIPMENT_SKIN then
		var_49_0 = var_49_0 - 1
	end

	local var_49_1 = "icon_frame_" .. var_49_0

	if arg_49_3 then
		var_49_1 = var_49_1 .. "_small"
	end

	self.loader:GetSpriteQuiet(var_0_5, var_49_1, arg_49_1)

	if arg_49_2.type == DROP_TYPE_EQUIP or arg_49_2.type == DROP_TYPE_SPWEAPON then
		onButton(self, arg_49_1, function()
			self:emit(AtelierCompositeScene.ON_DROP, arg_49_2)
		end, SFX_PANEL)
	else
		removeOnButton(arg_49_1)
	end
end

local var_0_7 = {
	[AtelierFormulaCircle.TYPE.BASE] = "circle",
	[AtelierFormulaCircle.TYPE.NORMAL] = "hexagon",
	[AtelierFormulaCircle.TYPE.SAIREN] = "doubleHexagon",
	[AtelierFormulaCircle.TYPE.ANY] = "anyHexagon"
}

function AtelierCompositeScene:ShowFormulaDetail(arg_51_1)
	setActive(self.layerFormulaDetail, true)
	setParent(self.layerFormulaOverlay, self.top)
	self.layerFormulaOverlay:SetSiblingIndex(0)
	setParent(self.painting, self.layerFormulaOverlay)
	self.painting:SetSiblingIndex(0)

	if not self.nodePools then
		self.nodePools = {
			circle = PoolPlural.New(self.layerFormulaDetail:Find("CircleNode").gameObject, 100),
			hexagon = PoolPlural.New(self.layerFormulaDetail:Find("HexagonNode").gameObject, 100),
			anyHexagon = PoolPlural.New(self.layerFormulaDetail:Find("AnyHexagonNode").gameObject, 100),
			doubleHexagon = PoolPlural.New(self.layerFormulaDetail:Find("DoubleHexagonNode").gameObject, 100)
		}

		table.Foreach(self.nodePools, function(arg_52_0, arg_52_1)
			setActive(arg_52_1.prefab, false)
		end)
	end

	self.pluralRoot = self.pluralRoot or pg.PoolMgr.GetInstance().root
	self.nodeList = self.nodeList or {}

	_.each(self.nodeList, function(arg_53_0)
		local var_53_0 = tf(arg_53_0.GO)

		SetCompomentEnabled(var_53_0:Find("Item"), typeof(Image), false)
		self.loader:ClearRequest(var_53_0:Find("Ring"))
		table.Foreach(arg_53_0.links, function(arg_54_0)
			self.loader:ClearRequest((var_53_0:Find("Links/" .. arg_54_0)))
		end)
		self.loader:ClearRequest(var_53_0)

		if not self.nodePools[var_0_7[arg_53_0.Data:GetType()]]:Enqueue(go(arg_53_0.GO)) then
			setParent(go(arg_53_0.GO), self.pluralRoot)
			setActive(go(arg_53_0.GO), false)
		end
	end)
	table.clean(self.nodeList)
	self:InitFormula(arg_51_1)
end

function AtelierCompositeScene:HideFormulaDetail()
	if not isActive(self.layerFormulaDetail) then
		return
	end

	self:HideCandicatePanel()
	setParent(self.painting, self._tf)
	self.painting:SetSiblingIndex(1)
	setParent(self.layerFormulaOverlay, self.layerFormulaDetail)
	setActive(self.layerFormulaDetail, false)

	return true
end

local var_0_8 = {
	{
		0,
		1
	},
	{
		-1,
		1
	},
	{
		-1,
		0
	},
	{
		0,
		-1
	},
	{
		1,
		-1
	},
	{
		1,
		0
	}
}
local var_0_9 = {
	[AtelierFormula.TYPE.EQUIP] = "text_equip",
	[AtelierFormula.TYPE.ITEM] = "text_item",
	[AtelierFormula.TYPE.TOOL] = "text_other",
	[AtelierFormula.TYPE.OTHER] = "text_other"
}

function AtelierCompositeScene:InitFormula(arg_56_1)
	self.contextData.formulaId = arg_56_1:GetConfigID()

	local var_56_0 = self.layerFormulaOverlay:Find("Description")

	self.loader:GetSpriteQuiet(var_0_4, var_0_9[arg_56_1:GetType()], var_56_0:Find("Type"))
	self:UpdateRyzaDrop(var_56_0:Find("Icon"), {
		type = arg_56_1:GetProduction()[1],
		id = arg_56_1:GetProduction()[2]
	})
	setText(var_56_0:Find("Name"), arg_56_1:GetName())
	setText(var_56_0:Find("Description/Text"), arg_56_1:GetDesc())

	local var_56_1 = tostring(arg_56_1:GetMaxLimit() - arg_56_1:GetUsedCount())

	setText(var_56_0:Find("RestCount/Text"), i18n("ryza_rest_produce_count", (arg_56_1:GetMaxLimit() < 0 or nil) and "∞"))
	setActive(self.layerMaterialSelect, false)

	local var_56_2 = self.layerFormulaDetail:Find("ScrollView/Content")

	setAnchoredPosition(var_56_2, Vector2.zero)
	_.each(arg_56_1:GetCircleList(), function(arg_57_0)
		local var_57_0 = AtelierFormulaCircle.New({
			configId = arg_57_0
		})
		local var_57_1 = self.nodePools[var_0_7[var_57_0:GetType()]]:Dequeue()

		var_57_1.name = arg_57_0

		setActive(var_57_1, true)
		setParent(tf(var_57_1), var_56_2)
		table.insert(self.nodeList, {
			Change = true,
			Data = var_57_0,
			GO = var_57_1
		})
	end)

	local var_56_3 = 280 * Vector2.New(math.cos(math.deg2Rad * 30), math.sin(math.deg2Rad * 30))
	local var_56_4 = 280 * Vector2(0, 1)
	local var_56_5 = Vector2.zero

	local function var_56_6(arg_58_0, arg_58_1)
		setAnchoredPosition(arg_58_0.GO, arg_58_1)

		arg_58_0.links = {}

		_.each(arg_58_0.Data:GetNeighbors(), function(arg_59_0)
			local var_59_0 = arg_59_0[2]
			local var_59_1 = var_0_8[arg_59_0[1]][1] * var_56_3 + var_0_8[arg_59_0[1]][2] * var_56_4
			local var_59_2 = _.detect(self.nodeList, function(arg_60_0)
				return arg_60_0.Data:GetConfigID() == var_59_0
			end)

			var_59_2.prevLink = {
				(arg_59_0[1] + 2) % 5 + 1,
				arg_58_0
			}
			arg_58_0.links[arg_59_0[1]] = var_59_2

			var_56_6(var_59_2, arg_58_1 + var_59_1)

			var_56_5 = Vector2.Max(var_56_5, -(arg_58_1 + var_59_1))
			var_56_5 = Vector2.Max(var_56_5, arg_58_1 + var_59_1)
		end)
	end

	var_56_6(self.nodeList[1], Vector2.zero)
	setSizeDelta(var_56_2, (Vector2.zero + Vector2.New(280, 280)) * 2)
	onButton(self, self.layerFormulaDetail:Find("Composite"), function()
		if not _.all(self.nodeList, function(arg_62_0)
			return arg_62_0.Instance
		end) then
			self:ShowMaterialsPreview()

			return
		end

		if not self.activity:GetFormulas()[self.contextData.formulaId]:IsAvaliable() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_tip_composite_invalid"))

			return
		end

		self:ShowCompositeConfirmWindow()
	end, SFX_PANEL)
	onButton(self, self.layerFormulaDetail:Find("AutoFill"), function()
		local var_63_0 = {}
		local var_63_1 = self.activity:GetItems()

		local function var_63_2(arg_64_0)
			local var_64_0 = var_63_0[arg_64_0:GetConfigID()] or Clone(var_63_1[arg_64_0:GetConfigID()])

			assert(var_64_0, "Using Unexist material")

			var_64_0.count = var_64_0.count - 1
			var_63_0[arg_64_0:GetConfigID()] = var_64_0
		end

		local var_63_3 = {}

		_.each(self.nodeList, function(arg_65_0)
			if arg_65_0.Instance then
				var_63_2(arg_65_0.Instance)
			else
				table.insert(var_63_3, arg_65_0)
			end
		end)

		if #var_63_3 <= 0 then
			return
		end

		local var_63_4 = true

		local function var_63_5()
			if not var_63_4 then
				return
			end

			self:DispalyChat({
				"ryza_atellier5",
				"ryza_atellier6",
				"ryza_atellier7"
			})

			var_63_4 = false
		end

		local var_63_6 = false
		local var_63_7

		local function var_63_8()
			if var_63_7 and coroutine.status(var_63_7) == "suspended" then
				local var_67_0, var_67_1 = coroutine.resume(var_63_7)

				assert(var_67_0, debug.traceback(var_63_7, var_67_1))
			end
		end

		var_63_7 = coroutine.create(function()
			_.each(var_63_3, function(arg_69_0)
				if arg_69_0.Data:GetType() == AtelierFormulaCircle.TYPE.BASE or arg_69_0.Data:GetType() == AtelierFormulaCircle.TYPE.SAIREN then
					local var_69_0 = arg_69_0.Data:GetLimitItemID()
					local var_69_1 = var_63_0[var_69_0] or var_63_1[var_69_0]

					if var_69_1 and var_69_1.count > 0 then
						var_63_2(var_69_1)
						var_63_5()
						self:FillNodeAndPlayAnim(arg_69_0, AtelierMaterial.New({
							count = 1,
							configId = var_69_0
						}), var_63_8, true)
						coroutine.yield()
					else
						var_63_6 = true
					end
				end
			end)

			if not var_63_6 then
				local var_68_0 = false
				local var_68_1 = false

				self:DisPlayUnlockEffect(function()
					var_68_0 = true

					if var_68_1 then
						var_63_8()
					end
				end)

				if not false then
					var_68_1 = true

					coroutine.yield()
				end

				local var_68_2 = true

				local function var_68_3()
					if not var_68_2 then
						return
					end

					pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_5")

					var_68_2 = false
				end

				local var_68_4 = AtelierMaterial.bindConfigTable()

				local function var_68_5(arg_72_0)
					for iter_72_0, iter_72_1 in ipairs(var_68_4.all) do
						local var_72_0 = var_63_0[iter_72_1] or var_63_1[iter_72_1]

						if var_72_0 and var_72_0.count > 0 and var_72_0:IsNormal() and arg_72_0.Data:CanUseMaterial(var_72_0, arg_56_1) then
							var_63_2(var_72_0)
							var_63_5()
							var_68_3()
							self:FillNodeAndPlayAnim(arg_72_0, AtelierMaterial.New({
								count = 1,
								configId = var_72_0:GetConfigID()
							}), true)

							return
						end
					end

					var_63_6 = true
				end

				_.each(var_63_3, function(arg_73_0)
					if arg_73_0.Data:GetType() == AtelierFormulaCircle.TYPE.NORMAL then
						var_68_5(arg_73_0)
					end
				end)
				_.each(var_63_3, function(arg_74_0)
					if arg_74_0.Data:GetType() == AtelierFormulaCircle.TYPE.ANY then
						var_68_5(arg_74_0)
					end
				end)
			end

			if var_63_6 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_material_not_enough"))
			end

			self:UpdateFormulaDetail()
		end)

		var_63_8()
	end, SFX_PANEL)
	self:UpdateFormulaDetail()
end

function AtelierCompositeScene:CleanNodeInstance()
	local var_75_0 = self.activity:GetFormulas()[self.contextData.formulaId]

	if not var_75_0:IsAvaliable() then
		self:HideFormulaDetail()

		self.contextData.formulaId = nil

		self:ShowFormulaList()

		return
	end

	_.each(self.nodeList, function(arg_76_0)
		arg_76_0.Instance = nil
		arg_76_0.Change = true
	end)
	self:ShowFormulaDetail(var_75_0)
end

function AtelierCompositeScene:UpdateFormulaDetail()
	local var_77_0 = 0
	local var_77_1 = 0

	self.unlockAllBase = true

	_.each(self.nodeList, function(arg_78_0)
		var_77_0 = var_77_0 + 1
		var_77_1 = var_77_1 + (arg_78_0.Instance and 1 or 0)
		self.unlockAllBase = self.unlockAllBase and (arg_78_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.BASE and arg_78_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.SAIREN or arg_78_0.Instance)
	end)
	_.each(self.nodeList, function(arg_79_0)
		local var_79_0 = not self.unlockAllBase and arg_79_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.BASE and arg_79_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.SAIREN
		local var_79_1 = arg_79_0.ChangeLock

		if not arg_79_0.ChangeLock then
			var_79_1 = tobool(arg_79_0.Lock)
			var_79_1 = var_79_1 and not var_79_0
		end

		arg_79_0.ChangeLock = var_79_1
		arg_79_0.Lock = var_79_0
	end)

	local var_77_2 = self.unlockAllBase ~= tobool(self.unlockAllBase)

	_.each(self.nodeList, function(arg_80_0)
		if var_77_2 then
			arg_80_0.Change = true
		end

		self:UpdateNodeView(arg_80_0)
	end)
	setText(self.layerFormulaDetail:Find("Bar/Text"), i18n("ryza_tip_put_materials", var_77_1, 0))
	setGray(self.layerFormulaDetail:Find("AutoFill"), not self.activity:GetFormulas()[self.contextData.formulaId]:IsAvaliable())
	setActive(self.layerFormulaDetail:Find("Composite/Disabled"), var_77_1 < 0)
end

local var_0_10 = {
	[AtelierFormulaCircle.ELEMENT_TYPE.PYRO] = "laisha_ui_huo",
	[AtelierFormulaCircle.ELEMENT_TYPE.CRYO] = "laisha_ui_bing",
	[AtelierFormulaCircle.ELEMENT_TYPE.ELECTRO] = "laisha_ui_lei",
	[AtelierFormulaCircle.ELEMENT_TYPE.ANEMO] = "laisha_ui_feng",
	[AtelierFormulaCircle.ELEMENT_TYPE.SAIREN] = "laisha_ui_sairen"
}
local var_0_11 = "laisha_ui_wupinshanguang"
local var_0_12 = "laisha_ui_jiesuo"
local var_0_13 = {
	"laisha_ui_lianjie01",
	"laisha_ui_lianjie02",
	"laisha_ui_lianjie_qiehuan"
}

function AtelierCompositeScene:UpdateNodeView(arg_81_1)
	local var_81_0 = tf(arg_81_1.GO)

	for iter_81_0 = 1, 6 do
		setActive(var_81_0:Find("Links"):GetChild(iter_81_0 - 1), false)
	end

	local var_81_1 = arg_81_1.Data

	_.each(arg_81_1.Data:GetNeighbors(), function(arg_82_0)
		setActive(var_81_0:Find("Links"):GetChild(arg_82_0[1] - 1), true)
	end)

	local var_81_2 = var_81_1:GetElementName()
	local var_81_3 = arg_81_1.Lock

	setActive(var_81_0:Find("Lock"), arg_81_1.Lock)

	if var_81_3 then
		if var_81_1:GetType() ~= AtelierFormulaCircle.TYPE.ANY then
			self.loader:GetSpriteQuiet(var_0_5, "element_" .. var_81_2, var_81_0:Find("Lock/Require/Icon"))
		end

		setText(var_81_0:Find("Lock/Require/Text"), "X" .. var_81_1:GetLevel())
	end

	for iter_81_1 = 3, var_81_1:GetLevel() + 1, -1 do
		self.loader:GetSpriteQuiet(var_0_4, "slot_BLOCKED", var_81_0:Find("Slots"):GetChild(iter_81_1 - 1):Find("Image"))
	end

	local var_81_4 = arg_81_1.Instance

	if not arg_81_1.Instance then
		if var_81_1:GetType() == AtelierFormulaCircle.TYPE.ANY then
			setActive(var_81_0:Find("All"), true)
		else
			setActive(var_81_0:Find("Icon"), true)
			self.loader:GetSpriteQuiet(var_0_4, "icon_" .. var_81_2, var_81_0:Find("Icon"), true)
		end

		setActive(var_81_0:Find("Item"), false)

		if var_81_1:GetType() == AtelierFormulaCircle.TYPE.BASE or var_81_1:GetType() == AtelierFormulaCircle.TYPE.SAIREN then
			local var_81_5 = AtelierMaterial.New({
				configId = var_81_1:GetLimitItemID()
			})

			setActive(var_81_0:Find("Name"), true)
			setScrollText(var_81_0:Find("Name/Rect/Text"), var_81_5:GetName())
		else
			setActive(var_81_0:Find("Name"), false)
		end

		for iter_81_2 = 1, var_81_1:GetLevel() do
			self.loader:GetSpriteQuiet(var_0_4, "slot_NULL", var_81_0:Find("Slots"):GetChild(iter_81_2 - 1):Find("Image"))
		end
	else
		local var_81_6 = AtelierFormulaCircle.ELEMENT_NAME[var_81_1:GetRingElement(var_81_4)]

		if var_81_1:GetType() == AtelierFormulaCircle.TYPE.ANY then
			setActive(var_81_0:Find("All"), false)
		else
			setActive(var_81_0:Find("Icon"), false)
		end

		setActive(var_81_0:Find("Item"), true)

		local var_81_7 = (var_81_1:GetType() == AtelierFormulaCircle.TYPE.BASE or var_81_1:GetType() == AtelierFormulaCircle.TYPE.SAIREN) and var_81_4:GetBaseCircleTransform() or var_81_4:GetNormalCircleTransform()

		setLocalScale(var_81_0:Find("Item"), Vector3.New(unpack(var_81_7, 1, 3)))
		setAnchoredPosition(var_81_0:Find("Item"), Vector2.New(unpack(var_81_7, 4, 5)))
		self.loader:GetSpriteQuiet(var_81_4:GetIconPath(), "", var_81_0:Find("Item"), true)
		setActive(var_81_0:Find("Name"), true)
		setScrollText(var_81_0:Find("Name/Rect/Text"), var_81_4:GetName())

		for iter_81_3 = 1, var_81_1:GetLevel() do
			self.loader:GetSpriteQuiet(var_0_4, "slot_" .. var_81_6, var_81_0:Find("Slots"):GetChild(iter_81_3 - 1):Find("Image"))
		end
	end

	local var_81_8 = var_81_0:Find("Ring")

	setImageColor(var_81_8, var_81_1:GetElementRingColor(var_81_4))

	if arg_81_1.Change then
		local var_81_9 = arg_81_1.Data:GetRingElement(var_81_4)

		if var_81_3 then
			var_81_9 = nil
		end

		if var_0_10[var_81_9] then
			self.loader:GetPrefab("ui/" .. var_0_10[var_81_9] .. (arg_81_1.Data:GetType() == AtelierFormulaCircle.TYPE.BASE and "_o" or "_6"), "", function(arg_83_0)
				setParent(arg_83_0, var_81_8)
				setAnchoredPosition(arg_83_0, Vector2.zero)
			end, var_81_8)
		else
			self.loader:ClearRequest(var_81_8)
		end

		table.Foreach(arg_81_1.links, function(arg_84_0, arg_84_1)
			local var_84_0 = var_81_0:Find("Links/" .. arg_84_0)
			local var_84_1 = var_0_13[3]

			if arg_84_1.Lock and var_81_3 then
				var_84_1 = var_0_13[1]
			elseif not arg_84_1.Lock and not var_81_3 then
				var_84_1 = var_0_13[2]
			end

			self.loader:GetPrefab("ui/" .. var_84_1, "", function(arg_85_0)
				setParent(arg_85_0, var_84_0:Find("Link"))
				setAnchoredPosition(arg_85_0, Vector2.New(0, -15))
			end, var_84_0)
		end)

		arg_81_1.Change = nil
	end

	if arg_81_1.ChangeInstance then
		local var_81_10 = var_81_0:Find("Item")

		if var_81_4 then
			self.loader:GetPrefab("ui/" .. var_0_11, "", function(arg_86_0)
				setParent(arg_86_0, var_81_10)
				setAnchoredPosition(arg_86_0, Vector2.zero)
			end, var_81_0)
		else
			self.loader:ClearRequest(var_81_0)
		end

		arg_81_1.ChangeInstance = nil
	end

	onButton(self, var_81_0, function()
		if var_81_3 then
			return
		end

		local var_87_0 = self.layerMaterialSelect:Find("TargetBG")

		var_87_0.localRotation = Quaternion.identity

		local var_87_1 = var_81_1:GetType() == AtelierFormulaCircle.TYPE.BASE and 300 or 245

		setSizeDelta(var_87_0, {
			x = var_87_1,
			y = var_87_1
		})

		local var_87_2 = self.layerMaterialSelect:Find("Target")

		self:ShowCandicatePanel()

		local var_87_3 = tf(Instantiate(var_81_0))

		SetCompomentEnabled(var_87_3, typeof(Button), false)
		setParent(var_87_3, var_87_2)
		setAnchoredPosition(var_87_3, Vector2.zero)

		for iter_87_0 = 1, 6 do
			setActive(var_87_3:Find("Links"):GetChild(iter_87_0 - 1), false)
		end

		setAnchoredPosition(self.layerFormulaDetail:Find("ScrollView/Content"), var_87_2.anchoredPosition - (var_81_0.anchoredPosition + self.layerFormulaDetail:Find("ScrollView").anchoredPosition))

		self.candicateTarget = arg_81_1

		GetComponent(var_87_0, typeof(Animator)):SetBool("Selecting", true)
		self:UpdateCandicatePanel()
	end, SFX_PANEL)
end

function AtelierCompositeScene:FillNodeAndPlayAnim(arg_88_1, arg_88_2, arg_88_3, arg_88_4)
	self:LoadingOn()

	arg_88_1.ChangeInstance = arg_88_1.ChangeInstance or tobool(arg_88_1.Instance) ~= tobool(arg_88_2)
	arg_88_1.Instance = arg_88_2
	arg_88_1.Change = true

	local var_88_0 = {}
	local var_88_1 = {}

	seriesAsync({
		function(arg_89_0)
			table.ParallelIpairsAsync({
				"ui/laisha_ui_wupinzhiru",
				"ui/laisha_ui_baoshi"
			}, function(arg_90_0, arg_90_1, arg_90_2)
				var_88_0[arg_90_0] = self.loader:GetPrefab(arg_90_1, "", function(arg_91_0)
					setParent(arg_91_0, tf(arg_88_1.GO))
					setAnchoredPosition(arg_91_0, Vector2.zero)

					var_88_1[arg_90_0] = arg_91_0

					setActive(arg_91_0, false)
					arg_90_2()
				end)
			end, arg_89_0)
		end,
		function(arg_92_0)
			setActive(var_88_1[1], true)
			self:managedTween(LeanTween.delayedCall, function()
				if not arg_88_4 then
					self:UpdateFormulaDetail()
				else
					self:UpdateNodeView(arg_88_1)
				end

				pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_4")
				arg_92_0()
			end, 0.2, nil)
		end,
		function(arg_94_0)
			setActive(var_88_1[2], true)
			self:managedTween(LeanTween.delayedCall, function()
				arg_94_0()
			end, 0.5, nil)
		end,
		function(arg_96_0)
			self.loader:ClearRequest(var_88_0[1])
			self.loader:ClearRequest(var_88_0[2])
			self:LoadingOff()
			existCall(arg_88_3)
		end
	})
end

function AtelierCompositeScene:DisPlayUnlockEffect(arg_97_1)
	self.unlockAllBase = true

	_.each(self.nodeList, function(arg_98_0)
		self.unlockAllBase = self.unlockAllBase and (arg_98_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.BASE and arg_98_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.SAIREN or arg_98_0.Instance)
	end)
	_.each(self.nodeList, function(arg_99_0)
		local var_99_0 = not self.unlockAllBase and arg_99_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.BASE and arg_99_0.Data:GetType() ~= AtelierFormulaCircle.TYPE.SAIREN
		local var_99_1 = arg_99_0.ChangeLock

		if not arg_99_0.ChangeLock then
			var_99_1 = tobool(arg_99_0.Lock)
			var_99_1 = var_99_1 and not var_99_0
		end

		arg_99_0.ChangeLock = var_99_1
		arg_99_0.Lock = var_99_0
	end)

	if not _.any(self.nodeList, function(arg_100_0)
		return arg_100_0.ChangeLock
	end) then
		existCall(arg_97_1)

		return
	end

	self:LoadingOn()

	local var_97_0 = {}

	_.each(self.nodeList, function(arg_101_0)
		local var_101_0 = tf(arg_101_0.GO)

		if arg_101_0.ChangeLock then
			if arg_101_0.prevLink then
				arg_101_0.prevLink[2].Change = true
			end

			table.insert(var_97_0, (self.loader:GetPrefab("ui/" .. var_0_12, "", function(arg_102_0)
				setParent(arg_102_0, var_101_0)
				setAnchoredPosition(arg_102_0, Vector2.zero)
			end)))

			arg_101_0.ChangeLock = nil
		end
	end)
	self:managedTween(LeanTween.delayedCall, function()
		pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_3")
	end, 0.7, nil)
	self:managedTween(LeanTween.delayedCall, function()
		_.each(var_97_0, function(arg_105_0)
			self.loader:ClearRequest(arg_105_0)
		end)
		self:LoadingOff()
		existCall(arg_97_1)
	end, 1.7, nil)
end

function AtelierCompositeScene:ShowCandicatePanel()
	self:DispalyChat({
		"ryza_atellier2",
		"ryza_atellier3",
		"ryza_atellier4"
	})
	pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_1")
	pg.UIMgr.GetInstance():BlurPanel(self.top)
	setActive(self.layerMaterialSelect, true)
	SetCompomentEnabled(self.layerFormulaDetail:Find("ScrollView"), typeof(ScrollRect), false)
	removeAllChildren(self.layerMaterialSelect:Find("Target"))
end

function AtelierCompositeScene:CloseCandicatePanel()
	self:LoadingOn()

	local var_107_0 = GetComponent(self.layerMaterialSelect:Find("TargetBG"), typeof(DftAniEvent))

	var_107_0:SetEndEvent(function()
		self:LoadingOff()
		self:HideCandicatePanel()
		var_107_0:SetEndEvent(nil)
	end)
	GetComponent(self.layerMaterialSelect:Find("TargetBG"), typeof(Animator)):SetBool("Selecting", false)
end

function AtelierCompositeScene:HideCandicatePanel()
	if not isActive(self.layerMaterialSelect) then
		return
	end

	pg.UIMgr.GetInstance():OverlayPanel(self.top)
	self.painting:SetSiblingIndex(1)
	setActive(self.layerMaterialSelect, false)
	removeAllChildren(self.layerMaterialSelect:Find("Target"))
	SetCompomentEnabled(self.layerFormulaDetail:Find("ScrollView"), typeof(ScrollRect), true)

	self.candicateTarget = nil

	return true
end

function AtelierCompositeScene:UpdateCandicatePanel()
	self.candicates = {}

	local var_110_0 = self.activity:GetItems()
	local var_110_1 = self.activity:GetFormulas()[self.contextData.formulaId]
	local var_110_2 = _.map(AtelierMaterial.bindConfigTable().all, function(arg_111_0)
		local var_111_0 = var_110_0[arg_111_0] or AtelierMaterial.New({
			configId = arg_111_0
		})

		if self.candicateTarget.Data:CanUseMaterial(var_111_0, var_110_1) then
			if var_110_0[arg_111_0] then
				var_111_0 = AtelierMaterial.New({
					configId = arg_111_0,
					count = var_110_0[arg_111_0].count
				})
				var_111_0.count = _.reduce(self.nodeList, var_111_0.count, function(arg_112_0, arg_112_1)
					if arg_112_1.Instance and arg_112_1.Instance:GetConfigID() == arg_111_0 then
						arg_112_0 = arg_112_0 - 1
					end

					return arg_112_0
				end)
			end

			return var_111_0
		end
	end)

	table.sort(var_110_2, function(arg_113_0, arg_113_1)
		if arg_113_0.count * arg_113_1.count == 0 and arg_113_0.count - arg_113_1.count ~= 0 then
			return arg_113_0.count < arg_113_1.count
		else
			return arg_113_0:GetConfigID() < arg_113_1:GetConfigID()
		end
	end)
	_.each(var_110_2, function(arg_114_0)
		for iter_114_0 = 1, math.max(arg_114_0.count, 1) do
			table.insert(self.candicates, arg_114_0)
		end
	end)
	self.candicatesRect:SetTotalCount(#self.candicates, 0)
end

function AtelierCompositeScene:UpdateCandicateItem(arg_115_1, arg_115_2)
	local var_115_0 = tf(arg_115_2)
	local var_115_1 = self.candicates[arg_115_1]

	self:UpdateRyzaItem(var_115_0:Find("IconBG"), self.candicates[arg_115_1], true)

	local var_115_2 = var_115_1.count <= 0

	setActive(var_115_0:Find("IconBG/Lack"), var_115_1.count <= 0)
	onButton(self, var_115_0, function()
		if var_115_2 then
			var_115_1 = CreateShell(var_115_1)
			var_115_1.count = false

			self:ShowItemDetail(var_115_1)
		else
			self:DispalyChat({
				"ryza_atellier5",
				"ryza_atellier6",
				"ryza_atellier7"
			})
			pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_2")

			local var_116_0 = self.candicateTarget

			self:HideCandicatePanel()
			seriesAsync({
				function(arg_117_0)
					self:FillNodeAndPlayAnim(var_116_0, AtelierMaterial.New({
						count = 1,
						configId = var_115_1:GetConfigID()
					}), arg_117_0, true)
				end,
				function(arg_118_0)
					self:DisPlayUnlockEffect(arg_118_0)
				end,
				function(arg_119_0)
					self:UpdateFormulaDetail()
				end
			})
		end
	end, SFX_PANEL)
end

function AtelierCompositeScene:UpdateRyzaItem(arg_120_1, arg_120_2, arg_120_3)
	local var_120_0 = "icon_frame_" .. arg_120_2:GetRarity()

	if arg_120_3 then
		var_120_0 = var_120_0 .. "_small"
	end

	self.loader:GetSpriteQuiet(var_0_5, var_120_0, arg_120_1)
	self.loader:GetSpriteQuiet(arg_120_2:GetIconPath(), "", arg_120_1:Find("Icon"))

	if not IsNil(arg_120_1:Find("Lv")) then
		setText(arg_120_1:Find("Lv/Text"), arg_120_2:GetLevel())
	end

	local var_120_1 = arg_120_2:GetProps()

	for iter_120_0, iter_120_1 in ipairs((CustomIndexLayer.Clone2Full(arg_120_1:Find("List"), #var_120_1))) do
		self.loader:GetSpriteQuiet(var_0_5, "element_" .. AtelierFormulaCircle.ELEMENT_NAME[var_120_1[iter_120_0]], iter_120_1)
	end

	if not IsNil(arg_120_1:Find("Text")) then
		setText(arg_120_1:Find("Text"), arg_120_2.count)
	end
end

function AtelierCompositeScene:ShowItemDetail(arg_121_1)
	self:emit(AtelierMaterialDetailMediator.SHOW_DETAIL, arg_121_1)
end

local var_0_14 = 41
local var_0_15 = 5

function AtelierCompositeScene:ShowCompositeConfirmWindow()
	setActive(self.layerCompositeConfirm, true)
	pg.UIMgr.GetInstance():BlurPanel(self.layerCompositeConfirm)

	local var_122_0 = 1
	local var_122_1 = {}
	local var_122_2 = {}

	_.each(self.nodeList, function(arg_123_0)
		local var_123_0 = arg_123_0.Instance:GetConfigID()

		table.insert(var_122_1, {
			key = arg_123_0.Data:GetConfigID(),
			value = var_123_0
		})

		var_122_2[var_123_0] = (var_122_2[var_123_0] or 0) + 1
	end)
	onButton(self, self.layerCompositeConfirm:Find("Window/Confirm"), function()
		self:emit(GAME.COMPOSITE_ATELIER_RECIPE, var_122_1, var_122_0)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/ui/ryza_atellier_ui_6")
	end, SFX_PANEL)

	local var_122_3 = self.activity:GetFormulas()[self.contextData.formulaId]
	local var_122_4 = var_122_3:GetMaxLimit() ~= 1
	local var_122_5 = var_122_3:GetMaxLimit() > 0 and var_122_3:GetMaxLimit() - var_122_3:GetUsedCount() or 10000
	local var_122_6 = self.activity:GetItems()

	for iter_122_0, iter_122_1 in pairs(var_122_2) do
		var_122_5 = math.min(var_122_5, math.floor(((var_122_6[iter_122_0] or nil) and (var_122_6[iter_122_0].count or 0)) / iter_122_1))
	end

	local var_122_7 = {
		1,
		var_122_4 and var_122_5 or 1
	}
	local var_122_8 = Drop.New({
		type = var_122_3:GetProduction()[1],
		id = var_122_3:GetProduction()[2]
	})

	self:UpdateRyzaDrop(self.layerCompositeConfirm:Find("Window/Icon"), var_122_8)

	local var_122_9 = self.layerCompositeConfirm:Find("Window/Counters")
	local var_122_10 = var_122_8:getConfig("name")

	setActive(var_122_9, var_122_4)

	if var_122_4 then
		setAnchoredPosition(self.layerCompositeConfirm:Find("Window/Icon"), {
			y = var_0_14
		})

		local function var_122_11()
			setText(var_122_9:Find("Number"), var_122_0)
			setText(self.layerCompositeConfirm:Find("Window/Text"), i18n("ryza_composite_confirm", var_122_10, var_122_0))
		end

		var_122_11()
		onButton(self, var_122_9:Find("Plus"), function()
			var_122_0 = var_122_0 + 1
			var_122_0 = math.clamp(var_122_0, var_122_7[1], var_122_7[2])

			if var_122_0 == var_122_0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_tip_max_composite_count"))

				return
			end

			var_122_11()
		end)
		onButton(self, var_122_9:Find("Minus"), function()
			var_122_0 = var_122_0 - 1
			var_122_0 = math.clamp(var_122_0, var_122_7[1], var_122_7[2])

			var_122_11()
		end)
		onButton(self, var_122_9:Find("Plus10"), function()
			var_122_0 = var_122_0 + 10
			var_122_0 = math.clamp(var_122_0, var_122_7[1], var_122_7[2])

			if var_122_0 == var_122_0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ryza_tip_max_composite_count"))

				return
			end

			var_122_11()
		end)
		onButton(self, var_122_9:Find("Minus10"), function()
			var_122_0 = var_122_0 - 10
			var_122_0 = math.clamp(var_122_0, var_122_7[1], var_122_7[2])

			var_122_11()
		end)
	else
		setAnchoredPosition(self.layerCompositeConfirm:Find("Window/Icon"), {
			y = var_0_15
		})
		setText(self.layerCompositeConfirm:Find("Window/Text"), i18n("ryza_composite_confirm_single", var_122_10, var_122_0))
	end
end

function AtelierCompositeScene:HideCompositeConfirmWindow()
	if not isActive(self.layerCompositeConfirm) then
		return
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self.layerCompositeConfirm, self._tf)
	setActive(self.layerCompositeConfirm, false)

	return true
end

local var_0_16 = "laisha_lianjin"

function AtelierCompositeScene:OnCompositeResult(arg_131_1)
	self:LoadingOn()
	self:DispalyChat({
		"ryza_atellier8",
		"ryza_atellier9"
	})

	local var_131_0 = 1.5
	local var_131_1 = 0.5

	self.loader:GetPrefab("ui/" .. var_0_16, "", function(arg_132_0)
		pg.UIMgr.GetInstance():OverlayPanel(tf(arg_132_0))
		setAnchoredPosition(arg_132_0, Vector2.zero)
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self._tf, typeof(CanvasGroup)), 0, var_131_0):setFrom(1)
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.top, typeof(CanvasGroup)), 0, var_131_0):setFrom(1)
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.layerCompositeConfirm, typeof(CanvasGroup)), 0, var_131_0):setFrom(1)
		self:managedTween(LeanTween.delayedCall, function()
			self:HideCompositeConfirmWindow()
			setCanvasGroupAlpha(self.layerCompositeConfirm, 1)
			self:CleanNodeInstance()
			self:ShowCompositeResult(arg_131_1)
			self:DispalyChat({
				"ryza_atellier10",
				"ryza_atellier11"
			})
			self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self._tf, typeof(CanvasGroup)), 1, var_131_1):setFrom(0)
			self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.top, typeof(CanvasGroup)), 1, var_131_1):setFrom(0)
			self:managedTween(LeanTween.alphaCanvas, nil, GetOrAddComponent(self.layerCompositeResult, typeof(CanvasGroup)), 1, var_131_1):setFrom(0)
			self:managedTween(LeanTween.delayedCall, function()
				self:LoadingOff()
				pg.UIMgr.GetInstance():UnOverlayPanel(tf(arg_132_0), self._tf)
				self.loader:ClearRequest("CompositeResult")
			end, go(self.layerCompositeResult), var_131_1, nil)
		end, go(self.layerCompositeResult), var_131_0, nil)
	end, "CompositeResult")
end

function AtelierCompositeScene:ShowCompositeResult(arg_135_1)
	setActive(self.layerCompositeResult, true)
	pg.UIMgr.GetInstance():BlurPanel(self.layerCompositeResult)

	if arg_135_1[1] == nil then
		return
	end

	self:UpdateRyzaDrop(self.layerCompositeResult:Find("Window/Icon"), arg_135_1[1])
	setScrollText(self.layerCompositeResult:Find("Window/NameBG/Rect/Name"), arg_135_1[1]:getName())
	setText(self.layerCompositeResult:Find("Window/CountBG/Text"), arg_135_1[1].count)
end

function AtelierCompositeScene:HideCompositeResult()
	if not isActive(self.layerCompositeResult) then
		return
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self.layerCompositeResult, self._tf)
	setActive(self.layerCompositeResult, false)

	if pg.NewStoryMgr.GetInstance():IsPlayed("NG0032") then
		pg.SystemGuideMgr.GetInstance():PlayByGuideId("NG0033", {
			2
		})
	end

	return true
end

function AtelierCompositeScene:ShowStoreHouseWindow()
	setActive(self.layerStoreHouse, true)
	pg.UIMgr.GetInstance():BlurPanel(self.layerStoreHouse)

	local var_137_0 = _.filter(_.values(self.activity:GetItems()), function(arg_138_0)
		return arg_138_0.count > 0
	end)

	table.sort(var_137_0, function(arg_139_0, arg_139_1)
		return arg_139_0:GetConfigID() < arg_139_1:GetConfigID()
	end)
	setActive(self.layerStoreHouse:Find("Window/Empty"), #var_137_0 == 0)
	setActive(self.layerStoreHouse:Find("Window/ScrollView"), #var_137_0 > 0)

	if #var_137_0 == 0 then
		return
	end

	function self.storehouseRect.onUpdateItem(arg_140_0, arg_140_1)
		arg_140_0 = arg_140_0 + 1

		local var_140_0 = tf(arg_140_1)
		local var_140_1 = var_137_0[arg_140_0]

		self:UpdateRyzaItem(var_140_0:Find("IconBG"), var_137_0[arg_140_0])
		setScrollText(var_140_0:Find("NameBG/Rect/Name"), var_137_0[arg_140_0]:GetName())
		onButton(self, var_140_0, function()
			self:ShowItemDetail(var_140_1)
		end, SFX_PANEL)
	end

	self.storehouseRect:SetTotalCount(#var_137_0)
end

function AtelierCompositeScene:CloseStoreHouseWindow()
	self.contextData.showStoreHouse = nil

	return self:HideStoreHouseWindow()
end

function AtelierCompositeScene:HideStoreHouseWindow()
	if not isActive(self.layerStoreHouse) then
		return
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self.layerStoreHouse, self._tf)
	setActive(self.layerStoreHouse, false)

	return true
end

function AtelierCompositeScene:ShowMaterialsPreview()
	setActive(self.layerMaterialsPreview, true)
	pg.UIMgr.GetInstance():BlurPanel(self.layerMaterialsPreview)

	local var_144_0 = self.activity:GetItems()
	local var_144_1 = self.activity:GetFormulas()[self.contextData.formulaId]
	local var_144_2 = AtelierMaterial.bindConfigTable()
	local var_144_3 = {}
	local var_144_4 = {}
	local var_144_5 = {}

	local function var_144_6(arg_145_0)
		local var_145_0 = var_144_5[arg_145_0:GetConfigID()] or Clone(var_144_0[arg_145_0:GetConfigID()])

		assert(var_145_0, "Using Unexist material")

		var_145_0.count = var_145_0.count - 1
		var_144_5[arg_145_0:GetConfigID()] = var_145_0
	end

	_.each(self.nodeList, function(arg_146_0)
		if arg_146_0.Data:GetType() == AtelierFormulaCircle.TYPE.BASE or arg_146_0.Data:GetType() == AtelierFormulaCircle.TYPE.SAIREN then
			local var_146_0 = arg_146_0.Data:GetLimitItemID()
			local var_146_1 = var_144_5[var_146_0] or var_144_0[var_146_0]

			if var_146_1 and var_146_1.count > 0 then
				local var_146_2 = AtelierMaterial.New({
					configId = var_146_0
				})

				var_146_2.count = false

				table.insert(var_144_3, var_146_2)
				var_144_6(var_146_1)
			else
				local var_146_3 = AtelierMaterial.New({
					configId = var_146_0
				})

				var_146_3.count = false

				table.insert(var_144_4, var_146_3)
			end
		end
	end)

	local function var_144_7(arg_147_0)
		if arg_147_0.Instance then
			local var_147_0 = AtelierMaterial.New({
				configId = arg_147_0.Instance:GetConfigID()
			})

			var_147_0.count = false

			table.insert(var_144_3, var_147_0)
			var_144_6(arg_147_0.Instance)

			return
		end

		local var_147_1 = arg_147_0.Data
		local var_147_2

		for iter_147_0, iter_147_1 in ipairs(var_144_2.all) do
			local var_147_3 = var_144_5[iter_147_1] or var_144_0[iter_147_1] or AtelierMaterial.New({
				configId = iter_147_1
			})

			if var_147_3:IsNormal() and var_147_1:CanUseMaterial(var_147_3, var_144_1) then
				var_147_2 = var_147_2 or iter_147_1

				if var_147_3.count > 0 then
					local var_147_4 = AtelierMaterial.New({
						configId = iter_147_1
					})

					var_147_4.count = false

					table.insert(var_144_3, var_147_4)
					var_144_6(var_147_3)

					return
				end
			end
		end

		local var_147_5 = AtelierMaterial.New({
			configId = var_147_2
		})

		var_147_5.count = false

		table.insert(var_144_4, var_147_5)
	end

	_.each(self.nodeList, function(arg_148_0)
		if arg_148_0.Data:GetType() == AtelierFormulaCircle.TYPE.NORMAL then
			var_144_7(arg_148_0)
		end
	end)
	_.each(self.nodeList, function(arg_149_0)
		if arg_149_0.Data:GetType() == AtelierFormulaCircle.TYPE.ANY then
			var_144_7(arg_149_0)
		end
	end)

	local function var_144_8(arg_150_0, arg_150_1)
		return arg_150_0:GetConfigID() < arg_150_1:GetConfigID()
	end

	table.sort(var_144_3, var_144_8)
	table.sort(var_144_4, var_144_8)
	;(function()
		local var_151_0 = self.layerMaterialsPreview:Find("Frame/Scroll/Content/Owned/List")

		setActive(var_151_0.parent, #var_144_3 > 0)

		if #var_144_3 == 0 then
			return
		end

		table.Foreach(CustomIndexLayer.Clone2Full(var_151_0, #var_144_3), function(arg_152_0, arg_152_1)
			local var_152_0 = var_144_3[arg_152_0]

			self:UpdateRyzaItem(arg_152_1:Find("IconBG"), var_144_3[arg_152_0], true)
			onButton(self, arg_152_1, function()
				self:ShowItemDetail(var_152_0)
			end, SFX_PANEL)
		end)
	end)()
	;(function()
		local var_154_0 = self.layerMaterialsPreview:Find("Frame/Scroll/Content/Lack/List")

		setActive(var_154_0.parent, #var_144_4 > 0)

		if #var_144_4 == 0 then
			return
		end

		table.Foreach(CustomIndexLayer.Clone2Full(var_154_0, #var_144_4), function(arg_155_0, arg_155_1)
			local var_155_0 = var_144_4[arg_155_0]

			self:UpdateRyzaItem(arg_155_1:Find("IconBG"), var_144_4[arg_155_0], true)
			onButton(self, arg_155_1, function()
				self:ShowItemDetail(var_155_0)
			end, SFX_PANEL)
		end)
	end)()
end

function AtelierCompositeScene:HideMaterialsPreview()
	if not isActive(self.layerMaterialsPreview) then
		return
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self.layerMaterialsPreview, self._tf)
	setActive(self.layerMaterialsPreview, false)

	return true
end

function AtelierCompositeScene:OnReceiveFormualRequest(arg_158_1)
	self:HideCandicatePanel()
	self:HideCompositeConfirmWindow()
	self:HideCompositeResult()
	self:HideMaterialsPreview()
	self:CloseStoreHouseWindow()
	self:HideFormulaList()
	self:ShowFormulaDetail(self.activity:GetFormulas()[arg_158_1])
end

function AtelierCompositeScene:DispalyChat(arg_159_1)
	self:HideChat()
	setActive(self.chat, true)

	self.chatTween = LeanTween.delayedCall(go(self.chat), 4, System.Action(function()
		self:HideChat()
	end)).uniqueId

	local var_159_0 = arg_159_1[math.random(#arg_159_1)]
	local var_159_1 = _.detect(pg.gametip.ryza_composite_words.tip, function(arg_161_0)
		return arg_161_0[1] == var_159_0
	end)

	setText(self.chat:Find("Text"), var_159_1 and var_159_1[2])
	self:PlaySound("event:/cv/" .. 1090001 .. "/" .. var_159_0)
end

function AtelierCompositeScene:HideChat()
	if self.chatTween then
		LeanTween.cancel(self.chatTween)

		self.chatTween = nil
	end

	setActive(self.chat, false)
end

function AtelierCompositeScene:PlaySound(arg_163_1, arg_163_2)
	if not self.playbackInfo or arg_163_1 ~= self.prevCvPath or self.playbackInfo.channelPlayer == nil then
		self:StopSound()
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(arg_163_1, function(arg_164_0)
			if arg_164_0 then
				self.playbackInfo = arg_164_0

				self.playbackInfo:SetIgnoreAutoUnload(true)

				if arg_163_2 then
					arg_163_2(self.playbackInfo.cueInfo)
				end
			elseif arg_163_2 then
				arg_163_2()
			end
		end)

		self.prevCvPath = arg_163_1

		if self.playbackInfo == nil then
			return nil
		end

		return self.playbackInfo.cueInfo
	elseif self.playbackInfo then
		self.playbackInfo:PlaybackStop()
		self.playbackInfo:SetStartTimeAndPlay()

		if arg_163_2 then
			arg_163_2(self.playbackInfo.cueInfo)
		end

		return self.playbackInfo.cueInfo
	elseif arg_163_2 then
		arg_163_2()
	end

	return nil
end

function AtelierCompositeScene:StopSound()
	if self.playbackInfo then
		pg.CriMgr.GetInstance():StopPlaybackInfoForce(self.playbackInfo)
		self.playbackInfo:SetIgnoreAutoUnload(false)
	end
end

function AtelierCompositeScene:ClearSound()
	self:StopSound()

	if self.playbackInfo then
		self.playbackInfo:Dispose()

		self.playbackInfo = nil
	end
end

function AtelierCompositeScene:LoadingOn()
	if self.animating then
		return
	end

	self.animating = true

	pg.UIMgr.GetInstance():LoadingOn(false)
end

function AtelierCompositeScene:LoadingOff()
	if not self.animating then
		return
	end

	pg.UIMgr.GetInstance():LoadingOff()

	self.animating = false
end

function AtelierCompositeScene:willExit()
	self.loader:Clear()
	self:LoadingOff()
	self:HideChat()
	self:ClearSound()
	self:HideStoreHouseWindow()
	self:HideMaterialsPreview()
	self:HideCompositeResult()
	self:HideCompositeConfirmWindow()
	self:HideCandicatePanel()
	self:HideFormulaDetail()
	self:HideFormulaList()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.top, self._tf)

	if self.nodePools then
		for iter_169_0, iter_169_1 in pairs(self.nodePools) do
			iter_169_1:ClearItems()
		end
	end
end

return AtelierCompositeScene
