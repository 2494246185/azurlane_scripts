local IslandMainBaseBtn = class("IslandMainBaseBtn")

function IslandMainBaseBtn:Ctor(arg_1_1, arg_1_2, arg_1_3)
	pg.DelegateInfo.New(self)

	self._tf = arg_1_1
	self.event = arg_1_2
	self.configId = arg_1_3
	self.config = pg.island_main_btns[self.configId]
	self.iconTF = self._tf
	self.tipTF = self._tf:Find("tip")

	self:Init()
end

function IslandMainBaseBtn:SetAsLastSibling()
	self._tf:SetAsLastSibling()
end

function IslandMainBaseBtn:Init()
	LoadImageSpriteAtlasAsync("island/islandbtnicon", self.config.icon, self.iconTF, true)

	self._tf.name = self.config.btn_name

	onButton(self, self._tf, function()
		self:OnClick()
	end, SFX_PANEL)
end

function IslandMainBaseBtn:GetAbilityId()
	return self.config.ability_id
end

function IslandMainBaseBtn:OnClick()
	if self.config.open_page ~= "" then
		self:emit(IslandMediator.OPEN_PAGE, self.config.open_page, self.config.page_param)
	end
end

function IslandMainBaseBtn:Flush()
	self:UnlockCheck()
	self:TipCheck()
end

function IslandMainBaseBtn:UnlockCheck()
	setActive(self._tf, self:IsUnlock())
end

function IslandMainBaseBtn:IsUnlock()
	return getProxy(IslandProxy):GetIsland():GetAblityAgency():HasAbility(self:GetAbilityId())
end

function IslandMainBaseBtn:TipCheck()
	setActive(self.tipTF, self:IsUnlock() and self:IsTip())
end

function IslandMainBaseBtn:IsTip()
	return IslandMainBtnTipHelper.IsTip(self.config.btn_name)
end

function IslandMainBaseBtn:emit(...)
	self.event:emit(...)
end

function IslandMainBaseBtn:Dispose()
	pg.DelegateInfo.Dispose(self)
end

return IslandMainBaseBtn
