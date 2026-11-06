local ShipMainScene = class("ShipMainScene", import("...base.BaseUI"))
local var_0_1 = 0
local var_0_2 = 0.2
local var_0_3 = 0.3
local var_0_4 = 3
local var_0_6 = 11

function ShipMainScene:getUIName()
	return "ShipMainScene"
end

function ShipMainScene:ResUISettings()
	return true
end

function ShipMainScene:getResource()
	local var_3_0 = getProxy(BayProxy):getShipById(self.contextData.shipId)
	local var_3_1 = {
		"ui/ShipDetailView",
		"bg/star_level_bg_" .. var_3_0:rarity2bgPrintForGet(),
		"ui/star_level_bg_" .. var_3_0:rarity2bgPrintForGet()
	}
	local var_3_2 = var_3_0:getRarity()
	local var_3_3 = pg.ship_skin_template[var_3_0:getSkinId()]

	if var_3_2 > 2 and not (var_3_3.rarity_bg and var_3_3.rarity_bg ~= "") then
		table.insert(var_3_1, "ui/al_bg02_" .. var_3_2 - 1)
	end

	return table.insertto(var_3_1, ShipMainScene.super.getResource(self))
end

function ShipMainScene:preload(arg_4_1)
	local var_4_0 = getProxy(BayProxy):getShipById(self.contextData.shipId)

	parallelAsync({
		function(arg_5_0)
			GetSpriteFromAtlasAsync("bg/star_level_bg_" .. var_4_0:rarity2bgPrintForGet(), "", arg_5_0)
		end,
		function(arg_6_0)
			if self.exited then
				return
			end

			PoolMgr.GetInstance():PreloadUI("ShipDetailView", arg_6_0)
		end
	}, arg_4_1)
end

function ShipMainScene:setPlayer(arg_7_1)
	self.player = arg_7_1

	self:GetShareData():SetPlayer(arg_7_1)
end

function ShipMainScene:setShipList(arg_8_1)
	self.shipList = arg_8_1
end

function ShipMainScene:setShip(arg_9_1)
	self:GetShareData():SetShipVO(arg_9_1)

	local var_9_0 = false

	if self.shipVO and self.shipVO.id ~= arg_9_1.id then
		self:StopPreVoice()

		var_9_0 = true
	end

	self.shipVO = arg_9_1

	SplitPackConst.DownloadByLuaArr(ResPathSupport.GetShipAllRes(arg_9_1), function()
		if self.exited or self.shipVO ~= arg_9_1 then
			return
		end

		setActive(self.npcFlagTF, arg_9_1:isActivityNpc())
		self:setToggleEnable()

		local var_10_0 = pg.ship_skin_template[self.shipVO:getSkinId()]

		self.isSpBg = var_10_0.rarity_bg and var_10_0.rarity_bg ~= ""

		self:updatePreference(arg_9_1)
		self.shipDetailView:ActionInvokeExclusive("UpdateUI")
		self.shipFashionView:ActionInvokeExclusive("UpdateUI")
		self.shipEquipView:ActionInvokeExclusive("UpdateUI")

		if var_9_0 and not self:checkToggleActive(ShipViewConst.currentPage) then
			triggerToggle(self.detailToggle, true)
		end
	end)
end

function ShipMainScene:equipmentChange()
	if self.shipDetailView then
		self.shipDetailView:ActionInvoke("UpdateUI")
	end
end

function ShipMainScene:setToggleEnable()
	for iter_12_0, iter_12_1 in pairs(self.togglesList) do
		setActive(iter_12_1, self:checkToggleActive(iter_12_0))
	end

	setActive(self.technologyToggle, self.shipVO:isBluePrintShip())
	SetActive(self.metaToggle, self.shipVO:isMetaShip())
end

function ShipMainScene:checkToggleActive(arg_13_1)
	if arg_13_1 == ShipViewConst.PAGE.DETAIL then
		return true
	elseif arg_13_1 == ShipViewConst.PAGE.EQUIPMENT then
		return true
	elseif arg_13_1 == ShipViewConst.PAGE.INTENSIFY then
		return not self.shipVO:isTestShip() and not self.shipVO:isBluePrintShip() and not self.shipVO:isMetaShip()
	elseif arg_13_1 == ShipViewConst.PAGE.UPGRADE then
		return not self.shipVO:isTestShip() and not self.shipVO:isBluePrintShip() and not self.shipVO:isMetaShip()
	elseif arg_13_1 == ShipViewConst.PAGE.REMOULD then
		local var_13_0 = not self.shipVO:isTestShip() and not self.shipVO:isBluePrintShip() and pg.ship_data_trans[self.shipVO.groupId] and not self.shipVO:isMetaShip() or false

		return (false or nil) and true
	elseif arg_13_1 == ShipViewConst.PAGE.FASHION then
		if not self:hasFashion() then
			return false
		else
			return not ((PaintingGroupConst.IsPaintingNeedCheck() or false) and PaintingGroupConst.CalcPaintingListSize((PaintingGroupConst.GetPaintingNameListByShipVO(self.shipVO))) > 0)
		end
	else
		return false
	end
end

function ShipMainScene:setSkinList(arg_14_1)
	self.shipFashionView:ActionInvoke("SetSkinList", arg_14_1)
end

function ShipMainScene:updateLock()
	self.shipDetailView:ActionInvoke("UpdateLock")
end

function ShipMainScene:updatePreferenceTag()
	self.shipDetailView:ActionInvoke("UpdatePreferenceTag")
end

function ShipMainScene:updateFashionTag()
	self.shipDetailView:ActionInvoke("UpdateFashionTag")
end

function ShipMainScene:closeRecordPanel()
	self.shipDetailView:ActionInvoke("CloseRecordPanel")
end

function ShipMainScene:updateRecordEquipments(arg_19_1)
	self.shipDetailView:UpdateRecordEquipments(arg_19_1)
	self.shipDetailView:UpdateRecordSpWeapons(arg_19_1)
end

function ShipMainScene:setModPanel(arg_20_1)
	self.modPanel = arg_20_1
end

function ShipMainScene:setMaxLevelHelpFlag(arg_21_1)
	self.maxLevelHelpFlag = arg_21_1
end

function ShipMainScene:checkMaxLevelHelp()
	if not self.maxLevelHelpFlag and self.shipVO and self.shipVO:isReachNextMaxLevel() then
		self:openHelpPage()

		self.maxLevelHelpFlag = true

		getProxy(SettingsProxy):setMaxLevelHelp(true)
	end
end

