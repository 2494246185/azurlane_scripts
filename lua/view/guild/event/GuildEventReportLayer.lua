local GuildEventReportLayer = class("GuildEventReportLayer", import("...base.BaseUI"))

function GuildEventReportLayer:getUIName()
	return "GuildEventReportUI"
end

function GuildEventReportLayer:SetReports(arg_2_1)
	self.reports = arg_2_1
end

function GuildEventReportLayer:OnGetReportRankList(arg_3_1)
	self.rankPage:ExecuteAction("Show", arg_3_1)
end

function GuildEventReportLayer:init()
	self.scrollrect = self._tf:Find("frame/scrollrect"):GetComponent("LScrollRect")
	self.getAll = self._tf:Find("frame/get_all")
	self.gotAll = self._tf:Find("frame/get_all/gray")
	self.descTxt = self._tf:Find("frame/desc"):GetComponent(typeof(Text))
	self.cntTxt = self._tf:Find("frame/cnt"):GetComponent(typeof(Text))
	self.closeBtn = self._tf:Find("frame/close")

	setText(self.getAll:Find("Text"), i18n("guild_report_get_all"))

	self._parentTf = self._tf.parent

	setText(self._tf:Find("frame/desc"), i18n("guild_report_tooltip"))

	self.rankPage = GuildBossRankPage.New(self._tf, self.event)
end

function GuildEventReportLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	onButton(self, self.closeBtn, function()
		self:emit(GuildEventReportLayer.ON_CLOSE)
	end, SFX_PANEL)
	onButton(self, self._tf, function()
		self:emit(GuildEventReportLayer.ON_CLOSE)
	end, SFX_PANEL)
	onButton(self, self.getAll, function()
		local var_8_0 = {}

		for iter_8_0, iter_8_1 in pairs(self.reports) do
			if iter_8_1:CanSubmit() then
				table.insert(var_8_0, iter_8_1.id)
			end
		end

		if #var_8_0 == 0 then
			return
		end

		self:emit(GuildEventReportMediator.ON_SUBMIT_REPORTS, var_8_0)
	end, SFX_PANEL)

	function self.scrollrect.onInitItem(arg_9_0)
		self:OnInitItem(arg_9_0)
	end

	function self.scrollrect.onUpdateItem(arg_10_0, arg_10_1)
		self:OnUpdateItem(arg_10_0, arg_10_1)
	end

	self:SetTotalCount()
	self:UpdateGetAllBtn()
end

function GuildEventReportLayer:preload(arg_11_1)
	pg.m02:sendNotification(GAME.GET_GUILD_REPORT, {
		callback = function(arg_12_0)
			self:SetReports(arg_12_0)
			arg_11_1()
		end
	})
end

function GuildEventReportLayer:getResource()
	local var_13_0 = GuildEventReportLayer.super.getResource(self)

	for iter_13_0, iter_13_1 in ipairs({
		"ui/GuildEventReportUI_atlas",
		"ui/GuildBossRankPage"
	}) do
		if noEmptyStr(iter_13_1) and not table.contains(var_13_0, iter_13_1) then
			table.insert(var_13_0, iter_13_1)
		end
	end

	return var_13_0
end

function GuildEventReportLayer:UpdateReports(arg_14_1)
	for iter_14_0, iter_14_1 in ipairs(arg_14_1) do
		for iter_14_2, iter_14_3 in pairs(self.cards) do
			if iter_14_3.report.id == iter_14_1 then
				iter_14_3:Update(self.reports[iter_14_1])
			end
		end
	end

	self:UpdateGetAllBtn()
end

function GuildEventReportLayer:UpdateGetAllBtn()
	setActive(self.gotAll, #self.displays == 0 or _.all(self.displays, function(arg_16_0)
		return not arg_16_0:CanSubmit()
	end))
end

function GuildEventReportLayer:SetTotalCount()
	self.displays = {}

	for iter_17_0, iter_17_1 in pairs(self.reports) do
		table.insert(self.displays, iter_17_1)
	end

	local function var_17_0(arg_18_0)
		if arg_18_0.state == 0 then
			return 1
		elseif arg_18_0.state == 1 then
			return 2
		elseif arg_18_0.state == 2 then
			return 0
		end
	end

	table.sort(self.displays, function(arg_19_0, arg_19_1)
		return var_17_0(arg_19_0) > var_17_0(arg_19_1)
	end)
	self.scrollrect:SetTotalCount(#self.displays)

	self.cntTxt.text = #self.displays .. "/" .. GuildConst.MAX_REPORT_CNT()
end

function GuildEventReportLayer:OnInitItem(arg_20_1)
	local var_20_0 = GuildReportCard.New(arg_20_1, self)

	self.cards = self.cards or {}

	onButton(self, var_20_0.getBtn, function()
		if var_20_0.report:IsLock() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("guild_can_not_get_tip"))

			return
		end

		self:emit(GuildEventReportMediator.ON_SUBMIT_REPORTS, {
			var_20_0.report.id
		})
	end, SFX_PANEL)

	self.cards[arg_20_1] = var_20_0
end

function GuildEventReportLayer:OnUpdateItem(arg_22_1, arg_22_2)
	if not self.cards[arg_22_2] then
		self:OnInitItem(arg_22_2)
	end

	self.cards[arg_22_2]:Update(self.displays[arg_22_1 + 1])
end

function GuildEventReportLayer:ShowReportRank(arg_23_1)
	self:emit(GuildEventReportMediator.GET_REPORT_RANK, arg_23_1)
end

function GuildEventReportLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)

	if self.cards then
		for iter_24_0, iter_24_1 in pairs(self.cards) do
			iter_24_1:Dispose()
		end

		self.cards = nil
	end

	if self.rankPage then
		self.rankPage:Destroy()

		self.rankPage = nil
	end
end

return GuildEventReportLayer
