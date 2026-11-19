local DailyLevelScene = class("DailyLevelScene", import("..base.BaseUI"))
local var_0_3 = 101

function DailyLevelScene:getUIName()
	return "DailyLevelUI"
end

function DailyLevelScene:getResource()
	local var_2_0 = {
		"weaponframes",
		"cue/level.b"
	}
	local var_2_1 = {}

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not var_2_1[arg_3_0] then
			var_2_1[arg_3_0] = true

			table.insert(var_2_0, arg_3_0)
		end
	end

	for iter_2_0, iter_2_1 in ipairs(pg.expedition_daily_template.all or {}) do
		if pg.expedition_daily_template[iter_2_1] then
			var_2_2("dailyui/" .. pg.expedition_daily_template[iter_2_1].pic)

			for iter_2_2, iter_2_3 in ipairs(pg.expedition_daily_template[iter_2_1].expedition_and_lv_limit_list or {}) do
				if pg.expedition_data_template[iter_2_3[1]] then
					for iter_2_4, iter_2_5 in ipairs(pg.expedition_data_template[iter_2_3[1]].award_display or {}) do
						var_2_2(Drop.Create(iter_2_5):getIcon())
					end
				end
			end
		end
	end

	if self.bonusActivity and not self.bonusActivity:isEnd() then
		for iter_2_6, iter_2_7 in ipairs(self.bonusActivity:getConfig("config_data") or {}) do
			if iter_2_7[2] then
				var_2_2(Drop.Create(iter_2_7[2]):getIcon())
			end
		end
	end

	return table.insertto(var_2_0, DailyLevelScene.super.getResource(self))
end

function DailyLevelScene:ResUISettings()
	return true
end

function DailyLevelScene:init()
	self.blurPanel = self._tf:Find("blur_panel")
	self.topPanel = self._tf:Find("blur_panel/adapt/top")
	self.backBtn = self.topPanel:Find("back_btn")
	self.listPanel = self._tf:Find("list_panel")
	self.content = self.listPanel:Find("list")

	setActive(self.content, true)

	self.dailylevelTpl = self:getTpl("list_panel/list/captertpl")
	self.descPanel = self._tf:Find("desc_panel")
	self.selectedPanel = self.descPanel:Find("selected")
	self.descMain = self.descPanel:Find("main_mask/main")
	self.stageTpl = self:getTpl("scrollview/content/stagetpl", self.descMain)
	self.stageScrollRect = self.descMain:Find("scrollview"):GetComponent(typeof(ScrollRect))
	self.stageContain = self.descMain:Find("scrollview/content")
	self.arrows = self._tf:Find("arrows")
	self.itemTpl = self:getTpl("item_tpl")
	self.selStageTF = self.selectedPanel:Find("stagetpl/info")
	self.selQuicklyTF = self.selStageTF.parent:Find("quickly/bg")
	self.selQuicklyTFSizeDeltaY = self.selQuicklyTF.sizeDelta.y
	self.descChallengeNum = self.descMain:Find("challenge_count")
	self.descChallengeText = self.descChallengeNum:Find("Text")
	self.challengeQuotaDaily = self.descMain:Find("challenge_count/label")
	self.challengeQuotaWeekly = self.descMain:Find("challenge_count/week_label")
	self.fleetEditView = self._tf:Find("fleet_edit")
	self.resource = self._tf:Find("resource")
	self.rightBtn = self._tf:Find("arrows/arrow1")
	self.leftBtn = self._tf:Find("arrows/arrow2")

	self:initItems()
end

function DailyLevelScene.getWeek()
	return (pg.TimeMgr.GetInstance():GetServerWeek())
end

function DailyLevelScene:setDailyCounts(arg_7_1)
	self.dailyCounts = arg_7_1
end

function DailyLevelScene:setActivity(arg_8_1)
	self.bonusActivity = arg_8_1
end

function DailyLevelScene:setShips(arg_9_1)
	self.shipVOs = arg_9_1
