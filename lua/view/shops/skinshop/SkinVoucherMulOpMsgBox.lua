local SkinVoucherMulOpMsgBox = class("SkinVoucherMulOpMsgBox", import(".SkinVoucherMsgBox"))
local var_0_1 = SkinVoucherMsgBox.OPTION_TYPE_COMMOM_ITEM
local var_0_2 = SkinVoucherMsgBox.OPTION_TYPE_MESH_IMAGE

function SkinVoucherMulOpMsgBox:getUIName()
	return "SkinVoucherMulOpMsgBoxUI"
end

function SkinVoucherMulOpMsgBox:OnLoaded()
	SkinVoucherMulOpMsgBox.super.OnLoaded(self)

	local var_2_0 = self.optionTr:Find("meshImage_discount")
	local var_2_1 = {
		[var_0_1] = {
			toggle = self.useBtn,
			link = self.switchBtn,
			text = self.linkText,
			gemIcon = self.gemIcon
		}
	}
	local var_2_2 = {
		toggle = var_2_0,
		link = var_2_0:Find("link")
	}

	var_2_2.text = var_2_0:Find("link/Text"):GetComponent(typeof(Text))
	var_2_2.gemIcon = var_2_0:Find("link/line_1")
	var_2_1[var_0_2] = var_2_2
	self.options = var_2_1
end

function SkinVoucherMulOpMsgBox:GetDisplayListAndOptionType(arg_3_1)
	self.optionItemLists = {
		[var_0_1] = arg_3_1.itemList,
		[var_0_2] = arg_3_1.meshImageItemList
	}
	self.optionSelectedItemIds = {}
	self.selectedItemId = nil
	self.optionType = nil

	local var_3_0

	if #arg_3_1.itemList > 0 then
		var_3_0 = var_0_1 or var_0_2
	end

	assert(#self.optionItemLists[var_3_0] > 0, "no item or mesh image to display")
	self:SetOptionType(var_3_0)

	return self.optionItemLists[var_3_0], var_3_0
end

function SkinVoucherMulOpMsgBox:SetOptionType(arg_4_1)
	if self.optionType then
		self.optionSelectedItemIds[self.optionType] = self.selectedItemId
	end

	self.optionType = arg_4_1
	self.displays = self.optionItemLists[arg_4_1]
	self.selectedItemId = self.optionSelectedItemIds[arg_4_1]
	self.useBtn = self.options[arg_4_1].toggle
	self.switchBtn = self.options[arg_4_1].link
	self.linkText = self.options[arg_4_1].text
	self.gemIcon = self.options[arg_4_1].gemIcon
end

function SkinVoucherMulOpMsgBox:SelectOption(arg_5_1)
	self:SetOptionType(arg_5_1)
	self:UpdateItem(self.settings)

	self.prevSelId = self:GetDefaultItem()

	self:UpdateContent(self.settings)
	self:UpdateStyle(self.style)
end

function SkinVoucherMulOpMsgBox:RegisterBtn(arg_6_1)
	SkinVoucherMulOpMsgBox.super.RegisterBtn(self, arg_6_1)

	for iter_6_0, iter_6_1 in pairs(self.options) do
		onToggle(self, iter_6_1.toggle, function(arg_7_0)
			if arg_7_0 then
				self:SelectOption(iter_6_0)
			end
		end, SFX_PANEL)
		onButton(self, iter_6_1.link, function()
			triggerToggle(iter_6_1.toggle, true)
			self:UpdateStyle(1)
		end, SFX_PANEL)
	end

	onButton(self, self.confirmBtn, function()
		self.prevSelId = self:GetDefaultItem()

		self:UpdateContent(self.settings)
		self:UpdateStyle(0)
		triggerToggle(self.useBtn, true)
	end, SFX_PANEL)
end

function SkinVoucherMulOpMsgBox:UpdateItem(arg_10_1)
	for iter_10_0, iter_10_1 in pairs(self.itemTrs or {}) do
		removeOnToggle(iter_10_1)
		triggerToggle(iter_10_1, false)
	end

	SkinVoucherMulOpMsgBox.super.UpdateItem(self, arg_10_1)
end

function SkinVoucherMulOpMsgBox:UpdateOptionName(arg_11_1)
	local var_11_0 = self.options[var_0_1]
	local var_11_1 = self.options[var_0_2]

	setActive(self.options[var_0_1].toggle, #arg_11_1.itemList > 0)
	setActive(var_11_1.toggle, #arg_11_1.meshImageItemList > 0)
	setText(var_11_0.toggle:Find("Text"), i18n("skin_shop_use_label"))
	setText(var_11_1.toggle:Find("Text"), i18n("exchange_op"))

	var_11_1.text.text = i18n("exchange_op1")

	setActive(var_11_1.gemIcon, false)
end

function SkinVoucherMulOpMsgBox:Show(arg_12_1)
	for iter_12_0, iter_12_1 in pairs(self.options) do
		removeOnToggle(iter_12_1.toggle)
		triggerToggle(iter_12_1.toggle, false)
	end

	removeOnToggle(self.nonUseBtn)
	triggerToggle(self.nonUseBtn, false)

	self.prevSelId = nil

	SkinVoucherMulOpMsgBox.super.Show(self, arg_12_1)
end

return SkinVoucherMulOpMsgBox
