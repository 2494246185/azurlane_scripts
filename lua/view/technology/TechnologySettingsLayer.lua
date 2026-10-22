local TechnologySettingsLayer = class("TechnologySettingsLayer", import("..base.BaseUI"))

TechnologySettingsLayer.TEC_PAGE_TENDENCY = 1
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET1 = 2
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET2 = 3
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET3 = 4
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET4 = 5
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET5 = 6
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET6 = 7
TechnologySettingsLayer.TEC_PAGE_CATCHUP_TARGET7 = 8
TechnologySettingsLayer.TEC_PAGE_CATCHUP_ACT = 99
TechnologySettingsLayer.PANEL_INTO_TIME = 0.15
TechnologySettingsLayer.SELECT_TENDENCY_FADE_TIME = 0.3
TechnologySettingsLayer.SELECT_CHAR_LIGHT_FADE_TIME = 0.3
TechnologySettingsLayer.CATCHUP_CLASSES = {
	import("view.technology.TargetCatchup.TargetCatchupPanel1"),
	import("view.technology.TargetCatchup.TargetCatchupPanel2"),
	import("view.technology.TargetCatchup.TargetCatchupPanel3"),
	import("view.technology.TargetCatchup.TargetCatchupPanel4"),
	import("view.technology.TargetCatchup.TargetCatchupPanel5"),
	import("view.technology.TargetCatchup.TargetCatchupPanel6"),
	import("view.technology.TargetCatchup.TargetCatchupPanel7")
}
TechnologySettingsLayer.CATCHUP_VERSION = 7

function TechnologySettingsLayer:getUIName()
	return "TechnologySettingsUI"
end

function TechnologySettingsLayer:getResource()
	local var_2_0 = {}
	local var_2_1 = {}

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not var_2_1[arg_3_0] then
			var_2_1[arg_3_0] = true

			table.insert(var_2_0, arg_3_0)
		end
	end

	var_2_2("ui/TechnologySettingsUI")
	var_2_2("ui/technologysettingsui_atlas")

	for iter_2_0 = 1, TechnologySettingsLayer.CATCHUP_VERSION do
		var_2_2("ui/TargetCatchupPanel" .. iter_2_0)
	end

	local var_2_3 = getProxy(TechnologyProxy)

	local function var_2_4(arg_4_0)
		if arg_4_0 then
			var_2_2("TecCatchup/QChar" .. arg_4_0)
			var_2_2("TecCatchup/selbg" .. arg_4_0)
		end
	end

	for iter_2_1 = 1, TechnologySettingsLayer.CATCHUP_VERSION do
		if pg.technology_catchup_template[iter_2_1] then
			for iter_2_2, iter_2_3 in ipairs(pg.technology_catchup_template[iter_2_1].char_choice or {}) do
				var_2_4(iter_2_3)
			end
		end
	end

	local var_2_6 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BLUEPRINT_CATCHUP)

	if var_2_6 and not var_2_6:isEnd() then
		local var_2_7 = var_2_6:getConfig("page_info")

		if var_2_7 and noEmptyStr(var_2_7.ui_name) then
			var_2_2("ui/" .. var_2_7.ui_name)
		end

		local var_2_8 = pg.activity_event_blueprint_catchup[var_2_6:getConfig("config_id")]

		if var_2_8 then
			var_2_4(var_2_8.char_choice)
		end
	end

	return var_2_0
end

function TechnologySettingsLayer:init()
	self:initData()
	self:findUI()
	self:addListener()
	self:initTendencyPage()
	self:initActCatchupPage()
end

function TechnologySettingsLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self:resetLeftBtnUnsel()
	self:updateTendencyBtn(self.curTendency)
	self:updateTargetCatchupBtns()
	self:updateActCatchupBtn()
	triggerButton(self.leftBtnList[1])
	triggerToggle(self.showFinish, self.showFinishFlag == 1 and true or false)
	getProxy(CommanderManualProxy):TaskProgressAdd(2024, 1)
end

function TechnologySettingsLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.actCatchupTimer then
		self.actCatchupTimer:Stop()

		self.actCatchupTimer = nil
	end

	for iter_7_0, iter_7_1 in pairs(self.catchupPanels) do
		iter_7_1:willExit()
	end

	self.loader:Clear()
end

