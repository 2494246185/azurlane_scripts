local TrophyGalleryLayer = class("TrophyGalleryLayer", import("..base.BaseUI"))

TrophyGalleryLayer.Filter = {
	"all",
	"claimed"
}
TrophyGalleryLayer.PAGE_COMMON = 1
TrophyGalleryLayer.PAGE_LIMITED = 2

function TrophyGalleryLayer:getUIName()
	return "TrophyGalleryUI"
end

function TrophyGalleryLayer:getResource()
	return ResPathSupport.MergeLuaArr(TrophyGalleryLayer.super.getResource(self), {
		"ui/trophygalleryui",
		"ui/iconcolorful",
		"ui/newstyleloveletterrewardmsgboxui"
	}, (function()
		local var_3_0 = {}

		for iter_3_0, iter_3_1 in ipairs(pg.medal_template.all) do
			if pg.medal_template[iter_3_1].icon and pg.medal_template[iter_3_1].icon ~= "" then
				table.insert(var_3_0, ResPathSupport.CombinePath("medal", pg.medal_template[iter_3_1].icon))
				table.insert(var_3_0, ResPathSupport.CombinePath("medal", "s_" .. pg.medal_template[iter_3_1].icon))

				local var_3_1 = tonumber(pg.medal_template[iter_3_1].icon)

				if var_3_1 < 9000 then
					var_3_1 = var_3_1 - var_3_1 % 10

					table.insert(var_3_0, ResPathSupport.CombinePath("artresource/effect/xunzhang/materials", "xunzhang" .. var_3_1))
				else
					table.insert(var_3_0, ResPathSupport.CombinePath("artresource/effect/xunzhang/materials", "xunzhang" .. var_3_1 - var_3_1 % 10 + 1))
				end
			end

			if pg.medal_template[iter_3_1].label and pg.medal_template[iter_3_1].label ~= "" then
				table.insert(var_3_0, ResPathSupport.CombinePath("medal", pg.medal_template[iter_3_1].label))
			end
		end

		return ResPathSupport.UniqueLuaArr(var_3_0)
	end)(), (function()
		local var_4_0 = {}
		local var_4_1 = {}
		local var_4_2 = {}

		for iter_4_0, iter_4_1 in ipairs(pg.lover_character_template.all) do
			if pg.lover_character_template[iter_4_1].exp_up and pg.lover_character_template[iter_4_1].exp_up > 0 and pg.lover_character_template[iter_4_1].exp_upper_limit and pg.lover_character_template[iter_4_1].exp_upper_limit > 0 then
				for iter_4_2 = 1, math.floor((math.floor(pg.lover_character_template[iter_4_1].exp_upper_limit / pg.lover_character_template[iter_4_1].exp_up) - 1) / 10) + 1 do
					table.insert(var_4_0, "lovelettermedal/default_" .. iter_4_2)
				end
			end
		end

		for iter_4_3, iter_4_4 in ipairs(getProxy(LoveLetterProxy):GetDisplayGroupList()) do
			table.insertto(var_4_1, ResPathSupport.GetPaintingShipYardIconListByPaintingName(iter_4_4:getPainting()))
			table.insert(var_4_2, string.format(ResPathSupport.ConstPath.BG.ShipCard, iter_4_4:rarity2bgPrint()))
		end

		return ResPathSupport.MergeLuaArr(var_4_1, var_4_0, var_4_2)
	end)())
end

function TrophyGalleryLayer:setTrophyGroups(arg_5_1)
	self.trophyGroups = arg_5_1
end

function TrophyGalleryLayer:setTrophyList(arg_6_1)
	self.trophyList = arg_6_1
end

