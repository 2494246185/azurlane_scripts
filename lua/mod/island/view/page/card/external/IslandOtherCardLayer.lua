local IslandOtherCardLayer = class("IslandOtherCardLayer", import(".IslandSelfCardLayer"))

IslandOtherCardLayer.DOUBLE_CLICK_TIME = 0.5

function IslandOtherCardLayer:getUIName()
	return "IslandOtherCardUI"
end

function IslandOtherCardLayer:preload(arg_2_1)
	local var_2_0 = self.contextData.userId

	seriesAsync({
		function(arg_3_0)
			local var_3_0 = getProxy(IslandProxy):GetIsland()

			if var_3_0 then
				self.island = var_3_0

				arg_3_0()
			else
				pg.m02:sendNotification(GAME.ISLAND_GET_DATA, {
					isCardRequest = true,
					id = var_2_0,
					list = {},
					callback = function()
						self.island = getProxy(IslandProxy):GetIsland()

						arg_3_0()
					end
				})
			end
		end,
		function(arg_5_0)
			pg.m02:sendNotification(GAME.ISLAND_GET_CARD_DATA, {
				userId = var_2_0,
				callback = function(arg_6_0)
					self.card = arg_6_0

					arg_5_0()
				end
			})
		end
	}, function()
		arg_2_1()
	end)
end

function IslandOtherCardLayer:getResource()
	local var_8_0 = IslandOtherCardLayer.super.getResource(self)

	for iter_8_0, iter_8_1 in ipairs({
		"ui/islandcardui_atlas"
	} or {}) do
		if not table.contains(var_8_0, iter_8_1) then
			table.insert(var_8_0, iter_8_1)
		end
	end

	return var_8_0
end

function IslandOtherCardLayer:init()
	IslandOtherCardLayer.super.init(self)
	setText(self._tf:Find("panel/achvs/tpl/empty/Text"), i18n("island_card_no_achv_other"))

	self.likeGreyTF = self._tf:Find("panel/photo/like_grey")

	for iter_9_0, iter_9_1 in ipairs({
		self.photoSwitchBtn,
		self.editBtn,
		self.diyBtn,
		self.setAchvsBtn
	}) do
		setActive(iter_9_1, false)
		removeOnButton(iter_9_1)
	end

	self.lableFlagLinkTFs = {
		self.labelsTF
	}
	self.socialFlagLinkTFs = {
		self.likeTF,
		self.likeGreyTF,
		self._tf:Find("panel/btns/visit")
	}
end

function IslandOtherCardLayer:didEnter()
	IslandOtherCardLayer.super.didEnter(self)
	onButton(self, self._tf:Find("panel/photo/like_btn"), function()
		if not self.card:ShowSocial() then
			return
		end

		self:GiveLike()
	end)
	onButton(self, self.addBtn, function()
		if self.isFriend then
			return
		end

		self.requestFriendBox:ExecuteAction("Show", self.card.userId)
	end, SFX_PANEL)
	onButton(self, self.removeBtn, function()
		if not self.isFriend then
			return
		end

		pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_COMMON_MSGBOX, {
			contentText = i18n("remove_friend_tip"),
			onConfirm = function()
				self:emit(IslandOtherCardMediator.REMOVE_FRIEND, self.card.userId)
			end
		})
	end, SFX_PANEL)
	onButton(self, self.whitelistBtn, function()
		if self.card.whiteMark then
			pg.TipsMgr.GetInstance():ShowTips(i18n("island_repeat_vip"))

			return
		end

		self:emit(IslandOtherCardMediator.ADD_WHITE_LIST, self.card.userId)
	end, SFX_PANEL)
	onButton(self, self.blacklistBtn, function()
		if self.card.blackMark then
			pg.TipsMgr.GetInstance():ShowTips(i18n("island_repeat_blacklist"))

			return
		end

		self:emit(IslandOtherCardMediator.ADD_BLACK_LIST, self.card.userId)
	end, SFX_PANEL)
end

function IslandOtherCardLayer:InitAchvUIList()
	self.achvUIList:make(function(arg_18_0, arg_18_1, arg_18_2)
		if arg_18_0 == UIItemList.EventUpdate then
			self:UpdataAchvItem(arg_18_1, arg_18_2)
		end
	end)
end

function IslandOtherCardLayer:InitBoxs()
	self.setLabelBox = IslandSetCardLabelBox.New(self._tf, self.event)
	self.requestFriendBox = IslandRequestFriendBox.New(self._tf, self.event)
end

function IslandOtherCardLayer:Flush()
	self:UpdataPhoto()
	self:UpdataLabels()
	self:UpdataInfos()
	self:FlushFlagTFs()

	self.isFriend = getProxy(FriendProxy):isFriend(self.card.userId)

	self:FlushFriendBtns()
	self:FlushLikeTFs()
	setText(self.likeGreyTF, self.card.likeCnt)
