local ShipFashionView = class("ShipFashionView", import("...base.BaseSubView"))

function ShipFashionView:getUIName()
	return "ShipFashionView"
end

function ShipFashionView:getFashionResList(arg_2_1)
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in ipairs((self.isShareSkinFlag or nil) and (self:GetShareSkins(arg_2_1) or self.shareData:GetGroupSkinList(arg_2_1.groupId))) do
		table.insertto(var_2_0, ResPathSupport.GetPaintingListByPaintingName(iter_2_1.painting))
	end

	return var_2_0
end

function ShipFashionView:OnInit()
	self:InitFashion()
end

function ShipFashionView:InitFashion()
	self.mainPanel = self._parentTf.parent
	self.stylePanel = self._tf
	self.styleScroll = self.stylePanel:Find("style_scroll")
	self.styleContainer = self.styleScroll:Find("view_port")
	self.styleCard = self.styleContainer:GetChild(0)
	self.hideObjToggleTF = findTF(self._tf, "btns/hideObjToggle")

	setActive(self.hideObjToggleTF, false)

	self.hideObjToggle = GetComponent(self.hideObjToggleTF, typeof(Toggle))

	setText(findTF(self.hideObjToggleTF, "Label"), i18n("paint_hide_other_obj_tip"))

	self.shareBtn = findTF(self._tf, "share_btn")
	self.phantomBtn = self._tf:Find("phantom_btn")

	onButton(self, self.phantomBtn, function()
		local var_5_0 = getProxy(TechnologyProxy):getBluePrintById(self:GetShipVO().groupId)

		self:emit(ShipMainMediator.OPEN_PHANTOM_LAYER, var_5_0 and var_5_0:getConfig("blueprint_version") or nil)
	end, SFX_PANEL)
	setParent(self.phantomBtn, self._tf.parent)
	setActive(self.stylePanel, true)
	setActive(self.styleCard, false)

	self.fashionSkins = {}
	self.fashionCellMap = {}
	self.fashionGroup = 0
	self.fashionSkinId = 0
	self.onSelected = false
	self.isShareSkinFlag = false

	self:RegisterShareToggle()
	self:bind(ShipMainMediator.ON_NEXTSHIP_PREPARE, function(arg_6_0, arg_6_1)
		self._lastSelectCard = nil

		if self.isShareSkinFlag and arg_6_1 and #self:GetShareSkins(arg_6_1) <= 0 then
			self.isShareSkinFlag = false
		end
	end)
end

function ShipFashionView:SetShareData(arg_7_1)
	self.shareData = arg_7_1
end

function ShipFashionView:GetShipVO()
	if self.shareData and self.shareData.shipVO then
		return self.shareData.shipVO
	end

	return nil
end

function ShipFashionView:SetSkinList(arg_9_1)
	self.skinList = arg_9_1
end