function TrophyGalleryLayer:init()
	self._bg = self._tf:Find("bg")
	self._blurPanel = self._tf:Find("blur_panel")
	self._topPanel = self._blurPanel:Find("adapt/top")
	self._backBtn = self._topPanel:Find("back_btn")
	self._helpBtn = self._topPanel:Find("help_btn")
	self._center = self._tf:Find("bg/taskBGCenter")
	self._trophyUpperTpl = self:getTpl("trophy_upper", self._center)
	self._trophyLowerTpl = self:getTpl("trophy_lower", self._center)
	self._trophyContainer = self._tf:Find("bg/taskBGCenter/right_panel/Grid")
	self._scrllPanel = self._tf:Find("bg/taskBGCenter/right_panel")
	self._scrollView = self._scrllPanel:GetComponent("LScrollRect")
	self._trophyDetailPanel = TrophyDetailPanel.New(self._tf:Find("trophyPanel"), self._tf)
	self._filterBtn = self._topPanel:Find("filter/toggle")
	self._trophyCounter = self._topPanel:Find("filter/counter/Text")
	self._reminderRes = self._tf:Find("bg/resource")
	self._pageToggle = {
		self._tf:Find("blur_panel/adapt/left_length/frame/root/common_toggle"),
		self._tf:Find("blur_panel/adapt/left_length/frame/root/limited_toggle"),
		self.toggleLoveLetter
	}
	self._hideExpireBtn = self._tf:Find("blur_panel/adapt/top/expireCheckBox")
	self._hideExpireCheck = self._hideExpireBtn:Find("check")
	self._pageIndex = self.contextData.index or 1
	self._hideExpire = false
	self._trophyTFList = {}
	self._trophyViewCache = {}
	self._trophyMatCache = {}
	self.cardItems = {}
	self.cardList = self.rtScrollContent:GetComponent("LScrollRect")

	function self.cardList.onInitItem(arg_8_0)
		self:onInitCard(arg_8_0)
	end

	function self.cardList.onUpdateItem(arg_9_0, arg_9_1)
		self:onUpdateCard(arg_9_0, arg_9_1)
	end

	function self.cardList.onReturnItem(arg_10_0, arg_10_1)
		self:onReturnCard(arg_10_0, arg_10_1)
	end

	self._loader = AutoLoader.New()
end

function TrophyGalleryLayer:checkTrophyVisible(arg_11_1, arg_11_2, arg_11_3)
	if arg_11_1:GetTrophyPage() ~= arg_11_2 then
		return false
	end

	local var_11_0 = false

	if arg_11_3 == "all" then
		var_11_0 = true
	elseif arg_11_3 == "claimed" then
		var_11_0 = arg_11_1:getMaxClaimedTrophy() ~= nil
	end

	if arg_11_2 == TrophyGalleryLayer.PAGE_LIMITED and self._hideExpire and arg_11_1:IsExpire() == 1 then
		if not arg_11_1:getProgressTrophy():isClaimed() then
			var_11_0 = false
		end
	end

	return var_11_0
end

function TrophyGalleryLayer:ensureTrophyViewCache(arg_12_1)
	if self._trophyViewCache[arg_12_1] then
		return self._trophyViewCache[arg_12_1]
	end

	local var_12_0 = cloneTplTo(self._trophyUpperTpl, self._trophyContainer)
	local var_12_1 = cloneTplTo(self._trophyLowerTpl, self._trophyContainer)

	local function var_12_2()
		local var_13_0 = self.trophyGroups[arg_12_1]:getProgressTrophy()

		if not self._trophyTFList[arg_12_1] then
			return
		end

		if var_13_0:canClaimed() and not var_13_0:isClaimed() then
			if not self._trophyTFList[arg_12_1]:IsPlaying() then
				self:emit(TrophyGalleryMediator.ON_TROPHY_CLAIM, var_13_0.id)
			end
		elseif not self._trophyTFList[arg_12_1]:IsPlaying() then
			self:openTrophyDetail(self.trophyGroups[arg_12_1], var_13_0)
		end
	end

	onButton(self, var_12_0.transform:Find("frame"), var_12_2)
	onButton(self, var_12_1.transform:Find("frame"), var_12_2)
	setActive(var_12_0, false)
	setActive(var_12_1, false)

	local var_12_3 = {
		upperGO = var_12_0,
		lowerGO = var_12_1,
		upperView = TrophyView.New(var_12_0),
		lowerView = TrophyView.New(var_12_1)
	}

	self._trophyViewCache[arg_12_1] = var_12_3

	return var_12_3
