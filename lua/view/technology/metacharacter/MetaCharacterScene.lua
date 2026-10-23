local MetaCharacterScene = class("MetaCharacterScene", import("...base.BaseUI"))

MetaCharacterScene.PAGES = {
	REPAIR = 3,
	ENERGY = 1,
	SYN = 4,
	TACTICS = 2
}
MetaCharacterScene.PAGES_EVENTS = {
	MetaCharacterMediator.ON_ENERGY,
	MetaCharacterMediator.ON_TACTICS,
	MetaCharacterMediator.ON_REPAIR,
	MetaCharacterMediator.ON_SYN
}
MetaCharacterScene.SCALE_ON_PITCH = {
	x = 1.7,
	y = 1.7
}
MetaCharacterScene.ON_SKILL = "MetaCharacterScene:ON_SKILL"

function MetaCharacterScene:getUIName()
	return "MetaCharacterUI"
end

function MetaCharacterScene:getResource()
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in ipairs((getProxy(MetaCharacterProxy):getMetaProgressVOList())) do
		if iter_2_1 and iter_2_1:isShow() then
			local var_2_1, var_2_2 = iter_2_1:getBannerPathAndName()

			table.insert(var_2_0, var_2_1)

			local var_2_3, var_2_4 = iter_2_1:getPaintPathAndName()

			table.insert(var_2_0, var_2_3)

			local var_2_5, var_2_6 = iter_2_1:getBGNamePathAndName()

			table.insert(var_2_0, var_2_5)
		end
	end

	return ResPathSupport.MergeLuaArr(MetaCharacterScene.super.getResource(self), {
		"ui/metacharacterui",
		"ui/metacharactertacticsui",
		"ui/metacharacterenergyui",
		"ui/metacharacterrepairui",
		"ui/metacharactersynui"
	}, var_2_0)
end

function MetaCharacterScene:init()
	Input.multiTouchEnabled = false

	self:initUITextTips()
	self:initData()
	self:findUI()
	self:addListener()
	self:initMetaProgressList()
	self:initBannerList()
end

function MetaCharacterScene:didEnter()
	self:overLayPanel(true)
	self:updateStart()
	self:autoOpenFunc()
end

function MetaCharacterScene:willExit()
	Input.multiTouchEnabled = true

	self:overLayPanel(false)
end

function MetaCharacterScene:initUITextTips()
	local var_6_0 = self._tf:Find("HidePanel/ScrollPanel/ListPanel/BannerTpl/ForScale")

	setText(var_6_0:Find("Empty/ActType/TipText"), i18n("meta_syn_rate"))
	setText(var_6_0:Find("Empty/BuildType/TipText"), i18n("meta_build"))
	setText(var_6_0:Find("Active/ActType/Text"), i18n("meta_repair_rate"))
	setText(var_6_0:Find("Active/BuildType/Text"), i18n("meta_build"))
	setText(self._tf:Find("HidePanel/PTPanel/Progress/Story/TipText1"), i18n("meta_story_tip_1"))
	setText(self._tf:Find("HidePanel/PTPanel/Progress/Story/TipText2"), i18n("meta_story_tip_2"))
	setText(self._tf:Find("HidePanel/ActTimeTip/Tip"), i18n("meta_acttime_limit"))
end

function MetaCharacterScene:initData()
	self.metaProgressVOList = {}
	self.curMetaGroupID = nil
	self.curMetaProgress = nil
	self.toggleList = {}
	self.bannerTFList = {}
	self.curPageIndex = nil
	self.curMetaIndex = nil
	self.metaCharacterProxy = getProxy(MetaCharacterProxy)
	self.bayProxy = getProxy(BayProxy)
	self.indexDatas = {}
end

