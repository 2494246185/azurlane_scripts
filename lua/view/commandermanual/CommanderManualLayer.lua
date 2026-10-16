local CommanderManualLayer = class("CommanderManualLayer", import("..base.BaseUI"))

function CommanderManualLayer:getUIName()
	return "CommanderManualUI"
end

function CommanderManualLayer:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype",
		"ui/iconcolorful",
		"ui/MsgBox"
	}

	table.insertto(var_2_0, CommanderManualLayer.super.getResource(self))

	return var_2_0
end

function CommanderManualLayer:init()
	self.backBtn = self._tf:Find("blur_panel/top/CommonTitleAndBack/back_btn")
	self.helpBtn = self._tf:Find("blur_panel/top/helpBtn")
	self.taskBtn = self._tf:Find("blur_panel/panel/pageBtns/taskBtn")
	self.techBtn = self._tf:Find("blur_panel/panel/pageBtns/techBtn")
	self.guideBtn = self._tf:Find("blur_panel/panel/pageBtns/guideBtn")
	self.topBtns = {
		self.taskBtn,
		self.techBtn,
		self.guideBtn
	}
	self.pages = self._tf:Find("blur_panel/panel/pages")
	self.taskPage = self._tf:Find("blur_panel/panel/pages/taskPage")
	self.techPage = self._tf:Find("blur_panel/panel/pages/techPage")
	self.guidePage = self._tf:Find("blur_panel/panel/pages/guidePage")
	self.blurPanel = self._tf:Find("blur_panel")
	self.pageBg = self._tf:Find("blur_panel/panel/mask/pageBg")

	self:OverlayPanel(self.blurPanel, {
		pbList = {
			self.pageBg
		}
	})
	setText(self._tf:Find("blur_panel/top/CommonTitleAndBack/title"), i18n("handbook_name"))
	setText(self._tf:Find("blur_panel/top/CommonTitleAndBack/title/en"), "HANDBOOK")
	setText(self.taskPage:Find("page/scroll/Viewport/Content/tpl/normal/go_btn/Text"), i18n("handbook_process"))
	setText(self.taskPage:Find("page/scroll/Viewport/Content/tpl/normal/get_btn/Text"), i18n("handbook_claim"))
	setText(self.taskPage:Find("page/scroll/Viewport/Content/tpl/normal/got_btn/Text"), i18n("handbook_finished"))
	setText(self.taskPage:Find("page/ptPanel/go_btn/Text"), i18n("handbook_process"))
	setText(self.taskPage:Find("page/ptPanel/get_btn/Text"), i18n("handbook_claim"))
	setText(self.taskPage:Find("page/ptPanel/got_btn/Text"), i18n("handbook_finished"))
	setText(self.techPage:Find("page/scroll/Viewport/Content/tpl/normal/go_btn/Text"), i18n("handbook_process"))
	setText(self.techPage:Find("page/scroll/Viewport/Content/tpl/normal/lock_btn/Text"), i18n("handbook_process"))
	setText(self.techPage:Find("page/scroll/Viewport/Content/tpl/normal/get_btn/Text"), i18n("handbook_claim"))
	setText(self.techPage:Find("page/scroll/Viewport/Content/tpl/normal/got_btn/Text"), i18n("handbook_finished"))
	setText(self.techPage:Find("page/ptPanel/go_btn/Text"), i18n("handbook_process"))
	setText(self.techPage:Find("page/ptPanel/get_btn/Text"), i18n("handbook_claim"))
	setText(self.techPage:Find("page/ptPanel/got_btn/Text"), i18n("handbook_finished"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/normal/content/descBg/go_btn/Text"), i18n("handbook_process"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/normal/content/descBg/get_btn/Text"), i18n("handbook_claim"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/normal/content/descBg/got_btn/Text"), i18n("handbook_finished"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/fold/descBg/go_btn/Text"), i18n("handbook_process"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/fold/descBg/get_btn/Text"), i18n("handbook_claim"))
	setText(self.guidePage:Find("page/scroll/Viewport/Content/tpl/fold/descBg/got_btn/Text"), i18n("handbook_finished"))
	setText(self.guidePage:Find("page/ptPanel/go_btn/Text"), i18n("handbook_process"))
	setText(self.guidePage:Find("page/ptPanel/get_btn/Text"), i18n("handbook_claim"))
	setText(self.guidePage:Find("page/ptPanel/got_btn/Text"), i18n("handbook_finished"))
end

function CommanderManualLayer:didEnter()
	onButton(self, self.backBtn, function()
		self:onBackPressed()
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.handbook_gametip.tip
		})
	end, SFX_PANEL)
	self:InitData()
	self:RefreshAll()
end

function CommanderManualLayer:InitData()
	self.commanderManualProxy = getProxy(CommanderManualProxy)
	self.taskProxy = getProxy(TaskProxy)
	self.taskPages = self.commanderManualProxy:GetPagesByType(1)
	self.guidePages = self.commanderManualProxy:GetPagesByType(2)
	self.topTaskCfg = pg.tutorial_handbook[CommanderManualProxy.TOP_PAGE_TASK]
	self.topTechCfg = pg.tutorial_handbook[CommanderManualProxy.TOP_PAGE_TECH]
	self.topGuideCfg = pg.tutorial_handbook[CommanderManualProxy.TOP_PAGE_GUIDE]

	self:UpdateTechActivity()
end

