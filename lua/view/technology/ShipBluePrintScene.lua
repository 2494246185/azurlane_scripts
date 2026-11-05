local ShipBluePrintScene = class("ShipBluePrintScene", import("..base.BaseUI"))
local var_0_1 = pg.ship_data_blueprint
local var_0_2 = pg.ship_data_template
local var_0_3 = pg.ship_data_breakout
local var_0_4 = 3
local var_0_5 = -10
local var_0_6 = 2.3
local var_0_7 = 0.3

function ShipBluePrintScene:getUIName()
	return "ShipBluePrintUI"
end

function ShipBluePrintScene:setVersion(arg_2_1)
	self.version = arg_2_1
end

function ShipBluePrintScene:setShipVOs(arg_3_1)
	self.shipVOs = arg_3_1
end

function ShipBluePrintScene:getShipById(arg_4_1)
	return self.shipVOs[arg_4_1]
end

function ShipBluePrintScene:setTaskVOs(arg_5_1)
	self.taskVOs = arg_5_1
end

function ShipBluePrintScene:getTaskById(arg_6_1)
	return self.taskVOs[arg_6_1] or Task.New({
		id = arg_6_1
	})
end

function ShipBluePrintScene:getItemById(arg_7_1)
	local var_7_0 = getProxy(BagProxy):getItemById(arg_7_1)

	var_7_0 = var_7_0 or Item.New({
		count = 0,
		id = arg_7_1
	})

	return var_7_0
end

function ShipBluePrintScene:setShipBluePrints(arg_8_1)
	self.bluePrintByIds = arg_8_1
end

function ShipBluePrintScene:updateShipBluePrintVO(arg_9_1)
	if arg_9_1 then
		self.bluePrintByIds[arg_9_1.id] = arg_9_1
	end

	self:initShips()
end

function ShipBluePrintScene:init()
	self.main = self._tf:Find("main")
	self.centerPanel = self.main:Find("center_panel")
	self.blurPanel = self._tf:Find("blur_panel")
	self.top = self.blurPanel:Find("adapt")
	self.topPanel = self.top:Find("top")
	self.topBg = self.blurPanel:Find("top_bg")
	self.backBtn = self.top:Find("top/back")
	self.leftPanle = self.top:Find("left_panel")
	self.bottomPanel = self.top:Find("bottom_panel")
	self.rightPanel = self.top:Find("right_panel")
	self.shipContainer = self.bottomPanel:Find("ships/bg/content")
	self.shipTpl = self.bottomPanel:Find("ship_tpl")
	self.versionBtn = self.bottomPanel:Find("ships/bg/version/version_btn")
	self.eyeTF = self.leftPanle:Find("eye")
	self.painting = self._tf:Find("main/center_panel/painting")
	self.nameTF = self.centerPanel:Find("name")
	self.shipName = self.nameTF:Find("name_mask/Text")
	self.shipType = self.nameTF:Find("type")
	self.englishName = self.nameTF:Find("english_name")
	self.shipInfoStarTpl = self.nameTF:Find("star_tpl")

	setActive(self.shipInfoStarTpl, false)

	self.stars = self.nameTF:Find("stars")
	self.initBtn = self.leftPanle:Find("property_panel/btns/init_toggle")
	self.attrBtn = self.leftPanle:Find("property_panel/btns/attr_toggle")
	self.attrDisableBtn = self.leftPanle:Find("property_panel/btns/attr_toggle/disable")
	self.initPanel = self.leftPanle:Find("property_panel/init_panel")
	self.propertyPanel = PropertyPanel.New(self.initPanel, 32)

	setText(self.initPanel:Find("property_title1/Text"), i18n("blueprint_combatperformance"))
	setText(self.initPanel:Find("property_title2/Text"), i18n("blueprint_shipperformance"))

	self.skillRect = self.leftPanle:Find("property_panel/init_panel/skills_rect")
	self.skillPanel = self.leftPanle:Find("property_panel/init_panel/skills_rect/skills")
	self.skillTpl = self.skillPanel:Find("skilltpl")
	self.skillArrLeft = self.leftPanle:Find("property_panel/init_panel/arrow1")
	self.skillArrRight = self.leftPanle:Find("property_panel/init_panel/arrow2")
	self.simulationBtn = self.leftPanle:Find("property_panel/init_panel/property_title2/simulation")
	self.attrPanel = self.leftPanle:Find("property_panel/attr_panel")
	self.modAdditionPanel = self.leftPanle:Find("property_panel/attr_panel")
	self.modAdditionContainer = self.modAdditionPanel:Find("scroll_rect/content")
	self.modAdditionTpl = self.modAdditionContainer:Find("addition_tpl")
	self.preViewBtn = self.attrPanel:Find("pre_view")
	self.stateInfo = self.centerPanel:Find("state_info")
	self.startBtn = self.centerPanel:Find("state_info/start_btn")
	self.lockPanel = self.centerPanel:Find("state_info/lock_panel")
	self.lockBtn = self.lockPanel:Find("lock")
	self.finishedBtn = self.centerPanel:Find("state_info/finished_btn")
	self.progressPanel = self.centerPanel:Find("state_info/progress")

	setText(self.progressPanel:Find("label"), i18n("blueprint_researching"))

	self.progressContainer = self.progressPanel:Find("content")
	self.progressTpl = self.progressContainer:Find("item")
	self.openCondition = self.centerPanel:Find("state_info/open_condition")
	self.speedupBtn = self._tf:Find("main/speedup_btn")
	self.taskListPanel = self.rightPanel:Find("task_list")
	self.taskContainer = self.rightPanel:Find("task_list/scroll/content")
	self.taskTpl = self.taskContainer:Find("task_tpl")
	self.modPanel = self.rightPanel:Find("mod_panel")
	self.attrContainer = self.modPanel:Find("desc/atrrs")
	self.levelSlider = self.modPanel:Find("title/slider"):GetComponent(typeof(Slider))
	self.levelSliderTxt = self.modPanel:Find("title/slider/Text")
	self.preLevelSlider = self.modPanel:Find("title/pre_slider"):GetComponent(typeof(Slider))
	self.modLevel = self.modPanel:Find("title/level_bg/Text"):GetComponent(typeof(Text))
	self.needLevelTxt = self.modPanel:Find("title/Text"):GetComponent(typeof(Text))
	self.phantomPanel = self.rightPanel:Find("phantom_panel")
	self.rtPhantomQuestContainer = self.phantomPanel:Find("desc/content")
	self.questTpl = self.rtPhantomQuestContainer:GetChild(0)
	self.btnPhantom = self.top:Find("phantomBtn")
	self.calcPanel = self.modPanel:Find("desc/calc_panel")
	self.calcMinusBtn = self.calcPanel:Find("calc/base/minus")
	self.calcPlusBtn = self.calcPanel:Find("calc/base/plus")
	self.calcTxt = self.calcPanel:Find("calc/base/count/Text")
	self.calcMaxBtn = self.calcPanel:Find("calc/max")
	self.itemInfo = self.calcPanel:Find("item_bg")
	self.itemInfoIcon = self.itemInfo:Find("icon")
	self.itemInfoCount = self.itemInfo:Find("kc")
	self.modBtn = self.calcPanel:Find("confirm_btn")
	self.fittingBtn = self.modPanel:Find("desc/fitting_btn")
	self.fittingBtnEffect = self.fittingBtn:Find("anim/ShipBlue02")
	self.fittingPanel = self.rightPanel:Find("fitting_panel")

	setActive(self.fittingPanel, false)

	self.fittingAttrPanel = self.fittingPanel:Find("desc/middle")
	self.phasePic = self.fittingPanel:Find("title/phase")
	self.phaseSlider = self.fittingPanel:Find("desc/top/slider"):GetComponent(typeof(Slider))
	self.phaseSliderTxt = self.fittingPanel:Find("desc/top/precent")
	self.prePhaseSlider = self.fittingPanel:Find("desc/top/pre_slider"):GetComponent(typeof(Slider))
	self.fittingNeedMask = self.fittingPanel:Find("desc/top/mask")
	self.fittingCalcPanel = self.fittingPanel:Find("desc/bottom")
	self.fittingCalcMinusBtn = self.fittingCalcPanel:Find("calc/base/minus")
	self.fittingCalcPlusBtn = self.fittingCalcPanel:Find("calc/base/plus")
	self.fittingCalcTxt = self.fittingCalcPanel:Find("calc/base/count/Text")
	self.fittingCalcMaxBtn = self.fittingCalcPanel:Find("calc/max")
	self.fittingItemInfo = self.fittingCalcPanel:Find("item_bg")
	self.fittingItemInfoIcon = self.fittingItemInfo:Find("icon")
	self.fittingItemInfoCount = self.fittingItemInfo:Find("kc")
	self.fittingConfirmBtn = self.fittingCalcPanel:Find("confirm_btn")
	self.fittingCancelBtn = self.fittingCalcPanel:Find("cancel_btn")
	self.msgPanel = self.blurPanel:Find("msg_panel")

	setActive(self.msgPanel, false)

	self.versionPanel = self._tf:Find("version_panel")

	setActive(self.versionPanel, false)

	self.preViewer = self._tf:Find("preview")
	self.preViewerFrame = self._tf:Find("preview/frame")

	setText(self.preViewerFrame:Find("bg/title/Image"), i18n("word_preview"))
	setActive(self.preViewer, false)

	self.sea = self.preViewerFrame:Find("sea")
	self.rawImage = self.sea:GetComponent("RawImage")

	setActive(self.rawImage, false)

	self.seaLoading = self.preViewerFrame:Find("bg/loading")
	self.healTF = self._tf:Find("resources/heal")
	self.healTF.transform.localPosition = Vector3(-360, 50, 40)

	setActive(self.healTF, false)

	self.stages = self.preViewerFrame:Find("stageScrollRect/stages")
	self.breakView = self.preViewerFrame:Find("content/Text")
	self.previewAttrPanel = self._tf:Find("preview/attrs_panel/attr_panel")
	self.previewAttrContainer = self.previewAttrPanel:Find("content")

	setText(self._tf:Find("preview/attrs_panel/Text"), i18n("meta_energy_preview_tip"))
	setText(self._tf:Find("preview/attrs_panel/desc"), i18n("meta_energy_preview_title"))

	self.helpBtn = self.top:Find("helpBtn")
	self.exchangeBtn = self.top:Find("exchangeBtn")
	self.itemUnlockBtn = self.top:Find("itemUnlockBtn")
	self.bottomWidth = self.bottomPanel.rect.height
	self.topWidth = self.topPanel.rect.height * 2
	self.taskTFs = {}
	self.leanTweens = {}
	self.unlockPanel = self.blurPanel:Find("unlock_panel")

	setActive(self.unlockPanel, false)

	self.svQuickExchange = BlueprintQuickExchangeView.New(self._tf, self.event)
end