function TechnologySettingsLayer:initData()
	self.technologyProxy = getProxy(TechnologyProxy)
	self.bayProxy = getProxy(BayProxy)
	self.bagProxy = getProxy(BagProxy)
	self.curPageID = 0
	self.curTendency = self.technologyProxy:getTendency(2)
	self.curSelectedIndex = 0
	self.reSelectTag = false
	self.actCatchup = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BLUEPRINT_CATCHUP)
	self.isShowActCatchup = self.actCatchup and not self.actCatchup:isEnd()
	self.loader = AutoLoader.New()
end

function TechnologySettingsLayer:findUI()
	self.bg = self._tf:Find("BG")

	setText(self.bg:Find("BackTips/ClickText"), i18n("click_back_tip"))

	local var_9_0 = self._tf:Find("Panel")
	local var_9_1 = var_9_0:Find("LeftScrollViewMask/LeftScrollView/LeftBtnList")

	self.leftBtnList = {}
	self.tendencyBtn = var_9_1:Find("TendencyBtn")
	self.leftBtnList[TechnologySettingsLayer.TEC_PAGE_TENDENCY] = self.tendencyBtn
	self.catchupBtns = {}

	for iter_9_0 = 1, TechnologySettingsLayer.CATCHUP_VERSION do
		self.catchupBtns[iter_9_0] = cloneTplTo(var_9_1:Find("TargetCatchupBtn_tpl"), var_9_1)
		self.leftBtnList[iter_9_0 + 1] = self.catchupBtns[iter_9_0]
	end

	self.actCatchupBtn = var_9_1:Find("ActCatchupBtn")

	self.actCatchupBtn:SetAsLastSibling()

	self.leftBtnList[TechnologySettingsLayer.TEC_PAGE_CATCHUP_ACT] = self.actCatchupBtn

	local var_9_2 = var_9_0:Find("RightPanelContainer")

	self.rightPageTFList = {}
	self.tendencyPanel = var_9_2:Find("TecTendencyPanel")
	self.rightPageTFList[TechnologySettingsLayer.TEC_PAGE_TENDENCY] = self.tendencyPanel
	self.catchupPanels = {}
	self.actCatchupPanel = var_9_2:Find("ActCatchupPanel")
	self.rightPageTFList[TechnologySettingsLayer.TEC_PAGE_CATCHUP_ACT] = self.actCatchupPanel
	self.showFinish = self._tf:Find("ShowFinishToggle")

	setText(self.showFinish:Find("Label"), i18n("tec_target_catchup_show_the_finished_version"))

	self.showFinishFlag = PlayerPrefs.GetInt("isShowFinishCatchupVersion") or 0

	if TechnologySettingsLayer.CATCHUP_VERSION < 1 then
		setActive(self.showFinish, false)
	end
end

function TechnologySettingsLayer:addListener()
	onButton(self, self.bg, function()
		self:closeView()
	end, SFX_PANEL)

	for iter_10_0, iter_10_1 in pairs(self.leftBtnList) do
		onButton(self, iter_10_1, function()
			if self.onPageSwitchAnim then
				return
			end

			if self.curPageID ~= iter_10_0 then
				self:resetLeftBtnUnsel()
				setActive(iter_10_1:Find("Selected"), true)
				self:switchRightPage(iter_10_0)
			end
		end, SFX_PANEL)
	end

	onToggle(self, self.showFinish, function(arg_13_0)
		if TechnologySettingsLayer.CATCHUP_VERSION < 1 then
			return
		end

		for iter_13_0, iter_13_1 in pairs(self.catchupBtns) do
			if iter_13_0 <= TechnologySettingsLayer.CATCHUP_VERSION then
				if self.technologyProxy:getCatchupState(iter_13_0) == TechnologyCatchup.STATE_FINISHED_ALL and not arg_13_0 then
					setActive(iter_13_1, false)
				else
					setActive(iter_13_1, true)
				end
			end
		end

		self.showFinishFlag = arg_13_0 and 1 or 0

		PlayerPrefs.SetInt("isShowFinishCatchupVersion", self.showFinishFlag)
		triggerButton(self.leftBtnList[1])
	end, SFX_PANEL)
end

function TechnologySettingsLayer:resetLeftBtnUnsel()
	for iter_14_0, iter_14_1 in pairs(self.leftBtnList) do
		setActive(iter_14_1:Find("Selected"), false)
	end
end

