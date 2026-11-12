local TechnologyScene = class("TechnologyScene", import("..base.BaseUI"))

TechnologyScene.PageBase = 1
TechnologyScene.PageQueue = 2
TechnologyScene.rarityColor = {
	["1"] = {
		"#4B7BC6FF",
		{
			0.06274509803921569,
			0.29411764705882354,
			0.8745098039215686,
			0.6705882352941176
		}
	},
	["2"] = {
		"#776AB0FF",
		{
			0.29411764705882354,
			0.23529411764705882,
			0.5764705882352941,
			0.6705882352941176
		}
	},
	["3"] = {
		"#B76642FF",
		{
			0.7490196078431373,
			0.28627450980392155,
			0.06274509803921569,
			0.6705882352941176
		}
	},
	["4"] = {
		"#368B78FF",
		{
			0.12941176470588237,
			0.4980392156862745,
			0.5019607843137255,
			0.6705882352941176
		}
	}
}

function TechnologyScene:getUIName()
	return "TechnologyUI"
end

function TechnologyScene:getResource()
	return ResPathSupport.MergeLuaArr({
		"ui/technologyui",
		"technologycard",
		"ui/TechnologyUI_atlas",
		"ui/iconcolorful",
		"ui/technologysettingsui_atlas",
		"ui/TechnologySettingsUI"
	}, (function()
		local var_3_0 = {}

		for iter_3_0, iter_3_1 in ipairs(pg.activity_event_blueprint_catchup.all) do
			table.insert(var_3_0, "TecCatchup/QChar" .. pg.activity_event_blueprint_catchup[iter_3_1].char_choice)
		end

		return var_3_0
	end)(), (function()
		local var_4_0 = getProxy(TechnologyProxy)
		local var_4_1 = {}

		local function var_4_2(arg_5_0)
			for iter_5_0, iter_5_1 in ipairs(arg_5_0:getConfig("drop_client")) do
				if iter_5_1 ~= nil then
					table.insert(var_4_1, (Drop.Create(iter_5_1):getIcon()))
				end
			end

			for iter_5_2, iter_5_3 in ipairs(arg_5_0:getConfig("consume")) do
				if iter_5_3 ~= nil then
					table.insert(var_4_1, (Drop.Create(iter_5_3):getIcon()))
				end
			end
		end

		for iter_4_0, iter_4_1 in ipairs((var_4_0:getTechnologys())) do
			local var_4_3 = "technologyshipicon/" .. iter_4_1:getConfig("bg_icon")

			var_4_2(iter_4_1)
			table.insert(var_4_1, var_4_3)
		end

		for iter_4_2, iter_4_3 in ipairs((var_4_0:getPlanningTechnologys())) do
			local var_4_4 = "technologyshipicon/" .. iter_4_3:getConfig("bg_icon")

			var_4_2(iter_4_3)
			table.insert(var_4_1, var_4_4)
		end

		return var_4_1
	end)(), technologySetting)
end

function TechnologyScene:onBackPressed()
	if self.contextData.selectedIndex then
		self:cancelSelected()

		return
	end

	if self.contextData.page == TechnologyScene.PageQueue then
		self:setPage(TechnologyScene.PageBase)

		return
	end

	TechnologyScene.super.onBackPressed(self)
end

function TechnologyScene:ResUISettings()
	return true
end

function TechnologyScene:setTechnologys(arg_8_1, arg_8_2)
	self.technologyVOs = arg_8_1
	self.technologyQueue = arg_8_2
end

function TechnologyScene:setRefreshFlag(arg_9_1)
	self.flag = arg_9_1
end

function TechnologyScene:setPlayer(arg_10_1)
	self.player = arg_10_1
end