function ShipBluePrintScene:didEnter()
	local var_11_0 = getProxy(TechnologyProxy):getConfigMaxVersion()

	if not self.contextData.shipBluePrintVO then
		local var_11_1 = {}

		for iter_11_0 = 1, var_11_0 do
			var_11_1[iter_11_0] = 0
		end

		for iter_11_1, iter_11_2 in pairs(self.bluePrintByIds) do
			local var_11_2 = iter_11_2:getConfig("blueprint_version")

			var_11_1[var_11_2] = var_11_1[var_11_2] + (iter_11_2.state == ShipBluePrint.STATE_UNLOCK and 1 or 0)

			if iter_11_2.state == ShipBluePrint.STATE_DEV then
				self.contextData.shipBluePrintVO = self.contextData.shipBluePrintVO or iter_11_2

				break
			end
		end

		if not self.contextData.shipBluePrintVO then
			for iter_11_3 = 1, var_11_0 do
				self.version = iter_11_3

				if var_11_1[iter_11_3] <= 4 then
					break
				end
			end

			self:emit(ShipBluePrintMediator.SET_TECHNOLOGY_VERSION, self.version)
		end
	end

	self:switchHide()
	self:initShips()
	onButton(self, self.speedupBtn, function()
		self:emit(ShipBluePrintMediator.ON_CLICK_SPEEDUP_BTN)
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SOUND_BACK)
	onButton(self, self.startBtn, function()
		if not self.contextData.shipBluePrintVO then
			return
		end

		self:emit(ShipBluePrintMediator.ON_START, self.contextData.shipBluePrintVO.id)
	end, SFX_PANEL)
	onButton(self, self.finishedBtn, function()
		if not self.contextData.shipBluePrintVO then
			return
		end

		self:emit(ShipBluePrintMediator.ON_FINISHED, self.contextData.shipBluePrintVO.id)
	end, SFX_PANEL)
	onButton(self, self.itemUnlockBtn, function()
		if not self.contextData.shipBluePrintVO then
			return
		end

		self:showUnlockPanel()
	end, SFX_PANEL)
	onButton(self, self.preViewBtn, function()
		self:openPreView()
	end, SFX_PANEL)
	onButton(self, self.seaLoading, function()
		if not self.previewer then
			self:showBarrage()
		end
	end, SFX_PANEL)
	onButton(self, self.preViewer, function()
		self:closePreview()
	end, SFX_PANEL)
	onButton(self, self.eyeTF, function()
		if self.isSwitchAnim then
			return
		end

		self:switchHide()
		self:switchState(var_0_7, not self.flag)
	end, SFX_PANEL)
	onButton(self, self.main, function()
		if self.isSwitchAnim then
			return
		end

		if not self.flag then
			self:switchHide()
			self:switchState(var_0_7, not self.flag)
		end
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip[isActive(self.fittingPanel) and "help_shipblueprintui_luck" or "help_shipblueprintui"].tip
		})
	end, SFX_PANEL)
	onButton(self, self.exchangeBtn, function()
		self.svQuickExchange:Load()
		self.svQuickExchange:ActionInvoke("Show")
		self.svQuickExchange:ActionInvoke("UpdateBlueprint", self.contextData.shipBluePrintVO)
	end)
	setText(self.modPanel:Find("switch/Text"), i18n("tech_shadow_change_button_1"))
	onButton(self, self.modPanel:Find("switch"), function()
		self:switchState(var_0_7, true, function()
			self.isPhantom = true

			setActive(self.phantomPanel, self.isPhantom)
			setActive(self.modPanel, not self.isPhantom)
		end)
	end, SFX_PANEL)
	setText(self.phantomPanel:Find("switch/Text"), i18n("tech_shadow_change_button_2"))
	onButton(self, self.phantomPanel:Find("switch"), function()
		self:switchState(var_0_7, true, function()
			self.isPhantom = false

			setActive(self.phantomPanel, self.isPhantom)
			setActive(self.modPanel, not self.isPhantom)
		end)
	end, SFX_PANEL)
	onButton(self, self.btnPhantom, function()
		self:emit(ShipBluePrintMediator.OPEN_PHANTOM_LAYER, self.version)
	end, SFX_PANEL)
	self:OverlayPanel(self.blurPanel, {
		pbList = {
			self.rightPanel:Find("task_list"),
			self.rightPanel:Find("mod_panel"),
			self.leftPanle:Find("property_panel"),
			self.bottomPanel:Find("ships/bg")
		}
	})
	setText(self.msgPanel:Find("window/top/bg/infomation/title"), i18n("title_info"))
	onButton(self, self.msgPanel:Find("window/top/btnBack"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgPanel, self.top)
		setActive(self.msgPanel, false)
	end, SFX_CANCEL)
	setText(self.msgPanel:Find("window/confirm_btn/Text"), i18n("text_confirm"))
	onButton(self, self.msgPanel:Find("window/confirm_btn"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgPanel, self.top)
		setActive(self.msgPanel, false)
	end, SFX_CANCEL)
	onButton(self, self.msgPanel:Find("bg"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgPanel, self.top)
		setActive(self.msgPanel, false)
	end, SFX_CANCEL)
	onButton(self, self.unlockPanel:Find("window/top/btnBack"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
	end, SFX_CANCEL)
	setText(self.unlockPanel:Find("window/confirm_btn/Text"), i18n("text_confirm"))
	setText(self.unlockPanel:Find("window/cancel_btn/Text"), i18n("text_cancel"))
	setText(self.unlockPanel:Find("window/top/bg/infomation/title"), i18n("title_info"))
	onButton(self, self.unlockPanel:Find("window/cancel_btn"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
	end, SFX_CANCEL)
	onButton(self, self.unlockPanel:Find("bg"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
	end, SFX_CANCEL)
	GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "version_" .. self.version, self.versionBtn)
	self:updateVersionBtnTip()

	if var_11_0 > 1 then
		onButton(self, self.versionBtn, function()
			if self.cbTimer then
				return
			end

			setActive(self.versionPanel, true)
			pg.UIMgr.GetInstance():BlurPanel(self.versionPanel)
		end, SFX_PANEL)
		onButton(self, self.versionPanel:Find("bg"), function()
			pg.UIMgr.GetInstance():UnOverlayPanel(self.versionPanel, self._tf)
			setActive(self.versionPanel, false)
		end, SFX_CANCEL)

		local var_11_3 = UIItemList.New(self.versionPanel:Find("window/content"), self.versionPanel:Find("window/content/version_1"))

		var_11_3:make(function(arg_37_0, arg_37_1, arg_37_2)
			arg_37_1 = arg_37_1 + 1

			if arg_37_0 == UIItemList.EventUpdate then
				arg_37_2.name = "version_" .. arg_37_1

				GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "newVersion_" .. arg_37_1, arg_37_2:Find("image"))

				if self.version == arg_37_1 then
					setActive(arg_37_2:Find("choose"), true)
				else
					setActive(arg_37_2:Find("choose"), false)
				end

				onButton(self, arg_37_2, function()
					self.version = arg_37_1

					self:emit(ShipBluePrintMediator.SET_TECHNOLOGY_VERSION, self.version)

					self.contextData.shipBluePrintVO = nil

					GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "version_" .. self.version, self.versionBtn)
					self:initShips()
					self:updateVersionBtnTip()
					var_11_3:align(var_11_0)
					pg.UIMgr.GetInstance():UnOverlayPanel(self.versionPanel, self._tf)
					setActive(self.versionPanel, false)
				end, SFX_CANCEL)
			end
		end)
		var_11_3:align(var_11_0)
		self:updateVersionPanelBtnTip()
	end

	LeanTween.alpha(rtf(self.skillArrLeft), 0.25, 1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong()
	LeanTween.alpha(rtf(self.skillArrRight), 0.25, 1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong()
end

function ShipBluePrintScene:updateVersionBtnTip()
	local var_39_0 = getProxy(TechnologyProxy)
	local var_39_1 = {}

	for iter_39_0 = 1, var_39_0:getConfigMaxVersion() do
		if iter_39_0 ~= self.version then
			table.insert(var_39_1, iter_39_0)
		end
	end

	setActive(self.versionBtn:Find("tip"), var_39_0:CheckPursuingCostTip(var_39_1))
end

function ShipBluePrintScene:updateVersionPanelBtnTip()
	local var_40_0 = getProxy(TechnologyProxy)

	for iter_40_0 = 1, var_40_0:getConfigMaxVersion() do
		setActive(self.versionPanel:Find("window/content/version_" .. iter_40_0 .. "/tip"), var_40_0:CheckPursuingCostTip({
			iter_40_0
		}))
	end
end

function ShipBluePrintScene:updateAllPursuingCostTip()
	self:updateVersionBtnTip()
	self:updateVersionPanelBtnTip()

	for iter_41_0, iter_41_1 in pairs(self.bluePrintItems) do
		iter_41_1:updatePursuingTip()
	end
end

function ShipBluePrintScene:switchHide()
	local var_42_0 = not self.flag

	LeanTween.cancel(self.bottomPanel)
	LeanTween.cancel(self.topPanel)
	LeanTween.cancel(self.topBg)

	if var_42_0 then
		LeanTween.moveY(self.bottomPanel, 0, var_0_7)
		LeanTween.moveY(self.topPanel, 0, var_0_7)
		LeanTween.moveY(self.topBg, 0, var_0_7)
	else
		LeanTween.moveY(self.bottomPanel, -self.bottomWidth, var_0_7)
		LeanTween.moveY(self.topPanel, self.topWidth, var_0_7)
		LeanTween.moveY(self.topBg, self.topWidth, var_0_7)
	end

	setActive(self.nameTF, var_42_0)
	setActive(self.stateInfo, var_42_0)
	setActive(self.helpBtn, var_42_0)
	setActive(self.exchangeBtn, var_42_0)
	setActive(self.btnPhantom, var_42_0)
	setImageAlpha(self.itemUnlockBtn, var_42_0 and 1 or 0)
	setImageRaycastTarget(self.itemUnlockBtn, var_42_0)
	setImageAlpha(self.speedupBtn, var_42_0 and 1 or 0)
	setImageRaycastTarget(self.speedupBtn, var_42_0)
end

function ShipBluePrintScene:switchState(arg_43_1, arg_43_2, arg_43_3, arg_43_4)
	local var_43_0 = {}

	if self.flag then
		table.insert(var_43_0, function(arg_44_0)
			self.flag = false

			self:switchUI(arg_43_1, {
				-self.leftPanle.rect.width - 400,
				self.rightPanel.rect.width + 400
			}, arg_44_0)
		end)
	end

	table.insert(var_43_0, function(arg_45_0)
		existCall(arg_43_3)

		return arg_45_0()
	end)

	if arg_43_2 then
		table.insert(var_43_0, function(arg_46_0)
			self.flag = true

			if self.isFate or self.isPhantom then
				self:switchUI(arg_43_1, {
					-self.leftPanle.rect.width - 400,
					0,
					-self.leftPanle.rect.width / 2
				}, arg_46_0)
			else
				self:switchUI(arg_43_1, {
					0,
					0,
					0
				}, arg_46_0)
			end
		end)
	end

	seriesAsync(var_43_0, arg_43_4)
end

function ShipBluePrintScene:switchUI(arg_47_1, arg_47_2, arg_47_3)
	LeanTween.cancel(self.leftPanle)
	LeanTween.cancel(self.rightPanel)
	LeanTween.cancel(self.centerPanel)

	self.isSwitchAnim = true

	parallelAsync({
		function(arg_48_0)
			LeanTween.moveX(self.leftPanle, arg_47_2[1], arg_47_1):setOnComplete(System.Action(arg_48_0))
		end,
		function(arg_49_0)
			LeanTween.moveX(self.rightPanel, arg_47_2[2], arg_47_1):setOnComplete(System.Action(arg_49_0))
		end,
		function(arg_50_0)
			if arg_47_2[3] then
				LeanTween.moveX(self.centerPanel, arg_47_2[3], arg_47_1):setOnComplete(System.Action(arg_50_0))
			else
				arg_50_0()
			end
		end
	}, function()
		self.isSwitchAnim = false

		return arg_47_3()
	end)
end

function ShipBluePrintScene:createShipItem(arg_52_1)
	local var_52_0 = {
		init = function(self)
			self._go = arg_52_1
			self._tf = tf(arg_52_1)
			self.icon = self._tf:Find("icon")
			self.state = self._tf:Find("state")
			self.count = self._tf:Find("count")
			self.tip = self._tf:Find("tip")
		end,
		update = function(self, arg_54_1, arg_54_2)
			SetCompomentEnabled(self._tf, typeof(Toggle), arg_54_1.id > 0)

			self.shipBluePrintVO = arg_54_1

			setActive(self.state, self.shipBluePrintVO.id > 0)
			setActive(self.count, self.shipBluePrintVO.id > 0)

			if self.shipBluePrintVO.id > 0 then
				LoadSpriteAsync("shipdesignicon/" .. self.shipBluePrintVO:getShipVO():getPainting(), function(arg_55_0)
					if self.shipBluePrintVO.id > 0 then
						if string.find(arg_55_0.name, self.shipBluePrintVO:getShipVO():getPainting()) then
							setImageSprite(self.icon, arg_55_0)
						end
					end
				end)

				local var_54_0 = {
					tip = false,
					pursuing = arg_54_1:isPursuing(),
					fate = arg_54_1:canFateSimulation()
				}

				switch(arg_54_1.state, {
					[ShipBluePrint.STATE_LOCK] = function()
						var_54_0.state = "lock" .. (arg_54_1:getUnlockItem() and "_item" or "")
					end,
					[ShipBluePrint.STATE_DEV] = function()
						var_54_0.state = "research"
					end,
					[ShipBluePrint.STATE_DEV_FINISHED] = function()
						var_54_0.state = var_54_0.fate and "fate" or "dev"
						var_54_0.tip = true
					end,
					[ShipBluePrint.STATE_UNLOCK] = function()
						var_54_0.state = var_54_0.fate and "fate" or "dev"
					end
				})
				setText(self.count, arg_54_2.count > 999 and "999+" or arg_54_2.count)
				setActive(self.count:Find("icon"), not var_54_0.pursuing)
				setActive(self.count:Find("icon_2"), var_54_0.pursuing)
				setText(self.state:Find("dev/Text"), self.shipBluePrintVO.level)

				if var_54_0.fate then
					GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "icon_phase_" .. self.shipBluePrintVO.fateLevel, self.state:Find("fate/Image"), true)
				end

				eachChild(self.state, function(arg_60_0)
					setActive(arg_60_0, arg_60_0.name == var_54_0.state)
				end)
				setActive(self.tip, var_54_0.tip)
			else
				LoadSpriteAsync("shipdesignicon/empty", function(arg_61_0)
					if self.shipBluePrintVO.id < 0 then
						setImageSprite(self.icon, arg_61_0)
					end
				end)
				setActive(self.tip, false)
			end
		end,
		updateSelectedStyle = function(self, arg_62_1)
			local var_62_0 = arg_62_1 and 0 or -25

			LeanTween.cancel(self.icon)
			LeanTween.moveY(self.icon, var_62_0, 0.1)
		end,
		updatePursuingTip = function(self)
			setActive(self.count:Find("icon_2/tip"), self.shipBluePrintVO.id > 0 and self.shipBluePrintVO:isPursuingCostTip())
		end
	}

	var_52_0:init()
	onButton(self, var_52_0.count:Find("icon_2"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("blueprint_catchup_by_gold_help")
		})
	end, SFX_PANEL)

	return var_52_0
end

