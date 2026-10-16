local ShipDestoryConfirmWindow = class("ShipDestoryConfirmWindow", import("...base.BaseSubView"))

function ShipDestoryConfirmWindow:getUIName()
	return "DestoryConfirmWindow"
end

function ShipDestoryConfirmWindow:getResource()
	return table.insertto({
		"weaponframes",
		"shiptype",
		"ui/iconcolorful"
	}, ShipDestoryConfirmWindow.super.getResource(self))
end

function ShipDestoryConfirmWindow:getShipResList(arg_3_1)
	local var_3_0 = {}

	_.each(arg_3_1 or {}, function(arg_4_0)
		if arg_4_0 then
			table.insertto(var_3_0, (ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_4_0:getPainting())))
		end
	end)

	return var_3_0
end

function ShipDestoryConfirmWindow:downloadShipResList(arg_5_1, arg_5_2)
	SplitPackConst.DownloadByLuaArr(self:getShipResList(arg_5_1), function()
		if self._state == ShipDestoryConfirmWindow.STATES.DESTROY then
			return
		end

		arg_5_2()
	end)
end

function ShipDestoryConfirmWindow:OnLoaded()
	self.closeBtn = self._tf:Find("window/top/btnBack")

	setActive(self._tf:Find("window/top/bg/infomation/title_en"), PLATFORM_CODE ~= PLATFORM_US)
	setText(self._tf:Find("window/top/bg/infomation/title"), i18n("title_info"))

	self.cancelBtn = self._tf:Find("window/cancel_btn")
	self.confirmBtn = self._tf:Find("window/confirm_btn")

	setText(findTF(self.confirmBtn, "pic"), i18n("destroy_confirm_access"))
	setText(findTF(self.cancelBtn, "pic"), i18n("destroy_confirm_cancel"))

	self.title = self._tf:Find("window/content/Text")
	self.label = self._tf:Find("window/content/desc/label")

	setText(self.label, i18n("destory_ship_before_tip"))

	self.urLabel = self._tf:Find("window/content/desc/label1")
	self.urInput = self._tf:Find("window/content/desc/InputField")
	self.urOverflowLabel = self._tf:Find("window/content/desc/label2")

	setText(self.urOverflowLabel, i18n("destory_ur_pt_overflowa"))
	setText(self.urInput:Find("Placeholder"), i18n("box_ship_del_click"))
end

function ShipDestoryConfirmWindow:OnInit()
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:Confirm()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bg"), function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
end

function ShipDestoryConfirmWindow:SetCallBack(arg_13_1)
	self.callback = arg_13_1
end

function ShipDestoryConfirmWindow:Confirm()
	if self.key then
		if self.key ~= tonumber((getInputText(self.urInput))) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("destory_ship_input_erro"))

			return
		end

		local var_14_0 = self.callback

		self:Hide()
		existCall(var_14_0)
	else
		local var_14_1 = self.callback

		self:Hide()
		existCall(var_14_1)
	end
end

function ShipDestoryConfirmWindow:ShowOneShipProtect(arg_15_1, arg_15_2)
	self:downloadShipResList(arg_15_1, function()
		self:ShowOneShipProtectAfterResDownload(arg_15_1, arg_15_2)
	end)
end