function TechnologyScene:init()
	self.backBtn = self._tf:Find("blur_panel/adapt/top/back")
	self.basePage = self._tf:Find("main/base_page")
	self.srcollView = self.basePage:Find("srcoll_rect/content")
	self.srcollViewCG = self.srcollView:GetComponent(typeof(CanvasGroup))
	self.helpBtn = self.basePage:Find("adapt/help_btn")
	self.refreshBtn = self.basePage:Find("adapt/refresh_btn")

	setText(self.refreshBtn:Find("Text"), i18n("technology_daily_refresh"))

	self.settingsBtn = self.basePage:Find("adapt/settings_btn")
	self.selectetPanel = self.basePage:Find("selecte_panel")

	setActive(self.selectetPanel, false)
	setText(self.selectetPanel:Find("consume_panel/bg/label/Text"), i18n("technology_consume"))
	setText(self.selectetPanel:Find("consume_panel/bg/task_panel/label/Text"), i18n("technology_request"))

	self.arrLeftBtn = self.selectetPanel:Find("left_arr_btn")
	self.arrRightBtn = self.selectetPanel:Find("right_arr_btn")
	self.technologyTpl = self.selectetPanel:Find("technology_card")
	self.descTxt = self.selectetPanel:Find("desc/bg/Text"):GetComponent(typeof(Text))
	self.timerTxt = self.selectetPanel:Find("timer/bg/Text"):GetComponent(typeof(Text))
	self.itemContainer = self.selectetPanel:Find("consume_panel/bg/container")
	self.itemTpl = self.itemContainer:Find("item_tpl")
	self.emptyTF = self.selectetPanel:Find("consume_panel/bg/empty")
	self.taskPanel = self.selectetPanel:Find("consume_panel/bg/task_panel")
	self.taskSlider = self.taskPanel:Find("slider"):GetComponent(typeof(Slider))
	self.taskDesc = self.taskPanel:Find("slider/Text"):GetComponent(typeof(Text))
	self.descBG = self.selectetPanel:Find("desc/bg"):GetComponent(typeof(Image))
	self.queuePage = self._tf:Find("main/queue_page")
	self.queueView = self.queuePage:Find("queue_rect/content")

	local var_11_0 = self._tf:Find("blur_panel/adapt/right")

	self.btnAwardQueue = var_11_0:Find("btn_award")

	setText(self.btnAwardQueue:Find("Text"), i18n("technology_queue_getaward"))

	self.btnAwardQueueDisable = var_11_0:Find("btn_award_disable")

	setText(self.btnAwardQueueDisable:Find("Text"), i18n("technology_queue_getaward"))

	self.btnQueue = self._tf:Find("blur_panel/adapt/left/btn_queue")
	self.cardtimer = {}
	self.queueTimer = {}
	self.queueCardTimer = {}
end

function TechnologyScene:updateSettingsBtn()
	local var_12_0 = self.settingsBtn:Find("RedPoint")

	setText(self.settingsBtn:Find("TipText"), i18n("tec_settings_btn_word"))

	local var_12_1 = self.settingsBtn:Find("TargetCatchup")
	local var_12_2 = var_12_1:Find("Selected")
	local var_12_3 = self.settingsBtn:Find("ActCatchup")

	self:updateSettingBtnVersion()

	local var_12_4 = false
	local var_12_5 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BLUEPRINT_CATCHUP)

	if var_12_5 and not var_12_5:isEnd() then
		local var_12_6 = var_12_5:getConfig("config_id")

		if var_12_5.data1 < pg.activity_event_blueprint_catchup[var_12_6].obtain_max then
			setImageSprite(var_12_3:Find("Selected/CharImg"), LoadSprite("TecCatchup/QChar" .. pg.activity_event_blueprint_catchup[var_12_6].char_choice, tostring(pg.activity_event_blueprint_catchup[var_12_6].char_choice)))
			setText(var_12_3:Find("Selected/ProgressText"), var_12_5.data1 .. "/" .. pg.activity_event_blueprint_catchup[var_12_6].obtain_max)

			local var_12_7 = var_12_5.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

			if self.actCatchupTimer then
				self.actCatchupTimer:Stop()

				self.actCatchupTimer = nil
			end

			local var_12_8 = var_12_3:Find("TimeLeft/Day")
			local var_12_9 = var_12_3:Find("TimeLeft/Hour")
			local var_12_10 = var_12_3:Find("TimeLeft/Min")
			local var_12_11 = var_12_3:Find("TimeLeft/NumText")

			self.actCatchupTimer = Timer.New(function()
				local var_13_0, var_13_1, var_13_2, var_13_3 = pg.TimeMgr.GetInstance():parseTimeFrom(var_12_7)

				var_12_7 = var_12_7 - 1

				if var_13_0 >= 1 then
					setActive(var_12_8, true)
					setActive(var_12_9, false)
					setActive(var_12_10, false)
					setText(var_12_11, var_13_0)
				elseif var_13_0 <= 0 and var_13_1 > 0 then
					setActive(var_12_8, false)
					setActive(var_12_9, true)
					setActive(var_12_10, false)
					setText(var_12_11, var_13_1)
				elseif var_13_0 <= 0 and var_13_1 <= 0 and (var_13_2 > 0 or var_13_3 > 0) then
					setActive(var_12_8, false)
					setActive(var_12_9, false)
					setActive(var_12_10, true)
					setText(var_12_11, math.max(var_13_2, 1))
				elseif var_13_0 <= 0 and var_13_1 <= 0 and var_13_2 <= 0 and var_13_3 <= 0 and self.actCatchupTimer then
					self.actCatchupTimer:Stop()

					self.actCatchupTimer = nil

					setActive(var_12_3, false)
				end
			end, 1, -1, 1)

			self.actCatchupTimer:Start()
			self.actCatchupTimer.func()

			var_12_4 = true
		end
	end

	setActive(var_12_3, var_12_4)
	setActive(var_12_1, true)

	local var_12_12 = getProxy(TechnologyProxy)

	if var_12_12:isOpenTargetCatchup() then
		if not var_12_12:isOnCatchup() then
			setActive(var_12_2, false)
			setActive(var_12_0, true)
		else
			local var_12_13 = var_12_12:getCurCatchupTecInfo()
			local var_12_14 = var_12_13.groupID
			local var_12_15 = var_12_13.printNum
			local var_12_16

			if var_12_12:getCatchupData(var_12_13.tecID):isUr(var_12_13.groupID) then
				var_12_16 = pg.technology_catchup_template[var_12_13.tecID].obtain_max_per_ur or pg.technology_catchup_template[var_12_13.tecID].obtain_max

				if var_12_16 <= var_12_15 then
					setActive(var_12_2, false)
					setActive(var_12_0, false)

					goto label_12_0
				end
			end

			setActive(var_12_2, true)
			setActive(var_12_0, false)
			setImageSprite(var_12_2:Find("CharImg"), LoadSprite("TecCatchup/QChar" .. var_12_14, tostring(var_12_14)))
			setText(var_12_2:Find("ProgressText"), var_12_15 .. "/" .. var_12_16)
		end
	else
		setActive(var_12_2, false)
		setActive(var_12_0, false)
	end

	::label_12_0::
