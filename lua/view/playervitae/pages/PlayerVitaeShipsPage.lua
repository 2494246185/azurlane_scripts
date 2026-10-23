local PlayerVitaeShipsPage = class("PlayerVitaeShipsPage", import("...base.BaseSubView"))
local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 3
local var_0_4 = 1
local var_0_5 = 2

PlayerVitaeShipsPage.RANDOM_FLAG_SHIP_PAGE = 2
PlayerVitaeShipsPage.EDUCATE_CHAR_SLOT_ID = 6
PlayerVitaeShipsPage.ON_BEGIN_DRAG_CARD = "PlayerVitaeShipsPage:ON_BEGIN_DRAG_CARD"
PlayerVitaeShipsPage.ON_DRAGING_CARD = "PlayerVitaeShipsPage:ON_DRAGING_CARD"
PlayerVitaeShipsPage.ON_DRAG_END_CARD = "PlayerVitaeShipsPage:ON_DRAG_END_CARD"

function PlayerVitaeShipsPage.GetSlotIndexList()
	local var_1_0, var_1_1 = PlayerVitaeShipsPage.GetSlotMaxCnt()
	local var_1_2 = {}

	for iter_1_0 = 1, var_1_1 do
		table.insert(var_1_2, iter_1_0)
	end

	if NewEducateHelper.GetEducateCharSlotMaxCnt() > 0 then
		table.insert(var_1_2, PlayerVitaeShipsPage.EDUCATE_CHAR_SLOT_ID)
	end

	return var_1_2
end

function PlayerVitaeShipsPage.GetAllUnlockSlotCnt()
	local var_2_0, var_2_1 = PlayerVitaeShipsPage.GetSlotMaxCnt()

	return var_2_1 + NewEducateHelper.GetEducateCharSlotMaxCnt()
end

function PlayerVitaeShipsPage.GetSlotMaxCnt()
	local var_3_0 = 1

	for iter_3_0, iter_3_1 in ipairs(pg.gameset.secretary_group_unlock.description) do
		if getProxy(ChapterProxy):isClear(iter_3_1[1]) then
			var_3_0 = iter_3_1[2]
		end
	end

	return pg.gameset.secretary_group_unlock.description[#pg.gameset.secretary_group_unlock.description][2], var_3_0
end

function PlayerVitaeShipsPage:getUIName()
	return "PlayerVitaeShipsPage"
end

function PlayerVitaeShipsPage:getResource()
	local var_5_0 = PlayerVitaeShipsPage.super.getResource(self)
	local var_5_1 = self.contextData.showTrans

	local function var_5_2(arg_6_0)
		local var_6_0 = getProxy(BayProxy):GetShipPhantom(arg_6_0)
		local var_6_1 = getProxy(ShipSkinProxy):GetAllSkinForShip(var_6_0)

		table.insertto(var_6_1, (_.map(getProxy(ShipSkinProxy):GetShareSkinsForShip(var_6_0), function(arg_7_0)
			return pg.ship_skin_template[arg_7_0.id]
		end)))

		for iter_6_0, iter_6_1 in ipairs(var_6_1) do
			if iter_6_1 then
				local var_6_2 = iter_6_1.painting or "unknown"

				if var_6_2 ~= "unknown" then
					table.insertto(var_5_0, (ResPathSupport.GetPaintingListByPaintingName(var_6_2)))
				end
			end
		end
	end

	local function var_5_3(arg_8_0)
		if not arg_8_0 then
			return
		end

		table.insert(var_5_0, string.format(ResPathSupport.ConstPath.BG.ShipCard, (arg_8_0:rarity2bgPrint(var_5_1))))

		local var_8_0, var_8_1 = arg_8_0:GetFrameAndEffect(true)

		if noEmptyStr(var_8_1) then
			table.insert(var_5_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_8_1))
		end
	end

	local function var_5_4(arg_9_0)
		var_5_3((getProxy(BayProxy):GetShipPhantom(arg_9_0)))
	end

	for iter_5_0, iter_5_1 in ipairs(getProxy(PlayerProxy):getRawData():GetShipPhantomMarks()) do
		var_5_4(iter_5_1)
		var_5_2(iter_5_1)
	end

	for iter_5_2, iter_5_3 in ipairs(getProxy(SettingsProxy):GetRandomFlagShipList()) do
		var_5_4(iter_5_3)
		var_5_2(iter_5_3)
	end

	local var_5_5 = getProxy(PlayerProxy):getRawData()

	if var_5_5:ExistEducateChar() then
		table.insert(var_5_0, "painting/" .. VirtualEducateCharShip.New(var_5_5:GetEducateCharacter()):getPainting())
	end

	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(var_5_0, {
		"ui/proposeShipCard"
	}))
