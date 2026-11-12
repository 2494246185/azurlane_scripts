local GuildOfficeLayer = class("GuildOfficeLayer", import("..base.BaseUI"))

function GuildOfficeLayer:getUIName()
	return "GuildEmptyUI"
end

function GuildOfficeLayer:setPlayer(arg_2_1)
	self.playerVO = arg_2_1
end

function GuildOfficeLayer:SetGuild(arg_3_1)
	self.guild = arg_3_1
	self.isAdmin = GuildMember.IsAdministrator(arg_3_1:getSelfDuty())

	if self.taskPage and self.taskPage:GetLoaded() then
		self.taskPage:OnUpdateGuild(self.guild, self.isAdmin)
	end
end

function GuildOfficeLayer:init()
	self.taskPage = GuildOfficeTaskPage.New(self._tf, self.event)
	self.helpBtn = self._tf:Find("frame/help")
end

function GuildOfficeLayer:didEnter()
	pg.GuildPaintingMgr.GetInstance():Update(self.guild:GetOfficePainting(), Vector3(-737, -171, 0))
	self.taskPage:ExecuteAction("Update", self.guild, self.isAdmin)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.guild_office_tip.tip
		})
	end, SFX_PANEL)
end

function GuildOfficeLayer:UpdateContribution()
	if self.taskPage and self.taskPage:GetLoaded() then
		self.taskPage:OnUpdateContribution()
	end
end

function GuildOfficeLayer:UpdateSupplyPanel()
	if self.taskPage and self.taskPage:GetLoaded() then
		self.taskPage:OnUpdateSupplyPanel()
	end
end

function GuildOfficeLayer:UpdateTask(arg_9_1)
	if self.taskPage and self.taskPage:GetLoaded() then
		self.taskPage:OnUpdateTask(arg_9_1)
	end
end

function GuildOfficeLayer:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	self:emit(GuildOfficeLayer.ON_BACK)
end

function GuildOfficeLayer:willExit()
	self.taskPage:Destroy()

	if isActive(pg.MsgboxMgr.GetInstance()._go) then
		triggerButton(pg.MsgboxMgr.GetInstance()._closeBtn)
	end
end

return GuildOfficeLayer