function MetaCharacterScene:findUI()
	self.shipImg = self._tf:Find("HidePanel/ShipImg")
	self.shipNameImg = self._tf:Find("HidePanel/NameImg")
	self.noCharTF = self._tf:Find("BG/NoCharacter")
	self.indexBtn = self._tf:Find("blur_panel/adapt/top/index")
	self.hidePanel = self._tf:Find("HidePanel")
	self.scrollPanel = self.hidePanel:Find("ScrollPanel")
	self.bannerListPanel = self.scrollPanel:Find("ListPanel")
	self.bannerContainer = self.bannerListPanel:Find("Container")
	self.bannerTpl = self.bannerListPanel:Find("BannerTpl")
	self.actTimePanel = self.hidePanel:Find("ActTimeTip")
	self.actTimeText = self.actTimePanel:Find("Text")
	self.menuPanel = self.hidePanel:Find("MenuPanel")
	self.energyBtn = self.menuPanel:Find("EnergyBtn")
	self.repairBtn = self.menuPanel:Find("RepairBtn")
	self.tacticsBtn = self.menuPanel:Find("TacticsBtn")
	self.synBtn = self.menuPanel:Find("SynBtn")
	self.synDecorateTF = self.menuPanel:Find("SynDecorate")
	self.synBtnLimitTimeTF = self.synBtn:Find("Limit")
	self.synBtnLock = self.synBtn:Find("LockMask")
	self.ptPanel = self.hidePanel:Find("PTPanel")
	self.ptRedBarImg = self.ptPanel:Find("RedBar")
	self.ptPreviewBtn = self.ptPanel:Find("PreviewBtn")
	self.ptGetBtn = self.ptPanel:Find("SynBtn")
	self.ptGetBtnTag = self.ptGetBtn:Find("Tag")
	self.ptShowWayBtn = self.ptPanel:Find("ShowWayBtn")

	local var_8_0 = self.ptPanel:Find("Progress")

	self.ptProgressImg = var_8_0:Find("CircleProgress/ProgressImg")
	self.ptProgressScaleLine = var_8_0:Find("CircleProgress/ScaleLine")
	self.ptInfoPanel = var_8_0:Find("PT")
	self.ptProgressRedRightNumText = self.ptInfoPanel:Find("ProgressTextBG/PointRedText/RightNumText")
	self.ptProgressRedLeftNumText = self.ptInfoPanel:Find("ProgressTextBG/PointRedText/LeftNumText")
	self.ptProgressWhiteRightNumText = self.ptInfoPanel:Find("ProgressTextBG/PointText/RightNumText")
	self.ptProgressWhiteLeftNumText = self.ptInfoPanel:Find("ProgressTextBG/PointText/LeftNumText")
	self.ptIcon = self.ptInfoPanel:Find("PTProgressText/PTIcon")
	self.ptProgressRedText = self.ptInfoPanel:Find("PTProgressRedText")
	self.ptProgressWhiteText = self.ptInfoPanel:Find("PTProgressText")
	self.storyInfoPanel = var_8_0:Find("Story")

	local var_8_1 = self.storyInfoPanel:Find("TipText1")
	local var_8_2 = self.storyInfoPanel:Find("TipText2")

	self.storyNameText = self.storyInfoPanel:Find("StroyNameText")
	self.getShipBtn = var_8_0:Find("FinishBtn")
	self.goGetPanel = self.hidePanel:Find("GoGetPanel")
	self.goGetBtn = self.goGetPanel:Find("GoGetBtn")
	self.blurPanel = self._tf:Find("blur_panel")

	local var_8_3 = self.blurPanel:Find("adapt")

	self.backBtn = var_8_3:Find("top/back")
	self.helpBtn = var_8_3:Find("top/help")
	self.toggleBtnsTF = var_8_3:Find("left/Btns")
	self.toggleGroupSC = GetComponent(self.toggleBtnsTF, "ToggleGroup")
	self.toggleGroupSC.allowSwitchOff = true
	self.toggleList[1] = self.toggleBtnsTF:Find("Energy")
	self.toggleList[2] = self.toggleBtnsTF:Find("Tactics")
	self.toggleList[3] = self.toggleBtnsTF:Find("Repair")
	self.toggleList[4] = self.toggleBtnsTF:Find("Syn")
	self.synToggleLock = self.toggleBtnsTF:Find("SynLock")
end

function MetaCharacterScene:addListener()
	onButton(self, self.backBtn, function()
		if self.curPageIndex then
			self:enterMenuPage(false)
			self:emit(MetaCharacterScene.PAGES_EVENTS[self.curPageIndex], nil, false)

			if self.curPageIndex == MetaCharacterScene.PAGES.REPAIR then
				self:backFromRepair()
			else
				self:backFromNotRepair()
			end
		else
			self:closeView()
		end
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.meta_help.tip
		})
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		self:openIndexLayer()
	end, SFX_PANEL)
	onButton(self, self.goGetBtn, function()
		local var_13_0 = self:getCurMetaProgressVO()

		if var_13_0:isPassType() then
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.CRUSING)
		elseif var_13_0:isBuildType() then
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.GETBOAT, {
				page = BuildShipScene.PAGE_BUILD,
				projectName = BuildShipScene.PROJECTS.ACTIVITY
			})
		end
	end, SFX_PANEL)
	onButton(self, self.ptPreviewBtn, function()
		self:emit(MetaCharacterMediator.OPEN_PT_PREVIEW_LAYER, self:getCurMetaProgressVO())
	end, SFX_PANEL)
	onButton(self, self.ptGetBtn, function()
		local var_15_0 = self:getCurMetaProgressVO()
		local var_15_1 = var_15_0:getMetaProgressPTState()

		if var_15_1 == MetaProgress.STATE_CAN_AWARD then
			local var_15_2, var_15_3 = self:getOneStepPTAwardLevelAndCount()

			pg.m02:sendNotification(GAME.GET_META_PT_AWARD, {
				groupID = var_15_0.id,
				targetCount = var_15_3
			})
		elseif var_15_1 == MetaProgress.STATE_LESS_PT then
			local var_15_5 = nowWorld()

			pg.TipsMgr.GetInstance():ShowTips(i18n((var_15_5 or nil) and var_15_5:IsSystemOpen(WorldConst.SystemWorldBoss) and "meta_pt_notenough" or "meta_boss_unlock"))
		elseif var_15_1 == MetaProgress.STATE_LESS_STORY then
			pg.TipsMgr.GetInstance():ShowTips(i18n("meta_story_lock"))
		end
	end, SFX_PANEL)
	onButton(self, self.ptShowWayBtn, function()
		local var_16_1 = nowWorld()

		pg.TipsMgr.GetInstance():ShowTips(i18n((var_16_1 or nil) and var_16_1:IsSystemOpen(WorldConst.SystemWorldBoss) and "meta_pt_notenough" or "meta_boss_unlock"))
	end, SFX_PANEL)
	onButton(self, self.getShipBtn, function()
		local var_17_0 = self:getCurMetaProgressVO()
		local var_17_1, var_17_2 = var_17_0.metaPtData:GetResProgress()

		pg.m02:sendNotification(GAME.GET_META_PT_AWARD, {
			groupID = var_17_0.id,
			targetCount = var_17_2
		})
	end, SFX_PANEL)
	onButton(self, self.synToggleLock, function()
		pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))
	end, SFX_PANEL)
	onButton(self, self.synBtnLock, function()
		pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))
	end)
	onButton(self, self.repairBtn:Find("RepairBtn"), function()
		self:switchPage(MetaCharacterScene.PAGES.REPAIR)
	end, SFX_PANEL)
	onButton(self, self.energyBtn, function()
		self.isMainOpenLayerTag = true

		self:switchPage(MetaCharacterScene.PAGES.ENERGY)
	end, SFX_PANEL)
	onButton(self, self.tacticsBtn, function()
		self.isMainOpenLayerTag = true

		self:switchPage(MetaCharacterScene.PAGES.TACTICS)
	end, SFX_PANEL)
	onButton(self, self.synBtn, function()
		if not isActive(self.synBtnLock) then
			self.isMainOpenLayerTag = true

			self:switchPage(MetaCharacterScene.PAGES.SYN)
		end
	end, SFX_PANEL)

	for iter_9_0, iter_9_1 in ipairs(self.toggleList) do
		onToggle(self, iter_9_1, function(arg_24_0)
			if self.curPageIndex == iter_9_0 and arg_24_0 == true then
				return
			end

			local var_24_0 = self:getCurMetaProgressVO():getShip()

			if self.curPageIndex == iter_9_0 and arg_24_0 == false then
				self:enterMenuPage(false)
				self:emit(MetaCharacterScene.PAGES_EVENTS[iter_9_0], var_24_0.id, false)
			end

			if self.curPageIndex ~= iter_9_0 and arg_24_0 == true then
				self:enterMenuPage(true)

				self.curPageIndex = iter_9_0

				self:emit(MetaCharacterScene.PAGES_EVENTS[iter_9_0], var_24_0.id, true)
			end
		end)
	end
