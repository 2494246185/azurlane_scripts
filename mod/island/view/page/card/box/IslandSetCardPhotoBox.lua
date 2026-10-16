local IslandSetCardPhotoBox = class("IslandSetCardPhotoBox", import("view.base.BaseSubView"))

function IslandSetCardPhotoBox:getUIName()
	return "IslandSetCardPhotoBox"
end

function IslandSetCardPhotoBox:OnLoaded()
	setText(self._tf:Find("frame/title"), i18n("island_card_choose_photo"))

	self.closeBtn = self._tf:Find("frame/close")
	self.cancelBtn = self._tf:Find("cancel")

	setText(self.cancelBtn:Find("Text"), i18n("word_cancel"))

	self.confirmBtn = self._tf:Find("confirm")

	setText(self.confirmBtn:Find("Text"), i18n("word_ok"))

	self.scrollRect = self._tf:Find("scrollrect"):GetComponent("LScrollRect")

	function self.scrollRect.onInitItem(arg_3_0)
		self:OnInitItem(arg_3_0)
	end

	function self.scrollRect.onUpdateItem(arg_4_0, arg_4_1)
		self:OnUpdateItem(arg_4_0, arg_4_1)
	end
end

function IslandSetCardPhotoBox:OnInit()
	onButton(self, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:emit(IslandSelfCardMediator.SET_CARD_PHOTO, self.selectedId)
	end, SFX_PANEL)

	self.cards = {}
end

function IslandSetCardPhotoBox:OnInitItem(arg_9_1)
	self.cards[arg_9_1] = IslandCardPhotoCard.New(arg_9_1)
end

function IslandSetCardPhotoBox:OnUpdateItem(arg_10_1, arg_10_2)
	local var_10_0 = self.cards[arg_10_2]

	if not self.cards[arg_10_2] then
		self:OnInitItem(arg_10_2)

		var_10_0 = self.cards[arg_10_2]
	end

	local var_10_1 = self.ids[arg_10_1 + 1]

	if self.ids[arg_10_1 + 1] then
		var_10_0:Update(var_10_1, self.selectedId)
	end

	onButton(self, var_10_0._go, function()
		for iter_11_0, iter_11_1 in pairs(self.cards) do
			iter_11_1:UpdateSelected(nil)
		end

		self.selectedId = var_10_1

		var_10_0:UpdateSelected(self.selectedId)
	end, SFX_PANEL)
end

function IslandSetCardPhotoBox:Show(arg_12_1, arg_12_2)
	IslandSetCardPhotoBox.super.Show(self)

	self.ids = arg_12_1

	table.sort(self.ids)

	self.selectedId = arg_12_2

	self.scrollRect:SetTotalCount(#self.ids, -1)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function IslandSetCardPhotoBox:Hide()
	IslandSetCardPhotoBox.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function IslandSetCardPhotoBox:OnDestroy()
	ClearLScrollrect(self.scrollRect)

	for iter_14_0, iter_14_1 in pairs(self.cards) do
		iter_14_1:Dispose()
	end

	self.cards = {}

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

return IslandSetCardPhotoBox
