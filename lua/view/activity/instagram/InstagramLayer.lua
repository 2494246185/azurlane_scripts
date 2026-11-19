local InstagramLayer = class("InstagramLayer", import("...base.BaseUI"))

function InstagramLayer:getUIName()
	return "InstagramUI"
end

function InstagramLayer:getResource()
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in pairs((getProxy(InstagramProxy):GetData())) do
		table.insert(var_2_0, "qicon/" .. iter_2_1:GetIcon())
		table.insert(var_2_0, iter_2_1:GetImage())
	end

	table.insertto(var_2_0, InstagramLayer.super.getResource(self))

	return var_2_0
end

function InstagramLayer:preload(arg_3_1)
	self:SetProxy(getProxy(InstagramProxy))
	arg_3_1()
end

function InstagramLayer:SetProxy(arg_4_1)
	self.proxy = arg_4_1
	self.instagramVOById = arg_4_1:GetData()
	self.messages = arg_4_1:GetMessages()
end

function InstagramLayer:UpdateSelectedInstagram(arg_5_1)
	if self.contextData.instagram and self.contextData.instagram.id == arg_5_1 then
		self.contextData.instagram = self.instagramVOById[arg_5_1]

		self:UpdateCommentList()
	end
end

function InstagramLayer:init()
	local var_6_0 = GameObject.Find("MainObject")

	self.downloadmgr = BulletinBoardMgr.Inst
	self.listTF = self._tf:Find("list")
	self.mainTF = self._tf:Find("main")
	self.closeBtn = self._tf:Find("closeBtn")
	self.noMsgTF = self._tf:Find("list/bg/no_msg")
	self.scrollBarTF = self._tf:Find("list/bg/scroll_bar")
	self.list = self._tf:Find("list/bg/scrollrect"):GetComponent("LScrollRect")
	self.imageTF = self._tf:Find("main/left_panel/mask/Image"):GetComponent(typeof(RawImage))
	self.likeBtn = self._tf:Find("main/left_panel/heart")
	self.bubbleTF = self._tf:Find("main/left_panel/bubble")
	self.planeTF = self._tf:Find("main/left_panel/plane")
	self.likeCntTxt = self._tf:Find("main/left_panel/zan"):GetComponent(typeof(Text))
	self.pushTimeTxt = self._tf:Find("main/left_panel/time"):GetComponent(typeof(Text))
	self.iconTF = self._tf:Find("main/right_panel/top/head/icon")
	self.nameTxt = self._tf:Find("main/right_panel/top/name"):GetComponent(typeof(Text))
	self.centerTF = self._tf:Find("main/right_panel/center")
	self.contentTxt = self._tf:Find("main/right_panel/center/Text/Text"):GetComponent(typeof(Text))
	self.commentList = UIItemList.New(self._tf:Find("main/right_panel/center/bottom/scroll/content"), self._tf:Find("main/right_panel/center/bottom/scroll/content/tpl"))
	self.commentPanel = self._tf:Find("main/right_panel/last/bg2")
	self.optionalPanel = self._tf:Find("main/right_panel/last/bg2/option")
	self.scroll = self._tf:Find("main/right_panel/center/bottom/scroll")

	setText(self._tf:Find("closeBtn/Text"), i18n("word_back"))

	self.sprites = {}
	self.timers = {}
	self.toDownloadList = {}

	self:OverlayPanel(self._tf)
end

function InstagramLayer:SetImageByUrl(arg_7_1, arg_7_2, arg_7_3)
	if not arg_7_1 or arg_7_1 == "" then
		setActive(arg_7_2.gameObject, false)

		if arg_7_3 then
			arg_7_3()
		end
	else
		setActive(arg_7_2.gameObject, true)

		if self.sprites[arg_7_1] then
			arg_7_2.texture = self.sprites[arg_7_1]

			if arg_7_3 then
				arg_7_3()
			end
		else
			arg_7_2.enabled = false

			self.downloadmgr:GetTexture("ins", "1", arg_7_1, UnityEngine.Events.UnityAction_UnityEngine_Texture(function(arg_8_0)
				if self.exited then
					return
				end

				if not self.sprites then
					return
				end

				self.sprites[arg_7_1] = arg_8_0
				arg_7_2.texture = arg_8_0
				arg_7_2.enabled = true

				if arg_7_3 then
					arg_7_3()
				end
			end))
			table.insert(self.toDownloadList, arg_7_1)
		end
	end
end

function InstagramLayer:didEnter()
	self:SetUp()

	self.cards = {}

	function self.list.onInitItem(arg_10_0)
		local var_10_0 = InstagramCard.New(arg_10_0, self)

		onButton(self, var_10_0._go, function()
			self:EnterDetail(var_10_0.instagram)
		end, SFX_PANEL)

		self.cards[arg_10_0] = var_10_0
	end

	function self.list.onUpdateItem(arg_12_0, arg_12_1)
		local var_12_0 = self.cards[arg_12_1]

		if not self.cards[arg_12_1] then
			var_12_0 = InstagramCard.New(arg_12_1)
			self.cards[arg_12_1] = var_12_0
		end

		var_12_0:Update(self.instagramVOById[self.display[arg_12_0 + 1].id])
	end

	self:InitList()