end

function MetaCharacterScene:resetToggleList()
	for iter_25_0, iter_25_1 in ipairs(self.toggleList) do
		setActive(iter_25_1:Find("On"), false)
		setActive(iter_25_1:Find("Off"), true)
	end
end

function MetaCharacterScene:initMetaProgressList()
	self.metaProgressVOList = self:getMetaProgressListForShow()

	self:fillMetaProgressList()
end

function MetaCharacterScene:fillMetaProgressList()
	if #self.metaProgressVOList < 5 then
		for iter_27_0 = #self.metaProgressVOList + 1, 5 do
			table.insert(self.metaProgressVOList, false)
		end
	end
end

function MetaCharacterScene:initBannerList()
	self.scrollUIItemList = UIItemList.New(self.bannerContainer, self.bannerTpl)

	self.scrollUIItemList:make(function(arg_29_0, arg_29_1, arg_29_2)
		if arg_29_0 == UIItemList.EventUpdate then
			table.insert(self.bannerTFList, arg_29_2)
			self:updateBannerTF(self.metaProgressVOList[arg_29_1 + 1], arg_29_2, arg_29_1 + 1)
		end
	end)
end

function MetaCharacterScene:updateBannerTF(arg_30_1, arg_30_2, arg_30_3)
	local var_30_0 = arg_30_2
	local var_30_1 = arg_30_2:Find("ForScale")
	local var_30_2 = var_30_1:Find("WillCome")
	local var_30_3 = var_30_1:Find("Empty")
	local var_30_4 = var_30_1:Find("Active")

	if arg_30_1 then
		local var_30_5 = arg_30_1:isInAct()

		setActive(var_30_3:Find("ActType/Tag"), var_30_5)
		setActive(var_30_3:Find("BuildType/Tag"), var_30_5)
		setActive(var_30_4:Find("ActType/Tag"), var_30_5)
		setActive(var_30_4:Find("BuildType/Tag"), var_30_5)
	end

	if arg_30_1 then
		local var_30_6 = Ship.New({
			configId = tonumber(arg_30_1.configId .. 1)
		}):getName()
		local var_30_7 = var_30_1:Find("Empty/ActType/ShipNameMask/ShipNameText")

		setText(nil, var_30_6)
		setScrollText(var_30_7, var_30_6)
		setActive(var_30_7, true)

		local var_30_9 = var_30_1:Find("Empty/BuildType/ShipNameMask/ShipNameText")

		setText(var_30_9, var_30_6)
		setScrollText(var_30_9, var_30_6)
		setActive(var_30_9, true)

		local var_30_10 = var_30_1:Find("Empty/PassType/ShipNameMask/ShipNameText")

		setText(var_30_10, var_30_6)
		setScrollText(var_30_10, var_30_6)
		setActive(var_30_10, true)

		local var_30_11 = var_30_1:Find("Active/ActType/ShipNameMask/ShipNameText")

		setText(var_30_11, var_30_6)
		setScrollText(var_30_11, var_30_6)
		setActive(var_30_11, true)

		local var_30_12 = var_30_1:Find("Active/BuildType/ShipNameMask/ShipNameText")

		setText(var_30_12, var_30_6)
		setScrollText(var_30_12, var_30_6)
		setActive(var_30_12, true)

		local var_30_13 = var_30_1:Find("Active/PassType/ShipNameMask/ShipNameText")

		setText(var_30_13, var_30_6)
		setScrollText(var_30_13, var_30_6)
		setActive(var_30_13, true)
	end

	if arg_30_1 == false then
		setActive(var_30_2, true)
		setActive(var_30_3, false)
		setActive(var_30_4, false)
	else
		setActive(var_30_2, false)

		local var_30_14 = arg_30_1:isUnlocked()

		setActive(var_30_3, not var_30_14)
		setActive(var_30_4, var_30_14)

		local var_30_15 = arg_30_1:isPtType()
		local var_30_16 = arg_30_1:isPassType()
		local var_30_17 = arg_30_1:isBuildType()

		if not var_30_14 then
			local var_30_18 = var_30_1:Find("Empty/ActType")
			local var_30_19 = var_30_1:Find("Empty/BuildType")
			local var_30_20 = var_30_1:Find("Empty/PassType")

			setActive(var_30_18, var_30_15)
			setActive(var_30_19, var_30_17)
			setActive(var_30_20, var_30_16)

			local var_30_21, var_30_22 = arg_30_1:getBannerPathAndName()
			local var_30_23 = LoadSprite(var_30_21, var_30_22)

			setImageSprite(var_30_18, var_30_23)
			setImageSprite(var_30_19, var_30_23)
			setImageSprite(var_30_20, var_30_23)

			local var_30_25

			if var_30_15 then
				setText(var_30_18:Find("NumText"), string.format("%d", arg_30_1:getSynRate() * 100) .. "%")

				local var_30_24 = var_30_18:Find("Slider")

				setSlider(var_30_24, 0, 1, arg_30_1:getSynRate())
				setActive(var_30_24, false)

				var_30_25 = {}
			end

			var_30_25.configId = pg.ship_strengthen_meta[arg_30_1.configId].ship_id

			local var_30_26 = Ship.New(var_30_25)
			local var_30_27 = var_30_26:getStar()
			local var_30_28 = UIItemList.New(var_30_1:Find("Empty/Stars"), (var_30_1:Find("Empty/StarTpl")))

			var_30_28:make(function(arg_31_0, arg_31_1, arg_31_2)
				if arg_31_0 == UIItemList.EventUpdate then
					arg_31_1 = arg_31_1 + 1

					setActive(arg_31_2:Find("On"), arg_31_1 <= var_30_27)
				end
			end)
			var_30_28:align((var_30_26:getMaxStar()))
		else
			local var_30_29 = var_30_1:Find("Active/ActType")

			setActive(var_30_29, var_30_15)
			setActive(var_30_1:Find("Active/BuildType"), var_30_17)
			setActive(var_30_1:Find("Active/PassType"), var_30_16)

			local var_30_30, var_30_31 = arg_30_1:getBannerPathAndName()
			local var_30_32 = LoadSprite(var_30_30, var_30_31)

			setImageSprite(var_30_1:Find("Active"), LoadSprite(var_30_30, var_30_31))

			local var_30_33 = arg_30_1:getShip()
			local var_30_34 = var_30_33:getMetaCharacter()

			if var_30_15 then
				setText(var_30_29:Find("NumText"), string.format("%d", var_30_34:getRepairRate() * 100) .. "%")

				local var_30_35 = var_30_29:Find("Slider")

				setSlider(var_30_35, 0, 1, var_30_34:getRepairRate())
				setActive(var_30_35, false)
			end

			local var_30_36 = var_30_33:getMaxStar()
			local var_30_37 = var_30_33:getStar()
			local var_30_38 = UIItemList.New(var_30_1:Find("Active/Stars"), (var_30_1:Find("Active/StarTpl")))

			var_30_38:make(function(arg_32_0, arg_32_1, arg_32_2)
				if arg_32_0 == UIItemList.EventUpdate then
					arg_32_1 = arg_32_1 + 1

					setActive(arg_32_2:Find("On"), arg_32_1 <= var_30_37)
				end
			end)
			var_30_38:align(var_30_36)
		end
	end

	onButton(self, arg_30_2, function()
		if self.curMetaIndex ~= arg_30_3 then
			if self.curMetaIndex and self.curMetaIndex > 0 then
				self:changeBannerOnClick(self.bannerTFList[self.curMetaIndex], false)
			end

			self.curMetaIndex = arg_30_3

			self:changeBannerOnClick(var_30_0, true)
			self:updateMain()
		end
	end, SFX_PANEL)

	if arg_30_1 == false then
		setButtonEnabled(arg_30_2, false)
	else
		setButtonEnabled(arg_30_2, true)
	end