function ShipBluePrintScene:initShips()
	self:checkStory()
	self:filterBlueprints()

	if not self.itemList then
		self.bluePrintItems = {}
		self.itemList = UIItemList.New(self.shipContainer, self.shipContainer:Find("ship_tpl"))

		self.itemList:make(function(arg_66_0, arg_66_1, arg_66_2)
			if arg_66_0 == UIItemList.EventUpdate then
				onToggle(self, arg_66_2, function(arg_67_0)
					if arg_67_0 then
						if self.cbTimer then
							self.cbTimer:Stop()

							self.cbTimer = nil
						end

						self:clearLeanTween()

						self.contextData.shipBluePrintVO = self.bluePrintItems[arg_66_2].shipBluePrintVO

						if self.nowShipId ~= self.contextData.shipBluePrintVO.id then
							self.nowShipId = self.contextData.shipBluePrintVO.id

							self:switchState(var_0_7, true, function()
								self:setSelectedBluePrint()
							end)
						else
							self:setSelectedBluePrint()
						end
					end

					self.bluePrintItems[arg_66_2]:updateSelectedStyle(arg_67_0)
				end, SFX_PANEL)

				self.bluePrintItems[arg_66_2] = self.bluePrintItems[arg_66_2] or self:createShipItem(arg_66_2)

				if self.filterBlueprintVOs[arg_66_1 + 1].id > 0 then
					self.bluePrintItems[arg_66_2]:update(self.filterBlueprintVOs[arg_66_1 + 1], (self:getItemById((self.filterBlueprintVOs[arg_66_1 + 1]:getItemId()))))
					self.bluePrintItems[arg_66_2]:updatePursuingTip()
				else
					self.bluePrintItems[arg_66_2]:update(self.filterBlueprintVOs[arg_66_1 + 1], nil)
				end

				triggerToggle(arg_66_2, false)
			end
		end)
	end

	setActive(self.shipContainer, false)
	self.itemList:align(#self.filterBlueprintVOs)
	setActive(self.shipContainer, true)

	if not self.contextData.shipBluePrintVO or underscore.all(self.filterBlueprintVOs, function(arg_69_0)
		return self.contextData.shipBluePrintVO.id ~= arg_69_0.id
	end) then
		self.contextData.shipBluePrintVO = self.filterBlueprintVOs[1]
	end

	eachChild(self.shipContainer, function(arg_70_0)
		if self.contextData.shipBluePrintVO.id == self.bluePrintItems[arg_70_0].shipBluePrintVO.id then
			triggerToggle(arg_70_0, true)
		end
	end)
end

function ShipBluePrintScene:filterBlueprints()
	if self.contextData.shipBluePrintVO then
		self.version = self.contextData.shipBluePrintVO:getConfig("blueprint_version")

		self:emit(ShipBluePrintMediator.SET_TECHNOLOGY_VERSION, self.version)
	end

	self.filterBlueprintVOs = {}

	local var_71_0 = 0

	for iter_71_0, iter_71_1 in pairs(self.bluePrintByIds) do
		if iter_71_1:getConfig("blueprint_version") == self.version then
			table.insert(self.filterBlueprintVOs, iter_71_1)

			var_71_0 = var_71_0 + 1
		end
	end

	for iter_71_2 = var_71_0, 5 do
		table.insert(self.filterBlueprintVOs, {
			id = -1,
			state = -1
		})
	end

	table.sort(self.filterBlueprintVOs, CompareFuncs({
		function(arg_72_0)
			return -arg_72_0.state
		end,
		function(arg_73_0)
			return arg_73_0.id
		end
	}))
end

function ShipBluePrintScene:getSelectedBluePrintResList(arg_74_1)
	local var_74_0 = {}
	local var_74_1 = arg_74_1:getShipVO():getPainting()
	local var_74_2 = arg_74_1:getTaskIds()

	table.insert(var_74_0, "painting/" .. var_74_1)

	if checkABExist("painting/" .. var_74_1 .. "_blueprint") then
		table.insert(var_74_0, "painting/" .. var_74_1 .. "_blueprint")
	end

	if PLATFORM_CODE == PLATFORM_CH then
		if checkABExist("painting/" .. var_74_1 .. "_hx") then
			table.insert(var_74_0, "painting/" .. var_74_1 .. "_hx")
		end

		if checkABExist("painting/" .. var_74_1 .. "n_hx") then
			table.insert(var_74_0, "painting/" .. var_74_1 .. "n_hx")
		end

		if checkABExist("painting/" .. var_74_1 .. "n") then
			table.insert(var_74_0, "painting/" .. var_74_1 .. "n")
		end
	end

	if arg_74_1:canFateSimulation() then
		for iter_74_0 = 1, arg_74_1:getMaxFateLevel() do
			local var_74_3 = arg_74_1:getFateStrengthenConfig(iter_74_0)

			if var_74_3 and var_74_3.special == 1 and type(var_74_3.special_effect) == "table" then
				for iter_74_1, iter_74_2 in ipairs(var_74_3.special_effect) do
					if iter_74_2[1] == ShipBluePrint.STRENGTHEN_TYPE_CHANGE_SKILL then
						if iter_74_2[2][2] then
							table.insert(var_74_0, "tecfateskillicon/skill_" .. iter_74_2[2][2])
							table.insert(var_74_0, "tecfateskillicon/skill_on_" .. iter_74_2[2][2])
						end

						break
					end
				end
			end
		end
	end

	return var_74_0
end

function ShipBluePrintScene:downloadSelectedBluePrintResList(arg_75_1, arg_75_2)
	SplitPackConst.DownloadByLuaArr(self:getSelectedBluePrintResList(arg_75_1), function()
		if self.exited then
			return
		end

		arg_75_2()
	end)
end

function ShipBluePrintScene:setSelectedBluePrint()
	assert(self.contextData.shipBluePrintVO, "should exist blue print")

	local var_77_0 = self.contextData.shipBluePrintVO

	self:downloadSelectedBluePrintResList(self.contextData.shipBluePrintVO, function()
		self:updateInfo()
		self:updatePainting()
		self:updateProperty()

		local var_78_0 = var_77_0:isUnlock()

		setActive(self.taskListPanel, not var_78_0)
		setActive(self.attrDisableBtn, not var_78_0)

		if var_78_0 then
			if var_77_0:canFateSimulation() then
				if not pg.NewStoryMgr.GetInstance():IsPlayed(var_77_0:getConfig("luck_story")) then
					self.isFate = false
				end
			end

			self:updateMod()
			self:updatePhantomQuest()
		else
			self.isFate = false

			self:updateTaskList()
			triggerToggle(self.initBtn, true)
		end

		setActive(self.phantomPanel, var_78_0 and self.isPhantom)
		setActive(self.fittingPanel, var_78_0 and self.isFate)
		setActive(self.modPanel, var_78_0 and not self.isFate and not self.isPhantom)
		setActive(self.itemUnlockBtn, not var_78_0 and var_77_0:getUnlockItem())

		if var_77_0:isDeving() then
			self:emit(ShipBluePrintMediator.ON_CHECK_TAKES, var_77_0.id)
		end
	end)
end

function ShipBluePrintScene:updateMod()
	if self.noUpdateMod then
		return
	end

	local var_79_0 = self.contextData.shipBluePrintVO

	if not self.contextData.shipBluePrintVO or not var_79_0:isUnlock() or not var_79_0:isFetched() then
		return
	end

	self:updateModPanel()
	self:updateModAdditionPanel()
end

function ShipBluePrintScene:updateModInfo(arg_80_1)
	local var_80_0 = self:getShipById(arg_80_1.shipId)
	local var_80_1 = self.contextData.shipBluePrintVO
	local var_80_2 = intProperties(self.contextData.shipBluePrintVO:getShipProperties(var_80_0))
	local var_80_3 = Clone(arg_80_1)

	var_80_3.level = var_80_3:getMaxLevel()

	local var_80_4 = intProperties(var_80_3:getShipProperties(var_80_0))

	local function var_80_5(arg_81_0, arg_81_1, arg_81_2, arg_81_3)
		local var_81_0 = arg_81_0:Find("pre_slider"):GetComponent(typeof(Slider))

		if arg_80_1:isMaxLevel() then
			arg_81_3 = arg_81_2
		end

		setText(arg_81_0:Find("attr_bg/max"), arg_81_3)
		setText(arg_81_0:Find("attr_bg/name"), AttributeType.Type2Name(arg_81_1))
		setText(arg_81_0:Find("attr_bg/value"), arg_81_2)

		local var_81_1, var_81_2 = var_80_1:getBluePrintAddition(arg_81_1)
		local var_81_3 = table.indexof(ShipModAttr.BLUEPRINT_ATTRS, arg_81_1)
		local var_81_4 = var_80_1:getExpRetio(var_81_3)

		arg_81_0:Find("slider"):GetComponent(typeof(Slider)).value = var_81_2 / var_81_4

		local var_81_5, var_81_6 = arg_80_1:getBluePrintAddition(arg_81_1)
		local var_81_7 = arg_80_1:getExpRetio(var_81_3)

		setText(arg_81_0:Find("exp"), math.floor(var_81_6) .. "/" .. var_81_4)

		var_81_0.value = math.floor(var_81_5) > math.floor(var_81_1) and 1 or var_81_6 / var_81_7
	end

	for iter_80_0, iter_80_1 in pairs((intProperties(arg_80_1:getShipProperties(var_80_0)))) do
		if table.contains(ShipModAttr.BLUEPRINT_ATTRS, iter_80_0) then
			var_80_5(self.attrContainer:Find(iter_80_0), iter_80_0, iter_80_1, var_80_4[iter_80_0] or 0)
		end
	end

	self.modLevel.text = self:formatModLvTxt(arg_80_1.level, arg_80_1:getMaxLevel())

	local var_80_9 = var_80_1:getNextLevelExp()

	self.levelSlider.value = var_80_9 == -1 and 1 or var_80_1.exp / var_80_9

	local var_80_10 = arg_80_1:getNextLevelExp()

	if var_80_10 == -1 then
		setText(self.levelSliderTxt, "MAX")

		self.preLevelSlider.value = 1
	else
		setText(self.levelSliderTxt, arg_80_1.exp .. "/" .. arg_80_1:getNextLevelExp())

		self.preLevelSlider.value = arg_80_1.level > var_80_1.level and 1 or arg_80_1.exp / var_80_10
	end

	local var_80_11, var_80_12 = arg_80_1:isShipModMaxLevel(var_80_0)

	setActive(self.needLevelTxt, var_80_11)
	setActive(self.levelSliderTxt, not var_80_11)

	if var_80_11 then
		setText(self.needLevelTxt, i18n("buleprint_need_level_tip", var_80_12))

		self.levelSlider.value = 1
	end
end

function ShipBluePrintScene:inModAnim()
	return self.inAnim
end

function ShipBluePrintScene:formatModLvTxt(arg_83_1, arg_83_2)
	return "<size=45>" .. arg_83_1 .. "</size>/<size=27>" .. arg_83_2 .. "</size>"
end

local var_0_8 = 0.2

function ShipBluePrintScene:doModAnim(arg_84_1, arg_84_2)
	self:clearLeanTween()

	self.inAnim = true

	local var_84_0 = {}
	local var_84_1 = arg_84_2:getMaxLevel()

	if arg_84_1.level ~= var_84_1 then
		local function var_84_2(arg_85_0, arg_85_1, arg_85_2)
			arg_85_0 = Clone(arg_85_0)
			arg_85_0.level = arg_85_1
			arg_85_0.exp = arg_85_2

			return arg_85_0
		end

		self.preLevelSlider.value = 0

		for iter_84_0 = arg_84_1.level, arg_84_2.level do
			local var_84_3 = iter_84_0 == arg_84_1.level and arg_84_1.exp / arg_84_1:getNextLevelExp() or 0
			local var_84_4 = iter_84_0 == arg_84_2.level and arg_84_2.level ~= var_84_1 and arg_84_2.exp / arg_84_2:getNextLevelExp() or 1

			table.insert(var_84_0, function(arg_86_0)
				TweenValue(go(self.levelSlider), var_84_3, var_84_4, var_0_8, nil, function(arg_87_0)
					self.levelSlider.value = arg_87_0
				end, function()
					local var_88_0

					if iter_84_0 == arg_84_1.level then
						var_88_0 = arg_84_1 or var_84_2(arg_84_1, iter_84_0, 0)

						local var_88_1

						if iter_84_0 == arg_84_2.level then
							var_88_1 = arg_84_2 or var_84_2(arg_84_1, iter_84_0 + 1, 0)
						end
					end

					self:doAttrsAinm(var_88_0, var_88_1, arg_86_0)

					self.modLevel.text = self:formatModLvTxt(var_88_1.level, var_84_1)
				end)
			end)
		end

		table.insert(self.leanTweens, self.levelSlider)
	else
		var_84_1 = arg_84_2:getMaxFateLevel()

		local function var_84_5(arg_89_0, arg_89_1, arg_89_2)
			arg_89_0 = Clone(arg_89_0)
			arg_89_0.fateLevel = arg_89_1
			arg_89_0.exp = arg_89_2

			return arg_89_0
		end

		self.prePhaseSlider.value = 0

		for iter_84_1 = arg_84_1.fateLevel, arg_84_2.fateLevel do
			local var_84_6 = iter_84_1 == arg_84_1.fateLevel and arg_84_1.exp / arg_84_1:getNextFateLevelExp() or 0
			local var_84_7 = iter_84_1 == arg_84_2.fateLevel and arg_84_2.fateLevel ~= var_84_1 and arg_84_2.exp / arg_84_2:getNextFateLevelExp() or 1

			table.insert(var_84_0, function(arg_90_0)
				TweenValue(go(self.phaseSlider), var_84_6, var_84_7, var_0_8, nil, function(arg_91_0)
					self.phaseSlider.value = arg_91_0
				end, function()
					if iter_84_1 ~= arg_84_1.fateLevel or not arg_84_1 then
						local var_92_0 = var_84_5(arg_84_1, iter_84_1, 0)
					end

					local var_92_1

					if iter_84_1 == arg_84_2.fateLevel then
						var_92_1 = arg_84_2 or var_84_5(arg_84_1, iter_84_1 + 1, 0)
					end

					self:updateFittingAttrPanel(var_92_1)
					GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "phase_" .. math.min(var_92_1.fateLevel + 1, var_92_1:getMaxFateLevel()), self.phasePic, true)
					arg_90_0()
				end)
			end)
		end

		table.insert(self.leanTweens, self.phaseSlider)
	end

	seriesAsync(var_84_0, function()
		self.noUpdateMod = false

		self:updateMod()

		self.inAnim = false
	end)
end