function ShipMainScene:GetShareData()
	if not self.shareData then
		self.shareData = ShipViewShareData.New(self.contextData)

		self.shipDetailView:SetShareData(self.shareData)
		self.shipFashionView:SetShareData(self.shareData)
		self.shipEquipView:SetShareData(self.shareData)
		self.shipEquipView:ActionInvoke("InitEvent")
		self.shipHuntingRangeView:SetShareData(self.shareData)
		self.shipCustomMsgBox:SetShareData(self.shareData)
		self.shipChangeNameView:SetShareData(self.shareData)
	end

	return self.shareData
end

function ShipMainScene:hasFashion()
	return self.shareData:HasFashion()
end

function ShipMainScene:DisplayRenamePanel(arg_25_1)
	self.shipChangeNameView:Load()
	self.shipChangeNameView:ActionInvoke("DisplayRenamePanel", arg_25_1)
end

function ShipMainScene:init()
	self:initShip()
	self:initPages()
	self:initEvents()

	self.bgEffect = self.bgEffect or {}
	self.mainCanvasGroup = self._tf:GetComponent(typeof(CanvasGroup))
	self.commonCanvasGroup = self._tf:Find("blur_panel/adapt"):GetComponent(typeof(CanvasGroup))
	Input.multiTouchEnabled = false
end

function ShipMainScene:initShip()
	self.shipInfo = self._tf:Find("main/character")

	setActive(self.shipInfo, true)

	self.tablePainting = {
		self.shipInfo:Find("painting"),
		self.shipInfo:Find("painting2")
	}
	self.nowPainting = nil
	self.isRight = true
	self.blurPanel = self._tf:Find("blur_panel")
	self.common = self.blurPanel:Find("adapt")
	self.npcFlagTF = self.common:Find("name/npc")
	self.shipName = self.common:Find("name")
	self.shipInfoStarTpl = self.shipName:Find("star_tpl")
	self.nameEditFlag = self.shipName:Find("nameRect/editFlag")

	setActive(self.shipName, true)
	setActive(self.shipInfoStarTpl, false)
	setActive(self.nameEditFlag, false)

	self.energyTF = self.shipName:Find("energy")
	self.energyDescTF = self.energyTF:Find("desc")
	self.energyText = self.energyTF:Find("desc/desc")

	setActive(self.energyDescTF, false)

	self.character = self._tf:Find("main/character")
	self.chat = self._tf:Find("main/character/chat")
	self.chatBg = self._tf:Find("main/character/chat/chatbgtop")
	self.chatText = self.chat:Find("Text")
	rtf(self.chat).localScale = Vector3.New(0, 0, 1)
	self.initChatBgH = self.chatBg.sizeDelta.y
	self.initChatTextH = self.chatText.sizeDelta.y
	self.initfontSize = self.chatText:GetComponent(typeof(Text)).fontSize
end

function ShipMainScene:initPages()
	ShipViewConst.currentPage = nil
	self.background = self._tf:Find("background")

	setActive(self.background, true)

	self.main = self._tf:Find("main")
	self.mainMask = self.main:GetComponent(typeof(RectMask2D))
	self.toggles = self.common:Find("left_length/frame/root")
	self.detailToggle = self.toggles:Find("detail_toggle")
	self.equipmentToggle = self.toggles:Find("equpiment_toggle")
	self.intensifyToggle = self.toggles:Find("intensify_toggle")
	self.upgradeToggle = self.toggles:Find("upgrade_toggle")
	self.remouldToggle = self.toggles:Find("remould_toggle")
	self.technologyToggle = self.toggles:Find("technology_toggle")
	self.metaToggle = self.toggles:Find("meta_toggle")
	self.togglesList = {}
	self.togglesList[ShipViewConst.PAGE.DETAIL] = self.detailToggle
	self.togglesList[ShipViewConst.PAGE.EQUIPMENT] = self.equipmentToggle
	self.togglesList[ShipViewConst.PAGE.INTENSIFY] = self.intensifyToggle
	self.togglesList[ShipViewConst.PAGE.UPGRADE] = self.upgradeToggle
	self.togglesList[ShipViewConst.PAGE.REMOULD] = self.remouldToggle
	self.detailContainer = self.main:Find("detail_container")

	setAnchoredPosition(self.detailContainer, {
		x = 1300
	})

	self.fashionContainer = self.main:Find("fashion_container")

	setAnchoredPosition(self.fashionContainer, {
		x = 900
	})

	self.equipContainer = self.main:Find("equip_container")
	self.equipLCon = self.equipContainer:Find("equipment_l_container")
	self.equipRCon = self.equipContainer:Find("equipment_r_container")
	self.equipBCon = self.equipContainer:Find("equipment_b_container")

	setAnchoredPosition(self.equipRCon, {
		x = 750
	})
	setAnchoredPosition(self.equipLCon, {
		x = -700
	})
	setAnchoredPosition(self.equipBCon, {
		y = -540
	})

	self.shipDetailView = ShipDetailView.New(self.detailContainer, self.event, self.contextData)
	self.shipFashionView = ShipFashionView.New(self.fashionContainer, self.event, self.contextData)
	self.shipEquipView = ShipEquipView.New(self.equipContainer, self.event, self.contextData)
	self.shipHuntingRangeView = ShipHuntingRangeView.New(self._tf, self.event, self.contextData)
	self.shipCustomMsgBox = ShipCustomMsgBox.New(self._tf, self.event, self.contextData)
	self.shipChangeNameView = ShipChangeNameView.New(self._tf, self.event, self.contextData)
	self.expItemUsagePage = ShipExpItemUsagePage.New(self._tf, self.event, self.contextData)

	for iter_28_0, iter_28_1 in ipairs({
		self.shipDetailView,
		self.shipFashionView,
		self.shipEquipView,
		self.shipHuntingRangeView,
		self.shipCustomMsgBox,
		self.shipChangeNameView,
		self.expItemUsagePage
	}) do
		iter_28_1:RegisterView(self)
	end

	self.viewList = {}
	self.viewList[ShipViewConst.PAGE.DETAIL] = self.shipDetailView
	self.viewList[ShipViewConst.PAGE.FASHION] = self.shipFashionView
	self.viewList[ShipViewConst.PAGE.EQUIPMENT] = self.shipEquipView

	onButton(self, self.shipName, function()
		if self.shipVO.propose and not self.shipVO:IsXIdol() then
			if not pg.PushNotificationMgr.GetInstance():isEnableShipName() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("word_rename_switch_tip"))

				return
			end

			local var_29_0 = self.shipVO.renameTime + 2592000 - pg.TimeMgr.GetInstance():GetServerTime()

			if var_29_0 > 0 then
				local var_29_1 = math.floor(var_29_0 / 60 / 60 / 24)

				if var_29_1 < 1 then
					var_29_1 = 1
				end

				pg.TipsMgr.GetInstance():ShowTips(i18n("word_rename_time_tip", var_29_1))
			else
				self:DisplayRenamePanel(true)
			end
		end
	end, SFX_PANEL)