function ShipFashionView:UpdateUI()
	triggerToggle(self.shareBtn, self.isShareSkinFlag)
	setActive(self.shareBtn, #self:GetShareSkins(self:GetShipVO()) > 0)
	setActive(self.phantomBtn, self:GetShipVO():isBluePrintShip())
end

function ShipFashionView:OnSelected(arg_11_1)
	if arg_11_1 then
		self:OverlayPanel(self._parentTf, {
			pbList = {
				self.stylePanel:Find("style_desc"),
				self.stylePanel:Find("frame")
			},
			overlayType = LayerWeightConst.OVERLAY_UI_ADAPT
		})
	else
		self:UnOverlayPanel(self._parentTf, self.mainPanel)
	end

	self.onSelected = arg_11_1
end

function ShipFashionView:GetShareSkins(arg_12_1)
	return (_.map(getProxy(ShipSkinProxy):GetShareSkinsForShip(arg_12_1), function(arg_13_0)
		return pg.ship_skin_template[arg_13_0.id]
	end))
end

function ShipFashionView:UpdateAllFashion(arg_14_1)
	SplitPackConst.DownloadByLuaArr(self:getFashionResList((self:GetShipVO())), function()
		if self.exited then
			return
		end

		self:updateAllFashion(arg_14_1)
	end)
end

function ShipFashionView:updateAllFashion(arg_16_1)
	local var_16_0 = self:GetShipVO()
	local var_16_1 = var_16_0.groupId

	if self.isShareSkinFlag then
		self.fashionSkins = self:GetShareSkins(var_16_0) or self.shareData:GetGroupSkinList(var_16_1)
	end

	if self.fashionGroup ~= var_16_1 or arg_16_1 then
		self.fashionGroup = var_16_1

		self:ResetFashion()

		for iter_16_0 = self.styleContainer.childCount, #self.fashionSkins - 1 do
			cloneTplTo(self.styleCard, self.styleContainer)
		end

		for iter_16_1 = #self.fashionSkins, self.styleContainer.childCount - 1 do
			local var_16_2 = self.styleContainer:GetChild(iter_16_1)

			if self.fashionCellMap[var_16_2] then
				self.fashionCellMap[var_16_2]:clear()
			end

			setActive(var_16_2, false)
		end

		for iter_16_2, iter_16_3 in ipairs(self.fashionSkins) do
			local var_16_3 = iter_16_2
			local var_16_4 = self.fashionSkins[iter_16_2]
			local var_16_5 = self.styleContainer:GetChild(iter_16_2 - 1)
			local var_16_6 = self.fashionCellMap[var_16_5]

			if not self.fashionCellMap[var_16_5] then
				var_16_6 = ShipSkinCard.New(var_16_5.gameObject)
				self.fashionCellMap[var_16_5] = var_16_6
			end

			local var_16_7 = self:GetShipVO():getRemouldSkinId() == var_16_4.id and self:GetShipVO():isRemoulded()
			local var_16_8 = self:GetShipVO():proposeSkinOwned(var_16_4)

			if not var_16_8 then
				var_16_8 = table.contains(self.skinList, var_16_4.id)
				var_16_8 = var_16_8 or var_16_7 or var_16_4.skin_type == ShipSkin.SKIN_TYPE_OLD or getProxy(ShipSkinProxy):hasSkin(var_16_4.id)
			end

			var_16_6:updateData(self:GetShipVO(), var_16_4, var_16_8)

			local var_16_9 = self:GetShipVO():useSkin(var_16_4.id)

			var_16_6:updateUsing(var_16_9)
			onButton(self, var_16_6.changeSkinTF, function(arg_17_0)
				if var_16_9 then
					ShipSkin.SetStoreChangeSkinId(ShipSkin.GetChangeSkinNextId(var_16_4.id), var_16_0:GetShipPhantomMark())
					pg.m02:sendNotification(GAME.CHANGE_SKIN_UPDATE, self:GetShipVO():GetShipPhantomMark())
				end
			end, SFX_PANEL)
			onButton(self, var_16_5, function()
				self:clickCell(var_16_6, var_16_4)

				self._lastSelectCard = var_16_3
			end)
			setActive(var_16_5, true)
		end
	else
		for iter_16_4, iter_16_5 in ipairs(self.fashionSkins) do
			local var_16_10 = self.fashionCellMap[self.styleContainer:GetChild(iter_16_4 - 1)]
			local var_16_11 = self:GetShipVO():getRemouldSkinId() == iter_16_5.id and self:GetShipVO():isRemoulded()
			local var_16_12 = self:GetShipVO():proposeSkinOwned(iter_16_5)

			if not var_16_12 then
				var_16_12 = table.contains(self.skinList, iter_16_5.id)
				var_16_12 = var_16_12 or var_16_11 or iter_16_5.skin_type == ShipSkin.SKIN_TYPE_OLD or getProxy(ShipSkinProxy):hasSkin(iter_16_5.id)
			end

			var_16_10:updateData(self:GetShipVO(), iter_16_5, var_16_12)
		end
	end

	self.fashionSkinId = self:GetShipVO():getSkinId()

	local var_16_13 = self.styleContainer:GetChild(0)

	for iter_16_6, iter_16_7 in ipairs(self.fashionSkins) do
		if iter_16_7.id == self.fashionSkinId then
			var_16_13 = self.styleContainer:GetChild(iter_16_6 - 1)

			break
		end
	end

	if self._lastSelectCard then
		var_16_13 = self.styleContainer:GetChild(self._lastSelectCard - 1)
		self._lastSelectCard = nil
	end

	triggerButton(var_16_13)
end

function ShipFashionView:clickCell(arg_19_1, arg_19_2)
	if ShipViewConst.currentPage ~= ShipViewConst.PAGE.FASHION then
		return
	end

	self.clickCellTime = Time.realtimeSinceStartup
	self.fashionSkinId = arg_19_2.id

	self:UpdateFashionDetail(arg_19_2)
	self:emit(ShipViewConst.LOAD_PAINTING, arg_19_2.painting)
	self:emit(ShipViewConst.LOAD_PAINTING_BG, self:GetShipVO():rarity2bgPrintForGet(), self:GetShipVO():isBluePrintShip(), self:GetShipVO():isMetaShip())

	for iter_19_0, iter_19_1 in ipairs(self.fashionSkins) do
		local var_19_0 = self.fashionCellMap[self.styleContainer:GetChild(iter_19_0 - 1)]

		var_19_0:updateSelected(iter_19_1.id == self.fashionSkinId)
		var_19_0:updateUsing(self:GetShipVO():useSkin(iter_19_1.id))
	end

	local var_19_1 = arg_19_2.painting
	local var_19_2 = checkABExist("painting/" .. arg_19_2.painting .. "_n")

	setActive(self.hideObjToggle, var_19_2)

	if var_19_2 then
		self.hideObjToggle.isOn = PlayerPrefs.GetInt("paint_hide_other_obj_" .. var_19_1, 0) ~= 0

		onToggle(self, self.hideObjToggleTF, function(arg_20_0)
			PlayerPrefs.SetInt("paint_hide_other_obj_" .. var_19_1, arg_20_0 and 1 or 0)
			arg_19_1:flushSkin()
			self:emit(ShipViewConst.LOAD_PAINTING, var_19_1, true)
		end, SFX_PANEL)
	end
end

function ShipFashionView:UpdateFashion(arg_21_1)
	if ShipViewConst.currentPage ~= ShipViewConst.PAGE.FASHION or not self.shareData:HasFashion() then
		return
	end

	self:UpdateAllFashion(arg_21_1)
end

function ShipFashionView:ResetFashion()
	self.fashionSkinId = 0
end

function ShipFashionView:UpdateFashionDetail(arg_23_1)
	local var_23_0 = self.fashionDetailWrapper

	if not self.fashionDetailWrapper then
		var_23_0 = {
			name = findTF(self.stylePanel, "style_desc/name_bg/name"),
			descTxt = findTF(self.stylePanel, "style_desc/desc_frame/desc/Text"),
			character = findTF(self.stylePanel, "style_desc/character"),
			confirm = findTF(self.stylePanel, "confirm_button"),
			cancel = findTF(self.stylePanel, "cancel_button")
		}
		var_23_0.diamond = findTF(var_23_0.confirm, "diamond")
		var_23_0.using = findTF(var_23_0.confirm, "using")
		var_23_0.experience = findTF(var_23_0.confirm, "experience")
		var_23_0.change = findTF(var_23_0.confirm, "change")
		var_23_0.buy = findTF(var_23_0.confirm, "buy")
		var_23_0.activity = findTF(var_23_0.confirm, "activity")
		var_23_0.cantbuy = findTF(var_23_0.confirm, "cantbuy")
		var_23_0.prefab = "unknown"
		self.fashionDetailWrapper = var_23_0
	end

	setText(var_23_0.name, arg_23_1.name)
	setText(var_23_0.descTxt, SwitchSpecialChar(arg_23_1.desc, true))

	local var_23_1 = var_23_0.descTxt:GetComponent(typeof(Text))

	var_23_1.alignment = #var_23_1.text > 50 and TextAnchor.MiddleLeft or TextAnchor.MiddleCenter

	if var_23_0.prefab ~= arg_23_1.prefab then
		local var_23_2 = var_23_0.character:Find(var_23_0.prefab)

		if not IsNil(var_23_2) then
			PoolMgr.GetInstance():ReturnSpineChar(var_23_0.prefab, var_23_2.gameObject)
		end

		var_23_0.prefab = arg_23_1.prefab

		local var_23_3 = var_23_0.prefab

		self.spineChar = SpineAnimChar.New()

		self.spineChar:SetPaint(var_23_0.prefab)
		self.spineChar:Load(true, function(arg_24_0)
			if var_23_0.prefab ~= var_23_3 then
				arg_24_0:Dispose()
			else
				arg_24_0:SetName(var_23_3)
				arg_24_0:SetLocalPosition(Vector3.zero)
				arg_24_0:SetLocalScale(Vector3(0.5, 0.5, 1))
				arg_24_0:SetParent(var_23_0.character)
				arg_24_0:SetAction(arg_23_1.show_skin or "stand", 0)
			end
		end)
	end

	local var_23_5 = (self:GetShipVO():proposeSkinOwned(arg_23_1) or table.contains(self.skinList, arg_23_1.id) or self:GetShipVO():getRemouldSkinId() == arg_23_1.id and self:GetShipVO():isRemoulded()) and 1 or 0
	local var_23_6 = arg_23_1.shop_id > 0 and ShopConst.GetShopConfig(arg_23_1.shop_id) or nil
	local var_23_7

	if var_23_6 then
		::label_23_0::

		var_23_7 = not pg.TimeMgr.GetInstance():inTime(var_23_6.time)
	end

	local var_23_8 = arg_23_1.id == self:GetShipVO():getSkinId()
	local var_23_9 = arg_23_1.id == self:GetShipVO():getConfig("skin_id") or var_23_5 >= 1 or arg_23_1.skin_type == ShipSkin.SKIN_TYPE_OLD or getProxy(ShipSkinProxy):hasSkin(arg_23_1.id)
	local var_23_10 = getProxy(ShipSkinProxy):getSkinById(arg_23_1.id)
	local var_23_11 = getProxy(ShipSkinProxy):InForbiddenSkinListAndShow(arg_23_1.id)
	local var_23_12 = var_23_8 and var_23_10 and var_23_10:isExpireType()

	setActive(var_23_0.using, false)
	setActive(var_23_0.change, false)
	setActive(var_23_0.buy, false)
	setActive(var_23_0.experience, false)

	if var_23_12 then
		setGray(var_23_0.confirm, false)
		setActive(var_23_0.experience, true)
	elseif var_23_8 then
		setGray(var_23_0.confirm, false)
		setActive(var_23_0.using, true)
	elseif var_23_9 and ShipSkin.IsShareSkin(self:GetShipVO(), arg_23_1.id) and not ShipSkin.CanUseShareSkinForShip(self:GetShipVO(), arg_23_1.id) then
		setActive(var_23_0.change, true)
		setGray(var_23_0.confirm, true)
	elseif var_23_9 then
		setActive(var_23_0.change, true)
		setGray(var_23_0.confirm, false)
	elseif var_23_6 then
		setActive(var_23_0.buy, true)
		setGray(var_23_0.confirm, var_23_7 or var_23_11)
	else
		setActive(var_23_0.change, true)
		setGray(var_23_0.confirm, true)
	end

	onButton(self, var_23_0.confirm, function()
		if var_23_8 then
			if ShipSkin.IsChangeSkin(arg_23_1.id) then
				if self.clickCellTime and Time.realtimeSinceStartup - self.clickCellTime <= 0.35 then
					return
				end

				self:SilentTriggerToggleFalse()
				self:emit(ShipViewConst.SWITCH_TO_PAGE, ShipViewConst.PAGE.DETAIL)
			end
		elseif var_23_9 then
			if ShipSkin.IsShareSkin(self:GetShipVO(), arg_23_1.id) and not ShipSkin.CanUseShareSkinForShip(self:GetShipVO(), arg_23_1.id) then
				-- block empty
			else
				self:emit(ShipMainMediator.CHANGE_SKIN, self:GetShipVO().id, arg_23_1.id == self:GetShipVO():getConfig("skin_id") and 0 or arg_23_1.id)
			end
		elseif var_23_6 then
			if var_23_7 or var_23_11 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_skin_out_of_stock"))
			else
				local var_25_0 = Goods.Create({
					shop_id = var_23_6.id
				}, Goods.TYPE_SKIN)

				if var_25_0:isDisCount() and var_25_0:IsItemDiscountType() then
					self:emit(ShipMainMediator.BUY_ITEM_BY_ACT, var_23_6.id, 1)
				else
					local var_25_1 = {}

					var_25_1.content = i18n("text_buy_fashion_tip", var_25_0:GetPrice(), arg_23_1.name)

					function var_25_1.onYes()
						self:emit(ShipMainMediator.BUY_ITEM, var_23_6.id, 1)
					end

					pg.MsgboxMgr.GetInstance():ShowMsgBox(var_25_1)
				end
			end
		end
	end)
	onButton(self, var_23_0.cancel, function()
		if self.clickCellTime and Time.realtimeSinceStartup - self.clickCellTime <= 0.35 then
			return
		end

		self:SilentTriggerToggleFalse()
		self:emit(ShipViewConst.SWITCH_TO_PAGE, ShipViewConst.PAGE.DETAIL)
	end)
end

function ShipFashionView:SilentTriggerToggleFalse()
	self.fashionGroup = false
	self.isShareSkinFlag = false

	removeOnToggle(self.shareBtn)
	triggerToggle(self.shareBtn, false)
	self:RegisterShareToggle()
end

function ShipFashionView:RegisterShareToggle()
	onToggle(self, self.shareBtn, function(arg_30_0)
		self.fashionGroup = false
		self.isShareSkinFlag = arg_30_0

		self:UpdateFashion()
	end, SFX_PANEL)
end

function ShipFashionView:OnDestroy()
	setParent(self.phantomBtn, self._tf)

	if self.fashionDetailWrapper and self.fashionDetailWrapper.character:Find(self.fashionDetailWrapper.prefab) and self.spineChar then
		self.spineChar:Dispose()

		self.spineChar = nil
	end

	self.fashionDetailWrapper = nil

	for iter_31_0, iter_31_1 in pairs(self.fashionCellMap) do
		iter_31_1:clear()
	end

	self.fashionCellMap = {}
	self.fashionSkins = {}
	self.fashionGroup = 0
	self.fashionSkinId = 0
	self.shareData = nil
end

return ShipFashionView
