local LimitChallengeScene = class("LimitChallengeScene", import("..base.BaseUI"))
local var_0_1 = LimitChallengeConst

function LimitChallengeScene:getUIName()
	return "LimitChallengeUI"
end

function LimitChallengeScene:getResource()
	local var_2_0 = {
		"weaponframes"
	}

	table.insertto(var_2_0, self:getLimitChallengeResList())

	return table.insertto(var_2_0, LimitChallengeScene.super.getResource(self))
end

function LimitChallengeScene:getLimitChallengeResList()
	local var_3_0 = {}
	local var_3_1 = pg.constellation_challenge_month and var_0_1.GetCurMonthConfig()

	if not var_3_1 then
		return var_3_0
	end

	for iter_3_0, iter_3_1 in ipairs(var_3_1.stage or {}) do
		if pg.expedition_constellation_challenge_template[iter_3_1] then
			table.insert(var_3_0, "limitchallenge/boss/" .. pg.expedition_constellation_challenge_template[iter_3_1].painting)
			table.insert(var_3_0, "limitchallenge/name/" .. pg.expedition_constellation_challenge_template[iter_3_1].information_icon)
			table.insert(var_3_0, "limitchallenge/btn/" .. pg.expedition_constellation_challenge_template[iter_3_1].button_style .. "_btn_start")

			for iter_3_2 = 1, 3 do
				table.insert(var_3_0, "limitchallenge/btn/" .. string.format("%d_level_%d_selected", pg.expedition_constellation_challenge_template[iter_3_1].button_style, iter_3_2))
			end

			for iter_3_3, iter_3_4 in ipairs(pg.expedition_constellation_challenge_template[iter_3_1].description or {}) do
				if iter_3_4 then
					table.insert(var_3_0, (self:getBuffIconPath(iter_3_1, iter_3_3)))
				end
			end

			table.insertto(var_3_0, self:getAwardResList(pg.expedition_constellation_challenge_template[iter_3_1].award_display and pg.expedition_constellation_challenge_template[iter_3_1].award_display[1]))
		end
	end

	return var_3_0
end

function LimitChallengeScene:getAwardResList(arg_4_1)
	local var_4_0 = {}

	if not arg_4_1 or #arg_4_1 == 0 then
		return var_4_0
	end

	local var_4_1 = arg_4_1[1]

	if arg_4_1[1] == DROP_TYPE_ICON_FRAME then
		table.insert(var_4_0, "Props/icon_frame")
	elseif var_4_1 == DROP_TYPE_CHAT_FRAME then
		table.insert(var_4_0, "Props/chat_frame")
	end

	return var_4_0
end

function LimitChallengeScene:init()
	self:initData()
	self:findUI()
	self:addListener()
end

function LimitChallengeScene:didEnter()
	var_0_1.SetRedPointMonth()
	self:updateLeftTime()
	self:updateToggleList()
	self:trigeHigestUnlockLevel()
end

function LimitChallengeScene:onBackPressed()
	self:closeView()
end

function LimitChallengeScene:willExit()
	if self.leftTimer then
		self.leftTimer:Stop()

		self.leftTimer = nil
	end
end

function LimitChallengeScene:initData()
	self.proxy = getProxy(LimitChallengeProxy)
	self.levelList = {
		1,
		2,
		3
	}
	self.curMonth = var_0_1.GetCurMonth()
	self.descList = {}
	self.nextMonthTS = LimitChallengeConst.GetNextMonthTS()
	self.curLevel = 0
end

function LimitChallengeScene:findUI()
	self.blurPanel = self._tf:Find("blur_panel")
	self.homeBtn = self.blurPanel:Find("adapt/top/option")
	self.backBtn = self.blurPanel:Find("adapt/top/back_button")
	self.helpBtn = self.blurPanel:Find("adapt/top/HelpBtn")
	self.shareBtn = self.blurPanel:Find("adapt/top/ShareBtn")
	self.levelPanel = self._tf:Find("Adapt/LevelPanel")
	self.levelToggleList = {}
	self.levelToggleLockList = {}

	for iter_10_0, iter_10_1 in ipairs(self.levelList) do
		local var_10_0 = self.levelPanel:Find("Level_" .. iter_10_1)
		local var_10_1 = var_10_0:Find("Lock")

		self.levelToggleList[iter_10_1] = var_10_0:Find("Toggle")
		self.levelToggleLockList[iter_10_1] = var_10_1
	end

	self.timePanel = self._tf:Find("Adapt/TimePanel")

	local var_10_2 = self.timePanel:Find("Left/LeftTime")

	self.leftTipText = var_10_2:Find("LeftTip")
	self.leftDayTipText = var_10_2:Find("DayTip")
	self.leftDayValueText = var_10_2:Find("DayValue")
	self.leftTimeValueText = var_10_2:Find("TimeValue")
	self.passTimeValueText = self.timePanel:Find("Challenge/Value")

	setText(self.leftTipText, i18n("time_remaining_tip"))
	setText(self.leftDayTipText, i18n("word_date"))

	self.iconContainer = self._tf:Find("Adapt/DescPanel/ScrollView/Viewport/Container")
	self.iconTpl = self._tf:Find("Adapt/DescPanel/IconTpl")

	local var_10_3 = self._tf:Find("Adapt/Award")

	self.awardIconTF = var_10_3:Find("IconTpl")
	self.awardGotTF = var_10_3:Find("Got")
	self.startBtn = self._tf:Find("Adapt/StartBtn")
	self.bgImg = self._tf:Find("BG")
	self.nameImg = self.timePanel:Find("Left")
	self.debugPanel = self._tf:Find("Adapt/Debug")
	self.debugText = self.debugPanel:Find("Text")