function ShipBluePrintScene:doAttrsAinm(arg_94_1, arg_94_2, arg_94_3)
	local var_94_0 = {}
	local var_94_1 = self:getShipById(arg_94_1.shipId)
	local var_94_2 = intProperties(arg_94_1:getShipProperties(var_94_1))
	local var_94_3 = intProperties(arg_94_2:getShipProperties(var_94_1))

	for iter_94_0, iter_94_1 in ipairs(ShipModAttr.BLUEPRINT_ATTRS) do
		if iter_94_1 ~= AttributeType.AntiAircraft then
			local var_94_4 = self.attrContainer:Find(iter_94_1)
			local var_94_5 = var_94_4:Find("attr_bg/value")
			local var_94_6 = var_94_5:GetComponent(typeof(Text))
			local var_94_7 = var_94_4:Find("slider"):GetComponent(typeof(Slider))
			local var_94_8 = var_94_4:Find("pre_slider").GetComponent(var_94_5, typeof(Slider))
			local var_94_9 = arg_94_1:getExpRetio((table.indexof(ShipModAttr.BLUEPRINT_ATTRS, iter_94_1)))
			local var_94_10 = var_94_2[iter_94_1]
			local var_94_11 = var_94_3[iter_94_1]
			local var_94_12, var_94_13 = arg_94_1:getBluePrintAddition(iter_94_1)
			local var_94_14, var_94_15 = arg_94_2:getBluePrintAddition(iter_94_1)
			local var_94_16 = var_94_13 / var_94_9
			local var_94_17 = var_94_15 / var_94_9

			var_94_8.value = 0

			table.insert(var_94_0, function(arg_95_0)
				self:doAttrAnim(var_94_7, var_94_6, var_94_16, var_94_17, math.floor(var_94_12), math.floor(var_94_14), var_94_10, var_94_11, arg_95_0)
			end)
		end
	end

	parallelAsync(var_94_0, arg_94_3)
end

local var_0_9 = 0.1

function ShipBluePrintScene:doAttrAnim(arg_96_1, arg_96_2, arg_96_3, arg_96_4, arg_96_5, arg_96_6, arg_96_7, arg_96_8, arg_96_9)
	table.insert(self.leanTweens, arg_96_1)

	local var_96_0 = {}

	for iter_96_0 = arg_96_5, arg_96_6 do
		local var_96_1 = iter_96_0 == arg_96_5 and arg_96_3 or 0
		local var_96_2 = iter_96_0 == arg_96_6 and arg_96_4 or 1

		table.insert(var_96_0, function(arg_97_0)
			TweenValue(go(arg_96_1), var_96_1, var_96_2, var_0_9, nil, function(arg_98_0)
				arg_96_1.value = arg_98_0
			end, function()
				arg_96_2.text = arg_96_8 - math.min(arg_96_6 - iter_96_0, arg_96_8 - arg_96_7)

				arg_97_0()
			end)
		end)
	end

	seriesAsync(var_96_0, function()
		arg_96_9()
	end)
end

function ShipBluePrintScene:clearLeanTween(arg_101_1)
	for iter_101_0, iter_101_1 in pairs(self.leanTweens) do
		if LeanTween.isTweening(go(iter_101_1)) then
			LeanTween.cancel(go(iter_101_1))
		end
	end

	if self.inAnim then
		self.inAnim = nil

		if not arg_101_1 then
			self.noUpdateMod = false
		end
	end

	self.leanTweens = {}
end

function ShipBluePrintScene:updateModPanel()
	local var_102_0 = self.contextData.shipBluePrintVO
	local var_102_1 = self:getShipById(self.contextData.shipBluePrintVO.shipId)
	local var_102_2 = self:getItemById((self.contextData.shipBluePrintVO:getConfig("strengthen_item")))
	local var_102_3 = var_102_2.count == 0 and var_102_0:isPursuing()
	local var_102_4 = 0
	local var_102_5
	local var_102_6

	if var_102_3 then
		local var_102_7 = getProxy(TechnologyProxy)

		var_102_5 = math.min(var_102_7:calcMaxPursuingCount(var_102_0), var_102_0:getUseageMaxItem())

		function var_102_6(arg_103_0)
			local var_103_0 = Clone(var_102_0)

			var_103_0:addExp(arg_103_0 * var_102_0:getItemExp())
			self:updateModInfo(var_103_0)
			setText(self.calcTxt, arg_103_0)

			local var_103_1 = var_102_0:isRarityUR()
			local var_103_2 = TechnologyProxy.getPursuingDiscount(var_102_7:getPursuingTimes(var_103_1) + var_102_4 + 1, var_103_1)

			setText(self.itemInfoIcon:Find("icon_bg/count"), var_102_0:getPursuingPrice(var_103_2))
			setActive(self.itemInfo:Find("no_cost"), var_103_2 == 0)
			setActive(self.itemInfo:Find("discount"), var_103_2 > 0 and var_103_2 < 100)

			if var_103_2 > 0 and var_103_2 < 100 then
				setText(self.itemInfo:Find("discount/Text"), 100 - var_103_2 .. "%OFF")
			end

			setActive(self.modBtn:Find("pursuing_cost"), var_102_4 > 0)
			setText(self.modBtn:Find("pursuing_cost/Text"), var_102_7:calcPursuingCost(var_102_0, arg_103_0))
		end

		local var_102_8 = {
			type = DROP_TYPE_RESOURCE,
			id = PlayerConst.ResGold
		}

		updateDrop(self.itemInfoIcon, var_102_8)
		onButton(self, self.itemInfoIcon, function()
			if LOCK_TECHNOLOGY_PURSUING_TIP then
				self:emit(BaseUI.ON_DROP, var_102_8)
			else
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = i18n("blueprint_catchup_by_gold_help")
				})
			end
		end, SFX_PANEL)
		setScrollText(findTF(self.itemInfo, "name/Text"), var_102_8:getConfig("name"))
		setText(self.itemInfoCount, i18n("tec_tip_material_stock") .. ":" .. getProxy(PlayerProxy):getRawData():getResource(PlayerConst.ResGold))
		setText(self.itemInfo:Find("no_cost/Text"), i18n("tec_tip_no_consumption"))
		setText(self.modBtn:Find("pursuing_cost/word"), i18n("tec_tip_to_consumption"))
		onButton(self, self.modBtn, function()
			if self:inModAnim() then
				return
			end

			if var_102_4 == 0 then
				return
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("blueprint_catchup_by_gold_confirm", var_102_7:calcPursuingCost(var_102_0, var_102_4)),
				onYes = function()
					self:emit(ShipBluePrintMediator.ON_PURSUING, var_102_0.id, var_102_4)
				end
			})
		end, SFX_PANEL)
	else
		var_102_5 = math.min(var_102_2.count, var_102_0:getUseageMaxItem())

		function var_102_6(arg_107_0)
			local var_107_0 = Clone(var_102_0)

			var_107_0:addExp(arg_107_0 * var_102_0:getItemExp())
			self:updateModInfo(var_107_0)
			setText(self.calcTxt, arg_107_0)
		end

		updateDrop(self.itemInfoIcon, {
			type = DROP_TYPE_ITEM,
			id = var_102_2.id
		})
		onButton(self, self.itemInfoIcon, function()
			ItemTipPanel.ShowItemTipbyID(var_102_2.id, i18n("title_item_ways", var_102_2:getConfig("name")))
		end, SFX_PANEL)
		setScrollText(findTF(self.itemInfo, "name/Text"), var_102_2:getConfig("name"))
		setText(self.itemInfoCount, i18n("tec_tip_material_stock") .. ":" .. var_102_2.count)
		setActive(self.itemInfo:Find("no_cost"), false)
		setActive(self.itemInfo:Find("discount"), false)
		setActive(self.modBtn:Find("pursuing_cost"), false)
		onButton(self, self.modBtn, function()
			if self:inModAnim() then
				return
			end

			if var_102_4 == 0 then
				return
			end

			self:emit(ShipBluePrintMediator.ON_MOD, var_102_0.id, var_102_4)
		end, SFX_PANEL)
	end

	var_102_6(var_102_4)

	local var_102_9 = 0
	local var_102_10 = Clone(var_102_0)
	local var_102_11 = var_102_0:getItemExp()

	while var_102_10.level < var_102_10:getMaxLevel() and var_102_1.level >= var_102_10:getStrengthenConfig(math.min(var_102_10.level + 1, var_102_10:getMaxLevel())).need_lv do
		var_102_9 = var_102_9 + 1

		var_102_10:addExp(var_102_11)
	end

	local var_102_12 = math.min(var_102_5, var_102_9)

	pressPersistTrigger(self.calcMinusBtn, 0.5, function(arg_110_0)
		if self:inModAnim() or var_102_0:isMaxLevel() or var_102_4 == 0 then
			arg_110_0()

			return
		end

		var_102_4 = var_102_4 - 1

		var_102_6(var_102_4)
	end, nil, true, true, 0.1, SFX_PANEL)
	pressPersistTrigger(self.calcPlusBtn, 0.5, function(arg_111_0)
		if self:inModAnim() or var_102_0:isMaxLevel() or var_102_4 == var_102_12 then
			arg_111_0()

			return
		end

		var_102_4 = var_102_4 + 1

		var_102_6(var_102_4)
	end, nil, true, true, 0.1, SFX_PANEL)
	onButton(self, self.calcMaxBtn, function()
		if self:inModAnim() or var_102_0:isMaxLevel() or var_102_4 == var_102_12 then
			return
		end

		var_102_4 = var_102_12

		var_102_6(var_102_4)
	end, SFX_PANEL)
	setActive(self.calcMaxBtn, not var_102_3)

	local var_102_13 = var_102_0:canFateSimulation()

	if var_102_13 then
		onButton(self, self.fittingBtn, function()
			if self.isSwitchAnim then
				return
			end

			setActive(self.fittingBtnEffect, true)

			self.cbTimer = Timer.New(function()
				self.cbTimer = nil

				setActive(self.fittingBtnEffect, false)
				self:switchState(var_0_7, true, function()
					self.isFate = true

					setActive(self.fittingPanel, self.isFate)
					setActive(self.modPanel, not self.isFate)

					if not PlayerPrefs.HasKey("first_fate") then
						triggerButton(self.helpBtn)
						PlayerPrefs.SetInt("first_fate", 1)
						PlayerPrefs.Save()
					end
				end)
			end, 0.6)

			self.cbTimer:Start()
		end, SFX_PANEL)
		self:updateFittingPanel()

		if not inGuide then
			pg.NewStoryMgr.GetInstance():Play(var_102_0:getConfig("luck_story"), function(arg_116_0)
				if arg_116_0 then
					self:buildStartAni("fateStartWindow", function()
						triggerButton(self.fittingBtn)
					end)
				end
			end)
		end
	end

	setActive(self.calcPanel, not var_102_13)
	setActive(self.fittingBtn, var_102_13)
	setActive(self.fittingBtnEffect, false)
end