end

function TrophyGalleryLayer:updateTrophyViewByFilter(arg_14_1, arg_14_2, arg_14_3)
	if arg_14_3 == "all" then
		arg_14_1:UpdateTrophyGroup(arg_14_2)
	elseif arg_14_3 == "claimed" then
		arg_14_1:ClaimForm(arg_14_2)
	elseif arg_14_3 == "unclaim" then
		arg_14_1:ProgressingForm(arg_14_2)
	end
end

function TrophyGalleryLayer:updateTrophyReminderMaterial(arg_15_1)
	local var_15_0 = arg_15_1:GetTrophyClaimTipsID()

	if self._trophyMatCache[var_15_0] then
		arg_15_1:SetTrophyReminderMaterial(self._trophyMatCache[var_15_0])

		return
	end

	if checkABExist("artresource/effect/xunzhang/materials/" .. var_15_0) then
		self._loader:LoadBundle("artresource/effect/xunzhang/materials/" .. var_15_0, function(arg_16_0)
			local var_16_0 = arg_16_0:LoadAssetSync(var_15_0, typeof(Material), false, false)

			self._trophyMatCache[var_15_0] = var_16_0

			arg_15_1:SetTrophyReminderMaterial(var_16_0)
		end)
	end
end

function TrophyGalleryLayer:didEnter()
	self:OverlayPanel(self._tf)
	onButton(self, self._backBtn, function()
		self:emit(TrophyGalleryLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self._filterBtn, function()
		self:onFilter()
	end, SFX_PANEL)
	onButton(self, self._helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.medal_help_tip.tip
		})
	end, SFX_PANEL)
	onButton(self, self._hideExpireBtn, function()
		self._hideExpire = not self._hideExpire

		setActive(self._hideExpireCheck, not self._hideExpire)
		self:updateTrophyList()
	end, SFX_PANEL)
	triggerButton(self._hideExpireBtn)

	for iter_17_0, iter_17_1 in ipairs(self._pageToggle) do
		onButton(self, iter_17_1, function()
			self:updatePage(iter_17_0)
		end, SFX_PANEL)
	end

	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(self.toggleLoveLetter:Find("tip"), {
		"love_letter_level_up",
		"love_letter_level_reward"
	}, function(arg_23_0)
		local var_23_0 = getProxy(LoveLetterProxy)

		setActive(arg_23_0, var_23_0:IsTipRealizeGift() or var_23_0:IsTipLevelUp() or var_23_0:IsTipAllLevelReward())
	end)
	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(self.rtCountLevelPanel:Find("info/icon/tip"), {
		"love_letter_level_up",
		"love_letter_level_reward"
	}, function(arg_24_0)
		setActive(arg_24_0, getProxy(LoveLetterProxy):IsTipAllLevelReward())
	end)

	self._filterIndex = 0

	triggerButton(self._filterBtn)
	triggerButton(self._pageToggle[self._pageIndex])
	self:updateTrophyCounter()
end

function TrophyGalleryLayer:updatePage(arg_25_1)
	for iter_25_0, iter_25_1 in ipairs(self._pageToggle) do
		setActive(iter_25_1:Find("selected"), iter_25_0 == arg_25_1)
		setActive(iter_25_1:Find("Image"), iter_25_0 ~= arg_25_1)
	end

	self._pageIndex = arg_25_1

	local var_25_0 = arg_25_1 == 3

	setActive(self._center, not (arg_25_1 == 3))
	setActive(self._topPanel:Find("filter"), not var_25_0)
	setActive(self.rtLoveLetterPanel, var_25_0)
	setActive(self.rtCountLevelPanel, var_25_0)
	setActive(self.rtCountLevelBg, var_25_0)

	if var_25_0 then
		self:updateLoveLetterPage()
	else
		self:updateTrophyList()
	end

	setActive(self._hideExpireBtn, arg_25_1 == TrophyGalleryLayer.PAGE_LIMITED)
end