end

function LimitChallengeScene:addListener()
	onButton(self, self.homeBtn, function()
		self:emit(BaseUI.ON_HOME)
	end, SFX_PANEL)
	print("-----------", tostring(self.backBtn))
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.challenge_help.tip
		})
	end, SFX_PANEL)
	onButton(self, self.shareBtn, function()
		pg.ShareMgr.GetInstance():Share(pg.ShareMgr.TypeChallenge)
	end, SFX_PANEL)

	for iter_11_0, iter_11_1 in ipairs(self.levelToggleList) do
		onToggle(self, iter_11_1, function()
			self.curLevel = iter_11_0

			self:updatePassTime()
			self:updateAward()
			self:updateDescPanel()
			self:updateBossImg()
			self:updateDebug()
		end, SFX_CONFIRM, SFX_CANCEL)
	end

	onButton(self, self.startBtn, function()
		self:emit(var_0_1.OPEN_PRE_COMBAT_LAYER, {
			stageID = var_0_1.GetStageIDByLevel(self.curLevel)
		})
	end, SFX_PANEL)

	self.iconUIItemList = UIItemList.New(self.iconContainer, self.iconTpl)

	self.iconUIItemList:make(function(arg_18_0, arg_18_1, arg_18_2)
		if arg_18_0 == UIItemList.EventUpdate then
			local var_18_0 = arg_18_2:Find("Icon")

			arg_18_1 = arg_18_1 + 1

			if self.descList[arg_18_1] ~= false then
				local var_18_1, var_18_2 = self:getBuffIconPath(var_0_1.GetChallengeIDByLevel(self.curLevel), arg_18_1)

				setImageSprite(var_18_0, LoadSprite(var_18_1, var_18_2))

				local var_18_3 = self.descList[arg_18_1][1]
				local var_18_4 = self.descList[arg_18_1][2]
				local var_18_5 = {}

				table.insert(var_18_5, {
					info = self.descList[arg_18_1][1]
				})
				table.insert(var_18_5, {
					info = self.descList[arg_18_1][2]
				})
				onButton(self, var_18_0, function()
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						hideNo = true,
						type = MSGBOX_TYPE_DROP_ITEM,
						name = var_18_3,
						content = var_18_4,
						iconPath = {
							var_18_1,
							var_18_2
						}
					})
				end, SFX_PANEL)
			end
		end
	end)
end

function LimitChallengeScene:updateDebug()
	local var_20_0 = string.format(" 月份: %s \n 选择难度: %s \n 选择挑战ID: %s \n 选择关卡ID: %s \n", tostring(self.curMonth), tostring(self.curLevel), tostring((var_0_1.GetChallengeIDByLevel(self.curLevel))), tostring((var_0_1.GetStageIDByLevel(self.curLevel))))

	for iter_20_0, iter_20_1 in ipairs(self.levelList) do
		var_20_0 = var_20_0 .. " 难度" .. iter_20_1 .. "奖励:" .. (self.proxy:isAwardedByChallengeID((LimitChallengeConst.GetChallengeIDByLevel(iter_20_1))) and "已领取" or "未领取") .. "\n"
	end

	for iter_20_2, iter_20_3 in ipairs(self.levelList) do
		local var_20_1 = self.proxy:getPassTimeByChallengeID((LimitChallengeConst.GetChallengeIDByLevel(iter_20_3)))

		var_20_0 = var_20_0 .. " 难度" .. iter_20_3 .. "时间:" .. (var_20_1 and var_20_1 or "没有记录") .. "\n"
	end

	setText(self.debugText, var_20_0)
end

function LimitChallengeScene:updateToggleList()
	local var_21_0 = self:getHigestUnlockLevel()

	for iter_21_0, iter_21_1 in ipairs(self.levelToggleLockList) do
		local var_21_1 = var_21_0 < iter_21_0

		setActive(iter_21_1, var_21_0 < iter_21_0)
		setActive(self.levelToggleList[iter_21_0], not var_21_1)
	end
end