function ShipBluePrintScene:updateFittingPanel()
	local var_118_0 = self.contextData.shipBluePrintVO
	local var_118_1 = self:getShipById(self.contextData.shipBluePrintVO.shipId)
	local var_118_2 = self:getItemById((self.contextData.shipBluePrintVO:getConfig("strengthen_item")))
	local var_118_3 = var_118_2.count == 0 and var_118_0:isPursuing()
	local var_118_4 = 0
	local var_118_5
	local var_118_6

	if var_118_3 then
		local var_118_7 = getProxy(TechnologyProxy)

		var_118_5 = math.min(var_118_7:calcMaxPursuingCount(var_118_0), var_118_0:getFateUseageMaxItem())

		function var_118_6(arg_119_0)
			local var_119_0 = Clone(var_118_0)

			var_119_0:addExp(arg_119_0 * var_118_0:getItemExp())
			self:updateFittingInfo(var_119_0)
			setText(self.fittingCalcTxt, arg_119_0)

			local var_119_1 = var_118_0:isRarityUR()
			local var_119_2 = TechnologyProxy.getPursuingDiscount(var_118_7:getPursuingTimes(var_119_1) + var_118_4 + 1, var_119_1)

			setText(self.fittingItemInfoIcon:Find("icon_bg/count"), var_118_0:getPursuingPrice(var_119_2))
			setActive(self.fittingItemInfo:Find("no_cost"), var_119_2 == 0)
			setActive(self.fittingItemInfo:Find("discount"), var_119_2 > 0 and var_119_2 < 100)

			if var_119_2 > 0 and var_119_2 < 100 then
				setText(self.fittingItemInfo:Find("discount/Text"), 100 - var_119_2 .. "%OFF")
			end

			setActive(self.fittingConfirmBtn:Find("pursuing_cost"), arg_119_0 > 0)
			setText(self.fittingConfirmBtn:Find("pursuing_cost/Text"), var_118_7:calcPursuingCost(var_118_0, arg_119_0))
		end

		local var_118_8 = {
			type = DROP_TYPE_RESOURCE,
			id = PlayerConst.ResGold
		}

		updateDrop(self.fittingItemInfoIcon, var_118_8)
		onButton(self, self.fittingItemInfoIcon, function()
			if LOCK_TECHNOLOGY_PURSUING_TIP then
				self:emit(BaseUI.ON_DROP, var_118_8)
			else
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = i18n("blueprint_catchup_by_gold_help")
				})
			end
		end, SFX_PANEL)
		setScrollText(findTF(self.fittingItemInfo, "name/Text"), var_118_8:getConfig("name"))
		setText(self.fittingItemInfoCount, i18n("tec_tip_material_stock") .. ":" .. getProxy(PlayerProxy):getRawData():getResource(PlayerConst.ResGold))
		setText(self.fittingItemInfo:Find("no_cost/Text"), i18n("tec_tip_no_consumption"))
		setText(self.fittingConfirmBtn:Find("pursuing_cost/word"), i18n("tec_tip_to_consumption"))
		onButton(self, self.fittingConfirmBtn, function()
			if self:inModAnim() then
				return
			end

			if var_118_4 == 0 then
				return
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("blueprint_catchup_by_gold_confirm", var_118_7:calcPursuingCost(var_118_0, var_118_4)),
				onYes = function()
					self:emit(ShipBluePrintMediator.ON_PURSUING, var_118_0.id, var_118_4)
				end
			})
		end, SFX_PANEL)
	else
		var_118_5 = math.min(var_118_2.count, var_118_0:getFateUseageMaxItem())

		function var_118_6(arg_123_0)
			local var_123_0 = Clone(var_118_0)

			var_123_0:addExp(arg_123_0 * var_118_0:getItemExp())
			self:updateFittingInfo(var_123_0)
			setText(self.fittingCalcTxt, arg_123_0)
		end

		updateDrop(self.fittingItemInfoIcon, {
			type = DROP_TYPE_ITEM,
			id = var_118_2.id
		})
		onButton(self, self.fittingItemInfoIcon, function()
			ItemTipPanel.ShowItemTipbyID(var_118_2.id, i18n("title_item_ways", var_118_2:getConfig("name")))
		end, SFX_PANEL)
		setScrollText(self.fittingItemInfo:Find("name/Text"), var_118_2:getConfig("name"))
		setText(self.fittingItemInfoCount, i18n("tec_tip_material_stock") .. ":" .. var_118_2.count)
		setActive(self.fittingItemInfo:Find("no_cost"), false)
		setActive(self.fittingItemInfo:Find("discount"), false)
		setActive(self.fittingConfirmBtn:Find("pursuing_cost"), false)
		onButton(self, self.fittingConfirmBtn, function()
			if self:inModAnim() then
				return
			end

			if var_118_4 == 0 then
				return
			end

			self:emit(ShipBluePrintMediator.ON_MOD, var_118_0.id, var_118_4)
		end, SFX_PANEL)
	end

	setText(self.fittingAttrPanel:Find("attr/name"), AttributeType.Type2Name(AttributeType.Luck))
	setText(self.fittingPanel:Find("desc/top/text/Text"), i18n("fate_phase_word"))
	onButton(self, self.fittingCancelBtn, function()
		self:switchState(var_0_7, true, function()
			self.isFate = false

			setActive(self.fittingPanel, self.isFate)
			setActive(self.modPanel, not self.isFate)
		end)
	end, SFX_PANEL)

	local var_118_9 = 0
	local var_118_10 = Clone(var_118_0)
	local var_118_11 = var_118_0:getItemExp()

	while var_118_10.fateLevel < var_118_10:getMaxFateLevel() and var_118_1.level >= var_118_10:getFateStrengthenConfig(math.min(var_118_10.fateLevel + 1, var_118_10:getMaxFateLevel())).need_lv do
		var_118_9 = var_118_9 + 1

		var_118_10:addExp(var_118_11)
	end

	local var_118_12 = math.min(var_118_5, var_118_9)

	pressPersistTrigger(self.fittingCalcMinusBtn, 0.5, function(arg_128_0)
		if self:inModAnim() or var_118_0:isMaxFateLevel() or var_118_4 == 0 then
			arg_128_0()

			return
		end

		var_118_4 = math.max(var_118_4 - 1, 0)

		var_118_6(var_118_4)
	end, nil, true, true, 0.1, SFX_PANEL)
	pressPersistTrigger(self.fittingCalcPlusBtn, 0.5, function(arg_129_0)
		if self:inModAnim() or var_118_0:isMaxFateLevel() or var_118_4 == var_118_12 then
			arg_129_0()

			return
		end

		var_118_4 = math.max(math.min(var_118_4 + 1, var_118_12), 0)

		var_118_6(var_118_4)
	end, nil, true, true, 0.1, SFX_PANEL)
	onButton(self, self.fittingCalcMaxBtn, function()
		if self:inModAnim() or var_118_0:isMaxFateLevel() or var_118_4 == var_118_12 then
			return
		end

		var_118_4 = var_118_12

		var_118_6(var_118_4)
	end, SFX_PANEL)
	setActive(self.fittingCalcMaxBtn, not var_118_3)

	local var_118_13 = self.fittingAttrPanel:Find("phase_panel")
	local var_118_14 = var_118_13:Find("phase_tpl")

	setActive(var_118_14, false)

	local var_118_15 = {
		0,
		-60,
		0,
		60
	}
	local var_118_16 = {}

	for iter_118_0 = 1, var_118_0:getMaxFateLevel() do
		local var_118_17 = var_118_13:Find("phase_" .. iter_118_0) or cloneTplTo(var_118_14, var_118_13, "phase_" .. iter_118_0)
		local var_118_18 = var_118_0:getFateStrengthenConfig(iter_118_0)

		assert(var_118_18.special == 1 and type(var_118_18.special_effect) == "table", "without fate config")

		local var_118_19

		for iter_118_1, iter_118_2 in ipairs(var_118_18.special_effect) do
			if iter_118_2[1] == ShipBluePrint.STRENGTHEN_TYPE_CHANGE_SKILL then
				var_118_19 = iter_118_2[2][2]

				break
			end
		end

		for iter_118_3, iter_118_4 in ipairs({
			"off",
			"on"
		}) do
			setActive(var_118_17:Find(iter_118_4 .. "/icon"), not var_118_19)
			setActive(var_118_17:Find(iter_118_4 .. "/skill"), var_118_19)
			setActive(var_118_17:Find(iter_118_4 .. "/icon/line"), var_118_15[iter_118_0])
			setActive(var_118_17:Find(iter_118_4 .. "/skill/line"), var_118_15[iter_118_0])

			if var_118_15[iter_118_0] then
				var_118_17:Find(iter_118_4 .. "/icon/line").localEulerAngles = Vector3(0, 0, var_118_15[iter_118_0])
				var_118_17:Find(iter_118_4 .. "/skill/line").localEulerAngles = Vector3(0, 0, var_118_15[iter_118_0])

				GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", iter_118_0 .. "_" .. iter_118_4, var_118_17:Find(iter_118_4 .. "/icon/icon"), true)
			end
		end

		if var_118_19 then
			GetImageSpriteFromAtlasAsync("tecfateskillicon/skill_" .. var_118_19, "", var_118_17:Find("off/skill/icon"), true)
			GetImageSpriteFromAtlasAsync("tecfateskillicon/skill_on_" .. var_118_19, "", var_118_17:Find("on/skill/icon"), true)

			var_118_16[iter_118_0] = 55
		else
			var_118_16[iter_118_0] = 40
		end

		onButton(self, var_118_17, function()
			self:showFittingMsgPanel(iter_118_0)
		end, SFX_PANEL)
	end

	for iter_118_5 = 1, var_118_0:getMaxFateLevel() do
		setAnchoredPosition(var_118_13:Find("phase_" .. iter_118_5), Vector2.zero)

		Vector2.zero.x = math.min(Vector2.zero.x, Vector2.zero.x)
		Vector2.zero.y = math.min(Vector2.zero.y, Vector2.zero.y)
		Vector2.zero.x = math.max(Vector2.zero.x, Vector2.zero.x)
		Vector2.zero.y = math.max(Vector2.zero.y, Vector2.zero.y)

		if var_118_15[iter_118_5] then
			local var_118_20 = Vector2.zero + (var_118_16[iter_118_5] + var_118_16[iter_118_5 + 1]) * Vector2(math.cos(math.pi * var_118_15[iter_118_5] / 180), math.sin(math.pi * var_118_15[iter_118_5] / 180))
		end
	end

	setSizeDelta(var_118_13, Vector2.zero - Vector2.zero)
	setAnchoredPosition(var_118_13, {
		y = -Vector2.zero.y
	})
	var_118_6(var_118_4)
end

function ShipBluePrintScene:updateFittingInfo(arg_132_1)
	local var_132_0 = self:getShipById(arg_132_1.shipId)
	local var_132_1 = self.contextData.shipBluePrintVO

	self:updateFittingAttrPanel(self.contextData.shipBluePrintVO, arg_132_1)
	GetImageSpriteFromAtlasAsync("ui/shipblueprintui_atlas", "phase_" .. math.max(arg_132_1.fateLevel, 1), self.phasePic, true)

	local var_132_2 = var_132_1:getNextFateLevelExp()

	self.phaseSlider.value = var_132_2 == -1 and 1 or var_132_1.exp / var_132_2

	local var_132_3 = arg_132_1:getNextFateLevelExp()

	if var_132_3 == -1 then
		setText(self.phaseSliderTxt, "MAX")

		self.prePhaseSlider.value = 1
	else
		setText(self.phaseSliderTxt, tostring((math.floor(arg_132_1.exp / arg_132_1:getNextFateLevelExp() * 100))) .. "%")

		self.prePhaseSlider.value = arg_132_1.fateLevel > var_132_1.fateLevel and 1 or arg_132_1.exp / var_132_3
	end

	local var_132_4, var_132_5 = arg_132_1:isShipModMaxFateLevel(var_132_0)

	setActive(self.fittingNeedMask, var_132_4)

	if var_132_4 then
		setText(self.fittingNeedMask:Find("limit"), i18n("buleprint_need_level_tip", var_132_5))

		self.phaseSlider.value = 1
	end
end

function ShipBluePrintScene:updateFittingAttrPanel(arg_133_1, arg_133_2)
	setText(self.fittingAttrPanel:Find("attr/name/Text"), " + " .. defaultValue((arg_133_2 or arg_133_1):attrSpecialAddition()[AttributeType.Luck], 0))

	self.blinkTarget = self.blinkTarget or {
		{},
		{}
	}

	for iter_133_0 = 1, arg_133_1:getMaxFateLevel() do
		local var_133_0 = self.fittingAttrPanel:Find("phase_panel/phase_" .. iter_133_0)
		local var_133_1 = var_133_0:Find("off")
		local var_133_2 = var_133_0:Find("on")

		if arg_133_2 and iter_133_0 > arg_133_1.fateLevel and iter_133_0 <= arg_133_2.fateLevel then
			setActive(var_133_1, true)
			setActive(var_133_2, true)

			if not table.contains(self.blinkTarget[1], var_133_1) then
				table.insert(self.blinkTarget[1], var_133_1)
				table.insert(self.blinkTarget[2], var_133_2)
			end
		else
			local var_133_3 = table.indexof(self.blinkTarget[1], var_133_1)

			if var_133_3 then
				table.remove(self.blinkTarget[1], var_133_3)
				table.remove(self.blinkTarget[2], var_133_3)
			end

			setActive(var_133_1, iter_133_0 > arg_133_1.fateLevel)
			setActive(var_133_2, iter_133_0 <= arg_133_1.fateLevel)

			var_133_1:GetComponent(typeof(CanvasGroup)).alpha = 1
			var_133_2:GetComponent(typeof(CanvasGroup)).alpha = 1
		end
	end

	if #self.blinkTarget[1] == 0 then
		LeanTween.cancel(go(self.fittingAttrPanel))
	elseif not LeanTween.isTweening(go(self.fittingAttrPanel)) then
		LeanTween.value(go(self.fittingAttrPanel), 1, 0, 0.8):setOnUpdate(System.Action_float(function(arg_134_0)
			for iter_134_0, iter_134_1 in ipairs(self.blinkTarget[1]) do
				iter_134_1:GetComponent(typeof(CanvasGroup)).alpha = arg_134_0
			end

			for iter_134_2, iter_134_3 in ipairs(self.blinkTarget[2]) do
				iter_134_3:GetComponent(typeof(CanvasGroup)).alpha = 1 - arg_134_0
			end
		end)):setEase(LeanTweenType.easeInOutSine):setLoopPingPong(0)
	end
end