end

function ShipMainScene:initEvents()
	self:bind(ShipViewConst.SWITCH_TO_PAGE, function(arg_31_0, arg_31_1)
		self:gotoPage(arg_31_1)
	end)
	self:bind(ShipViewConst.LOAD_PAINTING, function(arg_32_0, arg_32_1, arg_32_2)
		self:loadPainting(arg_32_1, arg_32_2)
	end)
	self:bind(ShipViewConst.LOAD_PAINTING_BG, function(arg_33_0, arg_33_1, arg_33_2, arg_33_3)
		self:loadSkinBg(arg_33_1, arg_33_2, arg_33_3, self.isSpBg)
	end)
	self:bind(ShipViewConst.HIDE_SHIP_WORD, function(arg_34_0)
		self:hideShipWord()
	end)
	self:bind(ShipViewConst.SET_CLICK_ENABLE, function(arg_35_0, arg_35_1)
		self.mainCanvasGroup.blocksRaycasts = arg_35_1
		self.commonCanvasGroup.blocksRaycasts = arg_35_1
		GetOrAddComponent(self.detailContainer, "CanvasGroup").blocksRaycasts = arg_35_1
	end)
	self:bind(ShipViewConst.SHOW_CUSTOM_MSG, function(arg_36_0, arg_36_1)
		self.shipCustomMsgBox:Load()
		self.shipCustomMsgBox:ActionInvoke("showCustomMsgBox", arg_36_1)
	end)
	self:bind(ShipViewConst.HIDE_CUSTOM_MSG, function(arg_37_0)
		self.shipCustomMsgBox:ActionInvoke("hideCustomMsgBox")
	end)
	self:bind(ShipViewConst.DISPLAY_HUNTING_RANGE, function(arg_38_0, arg_38_1)
		if arg_38_1 then
			self.shipHuntingRangeView:Load()
			self.shipHuntingRangeView:ActionInvoke("DisplayHuntingRange")
		else
			self.shipHuntingRangeView:HideHuntingRange()
		end
	end)
	self:bind(ShipViewConst.PAINT_VIEW, function(arg_39_0, arg_39_1)
		if arg_39_1 then
			self:paintView()
		else
			self:hidePaintView(true)
		end
	end)
	self:bind(ShipViewConst.SHOW_EXP_ITEM_USAGE, function(arg_40_0, arg_40_1)
		self.expItemUsagePage:ExecuteAction("Show", arg_40_1)
	end)
end

function ShipMainScene:didEnter()
	self:addRingDragListenter()
	onButton(self, self.common:Find("top/back_btn"), function()
		GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

		if not self.everTriggerBack then
			LeanTween.delayedCall(0.3, System.Action(function()
				self:closeView()
			end))

			self.everTriggerBack = true
		end
	end, SFX_CANCEL)
	onButton(self, self.npcFlagTF, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_actnpc.tip
		})
	end, SFX_PANEL)

	self.helpBtn = self.common:Find("help_btn")

	onButton(self, self.helpBtn, function()
		self:openHelpPage(ShipViewConst.currentPage)
	end, SFX_PANEL)

	for iter_41_0, iter_41_1 in pairs(self.togglesList) do
		if iter_41_1 == self.upgradeToggle or iter_41_1 == self.remouldToggle or iter_41_1 == self.equipmentToggle then
			onToggle(self, iter_41_1, function(arg_46_0)
				if arg_46_0 then
					if LeanTween.isTweening(go(self.chat)) then
						LeanTween.cancel(go(self.chat))
					end

					rtf(self.chat).localScale = Vector3.New(0, 0, 1)
					self.chatFlag = false

					self:switchToPage(iter_41_0)
				end
			end, SFX_PANEL)
		else
			onToggle(self, iter_41_1, function(arg_47_0)
				if arg_47_0 then
					self:switchToPage(iter_41_0)
				end
			end, SFX_PANEL)
		end
	end

	onButton(self, self.technologyToggle, function()
		self:emit(ShipMainMediator.ON_TECHNOLOGY, self.shipVO)
	end, SFX_PANEL)
	onButton(self, self.metaToggle, function()
		self:emit(ShipMainMediator.ON_META, self.shipVO)
	end, SFX_PANEL)
	onButton(self, tf(self.character), function()
		if ShipViewConst.currentPage ~= ShipViewConst.PAGE.FASHION then
			self:displayShipWord("detail")
		end
	end)
	onButton(self, self.energyTF, function()
		self:showEnergyDesc()
		getProxy(CommanderManualProxy):TaskProgressAdd(2022, 1)
	end)
	self:OverlayPanel(self.chat, {
		groupDelta = 1
	})
	self:OverlayPanel(self.blurPanel)

	local var_41_0

	if self:checkToggleActive(self.contextData.page) then
		var_41_0 = self.contextData.page or ShipViewConst.PAGE.DETAIL
	end

	self:gotoPage(var_41_0)

	if ShipViewConst.currentPage == ShipViewConst.PAGE.DETAIL or var_41_0 == ShipViewConst.PAGE.DETAIL then
		self:displayShipWord(self:getInitmacyWords())
		self:checkMaxLevelHelp()
	end

	self:changePaintingSortLayer(true)
end

function ShipMainScene:openHelpPage(arg_52_1)
	if arg_52_1 == ShipViewConst.PAGE.EQUIPMENT then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_equip.tip
		})
	elseif arg_52_1 == ShipViewConst.PAGE.DETAIL then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_detail.tip
		})
	elseif arg_52_1 == ShipViewConst.PAGE.INTENSIFY then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_intensify.tip
		})
	elseif arg_52_1 == ShipViewConst.PAGE.UPGRADE then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_upgrate.tip
		})
	elseif arg_52_1 == ShipViewConst.PAGE.FASHION then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_fashion.tip
		})
	else
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_shipinfo_maxlevel.tip
		})
	end
end