end

function IslandOtherCardLayer:OnSetAchvsDone(arg_21_1)
	self.setAchvsBox:ExecuteAction("Hide")

	self.card.achvList = arg_21_1

	self.achvUIList:align(IslandOtherCardLayer.ACHV_SHOW_CNT)

	local var_21_0 = {}

	self.achvUIList:eachActive(function(arg_22_0, arg_22_1)
		if self.card.achvList[arg_22_0 + 1] then
			local var_22_0 = arg_22_1:Find("content/Image")

			var_22_0:GetComponent(typeof(CanvasGroup)).alpha = 0

			table.insert(var_21_0, function(arg_23_0)
				arg_22_1:GetComponent(typeof(Animation)):Play()

				var_22_0:GetComponent(typeof(CanvasGroup)).alpha = 1

				self:managedTween(LeanTween.delayedCall, function()
					arg_23_0()
				end, 0.08, nil)
			end)
		end
	end)
	seriesAsync(var_21_0)
end

function IslandOtherCardLayer:FlushFlagTFs()
	for iter_25_0, iter_25_1 in ipairs(self.lableFlagLinkTFs) do
		setActive(iter_25_1, self.card:ShowLabel())
	end

	for iter_25_2, iter_25_3 in ipairs(self.socialFlagLinkTFs) do
		setActive(iter_25_3, self.card:ShowSocial())
	end
end

function IslandOtherCardLayer:FlushFriendBtns()
	setActive(self.addBtn, not self.isFriend)
	setActive(self.removeBtn, self.isFriend)
end

function IslandOtherCardLayer:FlushLikeTFs()
	if not self.card:ShowSocial() then
		return
	end

	setActive(self.likeTF, self.card.likeMark)
	setActive(self.likeGreyTF, not self.card.likeMark)
end

function IslandOtherCardLayer:UpdateGrayLabel(arg_28_1)
	LoadImageSpriteAtlasAsync("ui/islandcardui_atlas", "bg_label_gray", arg_28_1, true)
	setTextColor(arg_28_1:Find("name"), Color.NewHex("#F7F7F7"))
	setText(arg_28_1:Find("name"), i18n("island_card_edit_label"))
	setText(arg_28_1:Find("value"), "")
	onButton(self, arg_28_1, function()
		if self.card.labelMark then
			pg.TipsMgr.GetInstance():ShowTips(i18n("island_card_label_done"))

			return
		end

		self.setLabelBox:ExecuteAction("Show", self.card.userId, self.card.labelData)
	end, SFX_PANEL)
end

function IslandOtherCardLayer:GiveLike()
	if self.card.likeMark then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_card_like_done"))

		return
	end

	self:emit(IslandOtherCardMediator.GIVE_CARD_LIKE, self.card.userId)
end

function IslandOtherCardLayer:OnGiveLikeDone()
	self.card.likeCnt = self.card.likeCnt + 1

	setText(self.likeTF, self.card.likeCnt)
	setText(self.likeGreyTF, self.card.likeCnt)

	self.card.likeMark = true

	self:FlushLikeTFs()
	self.likeTF:GetComponent(typeof(Animation)):Play()
end

function IslandOtherCardLayer:OnGiveLabelDone(arg_32_1)
	self.setLabelBox:ExecuteAction("Hide")
	self.card:AddLabel(arg_32_1)

	self.card.labelMark = true

	self:UpdataLabels()
end

function IslandOtherCardLayer:OnAddFriendDone(arg_33_1)
	self.requestFriendBox:ExecuteAction("Hide")
end

function IslandOtherCardLayer:OnAddFriendPass(arg_34_1)
	if self.card.userId ~= arg_34_1 then
		return
	end

	self.isFriend = true

	self:FlushFriendBtns()
end

function IslandOtherCardLayer:OnRemoveFriendDone(arg_35_1)
	self.isFriend = false

	self:FlushFriendBtns()
end

function IslandOtherCardLayer:OnAccessOpDone(arg_36_1)
	if arg_36_1 == IslandConst.ACCESS_OP_ADD_WHITELIST then
		self.card.whiteMark = true
	elseif arg_36_1 == IslandConst.ACCESS_OP_ADD_BLACKLIST then
		self.card.blackMark = true
	end
end

function IslandOtherCardLayer:willExit()
	if not self.contextData.isIslandPage then
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	end

	if self.setLabelBox then
		self.setLabelBox:Destroy()

		self.setLabelBox = nil
	end

	if self.requestFriendBox then
		self.requestFriendBox:Destroy()

		self.requestFriendBox = nil
	end
end

return IslandOtherCardLayer