end

function PlayerVitaeShipsPage:UpdateCard(arg_10_1)
	for iter_10_0, iter_10_1 in ipairs(self.cards[var_0_1]) do
		if isActive(iter_10_1._tf) and iter_10_1.displayShip and iter_10_1.displayShip:GetShipPhantomMark() == arg_10_1 then
			iter_10_1:Refresh()

			break
		end
	end
end

function PlayerVitaeShipsPage:UpdateCardPaintingTag()
	for iter_11_0, iter_11_1 in ipairs(self.cards[var_0_1]) do
		iter_11_1:updatePaintingTag()
	end
end

function PlayerVitaeShipsPage:RefreshShips()
	self:Update()
end

function PlayerVitaeShipsPage:OnLoaded()
	self.cardContainer = self._tf:Find("frame")
	self.shipTpl = self._tf:Find("frame/shipCard")
	self.emptyTpl = self._tf:Find("frame/addCard")
	self.lockTpl = self._tf:Find("frame/lockCard")
	self.helpBtn = self._tf:Find("help_btn")
	self.settingBtn = self._tf:Find("setting_btn")
	self.settingBtnSlider = self.settingBtn:Find("toggle/on")
	self.randomBtn = self._tf:Find("ran_setting_btn")
	self.randomBtnSlider = self.randomBtn:Find("toggle/on")
	self.settingSeceneBtn = self._tf:Find("setting_scene_btn")
	self.nativeBtn = self._tf:Find("native_setting_btn")
	self.nativeBtnOn = self.nativeBtn:Find("on")
	self.nativeBtnOff = self.nativeBtn:Find("off")
	self.getMailBtn = self._tf:Find("get_mail")
	self.educateCharTr = self._tf:Find("educate_char")
	self.educateCharSettingList = UIItemList.New(self._tf:Find("educate_char/shipCard/settings/panel"), self._tf:Find("educate_char/shipCard/settings/panel/tpl"))
	self.educateCharSettingBtn = self._tf:Find("educate_char/shipCard/settings/tpl")
	self.educateCharTrTip = self.educateCharTr:Find("tip")

	if LOCK_EDUCATE_SYSTEM then
		setActive(self.educateCharTr, false)
		setAnchoredPosition(self.cardContainer, {
			x = 0
		})
		setAnchoredPosition(self._tf:Find("flagship"), {
			x = -720
		})
		setAnchoredPosition(self._tf:Find("zs"), {
			x = 763
		})
		setAnchoredPosition(self._tf:Find("line"), {
			x = 740
		})
	end

	self.educateCharCards = {
		[var_0_1] = PlayerVitaeEducateShipCard.New(self._tf:Find("educate_char/shipCard"), self.event),
		[var_0_2] = PlayerVitaeEducateAddCard.New(self._tf:Find("educate_char/addCard"), self.event),
		[var_0_3] = PlayerVitaeEducateLockCard.New(self._tf:Find("educate_char/lockCard"), self.event)
	}
	self.tip = self._tf:Find("tip"):GetComponent(typeof(Text))
	self.flagShipMark = self._tf:Find("flagship")

	self:bind(PlayerVitaeShipsPage.ON_BEGIN_DRAG_CARD, function(arg_14_0, arg_14_1)
		self:OnBeginDragCard(arg_14_1)
	end)
	self:bind(PlayerVitaeShipsPage.ON_DRAGING_CARD, function(arg_15_0, arg_15_1)
		self:OnDragingCard(arg_15_1)
	end)
	self:bind(PlayerVitaeShipsPage.ON_DRAG_END_CARD, function(arg_16_0)
		self:OnEndDragCard()
	end)
	setText(self.nativeBtnOn:Find("Text"), i18n("random_ship_before"))
	setText(self.nativeBtnOff:Find("Text"), i18n("random_ship_now"))
	setText(self.settingBtn:Find("Text"), i18n("player_vitae_skin_setting"))
	setText(self.randomBtn:Find("Text"), i18n("random_ship_label"))
	setText(self.settingSeceneBtn:Find("Text"), i18n("playervtae_setting_btn_label"))
	setText(self.getMailBtn:Find("Text"), i18n("spring_present_tips_btn"))
	setText(self.getMailBtn:Find("time"), i18n("spring_present_tips_time"))

	self.cardContainerCG = GetOrAddComponent(self.cardContainer, typeof(CanvasGroup))