function ShipMainScene:showAwakenCompleteAni(arg_53_1)
	local function var_53_0()
		self.awakenAni:SetActive(true)

		self.awakenPlay = true

		onButton(self, self.awakenAni, function()
			self.awakenAni:GetComponent("Animator"):SetBool("endFlag", true)
		end)

		local var_54_0 = tf(self.awakenAni)

		pg.UIMgr.GetInstance():BlurPanel(var_54_0)
		setText(var_54_0:Find("window/desc"), arg_53_1)
		var_54_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_56_0)
			self.awakenAni:GetComponent("Animator"):SetBool("endFlag", false)
			pg.UIMgr.GetInstance():UnOverlayPanel(var_54_0, self.common)
			self.awakenAni:SetActive(false)

			self.awakenPlay = false
		end)
	end

	local var_53_1 = self._tf:Find("AwakenCompleteWindows(Clone)")

	if var_53_1 then
		self.awakenAni = go(var_53_1)
	end

	if not self.awakenAni then
		PoolMgr.GetInstance():GetUI("AwakenCompleteWindows", true, function(arg_57_0)
			arg_57_0:SetActive(true)

			self.awakenAni = arg_57_0

			var_53_0()
		end)
	else
		var_53_0()
	end
end

function ShipMainScene:updatePreference(arg_58_1)
	setScrollText(self.shipName:Find("nameRect/name_mask/Text"), (self.shipVO:getName()))
	setText(self.shipName:Find("english_name"), arg_58_1:getConfigTable().english_name)
	setActive(self.nameEditFlag, arg_58_1.propose and not arg_58_1:IsXIdol())

	local var_58_0 = GetSpriteFromAtlas("energy", arg_58_1:getEnergyPrint())

	if not var_58_0 then
		warning("找不到疲劳")
	end

	setImageSprite(self.energyTF, var_58_0, true)
	setActive(self.energyTF, true)

	local var_58_1 = self.shipName:Find("stars")

	removeAllChildren(var_58_1)

	local var_58_2 = arg_58_1:getStar()

	for iter_58_0 = 1, arg_58_1:getMaxStar() do
		local var_58_3 = cloneTplTo(self.shipInfoStarTpl, var_58_1, "star_" .. iter_58_0)

		setActive(var_58_3:Find("star_tpl"), iter_58_0 <= var_58_2)
		setActive(var_58_3:Find("empty_star_tpl"), true)
	end

	if ShipViewConst.currentPage ~= ShipViewConst.PAGE.FASHION then
		self:loadPainting(self.shipVO:getPainting())
		self:loadSkinBg(self.shipVO:rarity2bgPrintForGet(), self.shipVO:isBluePrintShip(), self.shipVO:isMetaShip(), self.isSpBg)
	end

	local var_58_4 = GetSpriteFromAtlas("shiptype", arg_58_1:getShipType())

	if not var_58_4 then
		warning("找不到船形, shipConfigId: " .. arg_58_1.configId)
	end

	setImageSprite(self.shipName:Find("type"), var_58_4, true)
end

function ShipMainScene:doUpgradeMaxLeveAnim(arg_59_1, arg_59_2, arg_59_3)
	self.inUpgradeAnim = true

	self.shipDetailView:DoLeveUpAnim(arg_59_1, arg_59_2, function()
		if arg_59_3 then
			arg_59_3()
		end

		self.inUpgradeAnim = nil
	end)
end

function ShipMainScene:addRingDragListenter()
	local var_61_0 = GetOrAddComponent(self._tf, "EventTriggerListener")
	local var_61_1
	local var_61_2 = 0

	var_61_0:AddBeginDragFunc(function()
		var_61_2 = 0
		var_61_1 = nil
	end)
	var_61_0:AddDragFunc(function(arg_63_0, arg_63_1)
		if not self.inPaintingView then
			var_61_1 = var_61_1 or arg_63_1.position
			var_61_2 = arg_63_1.position.x - var_61_1.x
		end
	end)
	var_61_0:AddDragEndFunc(function(arg_64_0, arg_64_1)
		if not self.inPaintingView then
			if var_61_2 < -50 then
				if not self.isLoading then
					self:emit(ShipMainMediator.NEXTSHIP, -1)
				end
			elseif var_61_2 > 50 and not self.isLoading then
				self:emit(ShipMainMediator.NEXTSHIP)
			end
		end
	end)
end

function ShipMainScene:showEnergyDesc()
	if self.energyTimer then
		return
	end

	setActive(self.energyDescTF, true)

	local var_65_0, var_65_1 = self.shipVO:getEnergyPrint()

	setText(self.energyText, i18n(var_65_1))

	self.energyTimer = Timer.New(function()
		setActive(self.energyDescTF, false)
		self.energyTimer:Stop()

		self.energyTimer = nil
	end, 2, 1)

	self.energyTimer:Start()
end

function ShipMainScene:displayShipWord(arg_67_1, arg_67_2)
	if ShipViewConst.currentPage == ShipViewConst.PAGE.EQUIPMENT or ShipViewConst.currentPage == ShipViewConst.PAGE.UPGRADE then
		rtf(self.chat).localScale = Vector3.New(0, 0, 1)

		return
	end

	if arg_67_2 or not self.chatFlag then
		self.chatFlag = true
		self.chat.localScale = Vector3.zero

		setActive(self.chat, true)

		self.chat.localPosition = Vector3(self.character.localPosition.x + 100, self.chat.localPosition.y, 0)

		local var_67_0 = self.shipVO:getCVIntimacy()

		if findTF(self.nowPainting, "fitter").childCount > 0 then
			ShipExpressionHelper.SetExpression(findTF(self.nowPainting, "fitter"):GetChild(0), self.paintingCode, arg_67_1, var_67_0)
		end

		local var_67_1, var_67_2, var_67_3 = ShipWordHelper.GetWordAndCV(self.shipVO:getSkinId(), arg_67_1, nil, nil, var_67_0)
		local var_67_4 = self.chatText:GetComponent(typeof(Text))

		if PLATFORM_CODE ~= PLATFORM_US then
			setText(self.chatText, SwitchSpecialChar(var_67_3))
		else
			var_67_4.fontSize = self.initfontSize

			setTextEN(self.chatText, var_67_3)

			while var_67_4.preferredHeight > self.initChatTextH do
				var_67_4.fontSize = var_67_4.fontSize - 2

				setTextEN(self.chatText, var_67_3)

				if var_67_4.fontSize < 20 then
					break
				end
			end
		end

		var_67_4.alignment = #var_67_4.text > CHAT_POP_STR_LEN and TextAnchor.MiddleLeft or TextAnchor.MiddleCenter
		self.chatBg.sizeDelta = var_67_4.preferredHeight + 120 > self.initChatBgH and Vector2.New(self.chatBg.sizeDelta.x, var_67_4.preferredHeight + 120) or Vector2.New(self.chatBg.sizeDelta.x, self.initChatBgH)

		local var_67_5 = var_0_4

		local function var_67_6()
			if self.chatFlag then
				if self.chatani1Id then
					LeanTween.cancel(self.chatani1Id)
				end

				if self.chatani2Id then
					LeanTween.cancel(self.chatani2Id)
				end
			end

			self.chatani1Id = LeanTween.scale(rtf(self.chat.gameObject), Vector3.New(1, 1, 1), var_0_3):setEase(LeanTweenType.easeOutBack):setOnComplete(System.Action(function()
				self.chatani2Id = LeanTween.scale(rtf(self.chat.gameObject), Vector3.New(0, 0, 1), var_0_3):setEase(LeanTweenType.easeInBack):setDelay(var_0_3 + var_67_5):setOnComplete(System.Action(function()
					self.chatFlag = nil
				end)).uniqueId
			end)).uniqueId
		end

		if var_67_2 then
			self:StopPreVoice()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(var_67_2, function(arg_71_0)
				if arg_71_0 then
					var_67_5 = arg_71_0:GetLength() * 0.001
				end

				var_67_6()
			end)

			self.preVoiceContent = var_67_2
		else
			var_67_6()
		end
	end
