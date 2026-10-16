local PtAwardWindow = class("PtAwardWindow")

function PtAwardWindow:Ctor(arg_1_1, arg_1_2)
	self._tf = arg_1_1
	self.binder = arg_1_2
	self.scrollPanel = self._tf:Find("window/panel")
	self.UIlist = UIItemList.New(self._tf:Find("window/panel/list"), self._tf:Find("window/panel/list/item"))
	self.ptTF = self._tf:Find("window/pt")
	self.totalTxt = self._tf:Find("window/pt/Text"):GetComponent(typeof(Text))
	self.totalTitleTxt = self._tf:Find("window/pt/title"):GetComponent(typeof(Text))
	self.totalTitleIcon = self._tf:Find("window/pt/icon/image"):GetComponent(typeof(Image))
	self.closeBtn = self._tf:Find("window/top/btnBack")
	self.ptIcon = self._tf:Find("window/pt/icon")
	self.getBtn = self._tf:Find("window/btn_get")

	onButton(self.binder, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self.binder, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self.binder, self.getBtn, function()
		if not self.ptData or self.ptData:GetMaxAvailableTargetIndex() == self.ptData:GetLevel() then
			return
		end

		local var_4_0 = {}
		local var_4_1 = getProxy(PlayerProxy):getRawData()
		local var_4_3, var_4_4 = Task.StaticJudgeOverflow(var_4_1.gold, var_4_1.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, (self.ptData:GetAllAvailableAwards()))

		if var_4_3 then
			table.insert(var_4_0, function(arg_5_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_ITEM_BOX,
					content = i18n("award_max_warning"),
					items = var_4_4,
					onYes = arg_5_0
				})
			end)
		end

		seriesAsync(var_4_0, function()
			self.binder:emit(ActivityMediator.EVENT_PT_OPERATION, {
				cmd = 4,
				activity_id = self.ptData:GetId(),
				arg1 = self.ptData:GetCurrTarget(),
				callback = function()
					self:Refresh()
				end
			})
		end)
	end, SFX_PANEL)
end