function CommanderManualLayer:UpdateTechActivity()
	self.techActivity = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_FRESH_TEC_CATCHUP)

	if not self.techActivity or self.techActivity:isEnd() then
		return
	end

	local var_8_0 = self.techActivity

	self.allTechPhase = #self.techActivity:getConfig("config_data")[3] + 1

	if var_8_0.data1 == 0 then
		self.phaseId = "ready"
	else
		self.phaseId = var_8_0.data1

		if self.phaseId == 1 and var_8_0.data2 < 1 then
			self.phaseId = 0
		end
	end

	self.techFinishTaskId = self.phaseId ~= "ready" and var_8_0:getConfig("config_data")[3][math.max(1, self.phaseId)][2] or nil
	self.finishPhaseDic = {}

	for iter_8_0, iter_8_1 in ipairs(var_8_0.data1_list) do
		self.finishPhaseDic[iter_8_1] = true
	end

	self.finishPhaseDic[0] = self.finishPhaseDic[1]
	self.finishPhaseDic[1] = var_8_0.data2 == 1 and var_8_0.data1 ~= 1
end

function CommanderManualLayer:RefreshAll()
	local var_9_0 = self.commanderManualProxy:IsTopUnlock(CommanderManualProxy.TOP_PAGE_TASK)
	local var_9_1 = self.commanderManualProxy:IsTopUnlock(CommanderManualProxy.TOP_PAGE_TECH)
	local var_9_2 = self.commanderManualProxy:IsTopUnlock(CommanderManualProxy.TOP_PAGE_GUIDE)

	setActive(self.taskBtn, not self.commanderManualProxy:IsTopPageComplete(1))

	local var_9_3, var_9_4 = TechnologyConst.isTecActOn()

	setActive(self.techBtn, var_9_3)
	setActive(self.taskBtn:Find("Text/lock"), not var_9_0)
	setActive(self.techBtn:Find("Text/lock"), not var_9_1)
	setActive(self.guideBtn:Find("Text/lock"), not var_9_2)
	setText(self.taskBtn:Find("Text"), (var_9_0 or nil) and (self.topTaskCfg.name or self.topTaskCfg.lock_name))
	setText(self.techBtn:Find("Text"), (var_9_1 or nil) and (self.topTechCfg.name or self.topTechCfg.lock_name))
	setText(self.guideBtn:Find("Text"), (var_9_2 or nil) and (self.topGuideCfg.name or self.topGuideCfg.lock_name))
	setText(self.taskBtn:Find("select/Text"), self.topTaskCfg.name)
	setText(self.techBtn:Find("select/Text"), self.topTechCfg.name)
	setText(self.guideBtn:Find("select/Text"), self.topGuideCfg.name)
	setText(self.taskBtn:Find("select/en"), self.topTaskCfg.eng_name)
	setText(self.techBtn:Find("select/en"), self.topTechCfg.eng_name)
	setText(self.guideBtn:Find("select/en"), self.topGuideCfg.eng_name)
	setActive(self.taskBtn:Find("tip"), self.commanderManualProxy:ShouldShowTipByType(1))
	setActive(self.techBtn:Find("tip"), var_9_4)
	setActive(self.guideBtn:Find("tip"), self.commanderManualProxy:ShouldShowTipByType(2))

	self.hasRefreshed = false

	onButton(self, self.taskBtn, function()
		if self.contextData.topIndex ~= 1 or not self.hasRefreshed then
			if var_9_0 then
				self.contextData.topIndex = 1

				if self.hasRefreshed then
					self.contextData.currentPageId = nil
				end

				self:SetPagesActive(1)
				self:ShowTaskPage()

				for iter_10_0, iter_10_1 in ipairs(self.topBtns) do
					setActive(iter_10_1:Find("select"), iter_10_1 == self.taskBtn)
				end
			else
				local var_10_0 = self.commanderManualProxy:GetLockTip(CommanderManualProxy.TOP_PAGE_TASK)

				if var_10_0 and var_10_0 ~= "" then
					pg.TipsMgr.GetInstance():ShowTips(var_10_0)
				end
			end
		end
	end, SFX_PANEL)
	onButton(self, self.techBtn, function()
		if self.contextData.topIndex ~= 2 or not self.hasRefreshed then
			if var_9_1 then
				self.contextData.topIndex = 2

				if self.hasRefreshed then
					self.contextData.currentPageId = nil
				end

				self:SetPagesActive(2)
				self:ShowTechPage()

				for iter_11_0, iter_11_1 in ipairs(self.topBtns) do
					setActive(iter_11_1:Find("select"), iter_11_1 == self.techBtn)
				end
			else
				local var_11_0 = self.commanderManualProxy:GetLockTip(CommanderManualProxy.TOP_PAGE_TECH)

				if var_11_0 and var_11_0 ~= "" then
					pg.TipsMgr.GetInstance():ShowTips(var_11_0)
				end
			end
		end
	end, SFX_PANEL)
	onButton(self, self.guideBtn, function()
		if self.contextData.topIndex ~= 3 or not self.hasRefreshed then
			if var_9_2 then
				self.contextData.topIndex = 3

				if self.hasRefreshed then
					self.contextData.currentPageId = nil
				end

				self:SetPagesActive(3)
				self:ShowGuidePage()

				for iter_12_0, iter_12_1 in ipairs(self.topBtns) do
					setActive(iter_12_1:Find("select"), iter_12_1 == self.guideBtn)
				end
			else
				local var_12_0 = self.commanderManualProxy:GetLockTip(CommanderManualProxy.TOP_PAGE_GUIDE)

				if var_12_0 and var_12_0 ~= "" then
					pg.TipsMgr.GetInstance():ShowTips(var_12_0)
				end
			end
		end
	end, SFX_PANEL)

	if self.contextData.topIndex then
		triggerButton(self.topBtns[self.contextData.topIndex])

		self.hasRefreshed = true
	else
		local var_9_8 = false

		for iter_9_0, iter_9_1 in ipairs(self.topBtns) do
			if isActive(iter_9_1) and not isActive(iter_9_1:Find("Text/lock")) and isActive(iter_9_1:Find("tip")) then
				triggerButton(iter_9_1)

				var_9_8 = true
				self.hasRefreshed = true

				break
			end
		end

		if not var_9_8 then
			for iter_9_2, iter_9_3 in ipairs(self.topBtns) do
				if isActive(iter_9_3) and not isActive(iter_9_3:Find("Text/lock")) then
					triggerButton(iter_9_3)

					self.hasRefreshed = true

					break
				end
			end
		end
	end
