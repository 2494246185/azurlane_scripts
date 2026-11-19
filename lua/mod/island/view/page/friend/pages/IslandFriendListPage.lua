local IslandFriendListPage = class("IslandFriendListPage", import("view.base.BaseSubView"))

function IslandFriendListPage:getUIName()
	return "IslandFriendListUI"
end

function IslandFriendListPage:OnLoaded()
	self.morePanel = self._tf:Find("scrollrect/content/more_panel")
	self.whiteBtn = self.morePanel:Find("white")
	self.blackBtn = self.morePanel:Find("black")
	self.delBtn = self.morePanel:Find("del")
	self.cards = {}
	self._scrollrect = self._tf:Find("scrollrect"):GetComponent("LScrollRect")

	function self._scrollrect.onInitItem(arg_3_0)
		self:OnInitItem(arg_3_0)
	end

	function self._scrollrect.onUpdateItem(arg_4_0, arg_4_1)
		self:OnUpdateItem(arg_4_0, arg_4_1)
	end

	setText(self.morePanel:Find("white/Text"), i18n("island_whiteList"))
	setText(self.morePanel:Find("black/Text"), i18n("island_blackList"))

	if self.delBtn then
		setText(self.morePanel:Find("del/Text"), i18n("island_btn_label_del"))
	end
end

function IslandFriendListPage:CreateCard(arg_5_1)
	return IslandFriendCard.New(arg_5_1)
end

function IslandFriendListPage:OnInitItem(arg_6_1)
	local var_6_0 = self:CreateCard(arg_6_1)

	onButton(self, var_6_0.visitBtn, function()
		pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildIslandVisit(playerId))
		self:emit(IslandMediator.ENTER_ISLAND, var_6_0.player.id)
	end, SFX_PANEL)
	onButton(self, var_6_0.moreBtn, function()
		if self.isOpenMore then
			self:CloseMorePanel()
		else
			self:OpenMorePanel(var_6_0.player, (var_6_0.moreBtn.parent.parent:InverseTransformPoint(var_6_0.moreBtn.position)))
		end
	end, SFX_PANEL)
	onButton(self, var_6_0.cardBtn, function()
		self:emit(IslandMediator.OPEN_PAGE, "IslandOtherCardPage", {
			var_6_0.player.id
		})
	end, SFX_PANEL)

	self.cards[arg_6_1] = var_6_0
end

function IslandFriendListPage:OpenMorePanel(arg_10_1, arg_10_2)
	self.isOpenMore = true

	setActive(self.morePanel, true)
	self.morePanel:SetAsLastSibling()

	self.morePanel.localPosition = arg_10_2 - Vector3(110, 0, 0)
	self.whiteBtn = self.morePanel:Find("white")
	self.blackBtn = self.morePanel:Find("black")
	self.delBtn = self.morePanel:Find("del")

	self:InitMoreBtns(arg_10_1)
end

function IslandFriendListPage:InitMoreBtns(arg_11_1)
	onButton(self, self.whiteBtn, function()
		self:emit(IslandMediator.ADD_WHITE_LIST, arg_11_1.id)
	end, SFX_PANEL)
	onButton(self, self.blackBtn, function()
		self:emit(IslandMediator.ADD_BLACK_LIST, arg_11_1.id)
	end, SFX_PANEL)
	onButton(self, self.delBtn, function()
		pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_COMMON_MSGBOX, {
			contentText = i18n("remove_friend_tip"),
			onConfirm = function()
				self:emit(IslandMediator.REMOVE_FRIEND, arg_11_1.id)
			end
		})
	end, SFX_PANEL)
end

function IslandFriendListPage:CloseMorePanel()
	self.isOpenMore = false

	setActive(self.morePanel, false)
end

function IslandFriendListPage:OnUpdateItem(arg_17_1, arg_17_2)
	if not self.cards[arg_17_2] then
		self:OnInitItem(arg_17_2)
	end

	self.cards[arg_17_2]:Update(self.displays[arg_17_1 + 1])
end

function IslandFriendListPage:Show()
	IslandFriendListPage.super.Show(self)
	self:InitList()
end

function IslandFriendListPage:Hide()
	IslandFriendListPage.super.Hide(self)

	if self.isOpenMore then
		self:CloseMorePanel()
	end
end

function IslandFriendListPage:Flush()
	self:InitList()
end

function IslandFriendListPage:GetData(arg_21_1)
	local var_21_0 = getProxy(FriendProxy):getAllFriends()

	if #var_21_0 <= 0 then
		return arg_21_1({})
	end

	local var_21_1 = {}

	for iter_21_0, iter_21_1 in pairs(var_21_0) do
		table.insert(var_21_1, iter_21_1.id)
	end

	self:emit(IslandMediator.GET_GIFT_TAG, var_21_1, function()
		arg_21_1(var_21_0)
	end)
end

function IslandFriendListPage:InitList()
	pg.UIMgr.GetInstance():LoadingOn()
	self:GetData(function(arg_24_0)
		pg.UIMgr.GetInstance():LoadingOff()

		self.displays = arg_24_0

		self._scrollrect:SetTotalCount(#self.displays)
	end)
end

function IslandFriendListPage:OnDestroy()
	ClearLScrollrect(self._scrollrect)

	for iter_25_0, iter_25_1 in pairs(self.cards) do
		iter_25_1:Dispose()
	end

	self.cards = nil
end

return IslandFriendListPage