function PtAwardWindow:UpdateList(arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	assert(#arg_8_1 == #arg_8_2)
	self.UIlist:make(function(arg_9_0, arg_9_1, arg_9_2)
		if arg_9_0 == UIItemList.EventUpdate then
			local var_9_0 = GetPerceptualSize(self.resTitle)

			setText(arg_9_2:Find("title/Text"), "PHASE " .. arg_9_1 + 1)
			setText(arg_9_2:Find("target/Text"), arg_8_2[arg_9_1 + 1])

			if arg_9_2:Find("target/icon") then
				if self.resIcon == "" then
					self.resIcon = nil
				end

				if self.resIcon then
					LoadImageSpriteAsync(self.resIcon, arg_9_2:Find("target/icon"), false)
				end

				setActive(arg_9_2:Find("target/icon"), self.resIcon)
				setActive(arg_9_2:Find("target/mark"), self.resIcon)
			end

			setText(arg_9_2:Find("target/title"), self.resTitle)

			local var_9_1 = Drop.Create(arg_8_1[arg_9_1 + 1])

			updateDrop(arg_9_2:Find("award"), var_9_1, {
				hideName = true
			})
			onButton(self.binder, arg_9_2:Find("award"), function()
				self.binder:emit(BaseUI.ON_DROP, var_9_1)
			end, SFX_PANEL)
			setActive(arg_9_2:Find("award/mask"), arg_9_1 + 1 <= arg_8_3)

			if not IsNil(arg_9_2:Find("mask")) then
				if arg_8_4 then
					local var_9_2 = pg.TimeMgr.GetInstance()
					local var_9_3 = arg_8_4[arg_9_1 + 1]

					setActive(arg_9_2:Find("mask"), arg_8_4[arg_9_1 + 1] > var_9_2:GetServerTime())
					setText(arg_9_2:Find("mask/Text"), i18n("unlock_date_tip", var_9_2:STimeDescS(var_9_3, "%m"), (var_9_2:STimeDescS(var_9_3, "%d"))))
				else
					setActive(arg_9_2:Find("mask"), false)
				end
			end
		end
	end)
	self.UIlist:align(#arg_8_1)
	scrollTo(self.scrollPanel, 0, 1 - arg_8_3 * 166 / (#arg_8_2 * 166 + 20 - 570))
end

function PtAwardWindow:Show(arg_11_1)
	self.blur = arg_11_1.blur
	self.ptActId = arg_11_1.ptActId
	self.resIcon = nil

	self:UpdateTitle(arg_11_1.type)
	self:updateResIcon(arg_11_1.resDrop, arg_11_1.type)
	self:UpdateList(arg_11_1.dropList, arg_11_1.targets, arg_11_1.level, arg_11_1.unlockStamps)

	self.totalTxt.text = arg_11_1.count
	self.totalTitleTxt.text = self.cntTitle

	Canvas.ForceUpdateCanvases()
	setActive(self._tf, true)

	if self.blur then
		pg.UIMgr.GetInstance():BlurPanel(self._tf)
	end

	self:Refresh()
end

function PtAwardWindow:UpdateTitle(arg_12_1)
	local var_12_0 = ""

	switch(arg_12_1, {
		function()
			self.resTitle, self.cntTitle = i18n("target_get_tip"), i18n("pt_total_count", var_12_0)
			self.cntTitle = string.gsub(self.cntTitle, "：", "")
		end,
		function()
			self.resTitle, self.cntTitle = i18n("pt_cosume", var_12_0), i18n("pt_total_count", i18n("pt_cosume", var_12_0))
			self.cntTitle = string.gsub(self.cntTitle, "：", "")
		end,
		function()
			self.resTitle, self.cntTitle = i18n("pt_ship_goal"), i18n("pt_ship_now")
		end,
		function()
			self.resTitle, self.cntTitle = i18n("cumulative_victory_target_tip"), i18n("cumulative_victory_now_tip")
		end,
		function()
			self.resTitle, self.cntTitle = i18n("npcfriendly_count"), i18n("npcfriendly_total_count")
		end,
		function()
			self.resTitle, self.cntTitle = i18n("activity_yanhua_tip2"), i18n("activity_yanhua_tip3")
		end,
		[9] = 2,
		[8] = 1
	}, function()
		self.resTitle, self.cntTitle = i18n("target_get_tip"), i18n("pt_total_count", var_12_0)
		self.cntTitle = string.gsub(self.cntTitle, "：", "")
	end)
end

local var_0_1 = {
	nil,
	true,
	false,
	false,
	false,
	false
}

function PtAwardWindow:updateResIcon(arg_20_1, arg_20_2)
	if defaultValue(var_0_1[arg_20_2], true) then
		self.resIcon = arg_20_1:getIcon()
	end

	setActive(self.ptIcon, self.resIcon)

	if self.resIcon then
		LoadImageSpriteAsync(self.resIcon, self.totalTitleIcon, false)
	end
end

function PtAwardWindow:Refresh()
	if self.ptActId then
		local var_21_0 = getProxy(ActivityProxy):getActivityById(self.ptActId)

		if not self.ptData then
			self.ptData = ActivityPtData.New(var_21_0)
		else
			self.ptData:Update(var_21_0)
		end

		setActive(self.getBtn:Find("off"), self.ptData:GetMaxAvailableTargetIndex() == self.ptData:GetLevel())
		setActive(self.getBtn:Find("on"), self.ptData:GetMaxAvailableTargetIndex() ~= self.ptData:GetLevel())
	end
end

function PtAwardWindow:Hide()
	if self.blur then
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	end

	setActive(self._tf, false)
end

function PtAwardWindow:Dispose()
	self:Hide()
	removeOnButton(self._tf)
	removeOnButton(self.closeBtn)
end

return PtAwardWindow