end

function PlayerVitaeShipsPage:OnBeginDragCard(arg_17_1)
	self.dragIndex = arg_17_1
	self.displayCards = {}
	self.displayPos = {}

	for iter_17_0, iter_17_1 in ipairs(self.cards[var_0_1]) do
		if isActive(iter_17_1._tf) then
			self.displayCards[iter_17_0] = iter_17_1
			self.displayPos[iter_17_0] = iter_17_1._tf.localPosition
		end
	end

	for iter_17_2, iter_17_3 in pairs(self.displayCards) do
		if iter_17_2 ~= arg_17_1 then
			iter_17_3:DisableDrag()
		end
	end
end

function PlayerVitaeShipsPage:OnDragingCard(arg_18_1)
	if self.displayCards[self.dragIndex - 1] and self:ShouldSwap(arg_18_1, self.dragIndex - 1) then
		self:Swap(self.dragIndex, self.dragIndex - 1)
	elseif self.displayCards[self.dragIndex + 1] and self:ShouldSwap(arg_18_1, self.dragIndex + 1) then
		self:Swap(self.dragIndex, self.dragIndex + 1)
	end
end

function PlayerVitaeShipsPage:Swap(arg_19_1, arg_19_2)
	self.displayCards[arg_19_2]._tf.localPosition = self.displayPos[arg_19_1]
	self.displayCards[arg_19_1], self.displayCards[arg_19_2] = self.displayCards[arg_19_2], self.displayCards[arg_19_1]
	self.dragIndex = arg_19_2
	self.displayCards[arg_19_1].slotIndex = arg_19_2
	self.displayCards[arg_19_2].slotIndex = arg_19_1
	self.displayCards[arg_19_1].typeIndex, self.displayCards[arg_19_2].typeIndex = self.displayCards[arg_19_2].typeIndex, self.displayCards[arg_19_1].typeIndex

	local var_19_1 = self.cards[var_0_1]

	var_19_1[arg_19_1], var_19_1[arg_19_2] = self.cards[var_0_1][arg_19_2], self.cards[var_0_1][arg_19_1]
end

function PlayerVitaeShipsPage:ShouldSwap(arg_20_1, arg_20_2)
	return math.abs(self.displayPos[arg_20_2].x - arg_20_1.x) <= 130
end