end

function TechnologyScene:updateSettingBtnVersion()
	local var_14_0 = getProxy(TechnologyProxy):getTendency(2)
	local var_14_1 = self.settingsBtn:Find("tag")

	setActive(var_14_1, var_14_0 > 0)

	if var_14_0 > 0 then
		GetImageSpriteFromAtlasAsync("technologycard", "version_" .. var_14_0, var_14_1:Find("Image"), true)
	end
end

function TechnologyScene:setPage(arg_15_1)
	self.contextData.page = arg_15_1

	setActive(self.basePage, arg_15_1 == TechnologyScene.PageBase)
	setActive(self.queuePage, arg_15_1 == TechnologyScene.PageQueue)
	setActive(self._tf:Find("blur_panel/adapt/top/title"), arg_15_1 == TechnologyScene.PageBase)
	setActive(self._tf:Find("blur_panel/adapt/left"), arg_15_1 == TechnologyScene.PageBase)
	setActive(self._tf:Find("blur_panel/adapt/top/title_queue"), arg_15_1 == TechnologyScene.PageQueue)
	setActive(self._tf:Find("blur_panel/adapt/right"), arg_15_1 == TechnologyScene.PageQueue)

	if arg_15_1 == TechnologyScene.PageBase then
		for iter_15_0, iter_15_1 in ipairs(self.technologyVOs) do
			if iter_15_1:isActivate() then
				if self.enhancelTimer then
					self.enhancelTimer:Stop()
				end

				self.enhancelTimer = Timer.New(function()
					self.srcollView:GetComponent("EnhancelScrollView"):SetHorizontalTargetItemIndex(self.technologyCards[iter_15_0]:GetComponent("EnhanceItem").scrollViewItemIndex)

					self.enhancelTimer = nil
				end, 0.35, 1)

				self.enhancelTimer:Start()

				break
			end
		end
	end
end

function TechnologyScene:didEnter()
	self:initTechnologys()
	self:initQueue()
	self:setPage(self.contextData.page or TechnologyScene.PageBase)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.technology_help_text.tip
		})
	end, SFX_PANEL)
	onButton(self, self.refreshBtn, function()
		if tobool(getProxy(TechnologyProxy):getActivateTechnology()) then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("technology_canot_refresh")
			})

			return
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("technology_refresh_tip"),
			onYes = function()
				self:emit(TechnologyMediator.ON_REFRESH)
			end
		})
	end, SFX_PANEL)

	local var_17_0 = getProxy(TechnologyProxy):getConfigMaxVersion()

	onButton(self, self.settingsBtn, function()
		self:emit(TechnologyMediator.ON_CLICK_SETTINGS_BTN)
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		self:onBackPressed()
	end, SOUND_BACK)
	onButton(self, self.selectetPanel, function()
		self:cancelSelected()
	end, SFX_PANEL)
	self:updateRefreshBtn(self.flag)
	self:updateSettingsBtn()
end