end

function ShipMainScene:StopPreVoice()
	if self.preVoiceContent ~= nil then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self.preVoiceContent)
	end
end

function ShipMainScene:startChatTimer()
	if self.chatFlag then
		return
	end

	if self.chatTimer then
		self.chatTimer:Stop()

		self.chatTimer = nil
	end

	self.chatTimer = Timer.New(function()
		self:displayShipWord(self:getInitmacyWords())
	end, var_0_6, 1)

	self.chatTimer:Start()
end

function ShipMainScene:hideShipWord()
	if self.chatFlag then
		if self.chatani1Id then
			LeanTween.cancel(self.chatani1Id)
		end

		if self.chatani2Id then
			LeanTween.cancel(self.chatani2Id)
		end

		LeanTween.scale(rtf(self.chat.gameObject), Vector3.New(0, 0, 1), var_0_3):setEase(LeanTweenType.easeInBack):setOnComplete(System.Action(function()
			self.chatFlag = nil
		end))
	end

	self:StopPreVoice()
end

function ShipMainScene:gotoPage(arg_77_1)
	if arg_77_1 == ShipViewConst.PAGE.FASHION then
		self:checkPaintingRes(function()
			self:switchToPage(arg_77_1)
		end)
	else
		triggerToggle(self.togglesList[arg_77_1], true)
	end
end

function ShipMainScene:switchToPage(arg_79_1, arg_79_2)
	local function var_79_0(arg_80_0, arg_80_1)
		setActive(self.detailContainer, false)

		if arg_80_0 == ShipViewConst.PAGE.DETAIL then
			setActive(self.detailContainer, arg_80_1)

			local var_80_0 = arg_80_1 and {
				self.detailContainer.rect.width + 200,
				0
			} or {
				0,
				self.detailContainer.rect.width + 200
			}

			shiftPanel(self.detailContainer, var_80_0[2], 0, var_0_2, 0):setFrom(var_80_0[1])
		elseif arg_80_0 == ShipViewConst.PAGE.EQUIPMENT then
			local var_80_1 = {
				-(self.equipLCon.rect.width + 190),
				190
			}
			local var_80_2 = {
				self.equipRCon.rect.width,
				10
			}
			local var_80_3 = {
				-self.equipBCon.rect.height,
				0
			}
			local var_80_4 = arg_80_1 and 1 or 2
			local var_80_5 = arg_80_1 and 2 or 1

			shiftPanel(self.equipLCon, var_80_1[arg_80_1 and 2 or 1], 0, var_0_2, 0):setFrom(var_80_1[arg_80_1 and 1 or 2])
			shiftPanel(self.equipRCon, var_80_2[var_80_5], 0, var_0_2, 0):setFrom(var_80_2[var_80_4])
			shiftPanel(self.equipBCon, 0, var_80_3[var_80_5], var_0_2, 0):setFrom(var_80_3[var_80_4])
		elseif arg_80_0 == ShipViewConst.PAGE.FASHION then
			local var_80_6 = arg_80_1 and {
				self.fashionContainer.rect.width + 150,
				0
			} or {
				0,
				self.fashionContainer.rect.width + 150
			}

			shiftPanel(self.fashionContainer, var_80_6[2], 0, var_0_2, 0):setFrom(var_80_6[1])

			if arg_80_1 then
				self.shipFashionView:ActionInvoke("UpdateFashion")
			end
		elseif arg_80_0 == ShipViewConst.PAGE.INTENSIFY then
			if arg_80_1 then
				self:emit(ShipMainMediator.OPEN_INTENSIFY)
			else
				self:emit(ShipMainMediator.CLOSE_INTENSIFY)
			end
		elseif arg_80_0 == ShipViewConst.PAGE.UPGRADE then
			if arg_80_1 then
				self:emit(ShipMainMediator.ON_UPGRADE)
			else
				self:emit(ShipMainMediator.CLOSE_UPGRADE)
			end
		elseif arg_80_0 == ShipViewConst.PAGE.REMOULD then
			if arg_80_1 then
				self:emit(ShipMainMediator.OPEN_REMOULD)
			else
				self:emit(ShipMainMediator.CLOSE_REMOULD)
			end
		end

		self:blurPage(arg_80_0, arg_80_1)

		if arg_80_0 ~= ShipViewConst.PAGE.FASHION then
			self.fashionSkinId = self.shipVO:getSkinId()

			self:loadPainting(self.shipVO:getPainting())
		end

		local var_80_7 = not ShipViewConst.IsSubLayerPage(arg_80_0)
		local var_80_8 = self.bgEffect and self.bgEffect[self.shipVO:getRarity()]

		if var_80_8 then
			setActive(var_80_8, (arg_80_0 ~= ShipViewConst.PAGE.REMOULD or nil) and self.shipVO.bluePrintFlag and self.shipVO.bluePrintFlag == 0)
			self:changePaintingSortLayer(true)
		end

		setActive(self.helpBtn, var_80_7)
	end

	function switchHandler()
		if arg_79_1 == ShipViewConst.currentPage and arg_79_2 then
			var_79_0(arg_79_1, true)
		elseif arg_79_1 ~= ShipViewConst.currentPage then
			if ShipViewConst.currentPage then
				var_79_0(ShipViewConst.currentPage, false)
			end

			ShipViewConst.currentPage = arg_79_1
			self.contextData.page = arg_79_1

			var_79_0(arg_79_1, true)
			self:switchPainting()
		end
	end

	if self.viewList[arg_79_1] ~= nil then
		if not self.viewList[arg_79_1]:GetLoaded() then
			self.viewList[arg_79_1]:Load()
			self.viewList[arg_79_1]:CallbackInvoke(switchHandler)
		else
			switchHandler()
		end
	else
		switchHandler()
	end
