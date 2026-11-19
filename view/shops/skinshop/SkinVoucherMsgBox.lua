local SkinVoucherMsgBox = class("SkinVoucherMsgBox", import(".SkinCouponMsgBox"))
local var_0_1 = 0
local var_0_2 = 1
local var_0_3 = 1
local var_0_4 = 2

SkinVoucherMsgBox.OPTION_TYPE_COMMOM_ITEM = 1
SkinVoucherMsgBox.OPTION_TYPE_MESH_IMAGE = 2

function SkinVoucherMsgBox:getUIName()
	return "SkinVoucherMsgBoxUI"
end

function SkinVoucherMsgBox:OnLoaded()
	self.closeBtn = self._tf:Find("window/top/btnBack")
	self.cancelBtn = self._tf:Find("window/button_container/cancel")
	self.confirmBtn = self._tf:Find("window/button_container/confirm")
	self.label1 = self._tf:Find("window/frame/Text"):GetComponent(typeof(Text))
	self.leftItemTr = self._tf:Find("window/frame/left")
	self.nameTxt = self.leftItemTr:Find("name_bg/Text"):GetComponent(typeof(Text))

	setText(self.cancelBtn:Find("pic"), i18n("msgbox_text_cancel"))
	setText(self.confirmBtn:Find("pic"), i18n("msgbox_text_confirm"))
	setText(self._tf:Find("window/top/bg/infomation/title"), i18n("words_information"))
	setActive(self.confirmBtn, false)

	self.realPriceBtn = self._tf:Find("window/button_container/real_price")
	self.discountPriceBtn = self._tf:Find("window/button_container/discount_price")

	setText(self._tf:Find("window/top/bg/infomation/title"), i18n("title_info"))

	self.nonUseBtn = self._tf:Find("window/frame/option/nonuse")
	self.useBtn = self._tf:Find("window/frame/option/use")
	self.scrollrect = self._tf:Find("window/frame/scrollrect")
	self.optionTr = self._tf:Find("window/frame/option")
	self.switchBtn = self._tf:Find("window/frame/option/use/link")
	self.tipBar = self._tf:Find("window/frame/tipBar")
	self.tipText = self.tipBar:Find("Text")
	self.linkText = self._tf:Find("window/frame/option/use/link/Text"):GetComponent(typeof(Text))
	self.gemIcon = self._tf:Find("window/frame/option/use/link/line_1")

	setText(self._tf:Find("window/frame/option/nonuse/Text"), i18n("skin_shop_nonuse_label"))
end

function SkinVoucherMsgBox:RegisterBtn(arg_3_1)
	onButton(self, self.discountPriceBtn, function()
		if not self.prevSelId then
			return
		end

		if arg_3_1.onYes then
			arg_3_1.onYes(self.prevSelId)
		end

		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.realPriceBtn, function()
		if arg_3_1.onYes then
			arg_3_1.onYes()
		end

		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.switchBtn, function()
		self:UpdateStyle(1 - self.style)
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:UpdateStyle(1 - self.style)
		triggerToggle(self.useBtn, true)
	end, SFX_PANEL)
	onButton(self, self.cancelBtn, function()
		if self.style == var_0_2 then
			self:UpdateStyle(1 - self.style)
		else
			self:Hide()
		end
	end, SFX_PANEL)
	onToggle(self, self.nonUseBtn, function(arg_9_0)
		if arg_9_0 then
			self.prevSelId = nil

			self:UpdateContent(self.settings)
			self:UpdateStyle(self.style)
		end
	end, SFX_PANEL)
	onToggle(self, self.useBtn, function(arg_10_0)
		if arg_10_0 then
			self.prevSelId = self:GetDefaultItem()

			self:UpdateContent(self.settings)
			self:UpdateStyle(self.style)
		end
	end, SFX_PANEL)
end

function SkinVoucherMsgBox:GetDisplayListAndOptionType(arg_11_1)
	local var_11_0 = {}
	local var_11_1 = arg_11_1.itemList
	local var_11_2 = arg_11_1.meshImageItemList

	if #arg_11_1.itemList > 0 and #var_11_2 > 0 then
		assert(false, "use SkinVoucherMulOpMsgBox if you want to show both item and mesh image options")
	elseif #var_11_1 <= 0 and #var_11_2 <= 0 then
		assert(false, "no item or mesh image to display")
	end

	local var_11_3

	if #var_11_1 <= 0 then
		var_11_0 = var_11_2
		var_11_3 = var_0_4
	elseif #var_11_2 <= 0 then
		var_11_0 = var_11_1
		var_11_3 = var_0_3
	end

	return var_11_0, var_11_3
end

function SkinVoucherMsgBox:GetDefaultItem()
	self.selectedItemId = self.selectedItemId or (function()
		local var_13_0 = _.map(self.displays, function(arg_14_0)
			return {
				gem = self:GetDiscount(arg_14_0, self.settings.price),
				id = arg_14_0,
				time = pg.item_data_statistics[arg_14_0].time_limit
			}
		end)

		if #var_13_0 == 0 then
			return nil
		end

		table.sort(var_13_0, function(arg_15_0, arg_15_1)
			if arg_15_0.time ~= arg_15_1.time then
				return arg_15_0.time > arg_15_1.time
			else
				return arg_15_0.gem > arg_15_1.gem
			end
		end)

		return var_13_0[1].id
	end)()

	return self.selectedItemId
end

