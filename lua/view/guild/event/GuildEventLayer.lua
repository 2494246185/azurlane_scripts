local GuildEventLayer = class("GuildEventLayer", import("...base.BaseUI"))

GuildEventLayer.OPEN_EVENT_INFO = "GuildEventLayer:OPEN_EVENT_INFO"
GuildEventLayer.ON_OPEN_FORMATION = "GuildEventLayer:ON_OPEN_FORMATION"
GuildEventLayer.ON_OPEN_MISSION = "GuildEventLayer:ON_OPEN_MISSION"
GuildEventLayer.OPEN_MISSION_FORAMTION = "GuildEventLayer:OPEN_MISSION_FORAMTION"
GuildEventLayer.ON_OPEN_BOSS = "GuildEventLayer:ON_OPEN_BOSS"
GuildEventLayer.ON_OPEN_BOSS_FORMATION = "GuildEventLayer:ON_OPEN_BOSS_FORMATION"
GuildEventLayer.OPEN_BOSS_ASSULT = "GuildEventLayer:OPEN_BOSS_ASSULT"
GuildEventLayer.SHOW_SHIP_EQUIPMENTS = "GuildEventLayer:SHOW_SHIP_EQUIPMENTS"

function GuildEventLayer:getUIName()
	return "GuildEmptyUI"
end

function GuildEventLayer:SetPlayer(arg_2_1)
	self.player = arg_2_1
end

function GuildEventLayer:SetGuild(arg_3_1)
	self.guildVO = arg_3_1
	self.events = {}
	self.activeEvent = nil

	self:SetEvents(arg_3_1:GetEvents())

	self.myAssaultFleet = arg_3_1:getMemberById(self.player.id):GetExternalAssaultFleet()
end

function GuildEventLayer:SetEvents(arg_4_1)
	self.events = arg_4_1
	self.activeEvent = _.detect(self.events, function(arg_5_0)
		return arg_5_0:IsActive()
	end)
end

function GuildEventLayer:UpdateFleet()
	if self.formationPage:GetLoaded() then
		self.formationPage:ExecuteAction("OnFleetUpdated", self.myAssaultFleet)
	end
end

function GuildEventLayer:preload(arg_7_1)
	seriesAsync({
		function(arg_8_0)
			pg.m02:sendNotification(GAME.GET_GUILD_REPORT, {
				callback = arg_8_0
			})
		end,
		function(arg_9_0)
			local var_9_0 = getProxy(GuildProxy):getRawData():GetActiveEvent()

			if not var_9_0 then
				pg.m02:sendNotification(GAME.GUILD_GET_ACTIVATION_EVENT, {
					force = false,
					callback = arg_9_0
				})
			elseif var_9_0 and var_9_0:IsExpired() then
				pg.m02:sendNotification(GAME.GUILD_GET_ACTIVATION_EVENT, {
					force = true,
					callback = arg_9_0
				})
			else
				arg_9_0()
			end
		end
	}, arg_7_1)
end

function GuildEventLayer:getResource()
	local var_10_0 = GuildEventLayer.super.getResource(self)
	local var_10_1 = {
		"ui/GuildEventPage",
		"ui/GuildMissionBossPage",
		"ui/GuildEventUI_atlas",
		"ui/GuildMissionUI_atlas",
		"ui/guildmissionui_atlas",
		"commonbg/guild_event_bg",
		"guildevent/0",
		"guildevent/0_0"
	}

	local function var_10_2(arg_11_0)
		if noEmptyStr(arg_11_0) and not table.contains(var_10_1, arg_11_0) then
			table.insert(var_10_1, arg_11_0)
		end
	end

	local var_10_3 = getProxy(GuildProxy):getRawData()

	for iter_10_0, iter_10_1 in ipairs(var_10_3 and var_10_3:GetEvents() or {}) do
		var_10_2("guildevent/" .. iter_10_1.id)

		if iter_10_1:IsActive() then
			var_10_2("GuildMission/" .. iter_10_1:GetTheme())

			for iter_10_2, iter_10_3 in pairs(iter_10_1:GetMissions() or {}) do
				for iter_10_4, iter_10_5 in ipairs(iter_10_3) do
					var_10_2("GuildMission/" .. iter_10_5:GetIcon())
				end
			end

			local var_10_4 = iter_10_1:GetBossMission()

			if var_10_4 then
				var_10_2("GuildMission/boss_" .. var_10_4:GetIcon())

				if var_10_4:IsActive() then
					local var_10_5 = var_10_4:GetPainting()

					if noEmptyStr(var_10_5) then
						var_10_2("guildpainting/" .. var_10_5)
					else
						local var_10_6 = var_10_4:GetEmenyId()

						var_10_2("guildboss/" .. var_10_6)
						var_10_2("guildboss/name_" .. var_10_6)
					end
				end
			end
		end
	end

	for iter_10_6, iter_10_7 in ipairs(var_10_1) do
		if not table.contains(var_10_0, iter_10_7) then
			table.insert(var_10_0, iter_10_7)
		end
	end

	return var_10_0
end