function ShipDestoryConfirmWindow:ShowOneShipProtectAfterResDownload(arg_17_1, arg_17_2)
	ShipDestoryConfirmWindow.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.key = nil
	self.ships = arg_17_1

	self:SetCallBack(arg_17_2)
	setText(self.title, i18n("unique_ship_tip1"))

	self.key = math.random(100000, 999999)

	setText(self.urLabel, i18n("unique_ship_tip2", self.key))
	setActive(self.urLabel, true)
	setActive(self.urInput, true)
	setActive(self.urOverflowLabel, false)
	mergeSort(self.ships, CompareFuncs({
		function(arg_18_0)
			return -arg_18_0.level
		end,
		function(arg_19_0)
			return -arg_19_0:getRarity()
		end
	}, true))

	if #self.ships > 5 then
		setActive(self._tf:Find("window/content/ships"), true)
		setActive(self._tf:Find("window/content/ships_single"), false)

		local var_17_0 = self._tf:Find("window/content/ships/content"):GetComponent("LScrollRect")

		function var_17_0.onUpdateItem(arg_20_0, arg_20_1)
			updateShip(tf(arg_20_1), self.ships[arg_20_0 + 1])
		end

		onNextTick(function()
			var_17_0:SetTotalCount(#self.ships)
		end)
	else
		setActive(self._tf:Find("window/content/ships"), false)
		setActive(self._tf:Find("window/content/ships_single"), true)

		local var_17_1 = self._tf:Find("window/content/ships_single")
		local var_17_2 = UIItemList.New(var_17_1, var_17_1:Find("IconTpl"))

		var_17_2:make(function(arg_22_0, arg_22_1, arg_22_2)
			if arg_22_0 == UIItemList.EventUpdate then
				updateShip(arg_22_2, self.ships[arg_22_1 + 1])
			end
		end)
		var_17_2:align(#self.ships)
	end
end

function ShipDestoryConfirmWindow:Show(arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	self:downloadShipResList(table.mergeArray(arg_23_2 or {}, arg_23_1 or {}), function()
		self:ShowAfterResDownload(arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	end)
end

function ShipDestoryConfirmWindow:ShowAfterResDownload(arg_25_1, arg_25_2, arg_25_3, arg_25_4)
	ShipDestoryConfirmWindow.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.key = nil
	self.eliteShips = arg_25_1
	self.highLevelShips = arg_25_2
	self.overflow = arg_25_3

	self:SetCallBack(arg_25_4)
	self:Updatelayout()
	self:UpdateShips()
end

function ShipDestoryConfirmWindow:ShowEliteTag(arg_26_1, arg_26_2)
	self:downloadShipResList(arg_26_1, function()
		self:ShowEliteTagAfterResDownload(arg_26_1, arg_26_2)
	end)
end

function ShipDestoryConfirmWindow:ShowEliteTagAfterResDownload(arg_28_1, arg_28_2)
	ShipDestoryConfirmWindow.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self:SetCallBack(arg_28_2)
	setText(self.title, i18n("destroy_eliteship_tip", i18n("destroy_inHardFormation_tip")))
	setActive(self.urOverflowLabel, false)
	setActive(self.urLabel, false)
	setActive(self.urInput, false)

	self.ships = arg_28_1

	if #self.ships > 5 then
		setActive(self._tf:Find("window/content/ships"), true)
		setActive(self._tf:Find("window/content/ships_single"), false)

		local var_28_0 = self._tf:Find("window/content/ships/content"):GetComponent("LScrollRect")

		function var_28_0.onUpdateItem(arg_29_0, arg_29_1)
			updateShip(tf(arg_29_1), self.ships[arg_29_0 + 1])
		end

		onNextTick(function()
			var_28_0:SetTotalCount(#self.ships)
		end)
	else
		setActive(self._tf:Find("window/content/ships"), false)
		setActive(self._tf:Find("window/content/ships_single"), true)

		local var_28_1 = self._tf:Find("window/content/ships_single")
		local var_28_2 = UIItemList.New(var_28_1, var_28_1:Find("IconTpl"))

		var_28_2:make(function(arg_31_0, arg_31_1, arg_31_2)
			if arg_31_0 == UIItemList.EventUpdate then
				updateShip(arg_31_2, self.ships[arg_31_1 + 1])
			end
		end)
		var_28_2:align(#self.ships)
	end
end

function ShipDestoryConfirmWindow:Updatelayout()
	local var_32_0 = {}

	if #self.eliteShips > 0 then
		table.insert(var_32_0, i18n("destroy_high_rarity_tip"))
	end

	if #self.highLevelShips > 0 then
		table.insert(var_32_0, i18n("destroy_high_level_tip", ""))
	end

	setText(self.title, i18n("destroy_eliteship_tip", table.concat(var_32_0, "、")))

	local var_32_1 = _.any(self.eliteShips, function(arg_33_0)
		return arg_33_0:getConfig("rarity") >= ShipRarity.SSR
	end)

	if var_32_1 and not self.key then
		self.key = math.random(100000, 999999)

		setText(self.urLabel, i18n("destroy_ur_rarity_tip", self.key))
	end

	local var_32_2

	do
		setText(self.urLabel, "")

		var_32_2 = setActive
	end

	var_32_2(self.urOverflowLabel, var_32_1 and self.overflow)
	setActive(self.urLabel, var_32_1)
	setActive(self.urInput, var_32_1)
end

function ShipDestoryConfirmWindow:UpdateShips()
	local var_34_0 = table.mergeArray(self.highLevelShips, self.eliteShips)

	mergeSort(var_34_0, CompareFuncs({
		function(arg_35_0)
			return -arg_35_0.level
		end,
		function(arg_36_0)
			return -arg_36_0:getRarity()
		end
	}, true))

	self.ships = var_34_0

	if #self.ships > 5 then
		setActive(self._tf:Find("window/content/ships"), true)
		setActive(self._tf:Find("window/content/ships_single"), false)

		local var_34_1 = self._tf:Find("window/content/ships/content"):GetComponent("LScrollRect")

		function var_34_1.onUpdateItem(arg_37_0, arg_37_1)
			updateShip(tf(arg_37_1), self.ships[arg_37_0 + 1])
		end

		onNextTick(function()
			var_34_1:SetTotalCount(#self.ships)
		end)
	else
		setActive(self._tf:Find("window/content/ships"), false)
		setActive(self._tf:Find("window/content/ships_single"), true)

		local var_34_2 = self._tf:Find("window/content/ships_single")
		local var_34_3 = UIItemList.New(var_34_2, var_34_2:Find("IconTpl"))

		var_34_3:make(function(arg_39_0, arg_39_1, arg_39_2)
			if arg_39_0 == UIItemList.EventUpdate then
				updateShip(arg_39_2, self.ships[arg_39_1 + 1])
			end
		end)
		var_34_3:align(#self.ships)
	end
end

function ShipDestoryConfirmWindow:Hide()
	ShipDestoryConfirmWindow.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)

	self.key = nil
	self.callback = nil

	setInputText(self.urInput, "")
end

function ShipDestoryConfirmWindow:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end
end

return ShipDestoryConfirmWindow