end

function DailyLevelScene:updateRes(arg_10_1)
	self.player = arg_10_1
end

function DailyLevelScene:didEnter()
	onButton(self, self._tf:Find("help_btn"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_daily_task.tip
		})
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		if self.descMode then
			if LeanTween.isTweening(go(self.stageContain)) or LeanTween.isTweening(go(self.selQuicklyTF)) then
				return
			end

			self:enableDescMode(false)
		else
			self:emit(DailyLevelScene.ON_BACK)
		end
	end, SFX_CANCEL)
	onButton(self, self.leftBtn, function()
		self:flipToSpecificCard(self:getNextCardId(true))
	end)
	onButton(self, self.rightBtn, function()
		self:flipToSpecificCard(self:getNextCardId(false))
	end)
	self:displayDailyLevels()

	if self.contextData.dailyLevelId then
		self:tryOpenDesc(self.contextData.dailyLevelId)
	else
		self:enableDescMode(false)
	end

	self:tryPlayGuide()
	self:ShowGuildTaskTip()
end

function DailyLevelScene:initItems()
	local var_16_0 = getProxy(DailyLevelProxy)

	var_16_0:setDailyTip(false)

	self.dailyCounts = var_16_0:getRawData()
	self.dailyLevelTFs = {}
	self.dailyList = _.reverse(Clone(pg.expedition_daily_template.all))

	for iter_16_0 = #self.dailyList, 1, -1 do
		if pg.expedition_daily_template[self.dailyList[iter_16_0]].limit_period and type(pg.expedition_daily_template[self.dailyList[iter_16_0]].limit_period) == "table" then
			if not pg.TimeMgr.GetInstance():inTime(pg.expedition_daily_template[self.dailyList[iter_16_0]].limit_period) then
				table.remove(self.dailyList, iter_16_0)
			end
		elseif pg.expedition_daily_template[self.dailyList[iter_16_0]].insert_daily == 1 then
			table.remove(self.dailyList, iter_16_0)
		end
	end

	self:sortDailyList()
	self:updateShowCenter()

	if self.contextData.dailyLevelId then
		table.removebyvalue(self.dailyList, self.contextData.dailyLevelId)
		table.insert(self.dailyList, math.ceil(#pg.expedition_daily_template.all / 2), self.contextData.dailyLevelId)
	end

	for iter_16_1, iter_16_2 in pairs(self.dailyList) do
		self.dailyLevelTFs[iter_16_2] = cloneTplTo(self.dailylevelTpl, self.content, iter_16_2)
	end
end

function DailyLevelScene:sortDailyList()
	if #self.dailyList % 2 ~= 1 then
		table.insert(self.dailyList, var_0_3)
	end

	table.sort(self.dailyList, function(arg_18_0, arg_18_1)
		return tonumber(pg.expedition_daily_template[arg_18_0].sort) > tonumber(pg.expedition_daily_template[arg_18_1].sort)
	end)
end

function DailyLevelScene:updateShowCenter()
	local var_19_1
	local var_19_0

	if not self.dailyList or #self.dailyList == 0 then
		do return end

		var_19_0 = math.ceil(#self.dailyList / 2)
	end

	for iter_19_0 = 1, #self.dailyList do
		local var_19_2 = pg.expedition_daily_template[self.dailyList[iter_19_0]]

		if pg.expedition_daily_template[self.dailyList[iter_19_0]].show_with_count and var_19_2.show_with_count == 1 then
			if self.dailyCounts then
				if var_19_2.limit_time - (self.dailyCounts[var_19_2.id] or 0) > 0 then
					var_19_1 = var_19_1 or iter_19_0
				end
			end
		end
	end

	if var_19_1 then
		local var_19_4 = var_19_0 - var_19_1 < 0

		for iter_19_1 = 1, math.abs(var_19_0 - var_19_1) do
			if var_19_4 then
				table.insert(self.dailyList, (table.remove(self.dailyList, 1)))
			else
				table.insert(self.dailyList, 1, (table.remove(self.dailyList, #self.dailyList)))
			end
		end
	end
end

function DailyLevelScene:displayDailyLevels()
	for iter_20_0, iter_20_1 in pairs(self.dailyLevelTFs) do
		self:initDailyLevel(iter_20_0)
	end

	self.content:GetComponent(typeof(EnhancelScrollView)).onCenterClick = function(self)
		self:tryOpenDesc(tonumber(self.name))
	end
	self.centerAniItem = nil
	self.centerCardId = nil
	self.checkAniTimer = Timer.New(function()
		if not self.descMode then
			local var_22_0
			local var_22_1

			for iter_22_0, iter_22_1 in pairs(self.dailyLevelTFs) do
				GetComponent(iter_22_1, typeof(CanvasGroup)).alpha = 1

				if not var_22_0 and not var_22_1 then
					var_22_0 = iter_22_1
					var_22_1 = iter_22_1
				elseif iter_22_1.anchoredPosition.x < var_22_0.anchoredPosition.x then
					var_22_0 = iter_22_1
				elseif iter_22_1.anchoredPosition.x > var_22_1.anchoredPosition.x then
					var_22_1 = iter_22_1
				end
			end

			GetComponent(var_22_0, typeof(CanvasGroup)).alpha = 0.5
			GetComponent(var_22_1, typeof(CanvasGroup)).alpha = 0.5
		end

		for iter_22_2, iter_22_3 in pairs(self.dailyLevelTFs) do
			local var_22_2 = iter_22_3.localScale.x >= 0.98

			if self.centerAniItem == iter_22_3 and var_22_2 then
				return
			else
				if var_22_2 then
					self.centerAniItem = iter_22_3
					self.centerCardId = iter_22_2
				end

				local var_22_3 = iter_22_3:Find("icon/card")

				if var_22_3 then
					local var_22_4 = var_22_3:Find("mask/char"):GetComponent(typeof(Animator))

					setActive(var_22_3:Find("effect"), var_22_2)

					if var_22_4 then
						var_22_4.speed = var_22_2 and 1 or 0
					end
				end
			end
		end
	end, 0.1, -1)

	self.checkAniTimer:Start()
end

function DailyLevelScene:tryOpenDesc(arg_23_1)
	if table.contains(pg.expedition_daily_template[arg_23_1].weekday, tonumber(self:getWeek())) then
		self:openDailyDesc(arg_23_1)
	else
		pg.TipsMgr.GetInstance():ShowTips(pg.expedition_daily_template[arg_23_1].tips)
	end
end

function DailyLevelScene:CanOpenDailyLevel()
	return not not table.contains(pg.expedition_daily_template[self].weekday, tonumber(DailyLevelScene.getWeek())), pg.expedition_daily_template[self].tips
end

function DailyLevelScene:getNextCardId(arg_25_1)
	local var_25_0 = table.indexof(self.dailyList, self.centerCardId)

	if arg_25_1 then
		var_25_0 = var_25_0 - 1

		if var_25_0 <= 0 then
			var_25_0 = #self.dailyList or var_25_0
		end
	else
		var_25_0 = var_25_0 + 1
		var_25_0 = var_25_0 > #self.dailyList and 1 or var_25_0
	end

	return self.dailyList[var_25_0]
end

function DailyLevelScene:initDailyLevel(arg_26_1)
	local var_26_0 = pg.expedition_daily_template[arg_26_1]
	local var_26_1 = self.dailyLevelTFs[arg_26_1]
	local var_26_2 = table.contains(pg.expedition_daily_template[arg_26_1].weekday, tonumber(self:getWeek()))

	if var_26_2 then
		self.index = arg_26_1
	end

	setActive(findTF(var_26_1, "lock"), not var_26_2 and not table.isEmpty(var_26_0.weekday))
	setText(findTF(var_26_1, "name"), var_26_0.title)
	setActive(findTF(var_26_1, "time"), false)

	if self.bonusActivity and not self.bonusActivity:isEnd() then
		local var_26_3 = checkExist(underscore.detect(self.bonusActivity:getConfig("config_data"), function(arg_27_0)
			return arg_27_0[1] == arg_26_1
		end), {
			2
		})

		setText(var_26_1:Find("bonus/Text"), i18n("dailyLevel_bonus_activity"))
		setActive(var_26_1:Find("bonus"), tobool(var_26_3))

		if var_26_3 then
			updateDrop(var_26_1:Find("bonus/IconTpl"), Drop.Create(var_26_3))
		end
	else
		setActive(var_26_1:Find("bonus"), false)
	end

	local var_26_4 = findTF(var_26_1, "icon")

	PoolMgr.GetInstance():GetPrefab("dailyui/" .. var_26_0.pic, "", true, function(arg_28_0)
		arg_28_0 = tf(arg_28_0)

		arg_28_0:SetParent(var_26_4, false)

		arg_28_0.localPosition = Vector3.zero
		arg_28_0.name = "card"
	end)
	setText(findTF(var_26_1, "Text"), "")
	setActive(findTF(var_26_1, "lastTime"), false)

	local var_26_5 = Clone(var_26_0.limit_period)
	local var_26_6

	if var_26_5 and type(var_26_5) == "table" then
		if pg.TimeMgr.GetInstance():inTime(var_26_5) then
			var_26_6 = pg.TimeMgr.GetInstance():Table2ServerTime({
				year = var_26_5[2][1][1],
				month = var_26_5[2][1][2],
				day = var_26_5[2][1][3],
				hour = var_26_5[2][2][1],
				min = var_26_5[2][2][2],
				sec = var_26_5[2][2][3]
			}) - pg.TimeMgr.GetInstance():GetServerTime()
		end
	end

	if var_26_6 then
		local var_26_7 = ""
		local var_26_8 = ""

		if var_26_6 > 86400 then
			var_26_7 = math.floor(tonumber(var_26_6) / 86400)
			var_26_8 = i18n("word_date")
		elseif var_26_6 >= 3600 then
			var_26_7 = math.floor(tonumber(var_26_6) / 3600)
			var_26_8 = i18n("word_hour")
		elseif var_26_6 > 0 then
			var_26_7 = math.floor(tonumber(var_26_6) / 60)
			var_26_8 = i18n("word_minute")
		end

		setText(findTF(var_26_1, "lastTime/content/text"), tostring(var_26_7) .. " ")
		setText(findTF(var_26_1, "lastTime/content/word"), tostring(var_26_8))
		setActive(findTF(var_26_1, "lastTime"), true)
	end

	self:UpdateDailyLevelCnt(arg_26_1)
end

function DailyLevelScene:UpdateDailyLevelCnt(arg_29_1)
	local var_29_0 = pg.expedition_daily_template[arg_29_1]
	local var_29_1 = findTF(self.dailyLevelTFs[arg_29_1], "count")
	local var_29_2 = self.dailyCounts[arg_29_1] or 0

	if var_29_0.limit_time == 0 then
		setText(var_29_1, "N/A")
	else
		setText(var_29_1, string.format("%d/%d", var_29_0.limit_time - var_29_2, var_29_0.limit_time))
	end

	setActive(var_29_1, var_29_0.limit_time > 0)
end

function DailyLevelScene:openDailyDesc(arg_30_1)
	self.curId = arg_30_1

	self:enableDescMode(true)
	self:displayStageList(arg_30_1)
end

function DailyLevelScene:UpdateDailyLevelCntForDescPanel(arg_31_1)
	local var_31_0 = self.dailyCounts[arg_31_1] or 0

	if pg.expedition_daily_template[arg_31_1].limit_time == 0 then
		setText(self.descChallengeText, i18n("challenge_count_unlimit"))
	else
		setText(self.descChallengeText, string.format("%d/%d", pg.expedition_daily_template[arg_31_1].limit_time - var_31_0, pg.expedition_daily_template[arg_31_1].limit_time))
	end
end

function DailyLevelScene:displayStageList(arg_32_1)
	self.dailyLevelId = arg_32_1
	self.contextData.dailyLevelId = self.dailyLevelId

	local var_32_0 = pg.expedition_daily_template[arg_32_1]

	self:UpdateDailyLevelCntForDescPanel(arg_32_1)
	setActive(self.challengeQuotaDaily, var_32_0.limit_type == 1)
	setActive(self.challengeQuotaWeekly, var_32_0.limit_type == 2)
	removeAllChildren(self.stageContain)

	self.stageTFs = {}

	for iter_32_0, iter_32_1 in ipairs((_.sort(var_32_0.expedition_and_lv_limit_list, function(arg_33_0, arg_33_1)
		local var_33_0 = arg_33_0[2] <= self.player.level and 1 or 0
		local var_33_1 = arg_33_1[2] <= self.player.level and 1 or 0

		if arg_33_0[2] == arg_33_1[2] then
			return arg_33_0[1] < arg_33_1[1]
		end

		if var_33_0 == var_33_1 then
			if var_33_0 == 1 then
				return arg_33_0[2] > arg_33_1[2]
			else
				return arg_33_0[2] < arg_33_1[2]
			end
		else
			return var_33_1 < var_33_0
		end
	end))) do
		self.stageTFs[iter_32_1[1]] = cloneTplTo(self.stageTpl, self.stageContain)

		self:updateStage({
			id = iter_32_1[1],
			level = iter_32_1[2]
		})
	end
end

function DailyLevelScene:updateStageTF(arg_34_1, arg_34_2)
	local var_34_0 = pg.expedition_data_template[arg_34_2.id]

	setText(findTF(arg_34_1, "left_panel/name"), pg.expedition_data_template[arg_34_2.id].name)
	setText(findTF(arg_34_1, "left_panel/lv/Text"), "Lv." .. arg_34_2.level)

	local var_34_1 = arg_34_1:Find("mask")

	setActive(var_34_1, arg_34_2.level > self.player.level)

	if arg_34_2.level > self.player.level then
		setText(var_34_1:Find("msg/msg_contain/Text"), "Lv." .. arg_34_2.level .. " ")

		if PLATFORM_CODE == PLATFORM_US then
			var_34_1:Find("msg/msg_contain/Text"):SetAsLastSibling()
		end
	end

	local var_34_2 = UIItemList.New(arg_34_1:Find("scrollView/right_panel"), self.itemTpl)

	var_34_2:make(function(arg_35_0, arg_35_1, arg_35_2)
		if arg_35_0 == UIItemList.EventUpdate then
			updateDrop(arg_35_2, {
				type = var_34_0.award_display[arg_35_1 + 1][1],
				id = var_34_0.award_display[arg_35_1 + 1][2],
				count = var_34_0.award_display[arg_35_1 + 1][3]
			})
			setActive(arg_35_2, arg_35_1 <= 3)
		end
	end)
	var_34_2:align(#var_34_0.award_display)
	setImageSprite(arg_34_1, getImageSprite(findTF(self.resource, "normal_bg")))
	setActive(findTF(arg_34_1, "score"), false)
	onButton(self, var_34_1, function()
		pg.TipsMgr.GetInstance():ShowTips(i18n("dailyLevel_unopened"))
	end, SFX_PANEL)
end

function DailyLevelScene:updateStage(arg_37_1)
	local var_37_0 = self.stageTFs[arg_37_1.id]:Find("info")

	self:updateStageTF(var_37_0, arg_37_1)
	onButton(self, var_37_0, function()
		if getProxy(DailyLevelProxy):CanQuickBattle(arg_37_1.id) then
			if (self.dailyCounts[self.dailyLevelId] or 0) >= pg.expedition_daily_template[self.dailyLevelId].limit_time then
				pg.TipsMgr.GetInstance():ShowTips(i18n("dailyLevel_restCount_notEnough"))

				return
			end

			if LeanTween.isTweening(go(self.descMain)) or LeanTween.isTweening(go(self.listPanel)) then
				return
			end

			self:OnSelectStage(arg_37_1)
		else
			self:OnOpenPreCombat(arg_37_1)
		end
	end, SFX_PANEL)
end

function DailyLevelScene:OnOpenPreCombat(arg_39_1)
	if (self.dailyCounts[self.dailyLevelId] or 0) >= pg.expedition_daily_template[self.dailyLevelId].limit_time then
		pg.TipsMgr.GetInstance():ShowTips(i18n("dailyLevel_restCount_notEnough"))

		return
	end

	setActive(self.blurPanel, false)
	self:emit(DailyLevelMediator.ON_STAGE, arg_39_1)
end

function DailyLevelScene:OnSelectStage(arg_40_1)
	onButton(self, self.selectedPanel:Find("stagetpl/info"), function()
		self:EnableOrDisable(arg_40_1, false)
	end, SFX_PANEL)
	onButton(self, self.selectedPanel, function()
		self:EnableOrDisable(arg_40_1, false)
	end, SFX_PANEL)
	self:EnableOrDisable(arg_40_1, true)
end

function DailyLevelScene:EnableOrDisable(arg_43_1, arg_43_2)
	local var_43_0 = self.stageTFs[arg_43_1.id]:Find("quickly")

	if LeanTween.isTweening(go(self.stageContain)) or LeanTween.isTweening(go(self.selQuicklyTF)) then
		return
	end

	if arg_43_2 then
		self:updateStageTF(self.selStageTF, arg_43_1)
		self:UpdateBattleBtn(arg_43_1)
		self:DoSelectedAnimation(var_43_0, -1 * self.stageContain:GetComponent(typeof(VerticalLayoutGroup)).padding.top - self.stageContain.parent:InverseTransformPoint(var_43_0.parent.position).y, function()
			self.selectedStage = arg_43_1
		end)
	else
		self:DoUnselectAnimtion(var_43_0, function()
			self.selectedStage = nil
		end)
	end
end

function DailyLevelScene:DoSelectedAnimation(arg_46_1, arg_46_2, arg_46_3)
	local var_46_0 = math.abs(arg_46_2) / 2000

	seriesAsync({
		function(arg_47_0)
			self.stageScrollRect.enabled = false

			pg.UIMgr.GetInstance():BlurPanel(self.selectedPanel)

			arg_46_1.sizeDelta = Vector2(arg_46_1.sizeDelta.x, 0)

			setActive(arg_46_1, true)

			local var_47_0 = self.stageContain.anchoredPosition

			self.stageContainLposY = self.stageContain.anchoredPosition.y
			self.offsetY = arg_46_2

			LeanTween.value(go(self.stageContain), self.stageContain.anchoredPosition.y, self.stageContain.anchoredPosition.y + arg_46_2, var_46_0):setOnUpdate(System.Action_float(function(arg_48_0)
				self.stageContain.anchoredPosition = Vector3(var_47_0.x, arg_48_0, 0)

				local var_48_0 = self.selectedPanel:InverseTransformPoint(arg_46_1.parent.position)

				self.selStageTF.parent.localPosition = Vector3(var_48_0.x, var_48_0.y, 0)
				self.selQuicklyTF.sizeDelta = Vector2(self.selQuicklyTF.sizeDelta.x, 0)

				setActive(self.selectedPanel, true)
			end)):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(arg_47_0))
		end,
		function(arg_49_0)
			local var_49_0 = arg_46_1:GetComponent(typeof(LayoutElement))

			LeanTween.value(go(self.selQuicklyTF), 0, self.selQuicklyTFSizeDeltaY, 0.1):setOnUpdate(System.Action_float(function(arg_50_0)
				var_49_0.preferredHeight = arg_50_0
				self.selQuicklyTF.sizeDelta = Vector2(self.selQuicklyTF.sizeDelta.x, arg_50_0)
			end)):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(arg_49_0))
		end
	}, arg_46_3)
end

function DailyLevelScene:DoUnselectAnimtion(arg_51_1, arg_51_2)
	local var_51_0 = self.stageContain.anchoredPosition

	seriesAsync({
		function(arg_52_0)
			pg.UIMgr.GetInstance():UnOverlayPanel(self.selectedPanel, self._tf)
			setActive(self.selectedPanel, false)

			local var_52_0 = arg_51_1:GetComponent(typeof(LayoutElement))

			LeanTween.value(go(self.selQuicklyTF), self.selQuicklyTFSizeDeltaY, 0, 0.1):setOnUpdate(System.Action_float(function(arg_53_0)
				var_52_0.preferredHeight = arg_53_0
				self.selQuicklyTF.sizeDelta = Vector2(self.selQuicklyTF.sizeDelta.x, arg_53_0)
			end)):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(arg_52_0))
		end,
		function(arg_54_0)
			LeanTween.value(go(self.stageContain), var_51_0.y, var_51_0.y - self.offsetY, 0.15):setOnUpdate(System.Action_float(function(arg_55_0)
				self.stageContain.anchoredPosition = Vector3(var_51_0.x, arg_55_0, 0)
			end)):setDelay(0.1):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(arg_54_0))
		end
	}, function()
		self.stageScrollRect.enabled = true

		arg_51_2()
	end)
end

function DailyLevelScene:UpdateBattleBtn(arg_57_1)
	local var_57_0 = self.selectedPanel:Find("stagetpl/info").parent:Find("quickly/bg")
	local var_57_1 = pg.expedition_daily_template[self.dailyLevelId].limit_time - (self.dailyCounts[self.dailyLevelId] or 0)
	local var_57_2 = var_57_0:Find("challenge")

	onButton(self, var_57_2, function()
		self:OnOpenPreCombat(arg_57_1)
	end, SFX_PANEL)
	setText(var_57_2:Find("Text"), i18n("daily_level_quick_battle_label2"))

	local var_57_3 = var_57_0:Find("mult")

	onButton(self, var_57_3, function()
		self:OnQuickBattle(arg_57_1, var_57_1)
	end, SFX_PANEL)

	local var_57_4 = var_57_0:Find("once")

	onButton(self, var_57_4, function()
		self:OnQuickBattle(arg_57_1, 1)
	end, SFX_PANEL)
	setText(var_57_3:Find("label"), i18n("daily_level_quick_battle_label1", "   ", COLOR_WHITE))
	setText(var_57_3:Find("Text"), "<color=" .. COLOR_GREEN .. ">" .. math.max(1, var_57_1) .. "</color>")
	setText(var_57_4:Find("label"), i18n("daily_level_quick_battle_label3"))
	setText(var_57_4:Find("Text"), "")

	if var_57_1 == 0 then
		self:EnableOrDisable(arg_57_1, false)
	end
end

function DailyLevelScene:OnQuickBattle(arg_61_1, arg_61_2)
	if arg_61_2 <= 0 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("dailyLevel_restCount_notEnough"))

		return
	end

	if PlayerPrefs.GetInt("daily_level_quick_battle_tip", 0) == 0 then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("dailyLevel_quickfinish"),
			onYes = function()
				self:emit(DailyLevelMediator.ON_QUICK_BATTLE, self.dailyLevelId, arg_61_1.id, arg_61_2)
			end
		})
		PlayerPrefs.SetInt("daily_level_quick_battle_tip", 1)
		PlayerPrefs.Save()
	else
		self:emit(DailyLevelMediator.ON_QUICK_BATTLE, self.dailyLevelId, arg_61_1.id, arg_61_2)
	end