end

function InstagramLayer:SetUp()
	setActive(self.listTF, true)
	setActive(self.mainTF, false)
	setActive(self.closeBtn, false)
	onButton(self, self.closeBtn, function()
		if self.inDetail then
			self:ExitDetail()
		end
	end, SFX_PANEL)
end

function InstagramLayer:InitList()
	self.display = _.map(self.messages, function(arg_16_0)
		return {
			time = arg_16_0:GetLasterUpdateTime(),
			id = arg_16_0.id,
			order = arg_16_0:GetSortIndex()
		}
	end)

	table.sort(self.display, function(arg_17_0, arg_17_1)
		if arg_17_0.order == arg_17_1.order then
			return arg_17_0.id > arg_17_1.id
		else
			return arg_17_0.order > arg_17_1.order
		end
	end)

	if isActive(self.listTF) then
		self.list:SetTotalCount(#self.display)
	end

	setActive(self.noMsgTF, #self.display == 0)
	setActive(self.scrollBarTF, not #self.display == 0)
end

function InstagramLayer:UpdateInstagram(arg_18_1, arg_18_2)
	for iter_18_0, iter_18_1 in pairs(self.cards) do
		if iter_18_1.instagram and iter_18_1.instagram.id == arg_18_1 then
			iter_18_1:Update(self.instagramVOById[arg_18_1], arg_18_2)
		end
	end
end

function InstagramLayer:EnterDetail(arg_19_1)
	self.contextData.instagram = arg_19_1

	self:InitDetailPage()

	self.inDetail = true

	setActive(self.listTF, false)
	setActive(self.mainTF, true)
	setActive(self.closeBtn, true)
	pg.SystemGuideMgr.GetInstance():Play(self)
	self:RefreshInstagram()
	scrollTo(self.scroll, 0, 1)
end

function InstagramLayer:ExitDetail()
	if self.contextData.instagram and not self.contextData.instagram:IsReaded() then
		self:emit(InstagramMediator.ON_READED, self.contextData.instagram.id)
	end

	self.contextData.instagram = nil
	self.inDetail = false

	setActive(self.listTF, true)
	setActive(self.mainTF, false)
	setActive(self.closeBtn, false)
	self:CloseCommentPanel()
end

function InstagramLayer:RefreshInstagram()
	local var_21_0 = self.contextData.instagram:GetFastestRefreshTime()

	if var_21_0 then
		if var_21_0 - pg.TimeMgr.GetInstance():GetServerTime() <= 0 then
			self:emit(InstagramMediator.ON_REPLY_UPDATE, self.contextData.instagram.id)
		end
	end
end

function InstagramLayer:InitDetailPage()
	local var_22_0 = self.contextData.instagram

	self:SetImageByUrl(self.contextData.instagram:GetImage(), self.imageTF)
	onButton(self, self.planeTF, function()
		self:emit(InstagramMediator.ON_SHARE, var_22_0.id)
	end, SFX_PANEL)

	self.pushTimeTxt.text = self.contextData.instagram:GetPushTime()

	setImageSprite(self.iconTF, LoadSprite("qicon/" .. self.contextData.instagram:GetIcon()), false)

	self.nameTxt.text = self.contextData.instagram:GetName()
	self.contentTxt.text = self.contextData.instagram:GetContent()

	onToggle(self, self.commentPanel, function(arg_24_0)
		if arg_24_0 then
			self:OpenCommentPanel()
		else
			self:CloseCommentPanel()
		end
	end, SFX_PANEL)
	self:UpdateLikeBtn()
	self:UpdateCommentList()
end

function InstagramLayer:UpdateLikeBtn()
	local var_25_0 = self.contextData.instagram
	local var_25_1 = self.contextData.instagram:IsLiking()

	if not var_25_1 then
		onButton(self, self.likeBtn, function()
			self:emit(InstagramMediator.ON_LIKE, var_25_0.id)
		end, SFX_PANEL)
	else
		removeOnButton(self.likeBtn)
	end

	setActive(self.likeBtn:Find("heart"), var_25_1)

	self.likeBtn:GetComponent(typeof(Image)).enabled = not var_25_1
	self.likeCntTxt.text = i18n("ins_word_like", var_25_0:GetLikeCnt())
end

function InstagramLayer:UpdateCommentList()
	if not self.contextData.instagram then
		return
	end

	local var_27_0, var_27_1 = self.contextData.instagram:GetCanDisplayComments()

	table.sort(var_27_0, function(arg_28_0, arg_28_1)
		return arg_28_0.time < arg_28_1.time
	end)
	self.commentList:make(function(arg_29_0, arg_29_1, arg_29_2)
		if arg_29_0 == UIItemList.EventUpdate then
			local var_29_0 = var_27_0[arg_29_1 + 1]
			local var_29_1 = var_27_0[arg_29_1 + 1]:HasReply()

			setText(arg_29_2:Find("main/reply"), var_27_0[arg_29_1 + 1]:GetReplyBtnTxt())
			setText(arg_29_2:Find("main/content"), HXSet.hxLan((SwitchSpecialChar((var_29_0:GetContent())))))
			setText(arg_29_2:Find("main/bubble/Text"), var_29_0:GetReplyCnt())
			setText(arg_29_2:Find("main/time"), var_29_0:GetTime())

			if var_29_0:GetType() == Instagram.TYPE_PLAYER_COMMENT then
				local var_29_2, var_29_3 = var_29_0:GetIcon()

				setImageSprite(arg_29_2:Find("main/head/icon"), GetSpriteFromAtlas(var_29_2, var_29_3))
			else
				setImageSprite(arg_29_2:Find("main/head/icon"), LoadSprite("qicon/" .. var_29_0:GetIcon()), false)
			end

			if var_29_1 then
				onToggle(self, arg_29_2:Find("main/bubble"), function(arg_30_0)
					setActive(arg_29_2:Find("replys"), arg_30_0)
				end, SFX_PANEL)
				self:UpdateReplys(arg_29_2, var_29_0)
				triggerToggle(arg_29_2:Find("main/bubble"), true)
			else
				setActive(arg_29_2:Find("replys"), false)
				triggerToggle(arg_29_2:Find("main/bubble"), false)
			end

			arg_29_2:Find("main/bubble"):GetComponent(typeof(Toggle)).enabled = var_29_1
		end
	end)
	setActive(self.centerTF, false)
	setActive(self.centerTF, true)
	Canvas.ForceUpdateCanvases()
	self.commentList:align(#var_27_0)
end

function InstagramLayer:UpdateReplys(arg_31_1, arg_31_2)
	local var_31_0, var_31_1 = arg_31_2:GetCanDisplayReply()
	local var_31_2 = UIItemList.New(arg_31_1:Find("replys"), arg_31_1:Find("replys/sub"))

	table.sort(var_31_0, function(arg_32_0, arg_32_1)
		if arg_32_0.level == arg_32_1.level then
			if arg_32_0.time == arg_32_1.time then
				return arg_32_0.id < arg_32_1.id
			else
				return arg_32_0.time < arg_32_1.time
			end
		else
			return arg_32_0.level < arg_32_1.level
		end
	end)
	var_31_2:make(function(arg_33_0, arg_33_1, arg_33_2)
		if arg_33_0 == UIItemList.EventUpdate then
			setImageSprite(arg_33_2:Find("head/icon"), LoadSprite("qicon/" .. var_31_0[arg_33_1 + 1]:GetIcon()), false)
			setText(arg_33_2:Find("content"), HXSet.hxLan((SwitchSpecialChar((var_31_0[arg_33_1 + 1]:GetContent())))))
		end
	end)
	var_31_2:align(#var_31_0)
end

function InstagramLayer:OpenCommentPanel()
	local var_34_0 = self.contextData.instagram

	if not self.contextData.instagram:CanOpenComment() then
		return
	end

	setActive(self.optionalPanel, true)

	local var_34_1 = self.contextData.instagram:GetOptionComment()

	self.commentPanel:GetComponent(typeof(Image)).enabled = true
	self.commentPanel.sizeDelta = Vector2(0, #var_34_1 * 142 + 60)

	local var_34_2 = UIItemList.New(self.optionalPanel, self.optionalPanel:Find("option1"))

	var_34_2:make(function(arg_35_0, arg_35_1, arg_35_2)
		if arg_35_0 == UIItemList.EventUpdate then
			local var_35_0 = var_34_1[arg_35_1 + 1].id
			local var_35_1 = var_34_1[arg_35_1 + 1].index

			setText(arg_35_2:Find("Text"), HXSet.hxLan(var_34_1[arg_35_1 + 1].text))
			onButton(self, arg_35_2, function()
				self:emit(InstagramMediator.ON_COMMENT, var_34_0.id, var_35_1, var_35_0)
				self:CloseCommentPanel()
			end, SFX_PANEL)
		end
	end)
	var_34_2:align(#var_34_1)
end

function InstagramLayer:CloseCommentPanel()
	self.commentPanel:GetComponent(typeof(Image)).enabled = false
	self.commentPanel.sizeDelta = Vector2(0, 0)

	setActive(self.optionalPanel, false)
end

function InstagramLayer:onBackPressed()
	if self.inDetail then
		self:ExitDetail()

		return
	end

	self:emit(InstagramMediator.CLOSE_ALL)
end

function InstagramLayer:CloseDetail()
	if self.inDetail then
		self:ExitDetail()

		return
	end
end

function InstagramLayer:willExit()
	for iter_40_0, iter_40_1 in ipairs(self.toDownloadList or {}) do
		self.downloadmgr:StopLoader(iter_40_1)
	end

	self.toDownloadList = {}

	self:UnOverlayPanel(self._tf)
	self:ExitDetail()

	for iter_40_2, iter_40_3 in pairs(self.sprites) do
		if not IsNil(iter_40_3) then
			Object.Destroy(iter_40_3)
		end
	end

	self.sprites = nil

	for iter_40_4, iter_40_5 in pairs(self.cards) do
		iter_40_5:Dispose()
	end

	self.cards = {}
end

return InstagramLayer
