local ShipDestroyPage = class("ShipDestroyPage", import("...base.BaseSubView"))

function ShipDestroyPage:getUIName()
	return "DestoryInfoUI"
end

function ShipDestroyPage:getResource()
	return table.insertto({
		"energy",
		"shipstatus",
		"shipframe",
		"shiptype",
		"ui/proposeshipcard",
		"ui/heartshipcard",
		"shipyardicon/unknown",
		"ui/iconcolorful"
	}, ShipDestroyPage.super.getResource(self))
end

function ShipDestroyPage:getRefreshResList(arg_3_1, arg_3_2)
	local var_3_0 = {}

	for iter_3_0, iter_3_1 in ipairs(arg_3_1 or {}) do
		if arg_3_2[iter_3_1] then
			self:insertDockyardShipItemRes(var_3_0, arg_3_2[iter_3_1])
		end
	end

	local var_3_1, var_3_2, var_3_3 = ShipDestroyPage.CalcShipsReturnRes(arg_3_1, arg_3_2)

	table.insert(var_3_3, 1, Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResOil,
		count = var_3_2
	}))
	table.insert(var_3_3, 1, Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResGold,
		count = var_3_1
	}))
	_.each(var_3_3, function(arg_4_0)
		if arg_4_0.count > 0 then
			table.insert(var_3_0, arg_4_0:getIcon())
		end
	end)

	return var_3_0
end

function ShipDestroyPage:insertDockyardShipItemRes(arg_5_1, arg_5_2)
	table.insert(arg_5_1, (string.format(ResPathSupport.ConstPath.BG.ShipCard, arg_5_2:rarity2bgPrint())))
	table.insertto(arg_5_1, (ResPathSupport.GetPaintingShipYardIconListByPaintingName(arg_5_2:getPainting())))

	local var_5_0, var_5_1 = arg_5_2:GetFrameAndEffect()

	table.insert(arg_5_1, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_5_1)))
end

function ShipDestroyPage:OnLoaded()
	self.cardScrollRect = self._tf:Find("frame/sliders/content"):GetComponent("LScrollRect")

	function self.cardScrollRect.onInitItem(arg_7_0)
		return
	end

	function self.cardScrollRect.onUpdateItem(arg_8_0, arg_8_1)
		local var_8_0 = DockyardShipItem.New(arg_8_1, ShipStatus.TAG_HIDE_DESTROY)

		var_8_0:update(self.shipVOs[self.shipIds[arg_8_0 + 1]])
		onButton(self, var_8_0.tr, function()
			existCall(self.OnCardClick, var_8_0)
			self:DisplayShipList()
		end, SFX_PANEL)
	end

	function self.cardScrollRect.onReturnItem(arg_10_0, arg_10_1)
		removeOnButton(arg_10_1)
	end

	self.cancelBtn = self._tf:Find("frame/cancel_button")
	self.backBtn = self._tf:Find("frame/top/btnBack")
	self.confirmBtn = self._tf:Find("frame/confirm_button")

	setText(self._tf:Find("frame/bg_award/label"), i18n("disassemble_available") .. ":")

	local var_6_0 = self._tf:Find("frame/bg_award/res_list")

	self.resList = UIItemList.New(var_6_0, var_6_0:Find("res"))

	self.resList:make(function(arg_11_0, arg_11_1, arg_11_2)
		arg_11_1 = arg_11_1 + 1

		if arg_11_0 == UIItemList.EventUpdate then
			GetImageSpriteFromAtlasAsync(self.showList[arg_11_1]:getIcon(), "", arg_11_2:Find("icon"))
			setText(arg_11_2:Find("Text"), "X" .. self.showList[arg_11_1].count)
		end
	end)
end

function ShipDestroyPage:OnInit()
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self.backBtn, function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self.confirmBtn, function()
		if self.OnConfirm then
			self.OnConfirm()
		end
	end, SFX_PANEL)
end

function ShipDestroyPage:SetConfirmCallBack(arg_16_1)
	self.OnConfirm = arg_16_1
end

function ShipDestroyPage:SetCardClickCallBack(arg_17_1)
	self.OnCardClick = arg_17_1
end

function ShipDestroyPage:Refresh(arg_18_1, arg_18_2)
	self.shipIds = arg_18_1
	self.shipVOs = arg_18_2

	SplitPackConst.DownloadByLuaArr(self:getRefreshResList(arg_18_1, arg_18_2), function()
		if self._state == ShipDestroyPage.STATES.DESTROY then
			return
		end

		self:DisplayShipList()
		self:RefreshRes()
		self:Show()
	end)
end

function ShipDestroyPage:DisplayShipList()
	self.cardScrollRect:SetTotalCount(#self.shipIds)

	if #self.shipIds == 0 then
		self:Hide()
	end
end

function ShipDestroyPage:CalcShipsReturnRes(arg_21_1)
	return ShipCalcHelper.CalcDestoryRes((_.map(self, function(arg_22_0)
		return arg_21_1[arg_22_0]
	end)))
end

function ShipDestroyPage:RefreshRes()
	local var_23_0, var_23_1, var_23_2 = ShipDestroyPage.CalcShipsReturnRes(self.shipIds, self.shipVOs)

	table.insert(var_23_2, 1, Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResOil,
		count = var_23_1
	}))
	table.insert(var_23_2, 1, Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResGold,
		count = var_23_0
	}))

	self.showList = underscore.filter(var_23_2, function(arg_24_0)
		return arg_24_0.count > 0
	end)

	self.resList:align(#self.showList)
end

function ShipDestroyPage:Show()
	ShipDestroyPage.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function ShipDestroyPage:Hide()
	ShipDestroyPage.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function ShipDestroyPage:OnDestroy()
	self.OnCardClick = nil

	ClearLScrollrect(self.cardScrollRect)
	self:Hide()
end

return ShipDestroyPage