function TrophyGalleryLayer:updateTrophyList()
	self._trophyTFList = {}

	for iter_26_0, iter_26_1 in pairs(self._trophyViewCache) do
		setActive(iter_26_1.upperGO, false)
		setActive(iter_26_1.lowerGO, false)
	end

	local var_26_0 = TrophyGalleryLayer.Filter[self._filterIndex]
	local var_26_1 = 1

	for iter_26_2, iter_26_3 in pairs(self.trophyGroups) do
		if self:checkTrophyVisible(iter_26_3, self._pageIndex, var_26_0) then
			local var_26_2 = self:ensureTrophyViewCache(iter_26_2)
			local var_26_3 = math.fmod(var_26_1, 2) == 1
			local var_26_4

			if var_26_3 then
				var_26_4 = var_26_2.upperGO or var_26_2.lowerGO

				local var_26_5

				if var_26_3 then
					var_26_5 = var_26_2.lowerGO or var_26_2.upperGO

					local var_26_6

					if var_26_3 then
						var_26_6 = var_26_2.upperView or var_26_2.lowerView
					end
				end
			end

			setActive(var_26_4, true)
			setActive(var_26_5, false)
			var_26_4.transform:SetSiblingIndex(var_26_1 - 1)
			self:updateTrophyViewByFilter(var_26_6, iter_26_3, var_26_0)
			self:updateTrophyReminderMaterial(var_26_6)

			self._trophyTFList[iter_26_2] = var_26_6
			var_26_1 = var_26_1 + 1
		end
	end
end

function TrophyGalleryLayer:PlayTrophyClaim(arg_27_1)
	self._trophyTFList[arg_27_1]:PlayClaimAnima(self.trophyGroups[arg_27_1], Instantiate(self._reminderRes:Find("claim_fx")), function()
		self:updateTrophyByGroup(arg_27_1)
		self:updateTrophyCounter()
	end)
end

function TrophyGalleryLayer:updateTrophyByGroup(arg_29_1)
	self._trophyTFList[arg_29_1]:UpdateTrophyGroup(self.trophyGroups[arg_29_1])
end

function TrophyGalleryLayer:openTrophyDetail(arg_30_1, arg_30_2)
	self._trophyDetailPanel:SetTrophyGroup(arg_30_1)
	self._trophyDetailPanel:UpdateTrophy(arg_30_2)
	self._trophyDetailPanel:SetActive(true)
end

function TrophyGalleryLayer:updateTrophyCounter()
	local var_31_0 = 0

	for iter_31_0, iter_31_1 in pairs(self.trophyList) do
		if iter_31_1:isClaimed() and not iter_31_1:isHide() then
			var_31_0 = var_31_0 + 1
		end
	end

	setText(self._trophyCounter, var_31_0)
end

function TrophyGalleryLayer:onFilter()
	self._filterIndex = self._filterIndex + 1

	if self._filterIndex > #TrophyGalleryLayer.Filter then
		self._filterIndex = 1
	end

	for iter_32_0 = 1, #TrophyGalleryLayer.Filter do
		setActive(self._filterBtn:GetChild(iter_32_0 - 1), iter_32_0 == self._filterIndex)
	end

	self:updateTrophyList()
end