end

function MetaCharacterScene:changeBannerOnClick(arg_34_1, arg_34_2)
	local var_34_0 = arg_34_1:GetComponent("LayoutElement")
	local var_34_1 = arg_34_1:Find("ForScale")

	if arg_34_2 == true then
		setLocalScale(var_34_1, MetaCharacterScene.SCALE_ON_PITCH)

		var_34_0.preferredWidth = 338.3
		var_34_0.preferredHeight = 102
	else
		setLocalScale(var_34_1, Vector2.one)

		var_34_0.preferredWidth = 199
		var_34_0.preferredHeight = 60
	end

	setActive(var_34_1:Find("SelectedTag"), arg_34_2)
end

function MetaCharacterScene:updateBannerShipName(arg_35_1)
	local var_35_0 = arg_35_1:Find("ForScale")
	local var_35_1 = isActive((var_35_0:Find("SelectedTag")))

	setActive(var_35_0:Find("Empty/ActType/ShipNameText"), var_35_1)
	setActive(var_35_0:Find("Empty/BuildType/ShipNameText"), var_35_1)
	setActive(var_35_0:Find("Active/ActType/ShipNameText"), var_35_1)
	setActive(var_35_0:Find("Active/BuildType/ShipNameText"), var_35_1)
	setActive(var_35_0:Find("Empty/ActType/TipText"), not var_35_1)
	setActive(var_35_0:Find("Empty/BuildType/TipText"), not var_35_1)
	setActive(var_35_0:Find("Active/ActType/Text"), not var_35_1)
	setActive(var_35_0:Find("Active/BuildType/Text"), not var_35_1)
end