function LimitChallengeScene:updateLeftTime()
	if self.leftTimer then
		self.leftTimer:Stop()

		self.leftTimer = nil
	end

	local var_22_0 = pg.TimeMgr.GetInstance()
	local var_22_1 = self.nextMonthTS - var_22_0:GetServerTime()

	if var_22_0 > 0 then
		if self.leftTimer then
			self.leftTimer:Stop()

			self.leftTimer = nil
		end

		local function var_22_2()
			if var_22_1 <= 0 and self.leftTimer then
				self.leftTimer:Stop()

				self.leftTimer = nil
			end

			local var_23_0, var_23_1, var_23_2, var_23_3 = pg.TimeMgr.GetInstance():parseTimeFrom(var_22_1)

			setText(self.leftDayValueText, var_23_0)
			setText(self.leftTimeValueText, string.format("%02d:%02d:%02d", var_23_1, var_23_2, var_23_3))

			var_22_1 = var_22_1 - 1
		end

		self.leftTimer = Timer.New(var_22_2, 1, -1)

		self.leftTimer:Start()
		var_22_2()
	end
end

function LimitChallengeScene:updateBossImg()
	local var_24_0 = pg.expedition_constellation_challenge_template[var_0_1.GetChallengeIDByLevel(self.curLevel)]

	setImageSprite(self.bgImg, LoadSprite("limitchallenge/boss/" .. var_24_0.painting, var_24_0.painting))
	setImageSprite(self.nameImg, LoadSprite("limitchallenge/name/" .. var_24_0.information_icon, var_24_0.information_icon), true)
	setImageSprite(self.startBtn, LoadSprite("limitchallenge/btn/" .. var_24_0.button_style .. "_btn_start", var_24_0.button_style .. "_btn_start"), true)

	for iter_24_0, iter_24_1 in ipairs(self.levelList) do
		local var_24_1 = string.format("%d_level_%d_selected", var_24_0.button_style, iter_24_1)

		setImageSprite(self.levelToggleList[iter_24_1]:Find("Selected"), LoadSprite("limitchallenge/btn/" .. var_24_1, var_24_1), true)
	end
end

function LimitChallengeScene:updateDescPanel()
	self.descList = {}
	self.descList = pg.expedition_constellation_challenge_template[var_0_1.GetChallengeIDByLevel(self.curLevel)].description

	if 3 - #self.descList > 0 then
		for iter_25_0 = 1, 3 - #self.descList do
			table.insert(self.descList, false)
		end
	end

	self.iconUIItemList:align(#self.descList)
end

function LimitChallengeScene:updatePassTime()
	local var_26_0 = self.proxy:getPassTimeByChallengeID((LimitChallengeConst.GetChallengeIDByLevel(self.curLevel))) or 0

	setText(self.passTimeValueText, (string.format("%02d:%02d", math.floor(var_26_0 / 60), (math.floor(var_26_0 % 60)))))
end

function LimitChallengeScene:updateAward()
	local var_27_0 = LimitChallengeConst.GetChallengeIDByLevel(self.curLevel)

	setActive(self.awardGotTF, (self.proxy:isAwardedByChallengeID(var_27_0)))

	if pg.expedition_constellation_challenge_template[var_27_0].award_display[1] and #pg.expedition_constellation_challenge_template[var_27_0].award_display[1] > 0 then
		local var_27_1 = {
			type = pg.expedition_constellation_challenge_template[var_27_0].award_display[1][1],
			id = pg.expedition_constellation_challenge_template[var_27_0].award_display[1][2]
		}

		var_27_1.count = pg.expedition_constellation_challenge_template[var_27_0].award_display[1][3] or 1

		updateDrop(self.awardIconTF, var_27_1)
		onButton(self, self.awardIconTF, function()
			self:emit(BaseUI.ON_DROP, var_27_1)
		end, SFX_PANEL)
		setActive(self.awardIconTF, true)
	else
		setActive(self.awardIconTF, false)
	end
end

function LimitChallengeScene:trigeHigestUnlockLevel()
	triggerToggle(self.levelToggleList[self:getHigestUnlockLevel()], true)
end

function LimitChallengeScene:onReqInfo()
	self:initData()
	self:updateLeftTime()
	self:updateToggleList()
	self:trigeHigestUnlockLevel()
end

function LimitChallengeScene:getHigestUnlockLevel()
	for iter_31_0 = #self.levelList, 1, -1 do
		if self.proxy:isLevelUnlock(self.levelList[iter_31_0]) then
			return self.levelList[iter_31_0]
		end
	end
end

function LimitChallengeScene:getBuffIconPath(arg_32_1, arg_32_2)
	local var_32_0 = string.format("%s_%d", pg.expedition_constellation_challenge_template[arg_32_1].painting, arg_32_2)

	return "limitchallenge/icon/" .. var_32_0, var_32_0
end

return LimitChallengeScene