function TechnologySettingsLayer:switchRightPage(arg_15_1)
	seriesAsync({
		function(arg_16_0)
			if not self.rightPageTFList[arg_15_1] then
				local var_16_0 = arg_15_1 - 1
				local var_16_1 = self._tf:Find("Panel/RightPanelContainer")

				self.catchupPanels[arg_15_1 - 1] = TechnologySettingsLayer.CATCHUP_CLASSES[arg_15_1 - 1].New(nil, function()
					self.rightPageTFList[arg_15_1] = self.catchupPanels[var_16_0]._go

					setActive(self.rightPageTFList[arg_15_1], false)
					SetParent(self.rightPageTFList[arg_15_1], var_16_1, false)
					arg_16_0()
				end)
			else
				arg_16_0()
			end
		end,
		function(arg_18_0)
			local var_18_0 = self.rightPageTFList[self.curPageID]

			setActive(self.rightPageTFList[arg_15_1], true)

			self.onPageSwitchAnim = true

			self:managedTween(LeanTween.alphaCanvas, function()
				self.onPageSwitchAnim = false
			end, GetOrAddComponent(self.rightPageTFList[arg_15_1], typeof(CanvasGroup)), 1, TechnologySettingsLayer.PANEL_INTO_TIME):setFrom(0)

			if self.rightPageTFList[self.curPageID] then
				self:managedTween(LeanTween.alphaCanvas, function()
					setActive(var_18_0, false)
				end, GetOrAddComponent(self.rightPageTFList[self.curPageID], typeof(CanvasGroup)), 0, TechnologySettingsLayer.PANEL_INTO_TIME):setFrom(1)
			end

			self.curPageID = arg_15_1

			if arg_15_1 == TechnologySettingsLayer.TEC_PAGE_TENDENCY then
				self:updateTendencyPage(self.curTendency)
			elseif arg_15_1 == TechnologySettingsLayer.TEC_PAGE_CATCHUP_ACT then
				self:updateActCatchupPage()
			else
				self:updateTargetCatchupPage(arg_15_1 - 1)
			end
		end
	})
end

function TechnologySettingsLayer:initTendencyPage()
	local var_21_0 = getProxy(TechnologyProxy)
	local var_21_1 = self.tendencyPanel:Find("TecItemList")
	local var_21_2 = UIItemList.New(var_21_1, var_21_1:Find("tpl"))

	var_21_2.make(var_21_0, function(arg_22_0, arg_22_1, arg_22_2)
		if arg_22_0 == UIItemList.EventUpdate then
			local var_22_0 = arg_22_1 > 0 and i18n("tec_tendency_x", i18n("number_" .. arg_22_1)) or i18n("tec_tendency_0")

			setText(arg_22_2:Find("UnSelect/Text"), var_22_0)
			setText(arg_22_2:Find("Selected/Text"), var_22_0)
			onButton(self, arg_22_2, function()
				if self.curTendency ~= arg_22_1 then
					self:emit(TechnologySettingsMediator.CHANGE_TENDENCY, arg_22_1)
				end
			end, SFX_PANEL)
		end
	end)
	var_21_2:align(var_21_0:getConfigMaxVersion() + 1)
end

function TechnologySettingsLayer:updateTendencyPage(arg_24_1)
	local var_24_0 = self.tendencyPanel:Find("TecItemList")

	setActive(var_24_0:GetChild(self.curTendency):Find("Selected"), false)

	local var_24_1 = var_24_0:GetChild(arg_24_1):Find("Selected")

	setActive(var_24_1, true)
	setImageAlpha(var_24_1:Find("Image"), 0)
	self:managedTween(LeanTween.alpha, nil, var_24_1:Find("Image"), 1, TechnologySettingsLayer.SELECT_TENDENCY_FADE_TIME):setFrom(0)

	local var_24_2 = self.tendencyPanel:Find("TendencyNum")

	setImageAlpha(var_24_2:Find("Image"), 0)

	if arg_24_1 > 0 then
		GetImageSpriteFromAtlasAsync("ui/technologysettingsui_atlas", "right_tendency_num_" .. arg_24_1, var_24_2:Find("Image"), true)
		self:managedTween(LeanTween.alpha, nil, var_24_2:Find("Image"), 1, TechnologySettingsLayer.SELECT_TENDENCY_FADE_TIME):setFrom(0)
	end

	self.curTendency = arg_24_1
end