function MetaCharacterScene:updateBannerUIList()
	self.bannerTFList = {}

	self.scrollUIItemList:align(#self.metaProgressVOList)
end

function MetaCharacterScene:updateStart()
	local var_37_0 = false

	for iter_37_0, iter_37_1 in ipairs(self.metaProgressVOList) do
		if iter_37_1 ~= false then
			var_37_0 = true

			break
		end
	end

	setActive(self.indexBtn:Find("On"), not self:isDefaultStatus())
	setActive(self.noCharTF, not var_37_0)
	setActive(self.hidePanel, var_37_0)

	if not var_37_0 then
		return
	end

	self:resetBannerListScale()
	self:updateBannerUIList()

	self.curMetaIndex = nil

	if var_37_0 then
		triggerButton(self.bannerTFList[1])
	end
end

function MetaCharacterScene:resetBannerListScale()
	for iter_38_0, iter_38_1 in ipairs(self.bannerTFList) do
		local var_38_0 = iter_38_1:GetComponent("LayoutElement")

		setLocalScale(iter_38_1:Find("ForScale"), Vector2.one)

		var_38_0.preferredWidth = 199
		var_38_0.preferredHeight = 60
	end
end

function MetaCharacterScene:updateMain(arg_39_1)
	local var_39_0 = self:getCurMetaProgressVO()
	local var_39_1 = var_39_0:isUnlocked()

	setActive(self.menuPanel, var_39_1)
	setActive(self.ptPanel, not var_39_1)
	setActive(self.goGetPanel, not var_39_1)
	self:updateActTimePanel()

	if not var_39_1 then
		local var_39_2 = var_39_0:isPtType()

		setActive(self.ptPanel, var_39_2)
		setActive(self.goGetPanel, var_39_0:isPassType() or var_39_0:isBuildType())

		if var_39_2 then
			self:updatePTPanel(arg_39_1)
		end
	else
		self:TryPlayGuide()
	end

	self:updateRedPoints()

	local var_39_3, var_39_4 = var_39_0:getPaintPathAndName()

	setImageSprite(self.shipImg, LoadSprite(var_39_3, var_39_4), true)

	local var_39_5, var_39_6 = var_39_0:getBGNamePathAndName()

	setImageSprite(self.shipNameImg, LoadSprite(var_39_5, var_39_6), true)
	setLocalPosition(self.shipImg, {
		x = MetaCharacterConst.UIConfig[var_39_0.id][1],
		y = MetaCharacterConst.UIConfig[var_39_0.id][2]
	})
	setLocalScale(self.shipImg, {
		x = MetaCharacterConst.UIConfig[var_39_0.id][3],
		y = MetaCharacterConst.UIConfig[var_39_0.id][4]
	})
end

function MetaCharacterScene:TryPlayGuide()
	pg.SystemGuideMgr.GetInstance():PlayByGuideId("NG0024")
end

function MetaCharacterScene:updateActTimePanel()
	local var_41_0 = self:getCurMetaProgressVO()
	local var_41_1 = var_41_0:isInAct()

	setActive(self.actTimePanel, not var_41_0:isUnlocked() and var_41_1)
	setActive(self.synBtnLimitTimeTF, var_41_1)

	if var_41_1 then
		setText(self.actTimeText, (string.format("%d.%d.%d-%d.%d.%d", var_41_0.timeConfig[1][1][1], var_41_0.timeConfig[1][1][2], var_41_0.timeConfig[1][1][3], var_41_0.timeConfig[2][1][1], var_41_0.timeConfig[2][1][2], var_41_0.timeConfig[2][1][3])))
		setText(self.synBtnLimitTimeTF:Find("Text"), i18n("meta_pt_left", (pg.TimeMgr.GetInstance():DiffDay(pg.TimeMgr.GetInstance():GetServerTime(), (pg.TimeMgr.GetInstance():parseTimeFromConfig(var_41_0.timeConfig[2]))))))
	end
end

function MetaCharacterScene:updatePTPanel(arg_42_1)
	local var_42_0 = self:getCurMetaProgressVO()
	local var_42_1 = var_42_0:getSynRate()
	local var_42_2 = tonumber(tostring(var_42_1 * 100))

	setImageSprite(self.ptIcon, LoadSprite(var_42_0:getPtIconPath()))
	setFillAmount(self.ptProgressImg, var_42_1)
	setActive(self.ptProgressScaleLine, var_42_1 < 1)

	self.ptProgressScaleLine.localEulerAngles = Vector3(0, 0, -360 * var_42_1)

	local var_42_3 = string.format("%d", var_42_2)
	local var_42_4 = string.format("%2d", (var_42_2 - math.floor(var_42_2)) * 100)

	var_42_4 = (var_42_2 - math.floor(var_42_2)) * 100 == 0 and var_42_4 .. "0%" or var_42_4 .. "%"

	setText(self.ptProgressRedLeftNumText, var_42_3)
	setText(self.ptProgressWhiteLeftNumText, var_42_3)
	setText(self.ptProgressRedRightNumText, var_42_4)
	setText(self.ptProgressWhiteRightNumText, var_42_4)

	local var_42_5, var_42_6, var_42_7 = var_42_0.metaPtData:GetResProgress()

	setText(self.ptProgressRedText, (var_42_7 >= 1 and setColorStr(var_42_5, COLOR_GREEN) or setColorStr(var_42_5, COLOR_RED)) .. "/" .. var_42_6)
	setText(self.ptProgressWhiteText, (var_42_7 >= 1 and setColorStr(var_42_5, COLOR_GREEN) or setColorStr(var_42_5, COLOR_RED)) .. "/" .. var_42_6)

	local var_42_8 = var_42_0:getMetaProgressPTState()

	if var_42_8 == MetaProgress.STATE_CAN_FINISH then
		setActive(self.ptRedBarImg, true)
		setActive(self.ptPreviewBtn, false)
		setActive(self.ptGetBtn, false)
		setActive(self.ptShowWayBtn, false)
		setActive(self.ptInfoPanel, false)
		setActive(self.storyInfoPanel, false)
		setActive(self.getShipBtn, true)
	elseif var_42_8 == MetaProgress.STATE_CAN_AWARD then
		setActive(self.ptRedBarImg, false)
		setActive(self.ptPreviewBtn, true)
		setActive(self.ptGetBtn, true)
		setActive(self.ptShowWayBtn, false)
		setActive(self.ptGetBtnTag, true)
		setActive(self.ptInfoPanel, true)
		setActive(self.storyInfoPanel, false)
		setActive(self.getShipBtn, false)
		setImageAlpha(self.ptPreviewBtn, 0)
		setImageAlpha(self.ptGetBtn, 0)
		setImageAlpha(self.ptGetBtnTag, 0)
		setImageAlpha(self.ptShowWayBtn, 0)
	elseif var_42_8 == MetaProgress.STATE_LESS_STORY then
		setActive(self.ptRedBarImg, true)
		setActive(self.ptPreviewBtn, true)
		setActive(self.ptGetBtn, true)
		setActive(self.ptShowWayBtn, false)
		setActive(self.ptGetBtnTag, false)
		setActive(self.ptInfoPanel, false)
		setActive(self.storyInfoPanel, true)
		setActive(self.getShipBtn, false)
		setText(self.storyNameText, (var_42_0:getCurLevelStoryName()))
	elseif var_42_8 == MetaProgress.STATE_LESS_PT then
		setActive(self.ptRedBarImg, false)
		setActive(self.ptPreviewBtn, true)
		setActive(self.ptGetBtn, false)
		setActive(self.ptShowWayBtn, true)
		setActive(self.ptGetBtnTag, false)
		setActive(self.ptInfoPanel, true)
		setActive(self.storyInfoPanel, false)
		setActive(self.getShipBtn, false)
		setImageAlpha(self.ptPreviewBtn, 0)
		setImageAlpha(self.ptGetBtn, 0)
		setImageAlpha(self.ptShowWayBtn, 0)
	end

	if var_42_1 > 0 and not arg_42_1 then
		if var_42_8 == MetaProgress.STATE_CAN_AWARD or var_42_8 == MetaProgress.STATE_LESS_PT then
			local var_42_9 = math.min(var_42_1, 1)

			self:managedTween(LeanTween.value, nil, go(self.ptPanel), 0, var_42_1, var_42_9):setOnUpdate(System.Action_float(function(arg_43_0)
				setFillAmount(self.ptProgressImg, arg_43_0)
				setActive(self.ptProgressScaleLine, arg_43_0 < 1)

				self.ptProgressScaleLine.localEulerAngles = Vector3(0, 0, -360 * arg_43_0)

				local var_43_0 = string.format("%d", arg_43_0 * 100)
				local var_43_1 = string.format("%2d", (arg_43_0 * 100 - math.floor(arg_43_0 * 100)) * 100)

				var_43_1 = (arg_43_0 * 100 - math.floor(arg_43_0 * 100)) * 100 == 0 and var_43_1 .. "0%" or var_43_1 .. "%"

				setText(self.ptProgressRedLeftNumText, var_43_0)
				setText(self.ptProgressWhiteLeftNumText, var_43_0)
				setText(self.ptProgressRedRightNumText, var_43_1)
				setText(self.ptProgressWhiteRightNumText, var_43_1)
			end)):setOnComplete(System.Action(function()
				setFillAmount(self.ptProgressImg, var_42_1)
				setActive(self.ptProgressScaleLine, var_42_1 < 1)

				self.ptProgressScaleLine.localEulerAngles = Vector3(0, 0, -360 * var_42_1)

				local var_44_0 = string.format("%d", var_42_2)
				local var_44_1 = string.format("%2d", (var_42_2 - math.floor(var_42_2)) * 100)

				var_44_1 = (var_42_2 - math.floor(var_42_2)) * 100 == 0 and var_44_1 .. "0%" or var_44_1 .. "%"

				setText(self.ptProgressRedLeftNumText, var_44_0)
				setText(self.ptProgressWhiteLeftNumText, var_44_0)
				setText(self.ptProgressRedRightNumText, var_44_1)
				setText(self.ptProgressWhiteRightNumText, var_44_1)
				self:managedTween(LeanTween.value, nil, go(self.ptPanel), 0, 1, var_42_9 / 2):setOnUpdate(System.Action_float(function(arg_45_0)
					setImageAlpha(self.ptPreviewBtn, arg_45_0)
					setImageAlpha(self.ptGetBtn, arg_45_0)
					setImageAlpha(self.ptGetBtnTag, arg_45_0)
					setImageAlpha(self.ptShowWayBtn, arg_45_0)
				end)):setOnComplete(System.Action(function()
					setImageAlpha(self.ptPreviewBtn, 1)
					setImageAlpha(self.ptGetBtn, 1)
					setImageAlpha(self.ptGetBtnTag, 1)
					setImageAlpha(self.ptShowWayBtn, 1)
				end))
			end))
		end
	else
		setImageAlpha(self.ptPreviewBtn, 1)
		setImageAlpha(self.ptGetBtn, 1)
		setImageAlpha(self.ptGetBtnTag, 1)
		setImageAlpha(self.ptShowWayBtn, 1)
	end
end

function MetaCharacterScene:updateRedPoints()
	local var_47_0 = self:getCurMetaProgressVO()
	local var_47_1 = var_47_0.id
	local var_47_2 = MetaCharacterConst.isMetaRepairRedTag(var_47_0.id)

	setActive(self.repairBtn:Find("RepairBtn/Tag"), var_47_2)
	setActive(self.repairBtn:Find("Finish"), not MetaCharacterConst.filteMetaRepairAble(var_47_0))

	local var_47_3 = MetaCharacterConst.isMetaEnergyRedTag(var_47_1)

	setActive(self.energyBtn:Find("Tag"), var_47_3)
	setActive(self.energyBtn:Find("Finish"), not MetaCharacterConst.filteMetaEnergyAble(var_47_0))
	setActive(self.tacticsBtn:Find("Finish"), not MetaCharacterConst.filteMetaTacticsAble(var_47_0))

	local var_47_4 = MetaCharacterConst.isMetaTacticsRedTag(var_47_1)

	if var_47_0.metaShipVO then
		local var_47_5 = self.metaCharacterProxy:getMetaTacticsInfoByShipID(var_47_0.metaShipVO.id):getTacticsStateForShow()

		setActive(self.tacticsBtn:Find("Tag"), false)
		setActive(self.tacticsBtn:Find("Learnable"), var_47_5 == MetaTacticsInfo.States.LearnAble)
		setActive(self.tacticsBtn:Find("Learning"), var_47_5 == MetaTacticsInfo.States.Learning)
		setActive(self.tacticsBtn:Find("LearnFinish"), var_47_5 == MetaTacticsInfo.States.LearnFinished and var_47_4)
	else
		setActive(self.tacticsBtn:Find("Tag"), false)
		setActive(self.tacticsBtn:Find("Learnable"), false)
		setActive(self.tacticsBtn:Find("Learning"), false)
		setActive(self.tacticsBtn:Find("LearnFinish"), false)
	end

	local var_47_6 = var_47_0:isPtType()
	local var_47_7 = var_47_0:isInAct()
	local var_47_8 = var_47_0:isInArchive()

	setActive(self.synDecorateTF, var_47_6)
	setActive(self.synBtn, var_47_6)
	setActive(self.synBtnLock, var_47_6 and not var_47_7 and not var_47_8)
	setActive(self.toggleList[4], var_47_6)
	setActive(self.synToggleLock, var_47_6 and not var_47_7 and not var_47_8)

	local var_47_9

	if var_47_6 then
		var_47_9 = MetaCharacterConst.isMetaSynRedTag(var_47_1)

		setActive(self.synBtn:Find("Tag"), var_47_9)
	end

	setActive(self.synBtn:Find("Finish"), not MetaCharacterConst.filteMetaSynAble(var_47_0))
	setActive(self.toggleList[MetaCharacterScene.PAGES.REPAIR]:Find("Tip"), var_47_2)
	setActive(self.toggleList[MetaCharacterScene.PAGES.ENERGY]:Find("Tip"), var_47_3)
	setActive(self.toggleList[MetaCharacterScene.PAGES.TACTICS]:Find("Tip"), var_47_4)
	setActive(self.toggleList[MetaCharacterScene.PAGES.SYN]:Find("Tip"), var_47_9)

	for iter_47_0, iter_47_1 in ipairs(self.metaProgressVOList) do
		local var_47_10 = self.bannerTFList[iter_47_0]:Find("ForScale/RedPoint")

		if iter_47_1 then
			setActive(var_47_10, MetaCharacterConst.isMetaBannerRedPoint(iter_47_1.id))
		else
			setActive(var_47_10, false)
		end
	end
end

function MetaCharacterScene:getCurMetaProgressVO()
	return self.metaProgressVOList[self.curMetaIndex]
end

function MetaCharacterScene:refreshBannerTF()
	self:updateBannerTF(self:getCurMetaProgressVO(), self.bannerTFList[self.curMetaIndex], self.curMetaIndex)
end

function MetaCharacterScene:enterMenuPage(arg_50_1)
	setActive(self.hidePanel, not arg_50_1)
	setActive(self.indexBtn, not arg_50_1)
	setActive(self.toggleBtnsTF, arg_50_1)

	self.toggleGroupSC.allowSwitchOff = not arg_50_1
end

function MetaCharacterScene:switchPage(arg_51_1)
	if not self.curPageIndex then
		setActive(self.toggleBtnsTF, true)
		triggerToggle(self.toggleList[arg_51_1], true)
	end
end

function MetaCharacterScene:backFromRepair()
	setActive(self.menuPanel, false)
	self:managedTween(LeanTween.alpha, nil, self.shipImg, 1, 0.3):setFrom(0):setOnComplete(System.Action(function()
		setActive(self.menuPanel, true)
		setActive(self.hidePanel, true)
	end))
end

function MetaCharacterScene:backFromNotRepair()
	setActive(self.menuPanel, false)
	self:managedTween(LeanTween.moveX, nil, rtf(self.shipImg), MetaCharacterConst.UIConfig[self:getCurMetaProgressVO().id][1], 0.3):setFrom(-250):setOnComplete(System.Action(function()
		setActive(self.menuPanel, true)
		setActive(self.hidePanel, true)
	end))
end

function MetaCharacterScene:autoOpenFunc()
	if self.contextData.autoOpenShipConfigID then
		local var_56_0 = MetaCharacterConst.GetMetaShipGroupIDByConfigID(self.contextData.autoOpenShipConfigID)

		for iter_56_0, iter_56_1 in ipairs((self:getMetaProgressListForShow())) do
			if iter_56_1 and iter_56_1.id == var_56_0 then
				triggerButton(self.bannerTFList[iter_56_0])

				self.contextData.autoOpenShipConfigID = nil
			end
		end
	end

	if self.contextData.autoOpenTactics then
		triggerButton(self.tacticsBtn)

		self.contextData.autoOpenTactics = nil
	end

	if self.contextData.autoOpenEnergy then
		triggerButton(self.energyBtn)

		self.contextData.autoOpenEnergy = nil
	end

	if self.contextData.autoOpenSyn then
		if self:getCurMetaProgressVO():isUnlocked() then
			triggerButton(self.synBtn)
		end

		self.contextData.autoOpenSyn = nil
	end

	if self.contextData.lastPageIndex then
		triggerToggle(self.toggleList[self.contextData.lastPageIndex], true)

		self.contextData.lastPageIndex = nil
	end
end

function MetaCharacterScene:openIndexLayer()
	self.indexDatas = self.indexDatas or {}

	self:emit(MetaCharacterMediator.OPEN_INDEX_LAYER, {
		indexDatas = Clone(self.indexDatas),
		customPanels = {
			minHeight = 650,
			typeIndex = {
				mode = CustomIndexLayer.Mode.AND,
				options = ShipIndexConst.TypeIndexs,
				names = ShipIndexConst.TypeNames
			},
			rarityIndex = {
				mode = CustomIndexLayer.Mode.AND,
				options = ShipIndexConst.MetaRarityIndexs,
				names = ShipIndexConst.MetaRarityNames
			},
			extraIndex = {
				mode = CustomIndexLayer.Mode.OR,
				options = ShipIndexConst.MetaExtraIndexs,
				names = ShipIndexConst.MetaExtraNames
			}
		},
		groupList = {
			{
				dropdown = false,
				titleENTxt = "indexsort_typeeng",
				titleTxt = "indexsort_type",
				tags = {
					"typeIndex"
				}
			},
			{
				dropdown = false,
				titleENTxt = "indexsort_rarityeng",
				titleTxt = "indexsort_rarity",
				tags = {
					"rarityIndex"
				}
			},
			{
				dropdown = false,
				titleENTxt = "indexsort_indexeng",
				titleTxt = "indexsort_extraindex",
				tags = {
					"extraIndex"
				}
			}
		},
		callback = function(self)
			if not isActive(self._tf) then
				return
			end

			self.indexDatas.typeIndex = self.typeIndex
			self.indexDatas.rarityIndex = self.rarityIndex
			self.indexDatas.extraIndex = self.extraIndex
			self.metaProgressVOList = self:getMetaProgressListForShow()

			self:fillMetaProgressList()
			self:updateStart()
		end
	})
end

function MetaCharacterScene:isDefaultStatus()
	return (not self.indexDatas.typeIndex or self.indexDatas.typeIndex == ShipIndexConst.TypeAll) and (not self.indexDatas.rarityIndex or self.indexDatas.rarityIndex == ShipIndexConst.RarityAll) and (not self.indexDatas.extraIndex or self.indexDatas.extraIndex == ShipIndexConst.MetaExtraAll)
end

function MetaCharacterScene:overLayPanel(arg_60_1)
	if arg_60_1 == true then
		self:OverlayPanel(self.blurPanel)
	elseif arg_60_1 == false then
		self:UnOverlayPanel(self.blurPanel, self._tf)
	end
end

function MetaCharacterScene:getMetaProgressListForShow()
	local var_61_0 = {}
	local var_61_1
	local var_61_2

	for iter_61_0, iter_61_1 in ipairs((self.metaCharacterProxy:getMetaProgressVOList())) do
		if MetaCharacterConst.filteMetaByType(iter_61_1, self.indexDatas.typeIndex) and MetaCharacterConst.filteMetaByRarity(iter_61_1, self.indexDatas.rarityIndex) and MetaCharacterConst.filteMetaExtra(iter_61_1, self.indexDatas.extraIndex) and iter_61_1:isShow() then
			if iter_61_1:isPtType() and iter_61_1:isInAct() then
				var_61_1 = iter_61_1
			elseif iter_61_1:isPassType() and iter_61_1:isInAct() then
				var_61_2 = iter_61_1
			else
				local var_61_4

				if iter_61_1:isBuildType() and iter_61_1:isInAct() then
					var_61_4 = iter_61_1
				else
					table.insert(var_61_0, iter_61_1)
				end
			end
		end
	end

	if nil then
		table.insert(var_61_0, 1, nil)
	end

	if var_61_2 then
		table.insert(var_61_0, 1, var_61_2)
	end

	if var_61_1 then
		table.insert(var_61_0, 1, var_61_1)
	end

	return var_61_0
end

function MetaCharacterScene:filteMetaProgressList()
	local var_62_0 = {}

	for iter_62_0, iter_62_1 in ipairs((self:getMetaProgressListForShow())) do
		if MetaCharacterConst.filteMetaByType(iter_62_1, self.indexDatas.typeIndex) and MetaCharacterConst.filteMetaByRarity(iter_62_1, self.indexDatas.rarityIndex) and MetaCharacterConst.filteMetaExtra(iter_62_1, self.indexDatas.extraIndex) then
			table.insert(var_62_0, iter_62_1)
		end
	end

	return var_62_0
end

function MetaCharacterScene:getOneStepPTAwardLevelAndCount()
	local var_63_0 = self:getCurMetaProgressVO()
	local var_63_1 = var_63_0.metaPtData:GetResProgress()
	local var_63_2 = var_63_0:getStoryIndexList()
	local var_63_3 = 0

	for iter_63_0 = 1, var_63_0.unlockPTLevel - 1 do
		local var_63_4 = false
		local var_63_5 = false

		if var_63_1 >= var_63_0.metaPtData.targets[iter_63_0] then
			var_63_4 = true
		end

		if var_63_2[iter_63_0] == 0 then
			var_63_5 = true
		elseif pg.NewStoryMgr.GetInstance():IsPlayed(var_63_2[iter_63_0]) then
			var_63_5 = true
		end

		if var_63_4 and var_63_5 then
			var_63_3 = iter_63_0
		else
			break
		end
	end

	return var_63_3, var_63_0.metaPtData.targets[var_63_3]
end

return MetaCharacterScene