end

function ShipMainScene:blurPage(arg_82_1, arg_82_2)
	if arg_82_1 == ShipViewConst.PAGE.DETAIL then
		self.shipDetailView:ActionInvoke("OnSelected", arg_82_2)
	elseif arg_82_1 == ShipViewConst.PAGE.EQUIPMENT then
		self.shipEquipView:ActionInvoke("OnSelected", arg_82_2)
	elseif arg_82_1 == ShipViewConst.PAGE.FASHION then
		self.shipFashionView:ActionInvoke("OnSelected", arg_82_2)
	elseif arg_82_1 == ShipViewConst.PAGE.INTENSIFY then
		-- block empty
	elseif arg_82_1 == ShipViewConst.PAGE.UPGRADE then
		-- block empty
	elseif arg_82_1 == ShipViewConst.PAGE.REMOULD then
		-- block empty
	end
end

function ShipMainScene:switchPainting()
	setActive(self.shipInfo, not ShipViewConst.IsSubLayerPage(ShipViewConst.currentPage))
	setActive(self.shipName, not ShipViewConst.IsSubLayerPage(ShipViewConst.currentPage))

	if ShipViewConst.currentPage == ShipViewConst.PAGE.EQUIPMENT then
		shiftPanel(self.shipInfo, -20, 0, var_0_2, 0)

		self.paintingFrameName = "zhuangbei"
	else
		shiftPanel(self.shipInfo, -460, 0, var_0_2, 0)

		self.paintingFrameName = "chuanwu"
	end

	local var_83_0 = GetOrAddComponent(findTF(self.nowPainting, "fitter"), "PaintingScaler")

	var_83_0:Snapshoot()

	var_83_0.FrameName = self.paintingFrameName

	local var_83_1 = LeanTween.value(go(self.nowPainting), 0, 1, var_0_2):setOnUpdate(System.Action_float(function(arg_84_0)
		var_83_0.Tween = arg_84_0
		self.chat.localPosition = Vector3(self.character.localPosition.x + 100, self.chat.localPosition.y, 0)
	end)):setEase(LeanTweenType.easeInOutSine)
end

function ShipMainScene:setPreOrNext(arg_85_1, arg_85_2)
	self.isRight = not not arg_85_1

	if self.shipVO:getGroupId() ~= arg_85_2:getGroupId() then
		self.switchCnt = (self.switchCnt or 0) + 1
	end

	if self.switchCnt and self.switchCnt >= 10 then
		gcAll()

		self.switchCnt = 0
	end
end

function ShipMainScene:loadPainting(arg_86_1, arg_86_2)
	local var_86_0 = arg_86_1

	arg_86_1 = MainMeshImagePainting.StaticGetPaintingName(arg_86_1)

	if self.isLoading == true then
		return
	end

	for iter_86_0, iter_86_1 in pairs(self.tablePainting) do
		iter_86_1.localScale = Vector3(1, 1, 1)
	end

	if self.LoadShipVOId and not arg_86_2 and self.LoadShipVOId == self.shipVO.id and self.LoadPaintingCode == arg_86_1 and not arg_86_2 then
		return
	end

	local var_86_2 = self.isRight and 1800 or -1800
	local var_86_3 = self:getPaintingFromTable(false)

	self.isLoading = true

	local var_86_4 = self.paintingCode
	local var_86_5 = {}

	if var_86_3 then
		table.insert(var_86_5, function(arg_87_0)
			local var_87_0 = var_86_3:GetComponent(typeof(CanvasGroup))

			LeanTween.cancel(go(var_87_0))
			LeanTween.alphaCanvas(var_87_0, 0, 0.3):setFrom(1):setUseEstimatedTime(true)
			LeanTween.moveX(var_86_3:GetComponent(typeof(RectTransform)), -var_86_2, 0.3):setFrom(0):setOnComplete(System.Action(function()
				retPaintingPrefab(var_86_3, var_86_4)
				arg_87_0()
			end))
		end)
	end

	local var_86_6 = self:getPaintingFromTable(true)

	self.paintingCode = arg_86_1

	if self.paintingCode and var_86_6 then
		local var_86_7 = var_86_6:GetComponent(typeof(RectTransform))

		table.insert(var_86_5, function(arg_89_0)
			self.nowPainting = var_86_6

			LoadPaintingPrefabAsync(var_86_6, var_86_0, self.paintingCode, self.paintingFrameName or "chuanwu", function()
				ShipExpressionHelper.SetExpression(findTF(var_86_6, "fitter"):GetChild(0), self.paintingCode, self:getInitmacyWords(), (self.shipVO:getCVIntimacy()))
				arg_89_0()
			end)
		end)
		table.insert(var_86_5, function(arg_91_0)
			LeanTween.cancel(go(var_86_7))
			LeanTween.moveX(var_86_7, 0, 0.3):setFrom(var_86_2):setOnComplete(System.Action(arg_91_0))
			LeanTween.alphaCanvas(var_86_6:GetComponent(typeof(CanvasGroup)), 1, 0.3):setFrom(0):setUseEstimatedTime(true)
		end)
	end

	parallelAsync(var_86_5, function()
		self.LoadShipVOId = self.shipVO.id
		self.LoadPaintingCode = arg_86_1
		self.isLoading = false
	end)
end

function ShipMainScene:getPaintingFromTable(arg_93_1)
	if self.tablePainting == nil then
		print("self.tablePainting为空")

		return
	end

	for iter_93_0 = 1, #self.tablePainting do
		if findTF(self.tablePainting[iter_93_0], "fitter").childCount == 0 then
			if arg_93_1 == true and self.tablePainting[iter_93_0] then
				return self.tablePainting[iter_93_0]
			end
		elseif arg_93_1 == false and self.tablePainting[iter_93_0] then
			return self.tablePainting[iter_93_0]
		end
	end
end