function ShipBluePrintScene:updateModAdditionPanel()
	local var_135_0 = self.contextData.shipBluePrintVO
	local var_135_1 = self.contextData.shipBluePrintVO:specialStrengthens()

	for iter_135_0 = self.modAdditionContainer.childCount - 1, #var_135_1 do
		self:cloneTplTo(self.modAdditionTpl, self.modAdditionContainer)
	end

	for iter_135_1 = 1, self.modAdditionContainer.childCount do
		local var_135_2 = iter_135_1 <= #var_135_1
		local var_135_3 = self.modAdditionContainer:GetChild(iter_135_1 - 1)

		setActive(var_135_3, iter_135_1 <= #var_135_1)

		if var_135_2 then
			self:updateAdvanceTF(var_135_0, var_135_3, var_135_1[iter_135_1])
		end
	end
end

function ShipBluePrintScene:updateAdvanceTF(arg_136_1, arg_136_2, arg_136_3)
	local var_136_0 = arg_136_1.level < arg_136_3.level

	setActive(arg_136_2:Find("mask"), arg_136_1.level < arg_136_3.level)

	if var_136_0 then
		setText(arg_136_2:Find("mask/content/Text"), i18n("blueprint_mod_addition_lock", arg_136_3.level))
	end

	local var_136_1 = arg_136_3.des
	local var_136_2 = arg_136_3.extraDes or {}
	local var_136_3 = arg_136_2:Find("additions")

	removeAllChildren(var_136_3)

	local var_136_4 = self.modAdditionPanel:Find("scroll_rect/info")

	local function var_136_5(arg_137_0, arg_137_1)
		local var_137_0 = arg_137_0:Find("star_tpl")
		local var_137_1 = arg_137_0:Find("stars")
		local var_137_2 = arg_137_0:Find("pre_stars")

		removeAllChildren(var_137_1)
		removeAllChildren(var_137_2)

		for iter_137_0 = 1, Ship.New({
			configId = pg.ship_data_breakout[arg_137_1[2]].pre_id
		}):getStar() do
			cloneTplTo(var_137_0, var_137_1)
		end

		for iter_137_1 = 1, Ship.New({
			configId = arg_137_1[2]
		}):getStar() do
			cloneTplTo(var_137_0, var_137_2)
		end
	end

	for iter_136_0 = 1, #var_136_1 do
		local var_136_6 = cloneTplTo(var_136_4, var_136_3)
		local var_136_7 = var_136_6:Find("text_tpl")
		local var_136_8 = var_136_6:Find("breakout_tpl")

		setActive(var_136_7, false)
		setActive(var_136_6:Find("attr_tpl"), false)
		setActive(var_136_8, false)
		setActive(var_136_6:Find("empty_tpl"), false)

		if var_136_1[iter_136_0] then
			if var_136_1[iter_136_0][1] == ShipBluePrint.STRENGTHEN_TYPE_BREAKOUT then
				setActive(var_136_8, true)
				var_136_5(var_136_8, var_136_1[iter_136_0])
			else
				setActive(var_136_7, true)
				setText(var_136_7:Find("Text"), var_136_1[iter_136_0][3])
			end
		end
	end

	for iter_136_1 = 1, #var_136_2 do
		local var_136_9 = cloneTplTo(var_136_4, var_136_3)
		local var_136_10 = var_136_9:Find("text_tpl")

		setActive(var_136_10, true)
		setActive(var_136_9:Find("attr_tpl"), false)
		setActive(var_136_9:Find("breakout_tpl"), false)
		setActive(var_136_9:Find("empty_tpl"), false)
		setText(var_136_10:Find("Text"), var_136_2[iter_136_1])
	end
end

function ShipBluePrintScene:updateInfo()
	local var_138_0

	if self.contextData.shipBluePrintVO:isFetched() then
		var_138_0 = self.shipVOs[self.contextData.shipBluePrintVO.shipId]
	end

	var_138_0 = var_138_0 or self.contextData.shipBluePrintVO:getShipVO()

	local var_138_1 = var_138_0:getConfigTable()

	setText(self.shipName, (var_138_0:getName()))
	setText(self.englishName, var_138_1.english_name)
	removeAllChildren(self.stars)

	local var_138_2 = var_138_0:getMaxStar()

	for iter_138_0 = 1, var_138_2 do
		cloneTplTo(self.shipInfoStarTpl, self.stars, "star_" .. iter_138_0)
	end

	for iter_138_1 = 1, var_138_2 - var_138_0:getStar() do
		local var_138_3 = self.stars:GetChild(var_138_2 - iter_138_1)

		setActive(var_138_3:Find("star_tpl"), false)
		setActive(var_138_3:Find("empty_star_tpl"), true)
	end

	local var_138_4 = GetSpriteFromAtlas("shiptype", var_138_0:getShipType())

	if not var_138_4 then
		warning("找不到船形, shipConfigId: " .. var_138_0.configId)
	end

	setImageSprite(self.shipType, var_138_4, true)

	local var_138_5 = self.contextData.shipBluePrintVO:isLock()

	setActive(self.finishedBtn, self.contextData.shipBluePrintVO:isFinished())

	local var_138_6 = self.contextData.shipBluePrintVO:isDeving()

	setActive(self.progressPanel, var_138_6)

	if not var_138_6 then
		setActive(self.speedupBtn, false)
	end

	if var_138_6 then
		self:updateTasksProgress()
	end

	local var_138_7, var_138_8 = self.contextData.shipBluePrintVO:isFinishPrevTask()

	if var_138_5 and not var_138_8 then
		if var_138_7 then
			for iter_138_2, iter_138_3 in ipairs(self.contextData.shipBluePrintVO:getOpenTaskList()) do
				self:emit(ShipBluePrintMediator.ON_FINISH_TASK, iter_138_3)
			end

			var_138_8 = true
		else
			local var_138_9 = getProxy(TaskProxy)
			local var_138_10 = self.contextData.shipBluePrintVO:getOpenTaskList()

			for iter_138_4, iter_138_5 in ipairs(var_138_10) do
				local var_138_11 = var_138_9:getTaskVO(iter_138_5)
				local var_138_12

				if iter_138_4 > self.lockPanel.childCount then
					var_138_12 = cloneTplTo(self.lockBtn, self.lockPanel) or self.lockPanel:GetChild(iter_138_4 - 1)
				end

				setActive(var_138_12, true)

				local var_138_13 = var_138_11:getProgress()
				local var_138_14 = var_138_11:getConfig("target_num")

				setText(var_138_12:Find("Text"), (var_138_14 <= var_138_13 and setColorStr(var_138_13, COLOR_GREEN) or var_138_13) .. "/" .. var_138_14)
			end

			for iter_138_6 = #var_138_10 + 1, self.lockPanel.childCount do
				setActive(self.lockPanel:GetChild(iter_138_6 - 1), false)
			end
		end
	end

	setText(self.openCondition:Find("Text"), self.contextData.shipBluePrintVO:getConfig("unlock_word"))
	setActive(self.openCondition, var_138_5)
	setActive(self.startBtn, var_138_5 and var_138_8)
	setActive(self.lockPanel, var_138_5 and not var_138_8)
end

function ShipBluePrintScene:updateTasksProgress()
	local var_139_0 = self.contextData.shipBluePrintVO

	if not self.contextData.shipBluePrintVO:isDeving() then
		return
	end

	local var_139_1 = var_139_0:getTaskIds()

	for iter_139_0 = self.progressContainer.childCount, #var_139_1 do
		cloneTplTo(self.progressTpl, self.progressContainer)
	end

	for iter_139_1 = 1, self.progressContainer.childCount do
		local var_139_2 = self.progressContainer:GetChild(iter_139_1 - 1)
		local var_139_3 = iter_139_1 <= #var_139_1

		setActive(var_139_2, iter_139_1 <= #var_139_1)

		if var_139_3 then
			local var_139_4 = var_139_0:getTaskStateById(var_139_1[iter_139_1])

			setActive(findTF(var_139_2, "complete"), var_139_4 == ShipBluePrint.TASK_STATE_FINISHED)
			setActive(findTF(var_139_2, "lock"), var_139_4 == ShipBluePrint.TASK_STATE_LOCK or var_139_4 == ShipBluePrint.TASK_STATE_WAIT)
			setActive(findTF(var_139_2, "working"), var_139_4 == ShipBluePrint.TASK_STATE_ACHIEVED or var_139_4 == ShipBluePrint.TASK_STATE_OPENING or var_139_4 == ShipBluePrint.TASK_STATE_START)
		end
	end

	local var_139_5 = pg.gameset.technology_catchup_itemid.description[var_139_0:getConfig("blueprint_version")]

	if var_139_5 then
		setActive(self.speedupBtn, (var_139_0:getTaskStateById(var_139_1[1]) == ShipBluePrint.TASK_STATE_START or var_139_0:getTaskStateById(var_139_1[4]) == ShipBluePrint.TASK_STATE_START) and getProxy(BagProxy):getItemCountById(var_139_5[1]) > 0)
	else
		setActive(self.speedupBtn, false)
	end
end

function ShipBluePrintScene:updatePainting()
	local var_140_0 = self.contextData.shipBluePrintVO:getShipVO():getPainting()

	if PLATFORM_CODE == PLATFORM_CH and checkABExist("painting/" .. var_140_0 .. "_blueprint") then
		var_140_0 = var_140_0 .. "_blueprint"
	end

	if self.lastPaintingName and self.lastPaintingName ~= var_140_0 then
		retPaintingPrefab(self.painting, self.lastPaintingName)
	end

	self.lastPaintingName = var_140_0

	setPaintingPrefab(self.painting, var_140_0, "tuzhi")
	self:paintBreath()
end

function ShipBluePrintScene:updateProperty()
	local var_141_0 = self.contextData.shipBluePrintVO
	local var_141_1 = self.contextData.shipBluePrintVO:getShipVO()

	self.propertyPanel:initProperty(var_141_1.configId, PropertyPanel.TypeFlat)

	local var_141_2 = var_0_2[var_141_1.configId].buff_list_display

	for iter_141_0 = self.skillPanel.childCount, #var_0_2[var_141_1.configId].buff_list_display - 1 do
		cloneTplTo(self.skillTpl, self.skillPanel)
	end

	for iter_141_1 = 1, self.skillPanel.childCount do
		local var_141_3 = self.skillPanel:GetChild(iter_141_1 - 1)
		local var_141_4 = iter_141_1 <= #var_141_2

		if iter_141_1 <= #var_141_2 then
			local var_141_5 = getSkillConfig(var_141_2[iter_141_1])

			LoadImageSpriteAsync("skillicon/" .. var_141_5.icon, (findTF(var_141_3, "icon")))
			onButton(self, var_141_3, function()
				self:emit(ShipBluePrintMediator.SHOW_SKILL_INFO, var_141_5.id, {
					id = var_141_5.id,
					level = pg.skill_data_template[var_141_5.id].max_level
				}, function()
					return
				end)
			end, SFX_PANEL)
		end

		setActive(var_141_3, var_141_4)
	end

	setActive(self.skillArrLeft, #var_141_2 > 3)
	setActive(self.skillArrRight, #var_141_2 > 3)

	if #var_141_2 > 3 then
		onScroll(self, self.skillRect, function(arg_144_0)
			setActive(self.skillArrLeft, arg_144_0.x > 0.01)
			setActive(self.skillArrRight, arg_144_0.x < 0.99)
		end)
	else
		GetComponent(self.skillRect, typeof(ScrollRect)).onValueChanged:RemoveAllListeners()
	end

	setAnchoredPosition(self.skillPanel, {
		x = 0
	})

	local var_141_6 = var_141_0:getConfig("simulate_dungeon")

	setActive(self.simulationBtn, var_141_6 ~= 0)
	onButton(self, self.simulationBtn, function()
		if var_141_6 == 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("tech_simulate_closed"))
		else
			local var_145_0 = {}

			var_145_0.content = i18n("blueprint_simulation_confirm_" .. var_141_0.id)

			function var_145_0.onYes()
				self:emit(ShipBluePrintMediator.SIMULATION_BATTLE, var_141_6)
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox(var_145_0)
		end
	end, SFX_CONFIRM)
end

function ShipBluePrintScene:updateTaskList()
	local var_147_0 = self.contextData.shipBluePrintVO
	local var_147_1 = self.contextData.shipBluePrintVO:getTaskIds()

	UIItemList.StaticAlign(self.taskContainer, self.taskTpl, #var_147_1, function(arg_148_0, arg_148_1, arg_148_2)
		arg_148_1 = arg_148_1 + 1

		if arg_148_0 == UIItemList.EventUpdate then
			if self.taskTFs[arg_148_1] then
				self.taskTFs[arg_148_1]:clear()
			end

			if arg_148_1 <= #var_147_1 then
				self.taskTFs[arg_148_1] = self.taskTFs[arg_148_1] or self:createTask(arg_148_2)

				local var_148_0 = var_147_1[arg_148_1]
				local var_148_1 = self:getTaskById(var_147_1[arg_148_1])

				if var_147_0.duration > 0 then
					var_148_1.leftTime = var_147_0:getTaskOpenTimeStamp(var_148_0) - var_147_0.duration
				end

				var_148_1.taskState = var_147_0:getTaskStateById(var_148_0)
				var_148_1.dueTime = var_147_0:getTaskOpenTimeStamp(var_148_0)
				var_148_1.index = arg_148_1

				self.taskTFs[arg_148_1]:update(var_148_1)
			end
		end
	end)
end

function ShipBluePrintScene:updatePhantomQuest()
	local var_149_0 = self.contextData.shipBluePrintVO
	local var_149_1 = self.contextData.shipBluePrintVO:isUnlockShipPhantom()

	setActive(self.phantomPanel:Find("title/bg"), var_149_1)
	setActive(self.phantomPanel:Find("title/bg_lock"), not var_149_1)
	setActive(self.phantomPanel:Find("desc/content"), var_149_1)
	setActive(self.phantomPanel:Find("desc/lock_mask"), not var_149_1)
	setText(self.phantomPanel:Find("desc/lock_mask/Text"), i18n("tech_shadow_limit_text", getGameset("technology_shadow_unlock_lv")[1]))

	if not var_149_1 then
		return
	end

	local var_149_2 = self.contextData.shipBluePrintVO:getAllPhantomQuestInfo()

	setText(self.phantomPanel:Find("title/bg/Text"), string.format("%d/%d", #underscore.filter(var_149_2, function(arg_150_0)
		return arg_150_0.unlocked
	end), #var_149_2))
	UIItemList.StaticAlign(self.rtPhantomQuestContainer, self.questTpl, #var_149_2, function(arg_151_0, arg_151_1, arg_151_2)
		arg_151_1 = arg_151_1 + 1

		if arg_151_0 == UIItemList.EventUpdate then
			local var_151_0 = var_149_2[arg_151_1]

			setActive(arg_151_2:Find("title/bg"), var_149_2[arg_151_1].config.type ~= 5)
			setActive(arg_151_2:Find("title/bg_1"), var_151_0.config.type == 5)
			setActive(arg_151_2:Find("title/complete"), var_151_0.unlocked)
			setActive(arg_151_2:Find("title/working"), not var_151_0.unlocked)
			setText(arg_151_2:Find("title/name"), var_151_0.config.name)
			setText(arg_151_2:Find("title/number"), arg_151_1)
			setSlider(arg_151_2:Find("title/slider"), 0, var_151_0.config.target_num, (var_151_0.unlocked or nil) and (var_151_0.config.target_num or var_151_0.progress))
			setActive(arg_151_2:Find("title/slider/complete"), var_151_0.unlocked)
			setActive(arg_151_2:Find("title/tip"), not var_151_0.unlocked and var_151_0.progress >= var_151_0.config.target_num)

			if var_151_0.config.type == 5 then
				setText(arg_151_2:Find("desc/info/Text"), stringInset(var_151_0.config.desc, var_151_0.config.target_num))
			else
				setText(arg_151_2:Find("desc/info/Text"), var_151_0.config.desc)
			end

			local var_151_2 = string.format("%d", math.clamp((var_151_0.unlocked or nil) and (var_151_0.config.target_num or var_151_0.progress), 0, var_151_0.config.target_num) * 100 / var_151_0.config.target_num)

			setText(arg_151_2:Find("desc/info/progress"), var_151_2 .. "%")
			setText(arg_151_2:Find("desc/info/progress/shadow"), var_151_2 .. "%")

			local var_151_3 = ShipBluePrint.getPhantomQuestCostDrop(var_151_0)

			setActive(arg_151_2:Find("desc/item_info/items"), var_151_3)

			if var_151_3 then
				updateDrop(arg_151_2:Find("desc/item_info/items/item_tpl/award"), var_151_3)
			end

			local var_151_4 = var_151_0.unlocked or var_151_0.progress < var_151_0.config.target_num

			setActive(arg_151_2:Find("desc/commit_panel/commit_btn"), not canCommit)
			setActive(arg_151_2:Find("desc/commit_panel/lock_btn"), var_151_4)
			onButton(self, arg_151_2:Find("desc/commit_panel/commit_btn"), function()
				local var_152_0 = {}

				if var_151_3 then
					table.insert(var_152_0, function(arg_153_0)
						pg.MsgboxMgr.GetInstance():ShowMsgBox({
							content = i18n("tech_shadow_commit_tip", var_151_3:getName() .. "x" .. var_151_3.count),
							onYes = arg_153_0
						})
					end)
				end

				seriesAsync(var_152_0, function()
					self:emit(ShipBluePrintMediator.FINISH_PHANTOM_QUEST, var_149_0.id, arg_151_1)
				end)
			end, SFX_CONFIRM)
			onToggle(self, arg_151_2, function(arg_155_0)
				if arg_155_0 then
					Canvas.ForceUpdateCanvases()

					local var_155_0 = self.rtPhantomQuestContainer.parent.transform:InverseTransformPoint(arg_151_2.position).y
					local var_155_1 = 0

					if var_155_0 - arg_151_2.rect.height < self.rtPhantomQuestContainer.parent.transform.rect.yMin then
						var_155_1 = self.rtPhantomQuestContainer.parent.transform.rect.yMin - (var_155_0 - arg_151_2.rect.height)
					end

					if var_155_0 > self.rtPhantomQuestContainer.parent.transform.rect.yMax then
						var_155_1 = self.rtPhantomQuestContainer.parent.transform.rect.yMax - var_155_0
					end

					local var_155_2 = self.rtPhantomQuestContainer.localPosition

					var_155_2.y = self.rtPhantomQuestContainer.localPosition.y + var_155_1
					self.rtPhantomQuestContainer.localPosition = var_155_2
				end
			end, SFX_PANEL)
		end
	end)
end

function ShipBluePrintScene:createTask(arg_156_1)
	local var_156_0 = {
		title = arg_156_1:Find("title/name"),
		desc = arg_156_1:Find("desc/info/Text"),
		timerTF = arg_156_1:Find("title/timer"),
		timerTFTxt = arg_156_1:Find("title/timer/Text"),
		timerOpen = arg_156_1:Find("title/timer/open"),
		timerClose = arg_156_1:Find("title/timer/close"),
		maskAchieved = arg_156_1:Find("title/slider/complete"),
		tip = arg_156_1:Find("title/tip"),
		commitBtn = arg_156_1:Find("desc/commit_panel/commit_btn"),
		itemInfo = arg_156_1:Find("desc/item_info")
	}

	var_156_0.itemContainer = var_156_0.itemInfo:Find("items")
	var_156_0.itemTpl = var_156_0.itemContainer:Find("item_tpl")
	var_156_0.numberTF = arg_156_1:Find("title/number")
	var_156_0.progressTF = arg_156_1:Find("title/slider")
	var_156_0.progessSlider = var_156_0.progressTF:GetComponent(typeof(Slider))
	var_156_0.lockBtn = arg_156_1:Find("desc/commit_panel/lock_btn")
	var_156_0.itemCount = var_156_0.itemTpl:Find("award/icon_bg/count")
	var_156_0.progres = arg_156_1:Find("desc/info/progress")
	var_156_0.progreshadow = arg_156_1:Find("desc/info/progress/shadow")
	var_156_0.check = findTF(arg_156_1, "title/complete")
	var_156_0.lock = findTF(arg_156_1, "title/lock")
	var_156_0.working = findTF(arg_156_1, "title/working")
	var_156_0.pause = findTF(arg_156_1, "title/pause")
	var_156_0.pauseLock = findTF(arg_156_1, "title/pause_lock")
	var_156_0.view = self

	onToggle(self, arg_156_1, function(arg_157_0)
		setActive(var_156_0.desc, arg_157_0)
		setActive(var_156_0.progreshadow, arg_157_0)

		if arg_157_0 then
			Canvas.ForceUpdateCanvases()

			local var_157_0 = self.taskContainer.parent.transform:InverseTransformPoint(arg_156_1.position).y
			local var_157_1 = 0

			if var_157_0 - arg_156_1.rect.height < self.taskContainer.parent.transform.rect.yMin then
				var_157_1 = self.taskContainer.parent.transform.rect.yMin - (var_157_0 - arg_156_1.rect.height)
			end

			if var_157_0 > self.taskContainer.parent.transform.rect.yMax then
				var_157_1 = self.taskContainer.parent.transform.rect.yMax - var_157_0
			end

			local var_157_2 = self.taskContainer.localPosition

			var_157_2.y = self.taskContainer.localPosition.y + var_157_1
			self.taskContainer.localPosition = var_157_2
		end
	end, SFX_PANEL)

	function var_156_0:update(arg_158_1)
		self:clearTimer()

		self.autoCommit = true
		self.isExpTask = false

		removeOnButton(self.commitBtn)
		self:updateItemInfo(arg_158_1)
		self:updateView(arg_158_1)
		self:updateProgress(arg_158_1)
	end

	function var_156_0:updateItemInfo(arg_159_1)
		self.taskVO = arg_159_1

		changeToScrollText(self.title, arg_159_1:getConfig("name"))
		setText(self.desc, arg_159_1:getConfig("desc") .. "\n\n")

		local var_159_0
		local var_159_1 = arg_159_1:getConfig("target_num")
		local var_159_2 = arg_159_1:getConfig("sub_type")

		if var_159_2 == TASK_SUB_TYPE_GIVE_ITEM then
			self.autoCommit = false
			var_159_0 = tonumber(arg_159_1:getConfig("target_id"))
		elseif var_159_2 == TASK_SUB_TYPE_PLAYER_RES then
			self.autoCommit = false
			var_159_0 = id2ItemId(tonumber(arg_159_1:getConfig("target_id")))
		elseif var_159_2 == TASK_SUB_TYPE_BATTLE_EXP then
			self.isExpTask = true
			var_159_0 = 59000
		end

		setActive(self.itemContainer, not self.autoCommit or self.isExpTask)

		if var_159_0 then
			updateDrop(self.itemTpl:Find("award"), {
				type = 2,
				id = var_159_0,
				count = var_159_1
			})
			setText(self.itemCount, var_159_1 > 1000 and math.floor(var_159_1 / 1000) .. "K" or var_159_1)
		end

		setText(self.numberTF, arg_159_1.index)
	end

	function var_156_0:updateView(arg_160_1)
		local var_160_0 = false
		local var_160_1 = false
		local var_160_2 = false

		if arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE and arg_160_1.leftTime then
			local var_160_3 = getProxy(TaskProxy):getTaskVO(arg_160_1.id)

			var_160_0 = var_160_3 and var_160_3:isFinish()
			var_160_2 = arg_160_1.leftTime > 0
			var_160_1 = var_160_3 and var_160_3:isReceive()

			if arg_160_1.leftTime > 0 then
				setText(var_156_0.timerTFTxt, pg.TimeMgr.GetInstance():DescCDTime(arg_160_1.leftTime))
			end
		end

		setActive(self.pause, ShipBluePrint.TASK_STATE_PAUSE == arg_160_1.taskState and not var_160_0 and not var_160_2 or ShipBluePrint.TASK_STATE_PAUSE == arg_160_1.taskState and not var_160_2 and var_160_0 and not self.autoCommit)
		setActive(self.pauseLock, ShipBluePrint.TASK_STATE_PAUSE == arg_160_1.taskState and not var_160_0 and var_160_2)
		setActive(self.lockBtn, arg_160_1.taskState ~= ShipBluePrint.TASK_STATE_ACHIEVED and (arg_160_1.taskState ~= ShipBluePrint.TASK_STATE_START or not not self.autoCommit))
		setActive(self.commitBtn, arg_160_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_START and not self.autoCommit)
		setActive(self.progressTF, arg_160_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_START or arg_160_1.taskState == ShipBluePrint.TASK_STATE_FINISHED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE and not var_160_2)
		setActive(self.lock, arg_160_1.taskState == ShipBluePrint.TASK_STATE_LOCK or arg_160_1.taskState == ShipBluePrint.TASK_STATE_WAIT)
		setActive(self.working, arg_160_1.taskState == ShipBluePrint.TASK_STATE_OPENING or arg_160_1.taskState == ShipBluePrint.TASK_STATE_START or arg_160_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED)
		setActive(self.maskAchieved, arg_160_1.taskState == ShipBluePrint.TASK_STATE_FINISHED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE and var_160_1)

		if arg_160_1.taskState ~= ShipBluePrint.TASK_STATE_WAIT then
			local var_160_4

			if arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE then
				var_160_4 = arg_160_1.leftTime and arg_160_1.leftTime > 0
			end
		end

		setActive(self.timerTF, var_160_4)
		setActive(self.check, self.autoCommit and arg_160_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_FINISHED or arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE and var_160_1)
		setActive(self.tip, arg_160_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED)
		setActive(self.timerOpen, arg_160_1.taskState == ShipBluePrint.TASK_STATE_WAIT)
		setActive(self.timerClose, (arg_160_1.taskState == ShipBluePrint.TASK_STATE_PAUSE or nil) and arg_160_1.leftTime and arg_160_1.leftTime > 0)
	end

	function var_156_0:updateProgress(arg_161_1)
		local var_161_0 = arg_161_1:getProgress() / arg_161_1:getConfig("target_num")

		if arg_161_1.taskState == ShipBluePrint.TASK_STATE_WAIT then
			self:addTimer(arg_161_1, arg_161_1.dueTime)

			var_161_0 = 0
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_OPENING then
			var_161_0 = 0

			self.view:emit(ShipBluePrintMediator.ON_TASK_OPEN, arg_161_1.id)
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_PAUSE then
			if arg_161_1:isReceive() then
				var_161_0 = 1
			end
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_LOCK then
			var_161_0 = 0
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_ACHIEVED then
			onButton(self.view, self.commitBtn, function()
				self.view:emit(ShipBluePrintMediator.ON_FINISH_TASK, arg_161_1.id)
			end, SFX_PANEL)

			var_161_0 = 1
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_FINISHED then
			var_161_0 = 1
		elseif arg_161_1.taskState == ShipBluePrint.TASK_STATE_START and not self.autoCommit then
			onButton(self.view, self.commitBtn, function()
				self.view:emit(ShipBluePrintMediator.ON_FINISH_TASK, arg_161_1.id)
			end, SFX_PANEL)

			var_161_0 = 0
		end

		if var_161_0 > 0 then
			self.itemSliderLT = LeanTween.value(go(self.progressTF), 0, math.min(var_161_0, 1), 0.5 * math.min(var_161_0, 1)):setOnUpdate(System.Action_float(function(arg_164_0)
				self.progessSlider.value = arg_164_0
			end)).uniqueId
		else
			self.progessSlider.value = var_161_0
		end

		local var_161_1 = math.floor(var_161_0 * 100)

		setText(self.progres, math.ceil(math.min(var_161_1, 100)) .. "%")
		setText(self.progreshadow, math.min(var_161_1, 100) .. "%")
	end

	function var_156_0:addTimer(arg_165_1, arg_165_2)
		self:clearTimer()

		self.taskTimer = Timer.New(function()
			local var_166_0 = arg_165_2 - pg.TimeMgr.GetInstance():GetServerTime()

			if var_166_0 > 0 then
				setText(self.timerTFTxt, pg.TimeMgr.GetInstance():DescCDTime(var_166_0))
			else
				self:clearTimer()
				setText(self.timerTFTxt, "00:00:00")
				self.view:emit(ShipBluePrintMediator.ON_TASK_OPEN, arg_165_1.id)
			end
		end, 1, -1)

		self.taskTimer:Start()
		self.taskTimer.func()
	end

	function var_156_0:clearTimer()
		if self.taskTimer then
			self.taskTimer:Stop()

			self.taskTimer = nil
		end
	end

	function var_156_0:clear()
		self:clearTimer()

		if self.itemSliderLT then
			LeanTween.cancel(self.itemSliderLT)

			self.itemSliderLT = nil
		end
	end

	return var_156_0
end

function ShipBluePrintScene:openPreView()
	if self.contextData.shipBluePrintVO then
		setActive(self.preViewer, true)
		pg.UIMgr.GetInstance():BlurPanel(self.preViewer)
		self:playLoadingAni()

		self.viewShipVO = self.contextData.shipBluePrintVO:getShipVO()
		self.breakIds = self:getStages(self.viewShipVO)

		for iter_169_0 = 1, var_0_4 do
			local var_169_0 = self.breakIds[iter_169_0]
			local var_169_2 = self.stages:Find("stage" .. iter_169_0)

			onToggle(self, var_169_2, function(arg_170_0)
				if arg_170_0 then
					if PLATFORM_CODE == PLATFORM_US then
						changeToScrollText(self.breakView, var_0_3[var_169_0].breakout_view)
					else
						setText(self.breakView, var_0_3[var_169_0].breakout_view)
					end

					self:switchStage(var_169_0)
				end
			end, SFX_PANEL)

			if iter_169_0 == 1 then
				triggerToggle(var_169_2, true)
			end
		end

		self.isShowPreview = true

		self:updateMaxLevelAttrs(self.contextData.shipBluePrintVO)
	end
end

ShipBluePrintScene.MAX_LEVEL_ATTRS = {
	AttributeType.Durability,
	AttributeType.Cannon,
	AttributeType.Torpedo,
	AttributeType.AntiAircraft,
	AttributeType.Air,
	AttributeType.Reload,
	AttributeType.ArmorType,
	AttributeType.Dodge
}

function ShipBluePrintScene:updateMaxLevelAttrs(arg_171_1)
	if not arg_171_1:isFetched() then
		return
	end

	local var_171_0 = self.shipVOs[arg_171_1.shipId]
	local var_171_1 = Clone(self.shipVOs[arg_171_1.shipId])

	var_171_1.level = 125

	local var_171_2 = Clone(arg_171_1)

	var_171_2.level = arg_171_1:getMaxLevel()

	local var_171_3 = intProperties(var_171_2:getShipProperties(var_171_1, false))

	for iter_171_0, iter_171_1 in ipairs(ShipBluePrintScene.MAX_LEVEL_ATTRS) do
		local var_171_4 = self.previewAttrContainer:Find(iter_171_1)

		if iter_171_1 == AttributeType.ArmorType then
			setText(var_171_4:Find("bg/value"), var_171_0:getShipArmorName())
		else
			setText(var_171_4:Find("bg/value"), var_171_3[iter_171_1] or 0)
		end

		setText(var_171_4:Find("bg/name"), AttributeType.Type2Name(iter_171_1))
	end
end

function ShipBluePrintScene:closePreview(arg_172_1)
	if self.previewer then
		self.previewer:clear()

		self.previewer = nil
	end

	setActive(self.preViewer, false)
	setActive(self.rawImage, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self.preViewer, self._tf)

	self.isShowPreview = nil
end

function ShipBluePrintScene:playLoadingAni()
	setActive(self.seaLoading, true)
end

function ShipBluePrintScene:stopLoadingAni()
	setActive(self.seaLoading, false)
end

function ShipBluePrintScene:showBarrage()
	self.previewer = WeaponPreviewer.New(self.rawImage)

	self.previewer:configUI(self.healTF)
	self.previewer:setDisplayWeapon(self:getWaponIdsById(self.breakOutId))
	self.previewer:load(40000, self.viewShipVO, self:getAllWeaponIds(), function()
		self:stopLoadingAni()
	end)
end

function ShipBluePrintScene:getWaponIdsById(arg_177_1)
	return var_0_3[arg_177_1].weapon_ids
end

function ShipBluePrintScene:getAllWeaponIds()
	local var_178_0 = {}

	for iter_178_0, iter_178_1 in ipairs(self.breakIds) do
		local var_178_1 = Clone(var_0_3[iter_178_1].weapon_ids)

		setmetatable(var_178_0, {
			__add = function(arg_179_0, arg_179_1)
				for iter_179_0, iter_179_1 in ipairs(arg_179_0) do
					if not table.contains(arg_179_1, iter_179_1) then
						table.insert(arg_179_1, iter_179_1)
					end
				end

				return arg_179_1
			end
		})

		var_178_0 = var_178_0 + var_178_1
	end

	return var_178_0
end

function ShipBluePrintScene:getStages(arg_180_1)
	local var_180_0 = {}
	local var_180_1 = math.floor(arg_180_1.configId / 10)

	for iter_180_0 = 1, 4 do
		local var_180_2 = tonumber(var_180_1 .. iter_180_0)

		assert(var_0_3[var_180_2], "必须存在配置" .. var_180_2)
		table.insert(var_180_0, var_180_2)
	end

	return var_180_0
end

function ShipBluePrintScene:switchStage(arg_181_1)
	if self.breakOutId == arg_181_1 then
		return
	end

	self.breakOutId = arg_181_1

	if self.previewer then
		self.previewer:setDisplayWeapon(self:getWaponIdsById(self.breakOutId))
	end
end

function ShipBluePrintScene:clearTimers()
	for iter_182_0, iter_182_1 in pairs(self.taskTFs or {}) do
		iter_182_1:clear()
	end
end

function ShipBluePrintScene:cloneTplTo(arg_183_1, arg_183_2)
	local var_183_0 = tf(Instantiate(arg_183_1))

	SetActive(var_183_0, true)
	var_183_0:SetParent(tf(arg_183_2), false)

	return var_183_0
end

function ShipBluePrintScene:onBackPressed()
	if isActive(self.msgPanel) then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgPanel, self.top)
		setActive(self.msgPanel, false)
	elseif isActive(self.unlockPanel) then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
	elseif isActive(self.versionPanel) then
		triggerButton(self.versionPanel:Find("bg"))
	elseif self.isShowPreview then
		self:closePreview(true)
	elseif self.svQuickExchange:isShowing() then
		self.svQuickExchange:Hide()
	elseif self.awakenPlay or self:inModAnim() then
		-- block empty
	else
		self:emit(ShipBluePrintScene.ON_BACK_PRESSED)
	end
end

function ShipBluePrintScene:getResource()
	local var_185_0 = {
		"ui/shipblueprintui_atlas",
		"shipdesignicon/empty",
		"shiptype",
		"ui/fateStartWindow"
	}

	for iter_185_0, iter_185_1 in pairs(var_0_1.all) do
		local var_185_1 = tonumber(var_0_1[iter_185_1].id .. "0")
		local var_185_2 = tonumber(var_0_1[iter_185_1].id .. "1")
		local var_185_3

		if pg.ship_skin_template[var_185_1] then
			var_185_3 = pg.ship_skin_template[var_185_1].painting
		end

		if var_185_3 then
			if not table.contains(var_185_0, "shipdesignicon/" .. var_185_3) then
				table.insert(var_185_0, "shipdesignicon/" .. var_185_3)
			end

			if checkABExist("shipdesignicon/" .. var_185_3 .. "_hx") and not table.contains(var_185_0, "shipdesignicon/" .. var_185_3 .. "_hx") then
				table.insert(var_185_0, "shipdesignicon/" .. var_185_3 .. "_hx")
			end

			if not table.contains(var_185_0, "shipYardIcon/" .. var_185_3) then
				table.insert(var_185_0, "shipYardIcon/" .. var_185_3)
			end
		end

		if pg.ship_data_template[var_185_2] then
			if pg.ship_data_template[var_185_2].buff_list_display then
				for iter_185_2, iter_185_3 in ipairs(pg.ship_data_template[var_185_2].buff_list_display) do
					local var_185_4 = getSkillConfig(iter_185_3)

					if var_185_4 then
						if not table.contains(var_185_0, "skillicon/" .. var_185_4.icon) then
							table.insert(var_185_0, "skillicon/" .. var_185_4.icon)
						end
					end
				end
			end
		end
	end

	return table.insertto(var_185_0, ShipBluePrintScene.super.getResource(self))
end

function ShipBluePrintScene:willExit()
	if isActive(self.msgPanel) then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgPanel, self.top)
		setActive(self.msgPanel, false)
	end

	if isActive(self.unlockPanel) then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
	end

	self:UnOverlayPanel(self.blurPanel, self._tf)
	LeanTween.cancel(go(self.fittingAttrPanel))

	if self.lastPaintingName then
		retPaintingPrefab(self.painting, self.lastPaintingName)
	end

	for iter_186_0, iter_186_1 in pairs(self.taskTFs or {}) do
		iter_186_1:clear()
	end

	self:closePreview(true)
	self:clearLeanTween(true)

	if self.previewer then
		self.previewer:clear()

		self.previewer = nil
	end

	if self.cbTimer then
		self.cbTimer:Stop()

		self.cbTimer = nil
	end

	if self.svQuickExchange:isShowing() then
		self.svQuickExchange:Hide()
	end

	self.svQuickExchange:Destroy()
end

function ShipBluePrintScene:paintBreath()
	LeanTween.cancel(go(self.painting))
	LeanTween.moveY(rtf(self.painting), var_0_5, var_0_6):setLoopPingPong():setEase(LeanTweenType.easeInOutCubic):setFrom(0)
end

function ShipBluePrintScene:buildStartAni(arg_188_1, arg_188_2)
	if arg_188_1 == "researchStartWindow" then
		self.progressPanel.localScale = Vector3(0, 1, 1)

		LeanTween.scale(self.progressPanel, Vector3(1, 1, 1), 0.2):setDelay(2)
	end

	local function var_188_0()
		self.awakenAni:SetActive(true)

		self.awakenPlay = true

		local var_189_0 = tf(self.awakenAni)

		pg.UIMgr.GetInstance():BlurPanel(var_189_0)
		var_189_0:SetAsLastSibling()
		var_189_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_190_0)
			if not IsNil(self.awakenAni) then
				pg.UIMgr.GetInstance():UnOverlayPanel(var_189_0, self.blurPanel)
				self.awakenAni:SetActive(false)

				self.awakenPlay = false

				if arg_188_2 then
					arg_188_2()
				end
			end
		end)
	end

	local var_188_1 = self._tf:Find(arg_188_1 .. "(Clone)")

	self.awakenAni = var_188_1 and go(var_188_1)

	if not self.awakenAni then
		PoolMgr.GetInstance():GetUI(arg_188_1, true, function(arg_191_0)
			arg_191_0:SetActive(true)

			self.awakenAni = arg_191_0

			var_188_0()
		end)
	else
		var_188_0()
	end
