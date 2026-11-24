local Dorm3dInstagramLayer = class("Dorm3dInstagramLayer", import("view.base.BaseUI"))

function Dorm3dInstagramLayer:getUIName()
	return "Dorm3dInstagramUI"
end

function Dorm3dInstagramLayer:getResource()
	local var_2_0 = {
		"ui/instagramui_atlas"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local function var_2_2(arg_4_0, arg_4_1)
		if noEmptyStr(arg_4_1) then
			var_2_1(arg_4_0 .. arg_4_1)
		end
	end

	local function var_2_3(arg_5_0)
		for iter_5_0, iter_5_1 in ipairs(arg_5_0 or {}) do
			var_2_2("qicon/", iter_5_1:GetIcon())

			if iter_5_1.GetReplyedList then
				var_2_3(iter_5_1:GetReplyedList())
			end
		end
	end

	local var_2_4 = getProxy(Dorm3dInsProxy):GetInstagramList((self.contextData or {}).apartmentGroupId)

	var_2_4 = var_2_4 or {}

	for iter_2_0, iter_2_1 in ipairs(var_2_4) do
		var_2_2("dorm3dins/", iter_2_1:GetPicture())
		var_2_2("dorm3dins/", iter_2_1:GetBackground())
		var_2_2("qicon/", iter_2_1:GetIcon())
		var_2_3(iter_2_1:GetReplyedList())
	end

	return table.insertto(var_2_0, Dorm3dInstagramLayer.super.getResource(self))
end

function Dorm3dInstagramLayer:GetInstagramList()
	assert(self.contextData.apartmentGroupId, "groupId can not be nil")

	return getProxy(Dorm3dInsProxy):GetInstagramList(self.contextData.apartmentGroupId)
end

function Dorm3dInstagramLayer:init()
	self.listTF = self._tf:Find("list")
	self.mainTF = self._tf:Find("main")
	self.closeBtn = self._tf:Find("closeBtn")
	self.noMsgTF = self._tf:Find("list/bg/no_msg")
	self.scrollBarTF = self._tf:Find("list/bg/scroll_bar")
	self.list = self._tf:Find("list/bg/scrollrect"):GetComponent("LScrollRect")
	self.mainBg = self._tf:Find("main/left_panel/bg")
	self.imageTF = self._tf:Find("main/left_panel/mask/Image"):GetComponent(typeof(Image))
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

	setText(self._tf:Find("main_bg/Text"), i18n("dorm3d_privatechat_topics"))
	setText(self.noMsgTF:Find("Text"), i18n("dorm3d_ins_no_msg"))
	self:OverlayPanel(self._tf)
end

function Dorm3dInstagramLayer:didEnter()
	setActive(self.listTF, true)
	setActive(self.mainTF, false)
	onButton(self, self.closeBtn, function()
		if self.inDetail then
			self:ExitDetail()

			return
		end

		self:emit(Dorm3dInstagramLayer.ON_CLOSE)
	end, SFX_PANEL)

	self.cards = {}

	function self.list.onInitItem(arg_10_0)
		self:OnInitItem(arg_10_0)
	end

	function self.list.onUpdateItem(arg_11_0, arg_11_1)
		self:OnUpdateItem(arg_11_0, arg_11_1)
	end

	self:InitCards()
end

function Dorm3dInstagramLayer:OnInitItem(arg_12_1)
	local var_12_0 = Dorm3dInstagramCard.New(arg_12_1)

	onButton(self, var_12_0._go, function()
		if var_12_0.instagram:IsLock() then
			return
		end

		self:EnterDetail(var_12_0.instagram)
	end, SFX_PANEL)

	self.cards[arg_12_1] = var_12_0
end

function Dorm3dInstagramLayer:OnUpdateItem(arg_14_1, arg_14_2)
	local var_14_0 = self.cards[arg_14_2]

	if not self.cards[arg_14_2] then
		var_14_0 = Dorm3dInstagramCard.New(arg_14_2)
		self.cards[arg_14_2] = var_14_0
	end

	var_14_0:Update(self.display[arg_14_1 + 1])
end

function Dorm3dInstagramLayer:InitCards()
	self.display = {}

	for iter_15_0, iter_15_1 in ipairs((self:GetInstagramList())) do
		if not iter_15_1:IsLock() and iter_15_1:CanShow() then
			table.insert(self.display, iter_15_1)
		end
	end

	table.sort(self.display, function(arg_16_0, arg_16_1)
		local var_16_0 = arg_16_0:LockState()
		local var_16_1 = arg_16_1:LockState()

		if var_16_0 == var_16_1 then
			return var_16_1 < var_16_0
		else
			return arg_16_0.id > arg_16_1.id
		end
	end)

	if isActive(self.listTF) then
		self.list:SetTotalCount(#self.display)
	end

	setActive(self.noMsgTF, #self.display == 0)
	setActive(self.scrollBarTF, not #self.display == 0)
end

function Dorm3dInstagramLayer:EnterDetail(arg_17_1)
	self.contextData.instagram = arg_17_1

	self:InitDetailPage()

	self.inDetail = true

	setActive(self.listTF, false)
	setActive(self.mainTF, true)
	scrollTo(self.scroll, 0, 1)
end

function Dorm3dInstagramLayer:ExitDetail()
	self:emit(Dorm3dInstagramMediator.ON_EXIT, self.contextData.instagram.id)

	self.contextData.instagram = nil
	self.inDetail = false

	setActive(self.listTF, true)
	setActive(self.mainTF, false)
	self:ClosePlayerCommentPanel()
end

function Dorm3dInstagramLayer:MarkRead(arg_19_1)
	if arg_19_1 and not arg_19_1:IsRead() then
		self:emit(Dorm3dInstagramMediator.ON_READ, arg_19_1.id)
	end
end

function Dorm3dInstagramLayer:InitDetailPage()
	self:MarkRead(self.contextData.instagram)

	self.pushTimeTxt.text = self.contextData.instagram:GetPushTime()

	LoadSpriteAsync("Dorm3dIns/" .. self.contextData.instagram:GetPicture(), function(arg_21_0)
		setImageSprite(self.imageTF, arg_21_0, false)
	end)

	local var_20_0 = self.contextData.instagram:GetBackground()

	if var_20_0 and var_20_0 ~= "" then
		LoadSpriteAsync("Dorm3dIns/" .. var_20_0, function(arg_22_0)
			setImageSprite(self.mainBg, arg_22_0, false)
		end)
	end

	setImageSprite(self.iconTF, LoadSprite("qicon/" .. self.contextData.instagram:GetIcon()), false)

	self.nameTxt.text = self.contextData.instagram:GetName()
	self.contentTxt.text = self.contextData.instagram:GetText()

	onToggle(self, self.commentPanel, function(arg_23_0)
		if arg_23_0 then
			self:OpenPlayerCommentPanel()
		else
			self:ClosePlayerCommentPanel()
		end
	end, SFX_PANEL)
	self:UpdateLikeBtn()
	self:UpdateShareBtn()
	self:UpdateCommentList()
end

function Dorm3dInstagramLayer:UpdateShareBtn()
	local var_24_0 = self.contextData.instagram

	onButton(self, self.planeTF, function()
		self:emit(Dorm3dInstagramMediator.ON_SHARE, var_24_0.id)
	end, SFX_PANEL)
end

function Dorm3dInstagramLayer:UpdateLikeBtn()
	local var_26_0 = self.contextData.instagram

	if not self.contextData.instagram then
		return
	end

	local var_26_1 = self.contextData.instagram:IsGood()

	if not var_26_1 then
		onButton(self, self.likeBtn, function()
			self:emit(Dorm3dInstagramMediator.ON_LIKE, var_26_0.id)
		end, SFX_PANEL)
	else
		removeOnButton(self.likeBtn)
	end

	setActive(self.likeBtn:Find("heart"), var_26_1)

	self.likeBtn:GetComponent(typeof(Image)).enabled = not var_26_1
end

function Dorm3dInstagramLayer:OnLikeInstagram()
	if not self.contextData.instagram then
		return
	end

	self:UpdateLikeBtn()

	for iter_28_0, iter_28_1 in pairs(self.cards) do
		if iter_28_1.instagram.id == self.contextData.instagram.id then
			iter_28_1:Update(self.contextData.instagram)

			break
		end
	end
end

local function var_0_1(arg_29_0, arg_29_1, arg_29_2)
	setText(arg_29_1:Find("main/reply"), "reply")
	setText(arg_29_1:Find("main/content"), HXSet.hxLan((SwitchSpecialChar(arg_29_2:GetText()))))
	setText(arg_29_1:Find("main/time"), arg_29_2:GetPushTime())

	if isa(arg_29_2, InstagramPlayerComment3Dorm) then
		setImageSprite(arg_29_1:Find("main/head/icon"), GetSpriteFromAtlas("ui/InstagramUI_atlas", "txdi_3"))
	else
		setImageSprite(arg_29_1:Find("main/head/icon"), LoadSprite("qicon/" .. arg_29_2:GetIcon()), false)
	end
end

local function var_0_2(arg_30_0, arg_30_1, arg_30_2)
	local var_30_0 = _.select(arg_30_2:GetReplyedList(), function(arg_31_0)
		return arg_31_0:CanShow()
	end)
	local var_30_1 = UIItemList.New(arg_30_1:Find("replys"), arg_30_1:Find("replys/sub"))

	table.sort(var_30_0, function(arg_32_0, arg_32_1)
		if arg_32_0.time == arg_32_1.time then
			return arg_32_0.id < arg_32_1.id
		else
			return arg_32_0.time < arg_32_1.time
		end
	end)
	var_30_1:make(function(arg_33_0, arg_33_1, arg_33_2)
		if arg_33_0 == UIItemList.EventUpdate then
			setImageSprite(arg_33_2:Find("head/icon"), LoadSprite("qicon/" .. var_30_0[arg_33_1 + 1]:GetIcon()), false)
			setText(arg_33_2:Find("content"), HXSet.hxLan((SwitchSpecialChar(var_30_0[arg_33_1 + 1]:GetText()))))
		end
	end)
	var_30_1:align(#var_30_0)
end

local function var_0_3(arg_34_0, arg_34_1, arg_34_2)
	local var_34_0 = arg_34_2:ExistAnyReplay()

	if var_34_0 then
		onToggle(arg_34_0, arg_34_1:Find("main/bubble"), function(arg_35_0)
			setActive(arg_34_1:Find("replys"), arg_35_0)
		end, SFX_PANEL)
		var_0_2(arg_34_0, arg_34_1, arg_34_2)
	else
		setActive(arg_34_1:Find("replys"), false)
	end

	triggerToggle(arg_34_1:Find("main/bubble"), var_34_0)

	arg_34_1:Find("main/bubble"):GetComponent(typeof(Toggle)).enabled = var_34_0
end

function Dorm3dInstagramLayer:UpdateCommentList()
	if not self.contextData.instagram then
		return
	end

	local var_36_0 = _.select(self.contextData.instagram:GetReplyedList(), function(arg_37_0)
		return arg_37_0:CanShow()
	end)

	table.sort(var_36_0, function(arg_38_0, arg_38_1)
		return arg_38_0.time < arg_38_1.time
	end)
	self.commentList:make(function(arg_39_0, arg_39_1, arg_39_2)
		if arg_39_0 == UIItemList.EventUpdate then
			var_0_1(self, arg_39_2, var_36_0[arg_39_1 + 1])
			var_0_3(self, arg_39_2, var_36_0[arg_39_1 + 1])
		end
	end)
	setActive(self.centerTF, false)
	setActive(self.centerTF, true)
	Canvas.ForceUpdateCanvases()
	self.commentList:align(#var_36_0)
end

function Dorm3dInstagramLayer:OpenPlayerCommentPanel()
	local var_40_0 = self.contextData.instagram

	if not self.contextData.instagram:ExistAnyReplyable() then
		return
	end

	setActive(self.optionalPanel, true)

	local var_40_1 = self.contextData.instagram:GetReplyableList()

	self.commentPanel:GetComponent(typeof(Image)).enabled = true
	self.commentPanel.sizeDelta = Vector2(0, #var_40_1 * 142 + 60)

	local var_40_2 = UIItemList.New(self.optionalPanel, self.optionalPanel:Find("option1"))

	var_40_2:make(function(arg_41_0, arg_41_1, arg_41_2)
		if arg_41_0 == UIItemList.EventUpdate then
			local var_41_0 = var_40_1[arg_41_1 + 1].id
			local var_41_1 = var_40_1[arg_41_1 + 1].index

			setText(arg_41_2:Find("Text"), HXSet.hxLan((var_40_1[arg_41_1 + 1]:GetText())))
			onButton(self, arg_41_2, function()
				self:emit(Dorm3dInstagramMediator.ON_DISCUSS, var_40_0.id, var_41_0, var_41_1)
				self:ClosePlayerCommentPanel()
			end, SFX_PANEL)
		end
	end)
	var_40_2:align(#var_40_1)
end

function Dorm3dInstagramLayer:ClosePlayerCommentPanel()
	self.commentPanel:GetComponent(typeof(Image)).enabled = false
	self.commentPanel.sizeDelta = Vector2(0, 0)

	setActive(self.optionalPanel, false)
end

function Dorm3dInstagramLayer:onBackPressed()
	if self.inDetail then
		self:ExitDetail()

		return
	end

	Dorm3dInstagramLayer.super.onBackPressed(self)
end

function Dorm3dInstagramLayer:willExit()
	if self.inDetail then
		self:ExitDetail()
	end

	for iter_45_0, iter_45_1 in pairs(self.cards) do
		iter_45_1:Dispose()
	end

	self.cards = {}
end

return Dorm3dInstagramLayer