function ShipMainScene:loadSkinBg(arg_94_1, arg_94_2, arg_94_3, arg_94_4)
	self.bgEffect = self.bgEffect or {}

	if self.shipSkinBg ~= arg_94_1 or self.isDesign ~= arg_94_2 or self.isMeta ~= arg_94_3 then
		self.shipSkinBg = arg_94_1
		self.isDesign = arg_94_2
		self.isMeta = arg_94_3

		if self.isDesign then
			if self.metaBg then
				setActive(self.metaBg, false)
			end

			if self.bgEffect then
				for iter_94_0, iter_94_1 in pairs(self.bgEffect) do
					setActive(iter_94_1, false)
				end
			end

			if self.designBg and self.designName ~= "raritydesign" .. self.shipVO:getRarity() then
				PoolMgr.GetInstance():ReturnUI(self.designName, self.designBg)

				self.designBg = nil
			end

			if not self.designBg then
				PoolMgr.GetInstance():GetUI("raritydesign" .. self.shipVO:getRarity(), true, function(arg_95_0)
					self.designBg = arg_95_0
					self.designName = "raritydesign" .. self.shipVO:getRarity()

					arg_95_0.transform:SetParent(self._tf, false)

					arg_95_0.transform.localPosition = Vector3(1, 1, 1)
					arg_95_0.transform.localScale = Vector3(1, 1, 1)

					arg_95_0.transform:SetSiblingIndex(1)
					setActive(arg_95_0, true)
				end)
			else
				setActive(self.designBg, true)
			end
		elseif self.isMeta then
			if self.designBg then
				setActive(self.designBg, false)
			end

			if self.metaBg and self.metaName ~= "raritymeta" .. self.shipVO:getRarity() then
				PoolMgr.GetInstance():ReturnUI(self.metaName, self.metaBg)

				self.metaBg = nil
			end

			if not self.metaBg then
				PoolMgr.GetInstance():GetUI("raritymeta" .. self.shipVO:getRarity(), true, function(arg_96_0)
					self.metaBg = arg_96_0
					self.metaName = "raritymeta" .. self.shipVO:getRarity()

					arg_96_0.transform:SetParent(self._tf, false)

					arg_96_0.transform.localPosition = Vector3(1, 1, 1)
					arg_96_0.transform.localScale = Vector3(1, 1, 1)

					arg_96_0.transform:SetSiblingIndex(1)
					setActive(arg_96_0, true)
				end)
			else
				setActive(self.metaBg, true)
			end
		else
			if self.designBg then
				setActive(self.designBg, false)
			end

			if self.metaBg then
				setActive(self.metaBg, false)
			end

			for iter_94_2 = 1, 5 do
				local var_94_0 = self.shipVO:getRarity()

				if self.bgEffect[iter_94_2] then
					setActive(self.bgEffect[iter_94_2], iter_94_2 == var_94_0 and ShipViewConst.currentPage ~= ShipViewConst.PAGE.REMOULD and not arg_94_4)
				elseif var_94_0 > 2 and var_94_0 == iter_94_2 and not arg_94_4 then
					PoolMgr.GetInstance():GetUI("al_bg02_" .. var_94_0 - 1, true, function(arg_97_0)
						self.bgEffect[iter_94_2] = arg_97_0

						arg_97_0.transform:SetParent(self._tf, false)

						arg_97_0.transform.localPosition = Vector3(0, 0, 0)
						arg_97_0.transform.localScale = Vector3(1, 1, 1)

						arg_97_0.transform:SetSiblingIndex(1)
						setActive(arg_97_0, not ShipViewConst.IsSubLayerPage(ShipViewConst.currentPage))
					end)
				end

				self:changePaintingSortLayer(true)
			end
		end

		GetSpriteFromAtlasAsync("bg/star_level_bg_" .. arg_94_1, "", function(arg_98_0)
			if not self.exited and self.shipSkinBg == arg_94_1 then
				setImageSprite(self.background, arg_98_0)
			end
		end)
	end
end

function ShipMainScene:changePaintingSortLayer(arg_99_1)
	for iter_99_0, iter_99_1 in ipairs(self.tablePainting) do
		GetComponent(iter_99_1, typeof(Canvas)).sortingOrder = var_99_0
	end

	if arg_99_1 then
		local var_99_2 = self.shipVO:getRarity()

		if self.isDesign and self.designBg then
			setActive(self.designBg, true)
		elseif self.bgEffect and var_99_2 and self.bgEffect[var_99_2] then
			setActive(self.bgEffect[var_99_2], true)
		end
	else
		if self.designBg then
			setActive(self.designBg, false)
		end

		if self.bgEffect then
			for iter_99_2, iter_99_3 in pairs(self.bgEffect) do
				setActive(iter_99_3, false)
			end
		end
	end
end

function ShipMainScene:getInitmacyWords()
	return "feeling" .. Mathf.Clamp(self.shipVO:getIntimacyLevel(), 1, 5)
end