function TechnologyScene:initTechnologys()
	self.technologyCards = {}
	self.lastButtonListener = self.lastButtonListener or {}

	if not self.itemList then
		self.itemList = UIItemList.New(self.srcollView, self.srcollView:GetChild(0))

		self.itemList:make(function(arg_25_0, arg_25_1, arg_25_2)
			arg_25_1 = arg_25_1 + 1

			if arg_25_0 == UIItemList.EventUpdate then
				arg_25_2.name = arg_25_1
				self.technologyCards[arg_25_1] = arg_25_2

				self:updateTechnologyTF(arg_25_2, arg_25_1, "base")

				local var_25_0 = GetOrAddComponent(arg_25_2, typeof(Button)).onClick

				if self.lastButtonListener[arg_25_2] then
					var_25_0:RemoveListener(self.lastButtonListener[arg_25_2])
				end

				self.lastButtonListener[arg_25_2] = function()
					pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)

					if self.technologyVOs[arg_25_1]:isCompleted() then
						self:emit(TechnologyMediator.ON_FINISHED, {
							id = self.technologyVOs[arg_25_1].id,
							pool_id = self.technologyVOs[arg_25_1].poolId
						})
					else
						self:onSelected(arg_25_2, arg_25_1)
					end
				end

				var_25_0:AddListener(self.lastButtonListener[arg_25_2])
			end
		end)
	end

	self.itemList:align(#self.technologyVOs)
	setActive(self.srcollView, true)
end

function TechnologyScene:initQueue()
	if not self.queueItemList then
		self.queueItemList = UIItemList.New(self.btnQueue, self.btnQueue:GetChild(0))

		self.queueItemList:make(function(arg_28_0, arg_28_1, arg_28_2)
			arg_28_1 = arg_28_1 + 1

			if arg_28_0 == UIItemList.EventUpdate then
				arg_28_2.name = arg_28_1

				if self.queueTimer[arg_28_1] then
					self.queueTimer[arg_28_1]:Stop()

					self.queueTimer[arg_28_1] = nil
				end

				local var_28_0 = {}

				if not self.technologyQueue[arg_28_1] then
					var_28_0.empty = true
				else
					local var_28_1 = pg.TimeMgr.GetInstance()
					local var_28_2 = var_28_1:GetServerTime()
					local var_28_3 = self.technologyQueue[arg_28_1].time
					local var_28_4 = self.technologyQueue[arg_28_1]:getConfig("time")

					if var_28_2 < self.technologyQueue[arg_28_1].time - var_28_1 then
						var_28_0.waiting = true
					elseif var_28_2 < self.technologyQueue[arg_28_1].time then
						var_28_0.doing = true
						self.queueTimer[arg_28_1] = Timer.New(function()
							local var_29_0 = pg.TimeMgr.GetInstance():GetServerTime()

							if var_29_0 < var_28_3 then
								setSlider(arg_28_2:Find("doing"), 0, var_28_4, var_28_4 - var_28_3 + var_29_0)
							else
								self:updateQueueChange()
							end
						end, 1, -1)

						self.queueTimer[arg_28_1]:Start()
						self.queueTimer[arg_28_1].func()
					else
						var_28_0.complete = true
					end
				end

				eachChild(arg_28_2, function(arg_30_0)
					setActive(arg_30_0, var_28_0[arg_30_0.name])
				end)
			end
		end)
	end

	self.queueItemList:align(TechnologyConst.QUEUE_TOTAL_COUNT)
	onButton(self, self.btnQueue, function()
		self:setPage(TechnologyScene.PageQueue)
	end, SFX_PANEL)

	if not self.queueCardItemList then
		self.queueCardItemList = UIItemList.New(self.queueView, self.queueView:GetChild(0))

		self.queueCardItemList:make(function(arg_32_0, arg_32_1, arg_32_2)
			arg_32_1 = arg_32_1 + 1

			if arg_32_0 == UIItemList.EventUpdate then
				arg_32_2.name = arg_32_1

				self:updateTechnologyTF(arg_32_2, arg_32_1, "queue")
			end
		end)
	end

	self.queueCardItemList:align(TechnologyConst.QUEUE_TOTAL_COUNT)
	onButton(self, self.btnAwardQueue, function()
		if self.technologyQueue[1] and self.technologyQueue[1]:isCompleted() then
			self:emit(TechnologyMediator.ON_FINISH_QUEUE)
		end
	end, SFX_CONFIRM)
	setActive(self.btnAwardQueue, self.technologyQueue[1] and self.technologyQueue[1]:isCompleted())
	setActive(self.btnAwardQueueDisable, not isActive(self.btnAwardQueue))
end

function TechnologyScene:updateRefreshBtn(arg_34_1)
	setButtonEnabled(self.refreshBtn, arg_34_1 == 0)
end

function TechnologyScene:onSelected(arg_35_1, arg_35_2)
	if not arg_35_2 then
		return
	end

	if not self.technologyVOs[arg_35_2] then
		return
	end

	self.contextData.selectedIndex = arg_35_2

	self:updateTechnologyTF(self.technologyTpl, arg_35_2, "desc")

	self.srcollViewCG.alpha = 0.3

	setActive(arg_35_1, false)
	setActive(self.selectetPanel, true)

	local var_35_0 = {}

	eachChild(self.srcollView, function(arg_36_0)
		var_35_0[tonumber(arg_36_0.name)] = arg_36_0
	end)

	local function var_35_1(arg_37_0, arg_37_1)
		local var_37_0 = {}
		local var_37_1 = arg_37_0

		for iter_37_0, iter_37_1 in ipairs(var_35_0) do
			var_37_0[iter_37_0] = var_35_0[iter_37_0].localPosition.x - var_35_0[arg_37_0].localPosition.x
		end

		for iter_37_2, iter_37_3 in ipairs(var_37_0) do
			if iter_37_3 ~= 0 and (var_37_0[var_37_1] == 0 or arg_37_1 and (iter_37_3 > 0 and var_37_0[var_37_1] > 0 and iter_37_3 > var_37_0[var_37_1] or iter_37_3 < 0 and (var_37_0[var_37_1] > 0 or iter_37_3 > var_37_0[var_37_1])) or not arg_37_1 and (iter_37_3 < 0 and var_37_0[var_37_1] < 0 and iter_37_3 < var_37_0[var_37_1] or iter_37_3 > 0 and (var_37_0[var_37_1] < 0 or iter_37_3 < var_37_0[var_37_1]))) then
				var_37_1 = iter_37_2
			end
		end

		return var_35_0[var_37_1]
	end

	onButton(self, self.arrLeftBtn, function()
		if self.inAnim then
			return
		end

		self:cancelSelected()
		triggerButton(var_35_1(arg_35_2, true))
	end, SFX_PANEL)
	onButton(self, self.arrRightBtn, function()
		if self.inAnim then
			return
		end

		self:cancelSelected()
		triggerButton(var_35_1(arg_35_2, false))
	end, SFX_PANEL)
end

function TechnologyScene:cancelSelected()
	if not self.technologyVOs[self.contextData.selectedIndex or 0] then
		return
	end

	self.contextData.selectedIndex = nil

	setActive(self.technologyCards[self.contextData.selectedIndex], true)
	removeOnButton(self.arrLeftBtn)
	removeOnButton(self.arrRightBtn)
	setActive(self.selectetPanel, false)

	self.srcollViewCG.alpha = 1
	self.inAnim = true

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function()
		self.inAnim = nil
	end, 0.2, 1)

	self.timer:Start()

	if self.extraTimer then
		self.extraTimer:Stop()

		self.extraTimer = nil
	end