end

function CommanderManualLayer:SetPagesActive(arg_13_1)
	for iter_13_0 = 1, self.pages.childCount do
		setActive(self.pages:GetChild(iter_13_0 - 1), iter_13_0 == arg_13_1)
	end
end

function CommanderManualLayer:ShowTaskPage()
	self.taskItemAnimTime = self.taskItemAnimTime or {}

	local var_14_0 = UIItemList.New(self.taskPage:Find("subPageScroll/Viewport/Content"), self.taskPage:Find("subPageScroll/Viewport/Content/subPageBtn"))
	local var_14_1 = UIItemList.New(self.taskPage:Find("page/scroll/Viewport/Content"), self.taskPage:Find("page/scroll/Viewport/Content/tpl"))
	local var_14_2 = false

	var_14_0:make(function(arg_15_0, arg_15_1, arg_15_2)
		if arg_15_0 == UIItemList.EventUpdate then
			local var_15_0 = self.taskPages[arg_15_1 + 1]

			setActive(arg_15_2:Find("name/lock"), not self.taskPages[arg_15_1 + 1].isUnlock)
			setActive(arg_15_2:Find("tip"), var_15_0:ShouldShowTip())
			setText(arg_15_2:Find("name"), var_15_0.isUnlock and var_15_0:getConfig("name") or var_15_0:getConfig("lock_name"))
			setText(arg_15_2:Find("name/en"), var_15_0:getConfig("eng_name"))
			setText(arg_15_2:Find("select/name"), var_15_0:getConfig("name"))
			setText(arg_15_2:Find("select/name/en"), var_15_0:getConfig("eng_name"))

			arg_15_2:GetComponent(typeof(CanvasGroup)).alpha = var_15_0.isUnlock and 1 or 0.5

			onButton(self, arg_15_2, function()
				if var_15_0.isUnlock then
					self.contextData.currentPageId = var_15_0.id

					for iter_16_0 = 1, self.taskPage:Find("subPageScroll/Viewport/Content").childCount do
						setActive(self.taskPage:Find("subPageScroll/Viewport/Content"):GetChild(iter_16_0 - 1):Find("select"), iter_16_0 == arg_15_1 + 1)
						setActive(self.taskPage:Find("subPageScroll/Viewport/Content"):GetChild(iter_16_0 - 1):Find("name"), iter_16_0 ~= arg_15_1 + 1)

						self.taskPage:Find("subPageScroll/Viewport/Content"):GetChild(iter_16_0 - 1):Find("tip").anchoredPosition = Vector2(iter_16_0 == arg_15_1 + 1 and -34.295 or 18, -2)
					end

					var_15_0:SortTaskIdList()
					var_14_1:make(function(arg_17_0, arg_17_1, arg_17_2)
						if arg_17_0 == UIItemList.EventUpdate then
							local var_17_0 = var_15_0.taskIdList[arg_17_1 + 1]
							local var_17_1 = self.taskProxy:getTaskById(var_15_0.taskIdList[arg_17_1 + 1])

							setText(arg_17_2:Find("normal/number"), string.format("NO.%02d", arg_17_1 + 1))
							setText(arg_17_2:Find("normal/desc"), pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].desc)

							local var_17_2 = arg_17_2:Find("normal/awards")

							self:updateTaskAwards(pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].award_display, var_17_2, (var_17_2:GetChild(0)))

							local var_17_3 = arg_17_2:Find("normal/go_btn")
							local var_17_4 = arg_17_2:Find("normal/get_btn")
							local var_17_5 = arg_17_2:Find("normal/got_btn")
							local var_17_6 = arg_17_2:Find("normal")
							local var_17_7 = arg_17_2:Find("lock")

							if var_17_1 then
								local var_17_8 = math.min(var_17_1:getProgress(), pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num)

								setText(arg_17_2:Find("normal/progress"), var_17_8 .. "/" .. pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num)
								setSlider(arg_17_2:Find("normal/slider"), 0, pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num, var_17_8)

								if var_17_1:getTaskStatus() == 0 then
									setActive(var_17_3, true)
									setActive(var_17_4, false)
									setActive(var_17_5, false)
								elseif var_17_1:getTaskStatus() == 1 then
									setActive(var_17_3, false)
									setActive(var_17_4, true)
									setActive(var_17_5, false)
								elseif var_17_1:getTaskStatus() == 2 then
									setActive(var_17_3, false)
									setActive(var_17_4, false)
									setActive(var_17_5, true)
								end

								onButton(self, var_17_3, function()
									self:emit(CommanderManualMediator.ON_TASK_GO, var_17_1)
								end, SFX_PANEL)
								onButton(self, var_17_4, function()
									self:TaskAwardsCheckAndSubmit(var_17_1)
								end, SFX_PANEL)
								setActive(var_17_6, true)
								setActive(var_17_7, false)
							elseif var_15_0:IsTaskComplete(var_17_0) then
								setText(arg_17_2:Find("normal/progress"), pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num .. "/" .. pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num)
								setSlider(arg_17_2:Find("normal/slider"), 0, pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num, pg.task_data_template[var_15_0.taskIdList[arg_17_1 + 1]].target_num)
								setActive(var_17_3, false)
								setActive(var_17_4, false)
								setActive(var_17_5, true)
								setActive(var_17_6, true)
								setActive(var_17_7, false)
							else
								setText(arg_17_2:Find("lock/lockBg/Text"), var_15_0:GetTaskLockTip(var_17_0))
								setActive(var_17_6, false)
								setActive(var_17_7, true)
							end

							if not self.taskItemAnimTime[var_17_0] or Time.realtimeSinceStartup - self.taskItemAnimTime[var_17_0] > 1 then
								arg_17_2:GetComponent(typeof(Animation)):Play("anim_CommanderManualUI_tpl_update")

								self.taskItemAnimTime[var_17_0] = Time.realtimeSinceStartup
							end
						end
					end)
					var_14_1:align(#var_15_0.taskIdList)
					scrollTo(self.taskPage:Find("page/scroll"), 0, 1)
					self:SetPtPanel(self.taskPage:Find("page/ptPanel"), var_15_0)
				else
					local var_16_0 = var_15_0:GetLockTip()

					if var_16_0 and var_16_0 ~= "" then
						pg.TipsMgr.GetInstance():ShowTips(var_16_0)
					end
				end
			end, SFX_PANEL)

			if self.contextData.currentPageId == var_15_0.id then
				var_14_2 = true

				triggerButton(arg_15_2)
			end

			if not self.contextData.currentPageId and var_15_0.isUnlock and isActive(arg_15_2:Find("tip")) then
				var_14_2 = true
				self.contextData.currentPageId = var_15_0.id

				triggerButton(arg_15_2)
			end
		end
	end)
	var_14_0:align(#self.taskPages)

	if not false then
		for iter_14_0 = #self.taskPages, 1, -1 do
			if self.taskPages[iter_14_0].isUnlock then
				triggerButton(self.taskPage:Find("subPageScroll/Viewport/Content"):GetChild(iter_14_0 - 1))

				break
			end
		end
	end

	self:ShowBottomTip(self.taskPage, 1)
	onScroll(self, self.taskPage:Find("subPageScroll"), function(arg_20_0)
		self:ShowBottomTip(self.taskPage, arg_20_0.y)
	end)
end

function CommanderManualLayer:ShowGuidePage()
	local var_21_0 = UIItemList.New(self.guidePage:Find("subPageScroll/Viewport/Content"), self.guidePage:Find("subPageScroll/Viewport/Content/subPageBtn"))
	local var_21_1 = UIItemList.New(self.guidePage:Find("page/scroll/Viewport/Content"), self.guidePage:Find("page/scroll/Viewport/Content/tpl"))
	local var_21_2 = false

	var_21_0:make(function(arg_22_0, arg_22_1, arg_22_2)
		if arg_22_0 == UIItemList.EventUpdate then
			local var_22_0 = self.guidePages[arg_22_1 + 1]
			local var_22_1 = self.guidePages[arg_22_1 + 1]:getConfig("name")
			local var_22_2 = self.guidePages[arg_22_1 + 1]:getConfig("lock_name")

			setActive(arg_22_2:Find("lock0/lock"), not self.guidePages[arg_22_1 + 1].isUnlock)
			setActive(arg_22_2:Find("tip"), var_22_0:ShouldShowTip())
			arg_22_2:Find("mask/name"):GetComponent("ScrollText"):SetText(var_22_0.isUnlock and var_22_1 or var_22_2 or "")
			setText(arg_22_2:Find("en"), var_22_0:getConfig("eng_name"))
			arg_22_2:Find("select/mask/name"):GetComponent("ScrollText"):SetText(tostring(var_22_1 or ""))
			setText(arg_22_2:Find("select/en"), var_22_0:getConfig("eng_name"))

			arg_22_2:GetComponent(typeof(CanvasGroup)).alpha = var_22_0.isUnlock and 1 or 0.5

			onButton(self, arg_22_2, function()
				if var_22_0.isUnlock then
					self.contextData.currentPageId = var_22_0.id

					for iter_23_0 = 1, self.guidePage:Find("subPageScroll/Viewport/Content").childCount do
						setActive(self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(iter_23_0 - 1):Find("select"), iter_23_0 == arg_22_1 + 1)
						setActive(self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(iter_23_0 - 1):Find("lock0"), iter_23_0 ~= arg_22_1 + 1)
						setActive(self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(iter_23_0 - 1):Find("mask"), iter_23_0 ~= arg_22_1 + 1)
						setActive(self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(iter_23_0 - 1):Find("en"), iter_23_0 ~= arg_22_1 + 1)

						self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(iter_23_0 - 1):Find("tip").anchoredPosition = Vector2(iter_23_0 == arg_22_1 + 1 and -34.295 or 18, -2)
					end

					var_22_0:SortTaskIdList()
					var_21_1:make(function(arg_24_0, arg_24_1, arg_24_2)
						if arg_24_0 == UIItemList.EventUpdate then
							local var_24_0 = self.taskProxy:getTaskById(var_22_0.taskIdList[arg_24_1 + 1])

							setText(arg_24_2:Find("normal/number"), string.format("NO.%02d", arg_24_1 + 1))
							setText(arg_24_2:Find("normal/name"), pg.task_data_template[var_22_0.taskIdList[arg_24_1 + 1]].name)
							setText(arg_24_2:Find("normal/content/descBg/desc"), pg.task_data_template[var_22_0.taskIdList[arg_24_1 + 1]].desc)
							LoadImageSpriteAsync(pg.task_data_template[var_22_0.taskIdList[arg_24_1 + 1]].tutorial_handbook_pic, arg_24_2:Find("normal/content/picture"))
							setText(arg_24_2:Find("fold/number"), string.format("NO.%02d", arg_24_1 + 1))
							setText(arg_24_2:Find("fold/name"), pg.task_data_template[var_22_0.taskIdList[arg_24_1 + 1]].name)
							setText(arg_24_2:Find("fold/descBg/desc"), pg.task_data_template[var_22_0.taskIdList[arg_24_1 + 1]].desc)

							local var_24_1 = arg_24_2:Find("normal/content/descBg/go_btn")
							local var_24_2 = arg_24_2:Find("normal/content/descBg/get_btn")
							local var_24_3 = arg_24_2:Find("normal/content/descBg/got_btn")
							local var_24_4 = arg_24_2:Find("fold/descBg/go_btn")
							local var_24_5 = arg_24_2:Find("fold/descBg/get_btn")
							local var_24_6 = arg_24_2:Find("fold/descBg/got_btn")
							local var_24_7 = arg_24_2:Find("normal")
							local var_24_8 = arg_24_2:Find("fold")
							local var_24_9 = arg_24_2:Find("lock")
							local var_24_10 = arg_24_2:GetComponent(typeof(Animation))
							local var_24_11 = arg_24_2:GetComponent(typeof(DftAniEvent))

							if var_24_0 then
								if var_24_0:getTaskStatus() == 0 then
									setActive(var_24_1, true)
									setActive(var_24_2, false)
									setActive(var_24_3, false)
									setActive(var_24_4, true)
									setActive(var_24_5, false)
									setActive(var_24_6, false)
								elseif var_24_0:getTaskStatus() == 1 then
									setActive(var_24_1, false)
									setActive(var_24_2, true)
									setActive(var_24_3, false)
									setActive(var_24_4, false)
									setActive(var_24_5, true)
									setActive(var_24_6, false)
								elseif var_24_0:getTaskStatus() == 2 then
									setActive(var_24_1, false)
									setActive(var_24_2, false)
									setActive(var_24_3, true)
									setActive(var_24_4, false)
									setActive(var_24_5, false)
									setActive(var_24_6, true)
								end

								onButton(self, var_24_1, function()
									self:emit(CommanderManualMediator.ON_TASK_GO, var_24_0)
								end, SFX_PANEL)
								onButton(self, var_24_2, function()
									self:TaskAwardsCheckAndSubmit(var_24_0)
								end, SFX_PANEL)
								onButton(self, var_24_4, function()
									self:emit(CommanderManualMediator.ON_TASK_GO, var_24_0)
								end, SFX_PANEL)
								onButton(self, var_24_5, function()
									self:TaskAwardsCheckAndSubmit(var_24_0)
								end, SFX_PANEL)
								setActive(arg_24_2:Find("normal/content/descBg/triangle"), false)
								setActive(var_24_7, true)
								setActive(var_24_8, false)
								setActive(var_24_9, false)
							elseif var_22_0:IsTaskComplete(var_22_0.taskIdList[arg_24_1 + 1]) then
								setActive(var_24_1, false)
								setActive(var_24_2, false)
								setActive(var_24_3, true)
								setActive(var_24_4, false)
								setActive(var_24_5, false)
								setActive(var_24_6, true)
								setActive(arg_24_2:Find("normal/content/descBg/triangle"), true)
								onButton(self, arg_24_2:Find("normal/content/descBg/triangle"), function()
									setActive(var_24_7, true)
									var_24_11:SetEndEvent(function()
										setActive(var_24_7, false)
										setActive(var_24_8, true)
									end)
									var_24_10:Play("anim_CommanderManualUI_tpl_guidePage_expand")
								end, SFX_PANEL)
								onButton(self, arg_24_2:Find("fold/descBg/triangle"), function()
									setActive(var_24_7, true)
									var_24_11:SetEndEvent(function()
										setActive(var_24_8, false)
									end)
									var_24_10:Play("anim_CommanderManualUI_tpl_guidePage_retract")
								end, SFX_PANEL)
								setActive(var_24_7, false)
								setActive(var_24_8, true)
								setActive(var_24_9, false)
							else
								setText(arg_24_2:Find("lock/lockBg/Text"), var_22_0:GetTaskLockTip(var_22_0.taskIdList[arg_24_1 + 1]))
								setActive(var_24_7, false)
								setActive(var_24_8, false)
								setActive(var_24_9, true)
							end

							var_24_10:Play("anim_CommanderManualUI_tpl_guidePage")
						end
					end)
					var_21_1:align(#var_22_0.taskIdList)
					scrollTo(self.guidePage:Find("page/scroll"), 0, 1)
					self:SetPtPanel(self.guidePage:Find("page/ptPanel"), var_22_0)
				else
					local var_23_0 = var_22_0:GetLockTip()

					if var_23_0 and var_23_0 ~= "" then
						pg.TipsMgr.GetInstance():ShowTips(var_23_0)
					end
				end
			end, SFX_PANEL)

			if self.contextData.currentPageId == var_22_0.id then
				var_21_2 = true

				triggerButton(arg_22_2)
			end

			if not self.contextData.currentPageId and var_22_0.isUnlock and isActive(arg_22_2:Find("tip")) then
				var_21_2 = true
				self.contextData.currentPageId = var_22_0.id

				triggerButton(arg_22_2)
			end
		end
	end)
	var_21_0:align(#self.guidePages)

	if not false then
		triggerButton(self.guidePage:Find("subPageScroll/Viewport/Content"):GetChild(0))
	end

	self:ShowBottomTip(self.guidePage, 1)
	onScroll(self, self.guidePage:Find("subPageScroll"), function(arg_33_0)
		self:ShowBottomTip(self.guidePage, arg_33_0.y)
	end)
end

function CommanderManualLayer:SetPtPanel(arg_34_1, arg_34_2)
	local var_34_0 = arg_34_2:getConfig("target")
	local var_34_1 = arg_34_2:getConfig("drop_client")

	setText(arg_34_1:Find("upgrade/progress/progress1"), arg_34_2.pt)
	setText(arg_34_1:Find("upgrade/progress/progress2"), "/" .. #arg_34_2.taskIdList)
	setSlider(arg_34_1:Find("slider"), 0, #arg_34_2.taskIdList, arg_34_2.pt)

	if arg_34_2.pt == #arg_34_2.taskIdList then
		arg_34_1:Find("upgrade"):GetComponent(typeof(Animation)):Play("anim_CommanderManualUI_ptPanel_upgrade")
	end

	local var_34_2 = arg_34_2:GetCurrentPtTarget()

	setText(arg_34_1:Find("desc"), i18n("handbook_unfinished", var_34_2))

	local var_34_3 = arg_34_1:Find("awards")

	self:updateTaskAwards(arg_34_2:GetCurrentPtAward(), var_34_3, (var_34_3:GetChild(0)))
	setActive(arg_34_1:Find("go_btn"), var_34_2 > arg_34_2.pt)
	setActive(arg_34_1:Find("get_btn"), var_34_2 <= arg_34_2.pt and arg_34_2.award < #arg_34_2:getConfig("target"))
	setActive(arg_34_1:Find("got_btn"), arg_34_2.award == #arg_34_2:getConfig("target"))
	onButton(self, arg_34_1:Find("get_btn"), function()
		self:PtAwardsCheckAndSubmit(arg_34_2)
	end, SFX_PANEL)
end

function CommanderManualLayer:updateTaskAwards(arg_36_1, arg_36_2, arg_36_3)
	local var_36_0 = _.slice(arg_36_1, 1, 3)

	for iter_36_0 = arg_36_2.childCount, #var_36_0 - 1 do
		cloneTplTo(arg_36_3, arg_36_2)
	end

	for iter_36_1 = 1, arg_36_2.childCount do
		local var_36_1 = arg_36_2:GetChild(iter_36_1 - 1)
		local var_36_2 = iter_36_1 <= #var_36_0

		setActive(var_36_1, iter_36_1 <= #var_36_0)

		if var_36_2 then
			local var_36_3 = {
				type = var_36_0[iter_36_1][1],
				id = var_36_0[iter_36_1][2],
				count = var_36_0[iter_36_1][3]
			}

			updateDrop(var_36_1, var_36_3)
			onButton(self, var_36_1, function()
				self:emit(BaseUI.ON_DROP, var_36_3)
			end, SFX_PANEL)
		end
	end
end

function CommanderManualLayer:ShowTechPage()
	local var_38_0 = self.techPage:Find("subPageScroll/Viewport/Content")

	UIItemList.StaticAlign(var_38_0, var_38_0:GetChild(0), self.allTechPhase, function(arg_39_0, arg_39_1, arg_39_2)
		if arg_39_0 == UIItemList.EventUpdate then
			arg_39_2.name = "Phase" .. arg_39_1

			setText(arg_39_2:Find("name"), i18n("tec_catchup_" .. arg_39_1))
			setText(arg_39_2:Find("name/en"), "")
			setText(arg_39_2:Find("select/name"), i18n("tec_catchup_" .. arg_39_1))
			setText(arg_39_2:Find("select/name/en"), "")
			onToggle(self, arg_39_2, function(arg_40_0)
				setActive(arg_39_2:Find("select"), arg_40_0)
				setCanvasGroupAlpha(arg_39_2, not arg_40_0 and self.finishPhaseDic[arg_39_1] and 0.5 or 1)

				arg_39_2:Find("tip").anchoredPosition = Vector2(arg_40_0 and -34.295 or 18, -2)

				setActive(arg_39_2:Find("name"), not arg_40_0)

				if arg_40_0 then
					self:SetTechDisplayPage(arg_39_1)
				end
			end, SFX_PANEL)
		end
	end)
	self:UpdateTechPageState()
	setActive(self.techPage:Find("page"), true)

	local var_38_2 = self.phaseId == "ready" and 0 or self.phaseId

	eachChild(var_38_0, function(arg_41_0, arg_41_1)
		triggerToggle(arg_41_0, arg_41_1 == var_38_2)
	end)
	self:ShowBottomTip(self.techPage, 1)
	onScroll(self, self.techPage:Find("subPageScroll"), function(arg_42_0)
		self:ShowBottomTip(self.techPage, arg_42_0.y)
	end)
end

function CommanderManualLayer:GetTechTask(arg_43_1, arg_43_2)
	local var_43_0 = Task.New({
		id = arg_43_1
	})

	if arg_43_2 then
		var_43_0.progress = var_43_0:getConfig("target_num")
		var_43_0.submitTime = 1
	end

	return var_43_0
end

function CommanderManualLayer:SetTechDisplayPage(arg_44_1)
	local var_44_0 = arg_44_1 == self.phaseId
	local var_44_1 = self.finishPhaseDic[arg_44_1]

	setActive(self.techPage:Find("page/lock_mask"), not (arg_44_1 == self.phaseId))

	local var_44_2, var_44_3 = unpack(self.techActivity:getConfig("config_data")[3][math.max(1, arg_44_1)])
	local var_44_4 = underscore.map(var_44_2, function(arg_45_0)
		return self.taskProxy:getTaskVO(arg_45_0) or self:GetTechTask(arg_45_0, var_44_0 or var_44_1)
	end)

	table.sort(var_44_4, CompareFuncs({
		function(arg_46_0)
			return arg_46_0:isReceive() and 1 or 0
		end,
		function(arg_47_0)
			return arg_47_0:isFinish() and 0 or 1
		end,
		function(arg_48_0)
			return arg_48_0.id
		end
	}))

	local var_44_5 = self.techPage:Find("page/scroll/Viewport/Content")

	UIItemList.StaticAlign(var_44_5, var_44_5:Find("tpl"), #var_44_4, function(arg_49_0, arg_49_1, arg_49_2)
		arg_49_1 = arg_49_1 + 1

		if arg_49_0 == UIItemList.EventUpdate then
			local var_49_0 = var_44_4[arg_49_1]

			setText(arg_49_2:Find("normal/number"), string.format("NO.%02d", arg_49_1))
			setText(arg_49_2:Find("normal/desc"), var_49_0:getConfig("desc"))

			local var_49_1 = arg_49_2:Find("normal/awards")

			self:updateTaskAwards(var_49_0:getConfig("award_display"), var_49_1, (var_49_1:GetChild(0)))

			local var_49_2 = arg_49_2:Find("normal/go_btn")
			local var_49_3 = arg_49_2:Find("normal/get_btn")
			local var_49_4 = arg_49_2:Find("normal/got_btn")
			local var_49_5 = arg_49_2:Find("normal/lock_btn")
			local var_49_6 = arg_49_2:Find("normal")
			local var_49_7 = arg_49_2:Find("lock")
			local var_49_8 = var_49_0:getConfig("target_num")
			local var_49_9 = math.min(var_49_0:getProgress(), var_49_8)

			setText(arg_49_2:Find("normal/progress"), var_49_9 .. "/" .. var_49_8)
			setSlider(arg_49_2:Find("normal/slider"), 0, var_49_8, var_49_9)

			if not var_44_0 and not var_44_1 then
				setActive(var_49_2, false)
				setActive(var_49_3, false)
				setActive(var_49_4, false)
				setActive(var_49_5, true)
			else
				local var_49_10 = var_49_0:getTaskStatus()

				setActive(var_49_2, var_49_10 == 0)
				setActive(var_49_3, var_49_10 == 1)
				setActive(var_49_4, var_49_10 == 2)
				setActive(var_49_5, false)
			end

			onButton(self, var_49_2, function()
				self:emit(CommanderManualMediator.ON_TASK_GO, var_49_0)
			end, SFX_PANEL)
			onButton(self, var_49_3, function()
				self:TaskAwardsCheckAndSubmit(var_49_0)
			end, SFX_PANEL)
			setActive(var_49_6, true)
			setActive(var_49_7, false)
			arg_49_2:GetComponent(typeof(Animation)):Play("anim_CommanderManualUI_tpl_update")
		end
	end)
	scrollTo(self.techPage:Find("page/scroll"), 0, 1)

	local var_44_6 = self.techPage:Find("page/ptPanel")
	local var_44_7

	if var_44_0 then
		var_44_7 = self.taskProxy:getTaskVO(var_44_3)
	elseif var_44_1 then
		var_44_7 = self:GetTechTask(var_44_3, var_44_1)
	end

	if var_44_7 then
		if var_44_7 and var_44_7:isClientTrigger() and not var_44_7:isFinish() then
			self:emit(CommanderManualMediator.ON_UPDATE, var_44_7)
		end

		local var_44_8 = var_44_7:getConfig("target_num")
		local var_44_9 = math.min(var_44_7:getProgress(), var_44_8)

		setText(var_44_6:Find("upgrade/progress/progress1"), var_44_9)
		setText(var_44_6:Find("upgrade/progress/progress2"), "/" .. var_44_8)
		setSlider(var_44_6:Find("slider"), 0, var_44_8, var_44_9)

		if var_44_9 == var_44_8 then
			var_44_6:Find("upgrade"):GetComponent(typeof(Animation)):Play("anim_CommanderManualUI_ptPanel_upgrade")
		end

		setText(var_44_6:Find("desc"), var_44_7:getConfig("desc"))

		local var_44_10 = var_44_6:Find("awards")

		self:updateTaskAwards(var_44_7:getConfig("award_display"), var_44_10, (var_44_10:GetChild(0)))

		local var_44_11 = var_44_6:Find("go_btn")
		local var_44_12 = var_44_6:Find("get_btn")
		local var_44_13 = var_44_6:Find("got_btn")
		local var_44_14 = var_44_7:getTaskStatus()

		setActive(var_44_11, var_44_14 == 0)
		setActive(var_44_12, var_44_14 == 1)
		setActive(var_44_13, var_44_14 == 2)
		setActive(var_44_6:Find("unlock_btn"), false)
		setActive(var_44_6:Find("wait_btn"), false)
		onButton(self, var_44_11, function()
			self:emit(CommanderManualMediator.ON_TASK_GO, var_44_7)
		end, SFX_PANEL)
		onButton(self, var_44_12, function()
			self:TaskAwardsCheckAndSubmit(var_44_7)
		end, SFX_PANEL)
	else
		local var_44_15 = #var_44_4
		local var_44_16 = var_44_0 and underscore.reduce(var_44_4, 0, function(arg_54_0, arg_54_1)
			return arg_54_0 + (arg_54_1:isReceive() and 1 or 0)
		end) or 0

		setText(var_44_6:Find("upgrade/progress/progress1"), var_44_16)
		setText(var_44_6:Find("upgrade/progress/progress2"), "/" .. var_44_15)
		setSlider(var_44_6:Find("slider"), 0, var_44_15, var_44_16)

		if var_44_16 == var_44_15 then
			var_44_6:Find("upgrade"):GetComponent(typeof(Animation)):Play("anim_CommanderManualUI_ptPanel_upgrade")
		end

		setText(var_44_6:Find("desc"), i18n("handbook_research_final_task_desc_locked", i18n("tec_catchup_" .. arg_44_1)))

		local var_44_17 = var_44_6:Find("awards")

		self:updateTaskAwards(pg.task_data_template[var_44_3].award_display, var_44_17, (var_44_17:GetChild(0)))
		setActive(var_44_6:Find("go_btn"), false)
		setActive(var_44_6:Find("get_btn"), false)
		setActive(var_44_6:Find("got_btn"), false)

		if var_44_15 <= var_44_16 then
			self:emit(CommanderManualMediator.ON_TRIGGER, {
				cmd = 2,
				activity_id = self.techActivity.id
			})
		end

		local var_44_18, var_44_19 = TechnologyConst.isTecActOn()
		local var_44_20 = self.techFinishTaskId
		local var_44_21

		if self.techFinishTaskId then
			var_44_20 = self.taskProxy:getTaskVO(self.techFinishTaskId)
			var_44_21 = not var_44_1 and not var_44_0
		end

		if self.phaseId == "ready" or var_44_18 and var_44_20 and var_44_20:isReceive() then
			::label_44_0::

			local var_44_22

			if arg_44_1 == 1 then
				var_44_22 = self.finishPhaseDic[0] or self.phaseId == 0
			end
		end

		local var_44_23 = var_44_6:Find("unlock_btn")
		local var_44_24 = var_44_6:Find("wait_btn")

		setText(var_44_23:Find("Text"), i18n("handbook_research_confirm", i18n("tec_catchup_" .. arg_44_1)))
		setText(var_44_24:Find("Text"), i18n("handbook_research_final_task_btn_locked"))
		setActive(var_44_23, var_44_21 and var_44_22)
		setActive(var_44_24, var_44_0 and var_44_16 < var_44_15)
		onButton(self, var_44_23, function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("tec_catchup_confirm"),
				onYes = function()
					if arg_44_1 == 1 then
						self:emit(CommanderManualMediator.ON_TRIGGER, {
							cmd = 3,
							activity_id = self.techActivity.id
						})
					else
						self:emit(CommanderManualMediator.ON_TRIGGER, {
							cmd = 1,
							activity_id = self.techActivity.id,
							arg1 = math.max(arg_44_1, 1)
						})
					end
				end
			})
		end, SFX_CONFIRM)
		onButton(self, var_44_24, function()
			pg.TipsMgr.GetInstance():ShowTips(i18n("handbook_research_final_task_desc_locked", i18n("tec_catchup_" .. arg_44_1)))
		end, SFX_CONFIRM)
	end
end

function CommanderManualLayer:UpdateTechPageState()
	local var_58_0, var_58_1 = TechnologyConst.isTecActOn()
	local var_58_2 = self.techFinishTaskId and self.taskProxy:getTaskVO(self.techFinishTaskId)
	local var_58_3 = self.phaseId == "ready" or var_58_0 and var_58_2 and var_58_2:isReceive()

	eachChild(self.techPage:Find("subPageScroll/Viewport/Content"), function(arg_59_0, arg_59_1)
		local var_59_0 = not self.finishPhaseDic[arg_59_1] and self.phaseId ~= arg_59_1
		local var_59_1 = var_58_3

		if var_58_3 then
			if arg_59_1 == 1 then
				var_59_1 = self.finishPhaseDic[0] or self.phaseId == 0
			end
		end

		setActive(arg_59_0:Find("name/lock"), false)
		setActive(arg_59_0:Find("select/bg"), not self.finishPhaseDic[arg_59_1])
		setActive(arg_59_0:Find("select/bg_end"), self.finishPhaseDic[arg_59_1])

		if var_59_1 then
			setActive(arg_59_0:Find("tip"), var_59_0)
		else
			setActive(arg_59_0:Find("tip"), arg_59_1 == self.phaseId and var_58_1)
		end
	end)
end

function CommanderManualLayer:ShowBottomTip(arg_60_1, arg_60_2)
	local var_60_0 = arg_60_1:Find("subPageScroll")
	local var_60_1 = var_60_0:GetComponent(typeof(ScrollRect))
	local var_60_2 = arg_60_1:Find("subPageScroll/Viewport/Content")
	local var_60_3 = var_60_2:GetComponent(typeof(VerticalLayoutGroup))
	local var_60_4 = var_60_2:GetChild(0).rect.height
	local var_60_5 = arg_60_1:Find("subPageScroll/Viewport").rect.height

	if var_60_0.padding.top + var_60_3.padding.bottom + var_60_4 * var_60_2.childCount + var_60_3.spacing * (var_60_2.childCount - 1) < var_60_5 + var_60_3.spacing + var_60_4 then
		setActive(arg_60_1:Find("bottomTip"), false)

		return
	end

	local var_60_6 = math.floor(var_60_5 / (var_60_4 + var_60_3.spacing))
	local var_60_7 = math.ceil((var_60_2.childCount - var_60_6) * (1 - arg_60_2) + var_60_6)

	if var_60_7 < var_60_6 then
		var_60_7 = var_60_6
	end

	if var_60_7 > var_60_2.childCount - 1 then
		setActive(arg_60_1:Find("bottomTip"), false)

		return
	end

	setActive(arg_60_1:Find("bottomTip"), false)

	for iter_60_0 = var_60_7, var_60_2.childCount - 1 do
		if isActive(var_60_2:GetChild(iter_60_0):Find("tip")) then
			setActive(arg_60_1:Find("bottomTip"), true)

			break
		end
	end
end

function CommanderManualLayer:TaskAwardsCheckAndSubmit(arg_61_1)
	local var_61_0 = {}
	local var_61_1 = arg_61_1:getConfig("award_display")
	local var_61_2 = getProxy(PlayerProxy):getRawData()
	local var_61_3, var_61_4 = Task.StaticJudgeOverflow(var_61_2.gold, var_61_2.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, var_61_1)

	if var_61_3 then
		table.insert(var_61_0, function(arg_62_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_ITEM_BOX,
				content = i18n("award_max_warning"),
				items = var_61_4,
				onYes = arg_62_0
			})
		end)
	end

	seriesAsync(var_61_0, function()
		self:emit(CommanderManualMediator.ON_TASK_SUBMIT, arg_61_1)
	end)
end

function CommanderManualLayer:PtAwardsCheckAndSubmit(arg_64_1)
	local var_64_0 = {}
	local var_64_1 = arg_64_1:GetCurrentPtAward()
	local var_64_2 = getProxy(PlayerProxy):getRawData()
	local var_64_3, var_64_4 = Task.StaticJudgeOverflow(var_64_2.gold, var_64_2.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, var_64_1)

	if var_64_3 then
		table.insert(var_64_0, function(arg_65_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_ITEM_BOX,
				content = i18n("award_max_warning"),
				items = var_64_4,
				onYes = arg_65_0
			})
		end)
	end

	seriesAsync(var_64_0, function()
		self:emit(CommanderManualMediator.GET_PT_AWARD, arg_64_1.id)
	end)
end

function CommanderManualLayer:willExit()
	self:UnOverlayPanel(self.blurPanel, self._tf)
end

function CommanderManualLayer:onBackPressed()
	self:closeView()
end

return CommanderManualLayer