function PlayerVitaeShipsPage:OnEndDragCard()
	self.displayCards[self.dragIndex]._tf.localPosition = self.displayPos[self.dragIndex]

	local var_21_0 = {}
	local var_21_1 = getProxy(PlayerProxy):getRawData():GetShipPhantomMarks()
	local var_21_2 = false

	for iter_21_0, iter_21_1 in pairs(self.displayCards) do
		iter_21_1:EnableDrag()
		table.insert(var_21_0, iter_21_1.displayShip:GetShipPhantomMark())

		if not var_21_2 and var_21_1[#var_21_0] ~= var_21_0[#var_21_0] then
			var_21_2 = true
		end
	end

	self.dragIndex = nil
	self.displayCards = nil
	self.displayPos = nil
	self.cardContainerCG.blocksRaycasts = false

	if var_21_2 then
		self:emit(PlayerVitaeMediator.CHANGE_PAINTS, var_21_0, function()
			Timer.New(function()
				if self.cardContainerCG then
					self.cardContainerCG.blocksRaycasts = true
				end
			end, 0.3, 1):Start()
		end)
	else
		self.cardContainerCG.blocksRaycasts = true
	end
end

function PlayerVitaeShipsPage:OnInit()
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("secretary_help")
		})
	end, SFX_PANEL)

	local var_24_0 = false

	local function var_24_1()
		setAnchoredPosition(self.settingBtnSlider, {
			x = ({
				68,
				-68
			})[var_24_0 and 1 or 2]
		})
	end

	onButton(self, self.settingBtn, function()
		var_24_0 = not var_24_0

		self:EditCards(var_24_0)
		var_24_1()
	end, SFX_PANEL)
	var_24_1()

	local var_24_2 = getProxy(SettingsProxy)

	self.randomFlag = var_24_2:IsOpenRandomFlagShip()
	self.nativeFlag = false

	local function var_24_3()
		setAnchoredPosition(self.randomBtnSlider, {
			x = ({
				68,
				-68
			})[self.randomFlag and 1 or 2]
		})
		setActive(self.nativeBtn, self.randomFlag)
		setActive(self.flagShipMark, not self.randomFlag or self.nativeFlag)

		if self.randomFlag and var_24_0 then
			triggerButton(self.settingBtn)
		end
	end

	local function var_24_4()
		setActive(self.nativeBtnOn, self.nativeFlag)
		setActive(self.nativeBtnOff, not self.nativeFlag)
		setActive(self.flagShipMark, not self.randomFlag or self.nativeFlag)

		if var_24_0 then
			triggerButton(self.settingBtn)
		end
	end

	onButton(self, self.randomBtn, function()
		self.randomFlag = not self.randomFlag

		if self.randomFlag then
			local var_30_0 = MainRandomFlagShipSequence.New():Random()

			if not var_30_0 or #var_30_0 <= 0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("random_ship_off_0"))

				self.randomFlag = not self.randomFlag

				return
			end

			var_24_2:UpdateRandomFlagShipList(var_30_0)
		else
			var_24_2:UpdateRandomFlagShipList({})

			self.nativeFlag = false

			var_24_4()
		end

		self:SwitchToPage((self.randomFlag or nil) and (var_0_5 or var_0_4))
		var_24_3()
		pg.TipsMgr.GetInstance():ShowTips(self.randomFlag and i18n("random_ship_on") or i18n("random_ship_off"))
		self:emit(PlayerVitaeMediator.ON_SWITCH_RANDOM_FLAG_SHIP_BTN, self.randomFlag)
	end, SFX_PANEL)
	var_24_3()
	onButton(self, self.nativeBtn, function()
		self.nativeFlag = not self.nativeFlag

		var_24_4()
		self:SwitchToPage((self.nativeFlag or nil) and (var_0_4 or var_0_5))
	end, SFX_PANEL)
	var_24_4()
	onButton(self, self.getMailBtn, function()
		if self.randomFlag then
			pg.TipsMgr.GetInstance():ShowTips(i18n("spring_present_tips0"))

			return
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("spring_present_tips1"),
			onYes = function()
				local var_33_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_LOVE_LETTER_MAIL)

				if not var_33_0 then
					setActive(self.getMailBtn, false)
					pg.TipsMgr.GetInstance():ShowTips(i18n("challenge_end_tip"))

					return
				end

				self:emit(PlayerVitaeMediator.ON_GET_LOVE_LETTER_MAIL, var_33_0.id)
			end
		})
	end)
	self:UpdateGetMailBtn()
	onButton(self, self.educateCharSettingBtn, function()
		setActive(self.educateCharSettingList.container, not isActive(self.educateCharSettingList.container))
	end, SFX_PANEL)
	onButton(self, self.settingSeceneBtn, function()
		self.contextData.showSelectCharacters = true

		self:emit(PlayerVitaeMediator.GO_SCENE, SCENE.SETTINGS, {
			page = NewSettingsScene.PAGE_OPTION,
			scroll = SettingsRandomFlagShipAndSkinPanel
		})
	end, SFX_PANEL)

	self.cards = {
		{},
		{},
		{}
	}

	table.insert(self.cards[var_0_1], PlayerVitaeShipCard.New(self.shipTpl, self.event))
	table.insert(self.cards[var_0_2], PlayerVitaeAddCard.New(self.emptyTpl, self.event))
	table.insert(self.cards[var_0_3], PlayerVitaeLockCard.New(self.lockTpl, self.event))
end

function PlayerVitaeShipsPage:UpdateGetMailBtn()
	local var_36_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_LOVE_LETTER_MAIL)

	setActive(self.getMailBtn, var_36_0 and not var_36_0:isEnd() and var_36_0:readyToAchieve())
end

function PlayerVitaeShipsPage:Update()
	self:SwitchToPage(self.randomFlag and self.nativeFlag and var_0_4 or getProxy(SettingsProxy):IsOpenRandomFlagShip() and var_0_5 or var_0_4)
	self:UpdateEducateChar()
	self:UpdateGetMailBtn()
	self:Show()