end

function TechnologyScene:updateTechnology(arg_42_1)
	local var_42_0

	for iter_42_0, iter_42_1 in ipairs(self.technologyVOs) do
		if iter_42_1.id == arg_42_1.id then
			self.technologyVOs[iter_42_0] = arg_42_1
			var_42_0 = iter_42_0

			break
		end
	end

	self:updateTechnologyTF(self.technologyCards[var_42_0], var_42_0, "base")

	if self.contextData.selectedIndex and self.technologyVOs[self.contextData.selectedIndex].id == arg_42_1.id then
		self:updateTechnologyTF(self.technologyTpl, var_42_0, "desc")
	end
end

function TechnologyScene:updateQueueChange()
	self.queueItemList:align(#self.technologyQueue)
	self.queueCardItemList:align(TechnologyConst.QUEUE_TOTAL_COUNT)
	setActive(self.btnAwardQueue, self.technologyQueue[1] and self.technologyQueue[1]:isCompleted())
	setActive(self.btnAwardQueueDisable, not isActive(self.btnAwardQueue))

	local var_43_0 = getProxy(TechnologyProxy):getActivateTechnology()

	if var_43_0 then
		self:updateTechnology(var_43_0)
	end
end

function TechnologyScene:updateTechnologyTF(arg_44_1, arg_44_2, arg_44_3)
	local var_44_0

	if arg_44_3 == "queue" then
		var_44_0 = self.technologyQueue[arg_44_2]

		local var_44_1 = not tobool(self.technologyQueue[arg_44_2])

		setActive(arg_44_1:Find("frame"), not var_44_1)
		setActive(arg_44_1:Find("empty"), var_44_1)

		if var_44_1 then
			return
		end
	else
		var_44_0 = self.technologyVOs[arg_44_2]
	end

	self:updateInfo(arg_44_1, var_44_0, arg_44_3)
	self:updateInfoVersionPickUp(arg_44_1, var_44_0)

	local var_44_2 = var_44_0:getConfig("time")
	local var_44_3 = pg.TimeMgr.GetInstance():GetServerTime()
	local var_44_4 = var_44_0.time

	switch(arg_44_3, {
		base = function()
			if self.cardtimer[arg_44_2] then
				self.cardtimer[arg_44_2]:Stop()

				self.cardtimer[arg_44_2] = nil
			end

			local var_45_0 = arg_44_1:Find("frame/marks/time")
			local var_45_1 = arg_44_1:Find("frame/marks/Text")
			local var_45_2 = TechnologyScene.rarityColor[var_44_0:getConfig("bg")]

			GetComponent(var_45_0, "Shadow").effectColor = Color.New(unpack(var_45_2[2]))

			local var_45_3 = {}

			if var_44_4 <= 0 then
				var_45_3.blue = true

				setText(var_45_1, setColorStr(i18n("technology_detail"), var_45_2[1]))
				setText(var_45_0, pg.TimeMgr.GetInstance():DescCDTime(var_44_0:getConfig("time")))
			elseif var_44_3 < var_44_4 - var_44_2 then
				var_45_3.blue = true

				setText(var_45_1, setColorStr(i18n("technology_queue_waiting"), var_45_2[1]))
				setText(var_45_0, pg.TimeMgr.GetInstance():DescCDTime(var_44_0:getConfig("time")))

				self.cardtimer[arg_44_2] = Timer.New(function()
					self:updateTechnology(var_44_0)
				end, var_44_4 - var_44_2 - var_44_3)

				self.cardtimer[arg_44_2]:Start()
			elseif var_44_3 < var_44_4 then
				var_45_3.blue = true

				setText(var_45_1, setColorStr(i18n("technology_queue_processing"), var_45_2[1]))

				self.cardtimer[arg_44_2] = Timer.New(function()
					local var_47_0 = pg.TimeMgr.GetInstance():GetServerTime()

					if var_47_0 < var_44_0.time then
						setText(var_45_0, pg.TimeMgr.GetInstance():DescCDTime(var_44_0.time - var_47_0))
					else
						self:updateTechnology(var_44_0)
					end
				end, 1, -1)

				self.cardtimer[arg_44_2]:Start()
				self.cardtimer[arg_44_2].func()
			else
				var_45_3.green = true

				if var_44_0:isCompleted() then
					setText(var_45_1, setColorStr(i18n("technology_queue_complete"), var_45_2[1]))
				else
					setText(var_45_1, setColorStr(i18n("technology_mission_unfinish"), var_45_2[1]))
				end

				setText(var_45_0, "00:00:00")
			end

			eachChild(arg_44_1:Find("frame/marks/line"), function(arg_48_0)
				setActive(arg_48_0, var_45_3[arg_48_0.name])
			end)
		end,
		queue = function()
			if self.queueCardTimer[arg_44_2] then
				self.queueCardTimer[arg_44_2]:Stop()

				self.queueCardTimer[arg_44_2] = nil
			end

			local var_49_0 = arg_44_1:Find("frame/marks/time")
			local var_49_1 = arg_44_1:Find("frame/marks/Text")
			local var_49_2 = TechnologyScene.rarityColor[var_44_0:getConfig("bg")]

			GetComponent(var_49_0, "Shadow").effectColor = Color.New(unpack(var_49_2[2]))

			local var_49_3 = {}

			if var_44_4 <= 0 then
				assert(false, "error queue")
			elseif var_44_3 < var_44_4 - var_44_2 then
				var_49_3.blue = true

				setText(var_49_1, setColorStr(i18n("technology_queue_waiting"), var_49_2[1]))
				setText(var_49_0, pg.TimeMgr.GetInstance():DescCDTime(var_44_0:getConfig("time")))
			elseif var_44_3 < var_44_4 then
				var_49_3.blue = true

				setText(var_49_1, setColorStr(i18n("technology_queue_processing"), var_49_2[1]))

				self.queueCardTimer[arg_44_2] = Timer.New(function()
					local var_50_0 = pg.TimeMgr.GetInstance():GetServerTime()

					if var_50_0 < var_44_0.time then
						setText(var_49_0, pg.TimeMgr.GetInstance():DescCDTime(var_44_0.time - var_50_0))
					end
				end, 1, -1)

				self.queueCardTimer[arg_44_2]:Start()
				self.queueCardTimer[arg_44_2].func()
			else
				var_49_3.green = true

				setText(var_49_1, setColorStr(i18n("technology_queue_complete"), var_49_2[1]))
				setText(var_49_0, "00:00:00")
			end

			eachChild(arg_44_1:Find("frame/marks/line"), function(arg_51_0)
				setActive(arg_51_0, var_49_3[arg_51_0.name])
			end)
			setActive(arg_44_1:Find("frame/mask"), var_44_4 > 0 and var_44_3 < var_44_4 - var_44_2)
		end,
		desc = function()
			self.descTxt.text = var_44_0:getConfig("desc")
			self.descBG.sprite = GetSpriteFromAtlas("ui/TechnologyUI_atlas", var_44_0:getConfig("rarity"))

			local var_52_0 = var_44_0:getConfig("consume")
			local var_52_1 = UIItemList.New(self.itemContainer, self.itemTpl)

			var_52_1:make(function(arg_53_0, arg_53_1, arg_53_2)
				arg_53_1 = arg_53_1 + 1

				if arg_53_0 == UIItemList.EventUpdate then
					self:updateItem(arg_53_2, var_44_0, var_52_0[arg_53_1])
					setActive(arg_53_2:Find("check"), var_44_0:isActivate())
					setActive(arg_53_2:Find("icon_bg/count"), not var_44_0:isActivate())
				end
			end)
			var_52_1:align(#var_52_0)
			setActive(self.emptyTF, not var_52_0 or #var_52_0 <= 0)

			local var_52_2 = var_44_0:getConfig("condition")

			if var_52_2 > 0 then
				local var_52_3 = getProxy(TaskProxy):getTaskById(var_52_2)

				var_52_3 = var_52_3 or Task.New({
					id = var_52_2
				})
				self.taskSlider.value = var_52_3.progress / var_52_3:getConfig("target_num")
				self.taskDesc.text = var_52_3:getConfig("desc") .. "(" .. var_52_3.progress .. "/" .. var_52_3:getConfig("target_num") .. ")"
			else
				self.taskDesc.text = i18n("technology_task_none_tip")
				self.taskSlider.value = 0
			end

			if self.extraTimer then
				self.extraTimer:Stop()

				self.extraTimer = nil
			end

			local var_52_4 = {}

			if var_44_4 <= 0 then
				var_52_4.start_btn = true
				self.timerTxt.text = pg.TimeMgr.GetInstance():DescCDTime(var_44_2)
			elseif var_44_3 < var_44_4 - var_44_2 then
				var_52_4.stop_btn = true
				var_52_4.join_btn = var_44_0:finishCondition()
				var_52_4.lock_join_btn = not var_52_4.join_btn
				self.timerTxt.text = pg.TimeMgr.GetInstance():DescCDTime(var_44_2)
			elseif var_44_3 < var_44_4 then
				var_52_4.stop_btn = true
				var_52_4.join_btn = var_44_0:finishCondition()
				var_52_4.lock_join_btn = not var_52_4.join_btn
				self.extraTimer = Timer.New(function()
					local var_54_0 = pg.TimeMgr.GetInstance():GetServerTime()

					if var_54_0 < var_44_4 then
						self.timerTxt.text = pg.TimeMgr.GetInstance():DescCDTime(var_44_4 - var_54_0)
					end
				end, 1, -1)

				self.extraTimer:Start()
				self.extraTimer.func()
			else
				if var_44_0:isCompleted() then
					var_52_4.finish_btn = true
				else
					var_52_4.stop_btn = true
					var_52_4.lock_join_btn = true
				end

				self.timerTxt.text = "00:00:00"
			end

			eachChild(arg_44_1:Find("frame/btns"), function(arg_55_0)
				setActive(arg_55_0, var_52_4[arg_55_0.name])
			end)

			local var_52_5 = arg_44_1:Find("frame/btns/start_btn")

			onButton(self, var_52_5, function()
				if getProxy(TechnologyProxy):getActivateTechnology() then
					pg.TipsMgr.GetInstance():ShowTips(i18n("technology_is_actived"))

					return
				end

				local var_56_0 = var_44_0:getConfig("consume")

				if #var_56_0 > 0 then
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						content = i18n("technology_task_build_tip", (getDropInfo(var_56_0))),
						onYes = function()
							self:emit(TechnologyMediator.ON_START, {
								id = var_44_0.id,
								pool_id = var_44_0.poolId
							})
						end
					})
				else
					self:emit(TechnologyMediator.ON_START, {
						id = var_44_0.id,
						pool_id = var_44_0.poolId
					})
				end
			end, SFX_PANEL)
			setButtonEnabled(var_52_5, var_44_0:hasResToStart())
			onButton(self, arg_44_1:Find("frame/btns/stop_btn"), function()
				if not var_44_0:isActivate() then
					return
				end

				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("technology_stop_tip"),
					onYes = function()
						self:emit(TechnologyMediator.ON_STOP, {
							id = var_44_0.id,
							pool_id = var_44_0.poolId
						})
					end
				})
			end, SFX_PANEL)
			onButton(self, arg_44_1:Find("frame/btns/join_btn"), function()
				if #self.technologyQueue == TechnologyConst.QUEUE_TOTAL_COUNT then
					pg.TipsMgr.GetInstance():ShowTips(i18n("technology_queue_full"))

					return
				end

				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("technology_queue_in_doublecheck"),
					onYes = function()
						self:emit(TechnologyMediator.ON_JOIN_QUEUE, {
							id = var_44_0.id,
							pool_id = var_44_0.poolId
						})
					end
				})
			end, SFX_PANEL)
			onButton(self, arg_44_1:Find("frame/btns/lock_join_btn"), function()
				pg.TipsMgr.GetInstance():ShowTips(i18n("technology_queue_in_mission_incomplete"))
			end, SFX_PANEL)
			onButton(self, arg_44_1:Find("frame/btns/finish_btn"), function()
				self:emit(TechnologyMediator.ON_FINISHED, {
					id = var_44_0.id,
					pool_id = var_44_0.poolId
				})
			end, SFX_PANEL)
		end
	})