end

function DailyLevelScene:enableDescMode(arg_63_1, arg_63_2)
	self.descMode = arg_63_1

	setActive(self._tf:Find("help_btn"), not arg_63_1)

	local function var_63_0(arg_64_0, arg_64_1, arg_64_2)
		if LeanTween.isTweening(go(arg_64_0)) then
			LeanTween.cancel(go(arg_64_0))
		end

		LeanTween.moveX(rtf(arg_64_0), arg_64_1, 0.3):setEase(LeanTweenType.linear):setOnComplete(System.Action(function()
			if arg_64_2 then
				arg_64_2()
			end
		end))
	end

	local function var_63_1()
		for iter_66_0, iter_66_1 in pairs(self.dailyLevelTFs) do
			setButtonEnabled(iter_66_1, not arg_63_1)

			if iter_66_0 ~= self.curId then
				if LeanTween.isTweening(go(iter_66_1)) then
					LeanTween.cancel(go(iter_66_1))
				end

				local var_66_0 = GetComponent(iter_66_1, typeof(CanvasGroup))

				if arg_63_1 then
					LeanTween.value(go(iter_66_1), 1, 0, 0.3):setOnUpdate(System.Action_float(function(arg_67_0)
						var_66_0.alpha = arg_67_0
					end))
				else
					LeanTween.value(go(iter_66_1), 0, 1, 0.3):setOnUpdate(System.Action_float(function(arg_68_0)
						var_66_0.alpha = arg_68_0
					end))
				end
			end
		end
	end

	local function var_63_2()
		setActive(self.listPanel, true)
		setActive(self.content, true)
		setActive(self.descPanel, arg_63_1)
		setActive(self.arrows, not arg_63_1)
	end

	if arg_63_1 then
		var_63_2()
		var_63_1()
		var_63_0(self.listPanel, -622, function()
			var_63_0(self.descMain, 0, arg_63_2)
		end)
	else
		if self.selectedStage then
			self:EnableOrDisable(self.selectedStage, false)
		end

		var_63_2()
		var_63_1()
		var_63_0(self.listPanel, 0)
		var_63_0(self.descMain, -1342, arg_63_2)
	end