function GuildEventLayer:getResource()
	return (GuildEventLayer.super.getResource(self))
end

function GuildEventLayer:UpdateGuild(arg_13_1)
	self:SetGuild(arg_13_1)

	if self.formationPage and self.formationPage:GetLoaded() then
		self.formationPage:UpdateData(self.guildVO, self.player, {
			fleet = self.myAssaultFleet
		})
	end

	if self.eventPage and self.eventPage:GetLoaded() then
		self.eventPage:UpdateData(self.guildVO, self.player, self.events)
	end

	if self.eventInfoPage and self.eventInfoPage:GetLoaded() and self.eventInfoPage:isShowing() then
		self.eventInfoPage:Refresh(arg_13_1, self.player)
	end

	if self.showAssultShipPage and self.showAssultShipPage:GetLoaded() and self.showAssultShipPage:isShowing() then
		self:OnMemberAssultFleetUpdate()
	end
end

function GuildEventLayer:RefreshMission(arg_14_1)
	local var_14_0 = self.activeEvent:GetMissionById(arg_14_1)

	if self.eventPage and self.eventPage:GetLoaded() then
		self.eventPage:OnRefreshNode(self.activeEvent, var_14_0)
	end

	if self.missionInfoPage and self.missionInfoPage:GetLoaded() then
		self.missionInfoPage:OnRefreshMission(var_14_0)
	end

	if self.missionFormationPage and self.missionFormationPage:GetLoaded() then
		self.missionFormationPage:OnRefreshMission(var_14_0)
	end
end

function GuildEventLayer:RefreshBossMission(arg_15_1)
	local var_15_0 = self.activeEvent:GetBossMission()

	if self.eventPage and self.eventPage:GetLoaded() then
		self.eventPage:OnRefreshNode(self.activeEvent, var_15_0)
	end

	if self.missionBossPage and self.missionBossPage:GetLoaded() then
		self.missionBossPage:UpdateMission(var_15_0)
		self.missionBossPage:UpdateView()
	end
end

function GuildEventLayer:OnBossRankUpdate()
	if self.missionBossPage and self.missionBossPage:GetLoaded() then
		self.missionBossPage:UpdateMission((self.activeEvent:GetBossMission()))
		self.missionBossPage:UpdateRank()
	end
end

function GuildEventLayer:OnBossMissionFormationChanged()
	local var_17_0 = self.activeEvent:GetBossMission()

	if self.missionBossPage and self.missionBossPage:GetLoaded() then
		self.missionBossPage:UpdateMission(var_17_0)
	end

	if self.missBossForamtionPage and self.missBossForamtionPage:GetLoaded() then
		self.missBossForamtionPage:UpdateMission(var_17_0, false)
	end
end

function GuildEventLayer:OnMemberAssultFleetUpdate()
	if self.showAssultShipPage and self.showAssultShipPage:GetLoaded() then
		self.showAssultShipPage:UpdateData(self.guildVO, self.player)
	end
end

function GuildEventLayer:OnMyAssultFleetUpdate()
	if self.formationPage and self.formationPage:GetLoaded() then
		self.formationPage:OnFleetUpdated(self.myAssaultFleet)
	end
end

function GuildEventLayer:OnMyAssultFleetFormationDone()
	if self.formationPage and self.formationPage:GetLoaded() then
		self.formationPage:OnFleetFormationDone()
	end
end

function GuildEventLayer:OnReportUpdated()
	if self.eventPage and self.eventPage:GetLoaded() then
		self.eventPage:OnReportUpdated()
	end

	if self.missionBossPage and self.missionBossPage:GetLoaded() then
		self.missionBossPage:OnReportUpdated()
	end
end

function GuildEventLayer:OnMissionFormationDone()
	if self.missionFormationPage and self.missionFormationPage:GetLoaded() and self.missionFormationPage:isShowing() then
		self.missionFormationPage:OnFormationDone()
	end
end

function GuildEventLayer:OnMemberDeleted()
	if self.missionBossPage and self.missionBossPage:GetLoaded() then
		self.missionBossPage:CheckFleetShipState()
	end
end

function GuildEventLayer:OnAssultShipBeRecommanded(arg_24_1)
	if self.showAssultShipPage and self.showAssultShipPage:GetLoaded() then
		self.showAssultShipPage:OnAssultShipBeRecommanded(arg_24_1)
	end
end

function GuildEventLayer:OnRefreshAllAssultShipRecommandState()
	if self.showAssultShipPage and self.showAssultShipPage:GetLoaded() then
		self.showAssultShipPage:OnRefreshAll()
	end
end

function GuildEventLayer:OnBossCommanderFormationChange()
	if self.missBossForamtionPage and self.missBossForamtionPage:GetLoaded() then
		self.missBossForamtionPage:OnBossCommanderFormationChange()
	end
end

function GuildEventLayer:OnBossCommanderPrefabFormationChange()
	if self.missBossForamtionPage and self.missBossForamtionPage:GetLoaded() then
		self.missBossForamtionPage:OnBossCommanderPrefabFormationChange()
	end
end