end

function TechnologyScene:dfs(arg_64_1, arg_64_2)
	if arg_64_1.name ~= "item_tpl" then
		for iter_64_0 = 1, arg_64_1.childCount do
			self:dfs(arg_64_1:GetChild(iter_64_0 - 1), arg_64_2)
		end
	else
		arg_64_2(arg_64_1)
	end
end

local var_0_1 = {
	tag_red = "F15F34FF",
	tag_blue = "2541E3FF"
}

function TechnologyScene:updateInfo(arg_65_1, arg_65_2, arg_65_3)
	setImageSprite(arg_65_1:Find("frame"), GetSpriteFromAtlas("technologycard", arg_65_2:getConfig("bg") .. (arg_65_3 == "desc" and "_l" or "")))
	setImageSprite(arg_65_1:Find("frame/icon_mask/icon"), GetSpriteFromAtlas("technologyshipicon/" .. arg_65_2:getConfig("bg_icon"), arg_65_2:getConfig("bg_icon")), true)
	setImageSprite(arg_65_1:Find("frame/top/label"), GetSpriteFromAtlas("technologycard", arg_65_2:getConfig("label")))
	setImageSprite(arg_65_1:Find("frame/top/label/text"), GetSpriteFromAtlas("technologycard", arg_65_2:getConfig("label_color")), true)
	setImageSprite(arg_65_1:Find("frame/top/label/version"), GetSpriteFromAtlas("technologycard", "version_" .. arg_65_2:getConfig("blueprint_version")), true)
	setImageColor(arg_65_1:Find("frame/top/pick_up"), Color.NewHex(var_0_1[arg_65_2:getConfig("label")]))
	setText(arg_65_1:Find("frame/name_bg/Text"), arg_65_2:getConfig("name"))
	setText(arg_65_1:Find("frame/sub_name"), arg_65_2:getConfig("sub_name") or "")

	local var_65_0 = arg_65_2:getConfig("drop_client")
	local var_65_1 = arg_65_1:Find("frame/item_container")
	local var_65_2 = 0

	self:dfs(var_65_1, function(arg_66_0)
		var_65_2 = var_65_2 + 1

		setActive(arg_66_0, var_65_2 <= #var_65_0)

		if var_65_2 <= #var_65_0 then
			self:updateItem(arg_66_0, arg_65_2, var_65_0[var_65_2])
		end
	end)
	switch(arg_65_3, {
		desc = function()
			return
		end
	}, function()
		setActive(var_65_1:GetChild(1), #var_65_0 > 2)

		var_65_1:GetChild(0):GetComponent("HorizontalLayoutGroup").padding.right = #var_65_0 == 4 and 25 or 0
		var_65_1:GetChild(1):GetComponent("HorizontalLayoutGroup").padding.left = #var_65_0 == 4 and 25 or 0
	end)
end

function TechnologyScene:updateInfoVersionPickUp(arg_69_1, arg_69_2)
	setActive(arg_69_1:Find("frame/top/pick_up"), getProxy(TechnologyProxy):getTendency(2) == arg_69_2:getConfig("blueprint_version"))
end

function TechnologyScene:updateItem(arg_70_1, arg_70_2, arg_70_3)
	local var_70_0 = Drop.Create(arg_70_3)

	updateDrop(arg_70_1, setmetatable({
		count = 0
	}, {
		__index = var_70_0
	}))

	local var_70_1 = arg_70_1:Find("icon_bg/count")

	if not IsNil(var_70_1) then
		setColorCount(var_70_1, var_70_0:getOwnedCount(), var_70_0.count)
	end

	onButton(self, arg_70_1, function()
		local var_71_0 = var_70_0:getConfig("display_icon") or {}

		if #var_71_0 > 0 then
			local var_71_1 = {
				type = MSGBOX_TYPE_ITEM_BOX,
				items = _.map(var_71_0, function(arg_72_0)
					return {
						type = arg_72_0[1],
						id = arg_72_0[2]
					}
				end),
				content = var_70_0:getConfig("display")
			}

			function var_71_1.itemFunc(arg_73_0)
				self:emit(TechnologyScene.ON_DROP, arg_73_0, function()
					pg.MsgboxMgr.GetInstance():ShowMsgBox(var_71_1)
				end)
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox(var_71_1)
		else
			self:emit(TechnologyScene.ON_DROP, var_70_0)
		end
	end, SFX_PANEL)
end

function TechnologyScene:updatePickUpVersionChange()
	self:updateSettingBtnVersion()

	for iter_75_0, iter_75_1 in ipairs(self.technologyCards) do
		self:updateInfoVersionPickUp(iter_75_1, self.technologyVOs[iter_75_0])
	end

	for iter_75_2, iter_75_3 in ipairs(self.technologyQueue) do
		self:updateInfoVersionPickUp(self.queueCardItemList.container:GetChild(iter_75_2 - 1), iter_75_3)
	end
end

function TechnologyScene:clearTimer(...)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.extraTimer then
		self.extraTimer:Stop()

		self.extraTimer = nil
	end

	if self.enhancelTimer then
		self.enhancelTimer:Stop()

		self.enhancelTimer = nil
	end

	for iter_76_0, iter_76_1 in pairs(self.cardtimer) do
		iter_76_1:Stop()
	end

	self.cardtimer = {}

	for iter_76_2, iter_76_3 in pairs(self.queueTimer) do
		iter_76_3:Stop()
	end

	self.queueTimer = {}

	for iter_76_4, iter_76_5 in pairs(self.queueCardTimer) do
		iter_76_5:Stop()
	end

	self.queueCardTimer = {}

	if self.actCatchupTimer then
		self.actCatchupTimer:Stop()

		self.actCatchupTimer = nil
	end
end

function TechnologyScene:willExit()
	self:clearTimer()

	self.cardtimer = nil
	self.queueTimer = nil
	self.queueCardTimer = nil
end

return TechnologyScene