end

function DailyLevelScene:flipToSpecificCard(arg_71_1)
	local var_71_0 = self.content:GetComponent(typeof(EnhancelScrollView))

	for iter_71_0, iter_71_1 in pairs(self.dailyLevelTFs) do
		if arg_71_1 == iter_71_0 then
			var_71_0:SetHorizontalTargetItemIndex(iter_71_1:GetComponent(typeof(EnhanceItem)).scrollViewItemIndex)
		end
	end
end

function DailyLevelScene:tryPlayGuide()
	pg.SystemGuideMgr.GetInstance():PlayDailyLevel(function()
		triggerButton(self._tf:Find("help_btn"))
	end)
end

function DailyLevelScene:ShowGuildTaskTip()
	pg.GuildMsgBoxMgr.GetInstance():NotificationForDailyBattle()
end

function DailyLevelScene:clearTween()
	if self.tweens then
		cancelTweens(self.tweens)
	end

	local function var_75_0(arg_76_0)
		if LeanTween.isTweening(go(arg_76_0)) then
			LeanTween.cancel(go(arg_76_0))
		end
	end

	for iter_75_0, iter_75_1 in pairs(self.dailyLevelTFs) do
		var_75_0(iter_75_1)
	end

	var_75_0(self.listPanel)
	var_75_0(self.descMain)
end

function DailyLevelScene:onBackPressed()
	if self.descMode then
		if LeanTween.isTweening(go(self.stageContain)) or LeanTween.isTweening(go(self.selQuicklyTF)) then
			return
		end

		self:enableDescMode(false)

		return
	end

	DailyLevelScene.super.onBackPressed(self)
end

function DailyLevelScene:willExit()
	if self.selectedStage then
		pg.UIMgr.GetInstance():UnOverlayPanel(self.selectedPanel, self._tf)
	end

	self:clearTween()

	if self.checkAniTimer then
		self.checkAniTimer:Stop()

		self.checkAniTimer = nil
	end
end

return DailyLevelScene