function GuildEventLayer:init()
	self:bind(GuildEventLayer.OPEN_EVENT_INFO, function(arg_29_0, arg_29_1)
		self.eventInfoPage:ExecuteAction("Show", self.guildVO, self.player, {
			gevent = arg_29_1
		})
	end)
	self:bind(GuildEventLayer.ON_OPEN_FORMATION, function(arg_30_0)
		self.formationPage:ExecuteAction("Show", self.guildVO, self.player, {
			fleet = self.myAssaultFleet
		})
	end)
	self:bind(GuildEventLayer.ON_OPEN_MISSION, function(arg_31_0, arg_31_1)
		self.missionInfoPage:ExecuteAction("Show", self.guildVO, self.player, {
			mission = arg_31_1
		})
	end)
	self:bind(GuildEventLayer.OPEN_MISSION_FORAMTION, function(arg_32_0, arg_32_1)
		self.missionFormationPage:ExecuteAction("Show", self.guildVO, self.player, {
			mission = arg_32_1,
			shipCnt = GuildConst.MISSION_MAX_SHIP_CNT
		})
	end)
	self:bind(GuildEventLayer.ON_OPEN_BOSS, function(arg_33_0, arg_33_1)
		self.missionBossPage:ExecuteAction("Show", arg_33_1)
	end)
	self:bind(GuildEventLayer.ON_OPEN_BOSS_FORMATION, function(arg_34_0, arg_34_1)
		self.missBossForamtionPage:ExecuteAction("Show", self.guildVO, self.player, {
			mission = arg_34_1
		})
	end)
	self:bind(GuildEventLayer.OPEN_BOSS_ASSULT, function()
		self.showAssultShipPage:ExecuteAction("Show", self.guildVO, self.player)
	end)
	self:bind(GuildEventLayer.SHOW_SHIP_EQUIPMENTS, function(arg_36_0, arg_36_1, arg_36_2, arg_36_3)
		self.shipEquipmentsPage:ExecuteAction("Show", arg_36_1, arg_36_2, arg_36_3)
	end)

	self.eventPage = GuildEventPage.New(self._tf, self.event, self.contextData)
	self.eventInfoPage = GuildEventInfoPage.New(self._tf, self.event, self.contextData)
	self.formationPage = GuildEventFormationPage.New(self._tf, self.event, self.contextData)
	self.missionInfoPage = GuildMissionInfoPage.New(self._tf, self.event, self.contextData)
	self.missionFormationPage = GuildMissionFormationPage.New(self._tf, self.event, self.contextData)
	self.missionBossPage = GuildMissionBossPage.New(self._tf, self.event, self.contextData)
	self.missBossForamtionPage = GuildMissionBossFormationPage.New(self._tf, self.event, self.contextData)
	self.showAssultShipPage = GuildShowAssultShipPage.New(self._tf, self.event, self.contextData)
	self.shipEquipmentsPage = GuildShipEquipmentsPage.New(self._tf, self.event, self.contextData)
	self.helpBtn = self._tf:Find("frame/help")
end

function GuildEventLayer:didEnter()
	getProxy(GuildProxy):SetBattleBtnRecord()
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.guild_event_help_tip.tip
		})
	end, SFX_PANEL)
	self:EnterEvent()
	self:TryPlayGuide()
end

function GuildEventLayer:TryPlayGuide()
	pg.SystemGuideMgr.GetInstance():PlayGuildAssaultFleet()
end

function GuildEventLayer:EnterEvent()
	if not self:isLoaded() then
		return
	end

	local var_40_0 = self.activeEvent and self.activeEvent:GetBossMission()

	if self.activeEvent and var_40_0 and var_40_0:IsActive() and not var_40_0:IsDeath() and self.activeEvent:IsParticipant() then
		self.missionBossPage:ExecuteAction("Show", var_40_0)
	else
		self.eventPage:ExecuteAction("Show", self.guildVO, self.player, self.events)
	end

	if self.missionBossPage and self.missionBossPage:GetLoaded() and not self.activeEvent then
		self.missionBossPage:Destroy()

		self.missionBossPage = nil
	end

	if self.activeEvent and self.eventInfoPage and self.eventInfoPage:GetLoaded() and self.activeEvent:IsParticipant() then
		self.eventInfoPage:Destroy()

		self.eventInfoPage = nil
	end
end

function GuildEventLayer:OnEventEnd()
	self:EnterEvent()
end

function GuildEventLayer:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	self:emit(GuildEventLayer.ON_BACK)
end

function GuildEventLayer:willExit()
	if self.eventInfoPage then
		self.eventInfoPage:Destroy()
	end

	self.missBossForamtionPage:Destroy()
	self.formationPage:Destroy()
	self.missionFormationPage:Destroy()
	self.missionInfoPage:Destroy()
	self.showAssultShipPage:Destroy()
	self.eventPage:Destroy()
	self.shipEquipmentsPage:Destroy()

	if self.missionBossPage then
		self.missionBossPage:Destroy()
	end

	if isActive(pg.MsgboxMgr.GetInstance()._go) then
		triggerButton(pg.MsgboxMgr.GetInstance()._closeBtn)
	end
end

return GuildEventLayer