function SkinVoucherMsgBox:UpdateContent(arg_16_1)
	if self.prevSelId then
		local var_16_0 = math.max(0, arg_16_1.price - self:GetDiscount(self.prevSelId, arg_16_1.price))

		self.label1.text = i18n(var_16_0 > 0 and "skin_purchase_confirm" or "skin_purchase_over_price", pg.item_data_statistics[self.prevSelId].name, var_16_0, arg_16_1.skinName)
	else
		self.label1.text = i18n("charge_scene_buy_confirm", arg_16_1.price, arg_16_1.skinName)
	end

	self:UpdateLink()
	self:SetTipText(arg_16_1.skinId)
end

function SkinVoucherMsgBox:UpdateLink()
	setActive(self.gemIcon, self.optionType == var_0_3)

	if self.optionType == var_0_4 then
		self.linkText.text = i18n("exchange_op1")
	elseif self.optionType == var_0_3 then
		self.linkText.text = i18n("skin_shop_discount_item_link", (self:GetDiscount(self:GetDefaultItem(), self.settings.price)))
	end
end

function SkinVoucherMsgBox:GetDiscount(arg_18_1, arg_18_2)
	local var_18_0 = Item.New({
		id = arg_18_1
	})

	if var_18_0:IsMeshImageSkinExchangeType() then
		return arg_18_2 or 0
	else
		return var_18_0:getConfig("usage_arg")[2] or 0
	end
end

function SkinVoucherMsgBox:UpdateItem(arg_19_1)
	self.itemTrs = {}

	local var_19_0 = self.displays

	UIItemList.StaticAlign(self._tf:Find("window/frame/scrollrect/list"), self._tf:Find("window/frame/left"), #self.displays, function(arg_20_0, arg_20_1, arg_20_2)
		if arg_20_0 == UIItemList.EventUpdate then
			self:FlushItem(var_19_0[arg_20_1 + 1], arg_20_2)
		end
	end)
end

function SkinVoucherMsgBox:FlushItem(arg_21_1, arg_21_2)
	updateDrop(arg_21_2, {
		count = 1,
		type = DROP_TYPE_ITEM,
		id = arg_21_1
	})
	setText(arg_21_2:Find("name_bg/Text"), pg.item_data_statistics[arg_21_1].name)
	onToggle(self, arg_21_2, function(arg_22_0)
		if arg_22_0 then
			self.selectedItemId = arg_21_1
		end
	end, SFX_PANEL)

	self.itemTrs[arg_21_1] = arg_21_2
end

function SkinVoucherMsgBox:ClearPrevSel()
	self.prevSelId = nil
end

function SkinVoucherMsgBox:Show(arg_24_1)
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)
	setActive(self._tf, true)

	self.settings = arg_24_1
	self.displays, self.optionType = self:GetDisplayListAndOptionType(arg_24_1)

	self:UpdateItem(arg_24_1)
	self:RegisterBtn(arg_24_1)
	self:UpdateContent(arg_24_1)
	self:UpdateStyle(var_0_1)
	self:UpdateOptionName(arg_24_1)
	triggerToggle(self.useBtn, true)
end

function SkinVoucherMsgBox:UpdateOptionName(arg_25_1)
	if self.optionType == var_0_4 then
		setText(self._tf:Find("window/frame/option/use/Text"), i18n("exchange_op"))
	elseif self.optionType == var_0_3 then
		setText(self._tf:Find("window/frame/option/use/Text"), i18n("skin_shop_use_label"))
	end
end

function SkinVoucherMsgBox:UpdateStyle(arg_26_1)
	setActive(self.label1, arg_26_1 == var_0_1)
	setActive(self.optionTr, arg_26_1 == var_0_1)
	setActive(self.realPriceBtn, arg_26_1 == var_0_1 and not self.prevSelId)
	setActive(self.discountPriceBtn, arg_26_1 == var_0_1 and self.prevSelId)
	setActive(self.confirmBtn, arg_26_1 == var_0_2)
	setActive(self.scrollrect, arg_26_1 == var_0_2)
	triggerToggle(self.itemTrs[self:GetDefaultItem()], true)

	self.style = arg_26_1
end

function SkinVoucherMsgBox:Hide()
	self.settings = nil
	self.selectedItemId = nil

	setActive(self._tf, false)
	self:ClearPrevSel()

	for iter_27_0, iter_27_1 in pairs(self.itemTrs) do
		removeOnToggle(iter_27_1)
		triggerToggle(iter_27_1, false)
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function SkinVoucherMsgBox:SetTipText(arg_28_1)
	local var_28_0
	local var_28_1

	for iter_28_0, iter_28_1 in ipairs(pg.gameset.no_share_skin_tip.description) do
		for iter_28_2, iter_28_3 in ipairs(iter_28_1) do
			if pg.ship_skin_template[arg_28_1].ship_group == iter_28_3[1] then
				var_28_0 = iter_28_1
				var_28_1 = iter_28_2

				break
			end
		end
	end

	setActive(self.tipBar, var_28_1)

	if var_28_1 then
		local var_28_2 = ""

		for iter_28_4, iter_28_5 in ipairs(var_28_0) do
			if iter_28_4 ~= var_28_1 then
				var_28_2 = var_28_2 == "" and i18n(iter_28_5[2]) or var_28_2 .. "、" .. i18n(iter_28_5[2])
			end
		end

		setText(self.tipText, i18n("no_share_skin_gametip", i18n(var_28_0[var_28_1][2]), var_28_2))
	end
end

function SkinVoucherMsgBox:OnDestroy()
	self.super:OnDestroy()

	if self:isShowing() then
		self:Hide()
	end
end

return SkinVoucherMsgBox