end

function ShipBluePrintScene:showFittingMsgPanel(arg_192_1)
	pg.UIMgr.GetInstance():BlurPanel(self.msgPanel)
	setActive(self.msgPanel, true)

	local var_192_0 = self.contextData.shipBluePrintVO
	local var_192_1 = self.contextData.shipBluePrintVO:getMaxFateLevel()
	local var_192_2 = self.msgPanel:Find("window/content")
	local var_192_3 = var_192_2:Find("pre_btn")
	local var_192_4 = var_192_2:Find("next_btn")
	local var_192_5 = var_192_2:Find("attrl_panel")
	local var_192_6 = var_192_2:Find("skill_panel")
	local var_192_7 = var_192_2:Find("phase")
	local var_192_8 = {
		"I",
		"II",
		"III",
		"IV",
		"V"
	}

	local function var_192_9()
		setActive(var_192_3, arg_192_1 > 1)
		setActive(var_192_4, arg_192_1 < var_192_1)
		setText(var_192_7, "PHASE." .. var_192_8[arg_192_1])

		local var_193_0 = var_192_0:getFateStrengthenConfig(arg_192_1)

		assert(var_193_0.special == 1 and type(var_193_0.special_effect) == "table", "without fate config")

		local var_193_1
		local var_193_2 = {}

		for iter_193_0, iter_193_1 in ipairs(var_193_0.special_effect) do
			if iter_193_1[1] == ShipBluePrint.STRENGTHEN_TYPE_CHANGE_SKILL then
				var_193_1 = iter_193_1[2][2]
			elseif iter_193_1[1] == ShipBluePrint.STRENGTHEN_TYPE_ATTR then
				table.insert(var_193_2, iter_193_1[2])
			end
		end

		setActive(var_192_5, #var_193_2 > 0)
		setActive(var_192_6, var_193_1)

		if var_193_1 then
			GetImageSpriteFromAtlasAsync("skillicon/" .. getSkillConfig(var_193_1).icon, "", var_192_6:Find("skill_icon"))
			setText(var_192_6:Find("skill_name"), getSkillName(var_193_1))
			setText(var_192_6:Find("skill_lv"), "Lv." .. 1)
			setText(var_192_6:Find("help_panel/skill_intro"), getSkillDescGet(var_193_1))
		end

		if #var_193_2 > 0 then
			for iter_193_2, iter_193_3 in ipairs(var_193_2) do
				local var_193_3 = iter_193_2 < var_192_5.childCount and var_192_5:GetChild(iter_193_2) or cloneTplTo(var_192_5:GetChild(iter_193_2 - 1), var_192_5)

				setText(var_193_3:Find("name"), AttributeType.Type2Name(iter_193_3[1]))
				setText(var_193_3:Find("number"), " + " .. iter_193_3[2])
			end

			for iter_193_4 = #var_193_2 + 1, var_192_5.childCount - 1 do
				setActive(var_192_5:GetChild(iter_193_4), false)
			end
		end
	end

	onButton(self, var_192_3, function()
		arg_192_1 = arg_192_1 - 1

		var_192_9()
	end)
	onButton(self, var_192_4, function()
		arg_192_1 = arg_192_1 + 1

		var_192_9()
	end)
	setText(var_192_5:Find("desc"), i18n("fate_attr_word"))
	var_192_9()
end

function ShipBluePrintScene:showUnlockPanel()
	pg.UIMgr.GetInstance():BlurPanel(self.unlockPanel)
	setActive(self.unlockPanel, true)

	local var_196_0 = self.contextData.shipBluePrintVO.id
	local var_196_1 = self.contextData.shipBluePrintVO:getUnlockItem()
	local var_196_2 = Drop.New({
		type = DROP_TYPE_ITEM,
		id = var_196_1
	})
	local var_196_3 = self.contextData.shipBluePrintVO:getShipVO()
	local var_196_4 = var_196_3:getPainting()
	local var_196_5 = self.unlockPanel:Find("window/content")

	GetImageSpriteFromAtlasAsync("shipYardIcon/" .. var_196_4, var_196_4, var_196_5:Find("Image/mask/icon"), true)
	setText(var_196_5:Find("words/Text"), i18n("techpackage_item_use_1", var_196_3:getName()))
	setText(var_196_5:Find("words/Text_2"), i18n("techpackage_item_use_2", var_196_2:getName()))
	GetImageSpriteFromAtlasAsync(var_196_2:getIcon(), "", self.unlockPanel:Find("window/confirm_btn/Image/Image"))
	setText(self.unlockPanel:Find("window/confirm_btn/Image/Text"), i18n("event_ui_consume"))
	onButton(self, self.unlockPanel:Find("window/confirm_btn"), function()
		pg.UIMgr.GetInstance():UnOverlayPanel(self.unlockPanel, self.top)
		setActive(self.unlockPanel, false)
		self:emit(ShipBluePrintMediator.ON_ITEM_UNLOCK, var_196_0, var_196_1)
	end, SFX_CANCEL)
end

function ShipBluePrintScene:checkStory()
	local var_198_0 = {
		nil,
		"FANGAN3"
	}

	self.storyMgr = self.storyMgr or pg.NewStoryMgr.GetInstance()

	if var_198_0[self.version] and not self.storyMgr:IsPlayed(var_198_0[self.version]) then
		self.storyMgr:Play(var_198_0[self.version])
	end
end

function ShipBluePrintScene:changeEffectVisible(arg_199_1)
	setActive(self.fittingBtn, arg_199_1)
	setActive(self.initPanel, arg_199_1)
end

return ShipBluePrintScene