function TechnologySettingsLayer:updateTendencyBtn(arg_25_1)
	local var_25_0 = arg_25_1 > 0 and i18n("tec_tendency_cur_x", i18n("number_" .. arg_25_1)) or i18n("tec_tendency_cur_0")

	setText(self.tendencyBtn:Find("UnSelect/Text"), var_25_0)
	setText(self.tendencyBtn:Find("Selected/Text"), var_25_0)
end

function TechnologySettingsLayer:updateTargetCatchupPage(arg_26_1)
	self.catchupPanels[arg_26_1]:updateTargetCatchupPage()
end

function TechnologySettingsLayer:updateTargetCatchupBtns()
	for iter_27_0, iter_27_1 in pairs(self.catchupBtns) do
		if iter_27_0 <= TechnologySettingsLayer.CATCHUP_VERSION then
			local var_27_0 = self.technologyProxy:getCatchupState(iter_27_0)
			local var_27_1 = var_27_0 == TechnologyCatchup.STATE_CATCHUPING
			local var_27_2 = iter_27_1:Find("UnSelect/Text")
			local var_27_3 = iter_27_1:Find("Selected/Text")
			local var_27_4 = iter_27_1:Find("UnSelect/CharImg")
			local var_27_5 = iter_27_1:Find("Selected/CharImg")
			local var_27_6 = var_27_4:Find("ProgressText")
			local var_27_7 = var_27_5:Find("ProgressText")

			setActive(var_27_4, var_27_0 == TechnologyCatchup.STATE_CATCHUPING)
			setActive(var_27_5, var_27_1)

			if var_27_1 then
				local var_27_8 = iter_27_0 > 0 and i18n("tec_target_catchup_selected_x", i18n("number_" .. iter_27_0)) or i18n("tec_target_catchup_selected_0")

				setText(var_27_2, var_27_8)
				setText(var_27_3, var_27_8)

				local var_27_9 = self.technologyProxy:getCurCatchupTecInfo()
				local var_27_10 = var_27_9.groupID
				local var_27_11 = var_27_9.printNum
				local var_27_12

				if self.technologyProxy:getCatchupData(var_27_9.tecID):isUr(var_27_9.groupID) then
					var_27_12 = pg.technology_catchup_template[var_27_9.tecID].obtain_max_per_ur or pg.technology_catchup_template[var_27_9.tecID].obtain_max
				end

				setImageSprite(var_27_4, LoadSprite("TecCatchup/QChar" .. var_27_10, tostring(var_27_10)))
				setImageSprite(var_27_5, LoadSprite("TecCatchup/QChar" .. var_27_10, tostring(var_27_10)))
				setText(var_27_6, var_27_11 .. "/" .. var_27_12)
				setText(var_27_7, var_27_11 .. "/" .. var_27_12)
			elseif var_27_0 == TechnologyCatchup.STATE_UNSELECT then
				local var_27_13 = iter_27_0 > 0 and i18n("tec_target_catchup_none_x", i18n("number_" .. iter_27_0)) or i18n("tec_target_catchup_none_0")

				setText(var_27_2, var_27_13)
				setText(var_27_3, var_27_13)
			elseif var_27_0 == TechnologyCatchup.STATE_FINISHED_ALL then
				local var_27_14 = iter_27_0 > 0 and i18n("tec_target_catchup_finish_x", i18n("number_" .. iter_27_0)) or i18n("tec_target_catchup_finish_0")

				setText(var_27_2, var_27_14)
				setText(var_27_3, var_27_14)
			end
		end
	end
end

function TechnologySettingsLayer:initActCatchupPage()
	if self.isShowActCatchup then
		self.loader:GetPrefab("ui/" .. self.actCatchup:getConfig("page_info").ui_name, "", function(arg_29_0)
			setParent(arg_29_0, self.actCatchupPanel)
			setLocalScale(arg_29_0, {
				x = 0.925,
				y = 0.923
			})
			setAnchoredPosition(arg_29_0, Vector2.zero)

			self.actCatchupTF = tf(arg_29_0):Find("AD")
			self.actCatchupItemTF = self.actCatchupTF:Find("Award")
			self.actCatchupSliderTF = self.actCatchupTF:Find("Slider")
			self.actCatchupProgressText = self.actCatchupTF:Find("Progress")

			local var_29_0 = self.actCatchupTF:Find("GoBtn")

			if var_29_0 then
				setActive(var_29_0, false)
			end

			local var_29_1 = self.actCatchupTF:Find("FinishBtn")

			if var_29_1 then
				setActive(var_29_1, false)
			end

			local var_29_2 = self.actCatchup.data1
			local var_29_3 = pg.activity_event_blueprint_catchup[self.actCatchup:getConfig("config_id")].obtain_max
			local var_29_4 = {
				type = DROP_TYPE_ITEM,
				id = self.actCatchup:getConfig("config_client").itemid
			}

			updateDrop(self.actCatchupItemTF, var_29_4)
			onButton(self, self.actCatchupItemTF, function()
				self:emit(BaseUI.ON_DROP, var_29_4)
			end, SFX_PANEL)
			setSlider(self.actCatchupSliderTF, 0, var_29_3, var_29_2)
			setText(self.actCatchupProgressText, var_29_2 .. "/" .. var_29_3)
			setActive(arg_29_0, true)
		end)
	end
