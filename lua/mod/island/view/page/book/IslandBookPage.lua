local IslandBookPage = class("IslandBookPage", import("...base.IslandBasePage"))

function IslandBookPage:getUIName()
	return "IslandBookUI"
end

function IslandBookPage:OnLoaded()
	setText(self._tf:Find("adapt/top/title/Text"), i18n("island_guide"))
	setText(self._tf:Find("adapt/top/title/Text/en"), i18n("island_guide_en"))

	self.charBtn = self._tf:Find("adapt/view/content/char")
	self.charTip = self.charBtn:Find("tip")
	self.npcBtn = self._tf:Find("adapt/view/content/npc")
	self.npcTip = self.npcBtn:Find("tip")
	self.itemBtn = self._tf:Find("adapt/view/content/item")
	self.itemTip = self.itemBtn:Find("tip")
	self.fishBtn = self._tf:Find("adapt/view/content/fish")
	self.fishTip = self.fishBtn:Find("tip")
end

function IslandBookPage:OnInit()
	onButton(self, self._tf:Find("adapt/top/back"), function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.charBtn, function()
		self:OpenPage(IslandBookCharPage)
	end, SFX_PANEL)
	onButton(self, self.npcBtn, function()
		self:OpenPage(IslandBookNpcPage)
	end, SFX_PANEL)
	onButton(self, self.itemBtn, function()
		self:OpenPage(IslandBookItemPage)
	end, SFX_PANEL)
	onButton(self, self.fishBtn, function()
		self:OpenPage(IslandBookFishPage)
	end, SFX_PANEL)
end

function IslandBookPage:AddListeners()
	self:AddListener(GAME.ISLAND_UNLOCK_ILLUSTRATION_DONE, self.FlushTips)
	self:AddListener(GAME.ISLAND_GET_COLLECT_POINT_DONE, self.FlushTips)
	self:AddListener(GAME.ISLAND_GET_POINT_AWARD_DONE, self.FlushTips)
end

function IslandBookPage:RemoveListeners()
	self:RemoveListener(GAME.ISLAND_UNLOCK_ILLUSTRATION_DONE, self.FlushTips)
	self:RemoveListener(GAME.ISLAND_GET_COLLECT_POINT_DONE, self.FlushTips)
	self:RemoveListener(GAME.ISLAND_GET_POINT_AWARD_DONE, self.FlushTips)
end

function IslandBookPage:OnShow()
	self:FlushTips()
end

function IslandBookPage:FlushTips()
	setActive(self.fishBtn, IslandMainBtnTipHelper.IsUnlock("book_fish"))

	self.bookAgency = getProxy(IslandProxy):GetIsland():GetBookAgency()

	setActive(self.charTip, self.bookAgency:IsTipFromTypes({
		IslandIllustration.TYPES.CHAR
	}))
	setActive(self.npcTip, self.bookAgency:IsTipFromTypes({
		IslandIllustration.TYPES.NPC
	}))
	setActive(self.itemTip, self.bookAgency:IsTipFromTypes({
		IslandIllustration.TYPES.ITEM
	}))
	setActive(self.fishTip, self.bookAgency:IsTipFromTypes({
		IslandIllustration.TYPES.FISH
	}))
end

return IslandBookPage