function ShipMainScene:paintView()
	if LeanTween.isTweening(self.chat.gameObject) then
		LeanTween.cancel(self.chat.gameObject)

		self.chat.localScale = Vector3(0, 0, 0)
		self.chatFlag = nil
	end

	self.character:GetComponent("Image").enabled = false
	self.inPaintingView = true

	local var_101_0 = {}
	local var_101_1 = 0

	while var_101_1 < self._tf.childCount do
		local var_101_2 = self._tf:GetChild(var_101_1)

		if var_101_2.gameObject.activeSelf and var_101_2 ~= self.main and var_101_2 ~= self.background then
			var_101_0[#var_101_0 + 1] = var_101_2

			setActive(var_101_2, false)
		end

		var_101_1 = var_101_1 + 1
	end

	local var_101_3 = 0

	while var_101_3 < self.main.childCount do
		local var_101_4 = self.main:GetChild(var_101_3)

		if var_101_4.gameObject.activeSelf and var_101_4 ~= self.shipInfo then
			var_101_0[#var_101_0 + 1] = var_101_4

			setActive(var_101_4, false)
		end

		var_101_3 = var_101_3 + 1
	end

	self.shipDetailView:Hide()
	setActive(self.blurPanel, false)
	setActive(pg.playerResUI._go, false)

	var_101_0[#var_101_0 + 1] = self.chat

	openPortrait()
	setActive(self.common, false)

	self.mainMask.enabled = false

	self.mainMask:PerformClipping()

	local var_101_5 = self.nowPainting.anchoredPosition.x
	local var_101_6 = self.nowPainting.anchoredPosition.y
	local var_101_7 = self._tf.rect.width / UnityEngine.Screen.width
	local var_101_8 = self._tf.rect.height / UnityEngine.Screen.height
	local var_101_9 = self.nowPainting.rect.width / 2
	local var_101_10 = self.nowPainting.rect.height / 2
	local var_101_11
	local var_101_12
	local var_101_13 = GetOrAddComponent(self.background, "PinchZoom")
	local var_101_14 = GetOrAddComponent(self.background, "EventTriggerListener")
	local var_101_15 = true
	local var_101_16 = false

	var_101_14:AddPointDownFunc(function(arg_102_0)
		if Input.touchCount == 1 or IsUnityEditor then
			var_101_16 = true
			var_101_15 = true
		elseif Input.touchCount >= 2 then
			var_101_15 = false
			var_101_16 = false
		end
	end)
	var_101_14:AddPointUpFunc(function(arg_103_0)
		if Input.touchCount <= 2 then
			var_101_15 = true
		end
	end)
	var_101_14:AddBeginDragFunc(function(arg_104_0, arg_104_1)
		var_101_16 = false
		var_101_11 = arg_104_1.position.x * var_101_7 - var_101_9 - tf(self.nowPainting).localPosition.x
		var_101_12 = arg_104_1.position.y * var_101_8 - var_101_10 - tf(self.nowPainting).localPosition.y
	end)
	var_101_14:AddDragFunc(function(arg_105_0, arg_105_1)
		if var_101_13.processing then
			return
		end

		if var_101_15 then
			local var_105_0 = tf(self.nowPainting).localPosition

			tf(self.nowPainting).localPosition = Vector3(arg_105_1.position.x * var_101_7 - var_101_9 - var_101_11, arg_105_1.position.y * var_101_8 - var_101_10 - var_101_12, -22)
		end
	end)
	onButton(self, self.background, function()
		self:hidePaintView()
	end, SFX_CANCEL)

	function ShipMainScene:hidePaintView(arg_107_1)
		if not arg_107_1 and not var_101_16 then
			return
		end

		self.character:GetComponent("Image").enabled = true
		Input.multiTouchEnabled = false

		setActive(self.common, true)
		SwitchPanel(self.shipInfo, -460, nil, var_0_2 * 2)

		var_101_14.enabled = false
		var_101_13.enabled = false
		self.character.localScale = Vector3.one

		self.shipDetailView:Show()
		setActive(self.blurPanel, true)
		setActive(pg.playerResUI._go, true)

		for iter_107_0, iter_107_1 in ipairs(var_101_0) do
			setActive(iter_107_1, true)
		end

		closePortrait()

		self.nowPainting.localScale = Vector3(1, 1, 1)

		setAnchoredPosition(self.nowPainting, {
			x = var_101_5,
			y = var_101_6
		})

		self.background:GetComponent("Button").enabled = false
		self.nowPainting:GetComponent("CanvasGroup").blocksRaycasts = true
		self.mainMask.enabled = true

		self.mainMask:PerformClipping()

		self.inPaintingView = false
	end

	SwitchPanel(self.shipInfo, var_0_1, nil, var_0_2 * 2):setOnComplete(System.Action(function()
		var_101_13.enabled = true
		var_101_14.enabled = true
		self.background:GetComponent("Button").enabled = true
		self.nowPainting:GetComponent("CanvasGroup").blocksRaycasts = false
	end))
end

function ShipMainScene:onBackPressed()
	if self.inUpgradeAnim then
		return
	end

	if self.awakenPlay then
		return
	end

	if self.shipChangeNameView.isOpenRenamePanel then
		self.shipChangeNameView:ActionInvoke("DisplayRenamePanel", false)

		return
	end

	if self.shipCustomMsgBox.isShowCustomMsgBox then
		self.shipCustomMsgBox:ActionInvoke("hideCustomMsgBox")

		return
	end

	if self.shipHuntingRangeView.onSelected then
		self.shipHuntingRangeView:ActionInvoke("HideHuntingRange")

		return
	end

	if self.inPaintingView then
		self:hidePaintView(true)

		return
	end

	if self.expItemUsagePage and self.expItemUsagePage:GetLoaded() and self.expItemUsagePage:isShowing() then
		self.expItemUsagePage:Hide()

		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	triggerButton(self.common:Find("top/back_btn"))
end

function ShipMainScene:willExit()
	Input.multiTouchEnabled = true

	self:UnOverlayPanel(self.chat, self.character)
	self:blurPage(ShipViewConst.currentPage)
	setActive(self.background, false)

	if self.designBg then
		PoolMgr.GetInstance():ReturnUI(self.designName, self.designBg)
	end

	if self.metaBg then
		PoolMgr.GetInstance():ReturnUI(self.metaName, self.metaBg)
	end

	self.intensifyToggle:GetComponent("Toggle").onValueChanged:RemoveAllListeners()
	self.upgradeToggle:GetComponent("Toggle").onValueChanged:RemoveAllListeners()
	LeanTween.cancel(self.chat.gameObject)

	if self.paintingCode then
		for iter_110_0 = 1, #self.tablePainting do
			local var_110_0 = go(self.tablePainting[iter_110_0])

			if LeanTween.isTweening(var_110_0) then
				LeanTween.cancel(go(var_110_0))
			end
		end

		retPaintingPrefab(self.nowPainting, self.paintingCode)
	end

	self.shipDetailView:Destroy()
	self.shipFashionView:Destroy()
	self.shipEquipView:Destroy()
	self.shipHuntingRangeView:Destroy()
	self.shipCustomMsgBox:Destroy()
	self.shipChangeNameView:Destroy()
	clearImageSprite(self.background)

	if self.energyTimer then
		self.energyTimer:Stop()

		self.energyTimer = nil
	end

	if self.chatTimer then
		self.chatTimer:Stop()

		self.chatTimer = nil
	end

	self:StopPreVoice()
	cameraPaintViewAdjust(false)

	if self.tweens then
		cancelTweens(self.tweens)
	end

	self:UnOverlayPanel(self.blurPanel, self._tf)

	self.shareData = nil
end

function ShipMainScene:RefreshShipExpItemUsagePage()
	if self.expItemUsagePage and self.expItemUsagePage:GetLoaded() and self.expItemUsagePage:isShowing() then
		self.expItemUsagePage:Flush(self.shipVO)
	end
end

function ShipMainScene:OnWillLogout()
	if self.inPaintingView then
		self:hidePaintView(true)
	end
end

function ShipMainScene:checkPaintingRes(arg_113_1)
	PaintingGroupConst.PaintingDownload({
		isShowBox = true,
		paintingNameList = PaintingGroupConst.GetPaintingNameListByShipVO(self.shipVO),
		finishFunc = arg_113_1
	})
end

return ShipMainScene