end

function PlayerVitaeShipsPage:UpdateEducateChar()
	self:UpdateEducateCharSettings()
	self:UpdateEducateSlot()
	self:UpdateEducateCharTrTip()
end

function PlayerVitaeShipsPage:UpdateEducateCharTrTip()
	setActive(self.educateCharTrTip, getProxy(SettingsProxy):ShouldEducateCharTip())
end

local function var_0_6()
	if NewEducateHelper.GetEducateCharSlotMaxCnt() <= 0 then
		return var_0_3
	end

	if getProxy(PlayerProxy):getRawData():ExistEducateChar() then
		return var_0_1
	end

	return var_0_2
end

function PlayerVitaeShipsPage:UpdateEducateSlot()
	local var_41_0 = var_0_6()
	local var_41_1

	for iter_41_0, iter_41_1 in pairs(self.educateCharCards) do
		local var_41_2 = iter_41_0 == var_41_0

		iter_41_1:ShowOrHide(iter_41_0 == var_41_0)

		if var_41_2 then
			var_41_1 = iter_41_1
		end
	end

	var_41_1:Flush()
end

function PlayerVitaeShipsPage:UpdateEducateCharSettings()
	local var_42_0 = getProxy(SettingsProxy)

	local function var_42_1()
		setText(self.educateCharSettingBtn:Find("Text"), i18n("flagship_display_mode_" .. var_42_0:GetFlagShipDisplayMode()))
	end

	local var_42_2 = {
		FlAG_SHIP_DISPLAY_ONLY_SHIP,
		FlAG_SHIP_DISPLAY_ONLY_EDUCATECHAR,
		FlAG_SHIP_DISPLAY_ALL
	}

	self.educateCharSettingList:make(function(arg_44_0, arg_44_1, arg_44_2)
		if arg_44_0 == UIItemList.EventUpdate then
			local var_44_0 = var_42_2[arg_44_1 + 1]

			setText(arg_44_2:Find("Text"), i18n("flagship_display_mode_" .. var_42_2[arg_44_1 + 1]))
			onButton(self, arg_44_2, function()
				var_42_0:SetFlagShipDisplayMode(var_44_0)
				var_42_1()
				setActive(self.educateCharSettingList.container, false)
			end, SFX_PANEL)
			setActive(arg_44_2:Find("line"), arg_44_1 + 1 ~= #var_42_2)
		end
	end)
	self.educateCharSettingList:align(#var_42_2)
	var_42_1()
end

function PlayerVitaeShipsPage:SwitchToPage(arg_46_1)
	local var_46_0

	if arg_46_1 == var_0_5 then
		var_46_0 = _.select(getProxy(SettingsProxy):GetRandomFlagShipList(), function(arg_47_0)
			return getProxy(BayProxy):GetShipPhantom(arg_47_0) ~= nil
		end)
		self.tip.text = i18n("random_ship_tips1")

		self:emit(PlayerVitaeScene.ON_PAGE_SWTICH, PlayerVitaeScene.PAGE_RANDOM_SHIPS)
	elseif arg_46_1 == var_0_4 then
		var_46_0 = getProxy(PlayerProxy):getRawData():GetShipPhantomMarks()
		self.tip.text = i18n("random_ship_tips2")

		self:emit(PlayerVitaeScene.ON_PAGE_SWTICH, PlayerVitaeScene.PAGE_NATIVE_SHIPS)
	end

	self:Flush(var_46_0, arg_46_1)
	setActive(self.tip.gameObject, self.randomFlag)
end

function PlayerVitaeShipsPage:Flush(arg_48_1, arg_48_2)
	local var_48_0, var_48_1 = PlayerVitaeShipsPage.GetSlotMaxCnt()

	self.max = var_48_0
	self.unlockCnt = var_48_1

	self:UpdateCards(arg_48_2, arg_48_1, (self:GetUnlockShipCnt(arg_48_1)))
end

function PlayerVitaeShipsPage:UpdateCards(arg_49_1, arg_49_2, arg_49_3)
	local var_49_0 = {
		0
	}
	local var_49_1 = {}

	for iter_49_0, iter_49_1 in ipairs(arg_49_3) do
		table.insert(var_49_1, function(arg_50_0)
			self:UpdateTypeCards(arg_49_1, arg_49_2, iter_49_0, iter_49_1, var_49_0, arg_50_0)
		end)
	end

	seriesAsync(var_49_1)
end

function PlayerVitaeShipsPage:UpdateTypeCards(arg_51_1, arg_51_2, arg_51_3, arg_51_4, arg_51_5, arg_51_6)
	local var_51_0 = {}
	local var_51_1 = self.cards[arg_51_3]

	local function var_51_2(arg_52_0)
		local var_52_0 = var_51_1[arg_52_0]

		if not var_51_1[arg_52_0] then
			var_52_0 = var_51_1[1]:Clone()
			var_51_1[arg_52_0] = var_52_0
		end

		arg_51_5[1] = arg_51_5[1] + 1

		var_52_0:Enable()
		var_52_0:Update(arg_51_5[1], arg_52_0, arg_51_2, arg_51_1, self.nativeFlag)
	end

	for iter_51_0 = 1, arg_51_4 do
		table.insert(var_51_0, function(arg_53_0)
			if self.exited then
				return
			end

			var_51_2(iter_51_0)
			onNextTick(arg_53_0)
		end)
	end

	for iter_51_1 = #self.cards[arg_51_3], arg_51_4 + 1, -1 do
		self.cards[arg_51_3][iter_51_1]:Disable()
	end

	seriesAsync(var_51_0, arg_51_6)
end

function PlayerVitaeShipsPage:GetUnlockShipCnt(arg_54_1)
	return {
		#arg_54_1,
		self.unlockCnt - #arg_54_1,
		self.max - self.unlockCnt
	}
end

function PlayerVitaeShipsPage:EditCards(arg_55_1)
	for iter_55_0, iter_55_1 in ipairs({
		var_0_1,
		var_0_2
	}) do
		for iter_55_2, iter_55_3 in ipairs(self.cards[iter_55_1]) do
			if isActive(iter_55_3._tf) then
				iter_55_3:EditCard(arg_55_1)
			end
		end
	end

	self.IsOpenEdit = arg_55_1
end

function PlayerVitaeShipsPage:EditCardsForRandom(arg_56_1)
	local var_56_0 = {}

	for iter_56_0, iter_56_1 in ipairs(self.cards[var_0_1]) do
		if isActive(iter_56_1._tf) then
			if not arg_56_1 then
				var_56_0[iter_56_1.slotIndex] = iter_56_1:GetRandomFlagValue()
			end

			iter_56_1:EditCardForRandom(arg_56_1)
		end
	end

	self.IsOpenEditForRandom = arg_56_1

	if #var_56_0 > 0 then
		self:SaveRandomSettings(var_56_0)
	end

	for iter_56_2, iter_56_3 in ipairs(self.cards[var_0_2]) do
		if isActive(iter_56_3._tf) then
			iter_56_3:EditCard(arg_56_1)
		end
	end
end

function PlayerVitaeShipsPage:SaveRandomSettings(arg_57_1)
	local var_57_0 = getProxy(PlayerProxy):getRawData()

	for iter_57_0 = 1, self.max do
		arg_57_1[iter_57_0] = arg_57_1[iter_57_0] or var_57_0:RawGetRandomShipAndSkinValueInpos(iter_57_0)
	end

	self:emit(PlayerVitaeMediator.CHANGE_RANDOM_SETTING, arg_57_1)
end

function PlayerVitaeShipsPage:Show()
	PlayerVitaeShipsPage.super.Show(self)

	Input.multiTouchEnabled = false
end

function PlayerVitaeShipsPage:Hide()
	PlayerVitaeShipsPage.super.Hide(self)

	if self.IsOpenEdit then
		triggerButton(self.settingBtn)
	end

	if self.IsOpenEditForRandom then
		triggerButton(self.randomBtn)
	end

	Input.multiTouchEnabled = true

	self:emit(PlayerVitaeScene.ON_PAGE_SWTICH, PlayerVitaeScene.PAGE_DEFAULT)
end

function PlayerVitaeShipsPage:OnDestroy()
	self:Hide()

	for iter_60_0, iter_60_1 in pairs(self.cards) do
		for iter_60_2, iter_60_3 in pairs(iter_60_1) do
			iter_60_3:Dispose()
		end
	end

	self.exited = true
end

return PlayerVitaeShipsPage