end

function TechnologySettingsLayer:updateActCatchupPage()
	return
end

function TechnologySettingsLayer:updateActCatchupBtn()
	setText(self.actCatchupBtn:Find("UnSelect/Text"), i18n("tec_act_catchup_btn_word"))
	setText(self.actCatchupBtn:Find("Selected/Text"), i18n("tec_act_catchup_btn_word"))

	local var_32_0 = self.actCatchupBtn:Find("UnSelect/CharImg")
	local var_32_1 = self.actCatchupBtn:Find("Selected/CharImg")
	local var_32_2 = false
	local var_32_3 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BLUEPRINT_CATCHUP)

	if var_32_3 and not var_32_3:isEnd() then
		local var_32_4 = var_32_3:getConfig("config_id")

		setImageSprite(var_32_0, LoadSprite("TecCatchup/QChar" .. pg.activity_event_blueprint_catchup[var_32_4].char_choice, tostring(pg.activity_event_blueprint_catchup[var_32_4].char_choice)))
		setImageSprite(var_32_1, LoadSprite("TecCatchup/QChar" .. pg.activity_event_blueprint_catchup[var_32_4].char_choice, tostring(pg.activity_event_blueprint_catchup[var_32_4].char_choice)))
		setText(var_32_0:Find("ProgressText"), var_32_3.data1 .. "/" .. pg.activity_event_blueprint_catchup[var_32_4].obtain_max)
		setText(var_32_1:Find("ProgressText"), var_32_3.data1 .. "/" .. pg.activity_event_blueprint_catchup[var_32_4].obtain_max)

		local var_32_5 = var_32_3.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

		if self.actCatchupTimer then
			self.actCatchupTimer:Stop()

			self.actCatchupTimer = nil
		end

		local var_32_6 = self.actCatchupBtn:Find("TimeLeft/Day")
		local var_32_7 = self.actCatchupBtn:Find("TimeLeft/Hour")
		local var_32_8 = self.actCatchupBtn:Find("TimeLeft/Min")
		local var_32_9 = self.actCatchupBtn:Find("TimeLeft/NumText")

		self.actCatchupTimer = Timer.New(function()
			local var_33_0, var_33_1, var_33_2, var_33_3 = pg.TimeMgr.GetInstance():parseTimeFrom(var_32_5)

			var_32_5 = var_32_5 - 1

			if var_33_0 >= 1 then
				setActive(var_32_6, true)
				setActive(var_32_7, false)
				setActive(var_32_8, false)
				setText(var_32_9, var_33_0)
			elseif var_33_0 <= 0 and var_33_1 > 0 then
				setActive(var_32_6, false)
				setActive(var_32_7, true)
				setActive(var_32_8, false)
				setText(var_32_9, var_33_1)
			elseif var_33_0 <= 0 and var_33_1 <= 0 and (var_33_2 > 0 or var_33_3 > 0) then
				setActive(var_32_6, false)
				setActive(var_32_7, false)
				setActive(var_32_8, true)
				setText(var_32_9, math.max(var_33_2, 1))
			elseif var_33_0 <= 0 and var_33_1 <= 0 and var_33_2 <= 0 and var_33_3 <= 0 and self.actCatchupTimer then
				self.actCatchupTimer:Stop()

				self.actCatchupTimer = nil

				self:switchRightPage(TechnologySettingsLayer.TEC_PAGE_TENDENCY)
				setActive(self.actCatchupBtn, false)
			end
		end, 1, -1, 1)

		self.actCatchupTimer:Start()
		self.actCatchupTimer.func()

		var_32_2 = true
	end

	setActive(self.actCatchupBtn, var_32_2)
end

return TechnologySettingsLayer
