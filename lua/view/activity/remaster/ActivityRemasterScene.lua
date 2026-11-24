local ActivityRemasterScene = class("ActivityRemasterScene", import("view.base.BaseUI"))

function ActivityRemasterScene:getUIName()
	return "ActivityRemasterUI"
end

function ActivityRemasterScene:init()
	self.scrollRect = self._tf:Find("list"):GetComponent("LScrollRect")

	function self.scrollRect.onInitItem(arg_3_0)
		self:OnInitItem(arg_3_0)
	end

	function self.scrollRect.onUpdateItem(arg_4_0, arg_4_1)
		self:OnUpdateItem(arg_4_0, arg_4_1)
	end

	setText(self._tf:Find("adapt/top/title/Text"), i18n("act_remaster_title"))
	changeToScrollText(self._tf:Find("prints/tip/Text"), i18n("act_remaster_tip_1"))
end

function ActivityRemasterScene:didEnter()
	onButton(self, self._tf:Find("adapt/top/closeBtn"), function()
		self:emit(BaseUI.ON_BACK)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("adapt/top/homeBtn"), function()
		self:emit(BaseUI.ON_HOME)
	end, SFX_PANEL)

	self.cards = {}
	self.activityRemasterDataList = getProxy(ActivityRemasterProxy):GetRemasterActList()

	self:InitList()
	self:UpdateActTime()
end

function ActivityRemasterScene:OnInitItem(arg_8_1)
	local var_8_0 = ActivityRemasterCard.New(arg_8_1)

	onButton(self, var_8_0._go, function()
		if var_8_0.remasterData:IsFinish() then
			return
		end

		local var_9_0 = var_8_0.remasterData:GetName()
		local var_9_1, var_9_2 = getProxy(ActivityRemasterProxy):InActTime()

		if not var_9_1 or not var_9_2 then
			return
		end

		local var_9_3 = pg.activity_re_timer[var_9_2]
		local var_9_6
		local var_9_7
		local var_9_4
		local var_9_5

		if not pg.activity_re_timer[var_9_2] or not var_9_3.timer or not var_9_3.timer[3] then
			do return end

			var_9_4 = var_9_3.timer[3][1][1]
			var_9_5 = var_9_3.timer[3][1][2]
			var_9_6 = var_9_3.timer[3][1][3]
			var_9_7 = {
				year = var_9_3.timer[3][1][1],
				month = var_9_3.timer[3][1][2],
				day = var_9_3.timer[3][1][3],
				hour = var_9_3.timer[3][2][1],
				min = var_9_3.timer[3][2][2]
			}
		end

		var_9_7.sec = var_9_3.timer[3][2][3]

		local var_9_8 = setColorStr(i18n("act_remaster_open_tip", var_9_0, var_9_4 .. "/" .. var_9_5 .. "/" .. var_9_6), (pg.TimeMgr.GetInstance():Table2ServerTime(var_9_7) - pg.TimeMgr.GetInstance():GetServerTime() < 172800 or nil) and (COLOR_RED or "#393a3c"))

		self.infoDisplayPage = self.infoDisplayPage or ActivityRemasterInfoDisplayPage.New(self._tf, self.event)

		self.infoDisplayPage:ExecuteAction("Show", var_8_0.remasterData.id, var_9_8, function()
			self:emit(ActivityRemasterMediator.ACTIVE_ACT, var_8_0.remasterData.id)
		end)
	end, SFX_PANEL)

	self.cards[arg_8_1] = var_8_0
end

function ActivityRemasterScene:OnUpdateItem(arg_11_1, arg_11_2)
	if not self.cards[arg_11_2] then
		self:OnInitItem(arg_11_2)
	end

	self.cards[arg_11_2]:Update(self.displays[arg_11_1 + 1])
end

function ActivityRemasterScene:UpdateActTime()
	local var_12_0, var_12_1 = getProxy(ActivityRemasterProxy):InActTime()

	setText(self._tf:Find("prints/time/Text"), (var_12_1 or nil) and i18n("act_remaster_tip_2", (pg.activity_re_timer[var_12_1].timer[2][1][2] .. "/" .. pg.activity_re_timer[var_12_1].timer[2][1][3]) .. "-" .. pg.activity_re_timer[var_12_1].timer[3][1][2] .. "/" .. pg.activity_re_timer[var_12_1].timer[3][1][3]))
end

function ActivityRemasterScene:InitList()
	self.displays = {}

	local var_13_0 = {}
	local var_13_1 = {}

	for iter_13_0, iter_13_1 in pairs(self.activityRemasterDataList) do
		if iter_13_1:IsSpecial() then
			table.insert(var_13_0, iter_13_1)
		else
			table.insert(var_13_1, iter_13_1)
		end
	end

	for iter_13_2, iter_13_3 in ipairs(var_13_1) do
		table.insert(self.displays, iter_13_3)
	end

	table.sort(self.displays, function(arg_14_0, arg_14_1)
		local var_14_0 = arg_14_0:IsFinish() and 1 or 0
		local var_14_1 = arg_14_1:IsFinish() and 1 or 0

		if var_14_0 == var_14_1 then
			return arg_14_0.id > arg_14_1.id
		else
			return var_14_0 < var_14_1
		end
	end)

	if _.all(var_13_1, function(arg_15_0)
		return arg_15_0:IsFinish()
	end) then
		for iter_13_4, iter_13_5 in ipairs(var_13_0) do
			table.insert(self.displays, 1, iter_13_5)
		end
	end

	self.scrollRect:SetTotalCount(#self.displays)
end

function ActivityRemasterScene:willExit()
	if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() then
		self.infoDisplayPage:Destroy()
	end

	self.infoDisplayPage = nil

	for iter_16_0, iter_16_1 in pairs(self.cards) do
		iter_16_1:Dispose()
	end

	self.cards = nil
end

function ActivityRemasterScene:onBackPressed()
	if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() and self.infoDisplayPage:isShowing() then
		self.infoDisplayPage:onBackPressed()

		return
	end

	self:emit(ActivityRemasterScene.ON_BACK_PRESSED)
end

return ActivityRemasterScene
