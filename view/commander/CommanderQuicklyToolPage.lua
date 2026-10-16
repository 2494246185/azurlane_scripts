local CommanderQuicklyToolPage = class("CommanderQuicklyToolPage", import("..base.BaseSubView"))

function CommanderQuicklyToolPage:getUIName()
	return "CommanderQuicklyToolPage"
end

function CommanderQuicklyToolPage:OnLoaded()
	self.closeBtn = self._tf:Find("frame/close_btn")
	self.cancelBtn = self._tf:Find("frame/cancel_btn")
	self.confirmBtn = self._tf:Find("frame/confirm_btn")
	self.addBtn = self._tf:Find("frame/content/count/add")
	self.reduceBtn = self._tf:Find("frame/content/count/reduce")
	self.valueTxt = self._tf:Find("frame/content/count/Text"):GetComponent(typeof(Text))
	self.time1Txt = self._tf:Find("frame/content/time/Text"):GetComponent(typeof(Text))
	self.maxTxt = self._tf:Find("frame/total/Text"):GetComponent(typeof(Text))

	setText(self._tf:Find("frame/content/label1"), i18n("commander_box_quickly_tool_tip_1"))
	setText(self._tf:Find("frame/content/label2"), i18n("commander_box_quickly_tool_tip_2"))
	setText(self._tf:Find("frame/content/time/label"), i18n("commander_box_quickly_tool_tip_3"))
end

function CommanderQuicklyToolPage:OnInit()
	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.addBtn, function()
		if self.maxCnt == 0 then
			return
		end

		self:UpdateValue(math.min(self.value + 1, self.maxCnt))
	end, SFX_PANEL)
	onButton(self, self.reduceBtn, function()
		if self.value <= 1 then
			return
		end

		self:UpdateValue(math.max(1, self.value - 1))
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		if self.value <= 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("cat_accelfrate_notenough"))

			return
		end

		if self.value > self.maxCnt then
			return
		end

		local var_9_0 = self:CalcMaxUsageCnt()

		if var_9_0 <= 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("commander_box_was_finished"))

			return
		end

		if var_9_0 < self.value then
			self:UpdateValue(var_9_0)
			pg.TipsMgr.GetInstance():ShowTips(i18n("comander_tool_cnt_is_reclac"))

			return
		end

		self:emit(CommanderCatMediator.USE_QUICKLY_TOOL, self.itemId, self.value, self.boxId)
		self:Hide()
	end, SFX_PANEL)
end

function CommanderQuicklyToolPage:Show(arg_10_1, arg_10_2)
	setParent(self._tf, pg.UIMgr.GetInstance().OverlayMain)
	CommanderQuicklyToolPage.super.Show(self)

	self.itemId = arg_10_2
	self.boxId = arg_10_1
	self.cost = Item.getConfigData(self.itemId).usage_arg[1]
	self.costM = self.cost / 60

	local var_10_0 = getProxy(BagProxy):getItemCountById(arg_10_2)

	self.maxCnt = math.min(self:CalcMaxUsageCnt(), var_10_0)
	self.maxTxt.text = var_10_0

	self:UpdateValue(self.maxCnt)
end

function CommanderQuicklyToolPage:Hide()
	CommanderQuicklyToolPage.super.Hide(self)
	setParent(self._tf, self._parentTf)
end

function CommanderQuicklyToolPage:UpdateValue(arg_12_1)
	self.value = arg_12_1
	self.valueTxt.text = arg_12_1

	self:AddTimer(getProxy(CommanderProxy):getBoxById(self.boxId):getFinishTime() - self.costM * arg_12_1 * 60)
end

function CommanderQuicklyToolPage:CalcMaxUsageCnt()
	local var_13_0 = getProxy(CommanderProxy)
	local var_13_1 = var_13_0:getBoxById(self.boxId):getFinishTime() - pg.TimeMgr.GetInstance().GetServerTime(var_13_0)

	if var_13_1 > 0 then
		return (math.ceil(var_13_1 / self.cost))
	else
		return 0
	end
end

function CommanderQuicklyToolPage:AddTimer(arg_14_1)
	self:RemoveTimer()

	self.timer = Timer.New(function()
		local var_15_0 = arg_14_1 - pg.TimeMgr.GetInstance():GetServerTime()

		if var_15_0 <= 0 then
			self:RemoveTimer()

			self.time1Txt.text = "00:00:00"
		else
			self.time1Txt.text = pg.TimeMgr.GetInstance():DescCDTime(var_15_0)
		end
	end, 1, -1)

	self.timer:Start()
	self.timer.func()
end

function CommanderQuicklyToolPage:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function CommanderQuicklyToolPage:Hide()
	CommanderQuicklyToolPage.super.Hide(self)
	self:RemoveTimer()
end

function CommanderQuicklyToolPage:OnDestroy()
	self:RemoveTimer()
end

return CommanderQuicklyToolPage