function TrophyGalleryLayer:updateLoveLetterPage()
	if not self.contextData.checkRalizeGift then
		self.contextData.checkRalizeGift = true

		if getProxy(LoveLetterProxy):IsTipRealizeGift() then
			self:emit(TrophyGalleryMediator.OPEN_REALIZE_GIFT_LAYER)
		end
	end

	self.cardInfos = getProxy(LoveLetterProxy):GetDisplayGroupList()

	self.cardList:SetTotalCount(#self.cardInfos, -1)

	local var_33_0 = getProxy(LoveLetterProxy)
	local var_33_1 = self.rtCountLevelPanel:Find("info")

	setText(var_33_1:Find("word"), i18n("loveactivity_ui_10"))
	setText(var_33_1:Find("count"), (var_33_0:GetAllLevel()))

	local var_33_2, var_33_3 = var_33_0:GetAllLevelProgress()

	if var_33_3 == 0 then
		setSlider(var_33_1:Find("Slider"), 0, 1, 1)
	else
		setSlider(var_33_1:Find("Slider"), 0, var_33_3, var_33_2)
	end

	setText(var_33_1:Find("Slider/Text"), var_33_2 .. "/" .. var_33_3)
	updateDrop(var_33_1:Find("icon/mask/IconTpl"), var_33_0:GetAllLevelNextAward()[1])
	onButton(self, var_33_1:Find("icon/mask/IconTpl"), function()
		self:emit(BaseUI.ON_DROP, drop[1])
	end, SFX_PANEL)
	setActive(var_33_1:Find("icon/got"), var_33_3 == 0)
	onButton(self, var_33_1:Find("click"), function()
		local var_35_0 = getProxy(LoveLetterProxy):GetAllLevelReadyReward()
		local var_35_1 = pg.NewStyleMsgboxMgr.GetInstance()
		local var_35_2 = pg.NewStyleMsgboxMgr.TYPE_LOVE_LETTER_LEVEL_REWARD
		local var_35_3 = {}

		var_35_3.btnList = #var_35_0 > 0 and {
			{
				type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.cancel,
				name = i18n("msgbox_text_cancel"),
				sound = SFX_CANCEL
			},
			{
				type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.confirm,
				name = i18n("mail_get_oneclick"),
				func = function()
					self:emit(TrophyGalleryMediator.ON_GET_ALL_LOVE_LETTER_REWARD, var_35_0)
				end,
				sound = SFX_CONFIRM
			}
		} or nil

		var_35_1:Show(var_35_2, var_35_3)
	end, SFX_PANEL)
end

function TrophyGalleryLayer:onInitCard(arg_37_1)
	local var_37_0 = LoveLetterShipCard.New(arg_37_1)

	onButton(self, var_37_0.go, function()
		if var_37_0.shipGroup then
			self:emit(TrophyGalleryMediator.OPEN_DISPLAY_WINDOW, var_37_0.shipGroup.id)
		end
	end)

	self.cardItems[arg_37_1] = var_37_0
end

function TrophyGalleryLayer:onUpdateCard(arg_39_1, arg_39_2)
	local var_39_0 = self.cardItems[arg_39_2]

	if not self.cardItems[arg_39_2] then
		self:onInitCard(arg_39_2)

		var_39_0 = self.cardItems[arg_39_2]
	end

	local var_39_1 = self.cardInfos[arg_39_1 + 1]

	var_39_0:update(self.cardInfos[arg_39_1 + 1])
	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(arg_39_2.transform:Find("content/pick_up"), {
		"love_letter_level_up"
	}, function(arg_40_0)
		local var_40_0 = getProxy(LoveLetterProxy):GetGroupData(var_39_1.id)

		setActive(arg_40_0, var_40_0:GetDisplayLevel() < var_40_0:GetMaxLevel() and var_40_0:CanLevelUp())
	end)
end

function TrophyGalleryLayer:onReturnCard(arg_41_1, arg_41_2)
	if self.exited then
		return
	end

	if self.cardItems[arg_41_2] then
		self.cardItems[arg_41_2]:clear()
	end

	self.cardItems[arg_41_2] = nil
end

function TrophyGalleryLayer:onBackPressed()
	if self._trophyDetailPanel:IsActive() then
		self._trophyDetailPanel:SetActive(false)
	else
		TrophyGalleryLayer.super.onBackPressed(self)
	end
end

function TrophyGalleryLayer:willExit()
	self._loader:Clear()
	pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(self.toggleLoveLetter:Find("tip"))
	pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(self.rtCountLevelPanel:Find("info/icon/tip"))

	for iter_43_0, iter_43_1 in pairs(self.cardItems) do
		pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(iter_43_0.transform:Find("content/pick_up"))
	end

	self:UnOverlayPanel(self._blurPanel, self._tf)
	self._trophyDetailPanel:Dispose()
end

return TrophyGalleryLayer
